// Off-chain ECDSA signer for the virtual_wallet example.
//
// The example ships two sibling programs:
//   - virtual_wallet_eth.aleo     — verifies against a 20-byte eth address
//   - virtual_wallet_pubkey.aleo  — verifies against a 33-byte compressed
//                                   secp256k1 public key (SEC1)
//
// Both verify the same r‖s‖v signature over Keccak256(TransferAuth_bytes);
// only the on-chain identity-encoding differs.  This script handles both,
// selected by the `<mode>` argument.
//
// Usage:
//   node sign.js [--args-only] <mode> <selector> <recipient_aleo_addr> <amount> <nonce> <expiry>
//
//     mode:     "eth"    | "pubkey"
//     selector: "public" | "public_to_private"
//
//   The numeric selector baked into the signed payload is determined by
//   the (mode, selector) pair so that signatures cannot be cross-replayed
//   between the two programs:
//
//     eth    + public            = 1
//     eth    + public_to_private = 2
//     pubkey + public            = 3
//     pubkey + public_to_private = 4
//
// The custodian's ETH private key is read from the SIGNER_PRIVATE_KEY env
// var (0x-prefixed hex).  The derived eth address must match `OWNER_ETH_ADDR`
// in the eth program; the derived compressed pubkey must match
// `OWNER_PUBKEY` in the pubkey program.  If either doesn't match, every
// transition for that program will revert.

import { keccak_256 } from "@noble/hashes/sha3";
import { secp256k1 } from "@noble/curves/secp256k1";
import { Address } from "@provablehq/sdk/testnet.js";

// (mode, selector) → numeric selector baked into the signed payload.
const SELECTORS = {
    eth:    { public: 1, public_to_private: 2 },
    pubkey: { public: 3, public_to_private: 4 },
};

function hexToBytes(hex) {
    const s = hex.startsWith("0x") ? hex.slice(2) : hex;
    if (s.length % 2 !== 0) throw new Error("odd-length hex");
    const out = new Uint8Array(s.length / 2);
    for (let i = 0; i < out.length; i++) {
        out[i] = parseInt(s.slice(2 * i, 2 * i + 2), 16);
    }
    return out;
}

function bytesToHex(bytes) {
    return Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
}

// Derive the 20-byte Ethereum address from a secp256k1 private key.
// Used in `eth` mode for the informational log line; the eth address is
// NOT part of the signed payload (the on-chain verifier checks it against
// the program's `OWNER_ETH_ADDR` constant).
function ethAddressFromPrivateKey(privateKey) {
    const pub = secp256k1.getPublicKey(privateKey, false); // 65 bytes (0x04 ‖ x ‖ y)
    const hash = keccak_256(pub.slice(1));                 // keccak of x ‖ y
    return hash.slice(12);                                 // last 20 bytes
}

// SEC1 compressed public key (33 bytes: 0x02|0x03 ‖ x_coord).
function compressedPubkeyFromPrivateKey(privateKey) {
    return secp256k1.getPublicKey(privateKey, true);
}

// Encode u32/u64 as little-endian bytes.
function u64LE(value) {
    const out = new Uint8Array(8);
    let v = BigInt(value);
    for (let i = 0; i < 8; i++) {
        out[i] = Number(v & 0xffn);
        v >>= 8n;
    }
    return out;
}

function u32LE(value) {
    const out = new Uint8Array(4);
    let v = Number(value);
    for (let i = 0; i < 4; i++) {
        out[i] = v & 0xff;
        v >>>= 8;
    }
    return out;
}

// Encode an Aleo address as its 32-byte little-endian representation.
// The Aleo SDK's `toBytesLe()` is expected to produce the same bytes that
// the on-chain `address_to_bytes` helper computes via:
//     let x: field = to as field;
//     let bits: [bool; 253] = Serialize::to_bits_raw(x);
//     // pad to 256 with three trailing zero bits
//     let to_bytes: [u8; 32] = Deserialize::from_bits_raw::[[u8; 32]](padded);
// If the SDK encoding ever diverges, reimplement the on-chain steps here.
function aleoAddressToBytesLE(aleoAddr) {
    const addr = Address.from_string(aleoAddr);
    const bytes = addr.toBytesLe();
    if (bytes.length !== 32) {
        throw new Error(`expected 32 bytes from toBytesLe, got ${bytes.length}`);
    }
    return bytes;
}

// 53-byte canonical layout of the `TransferAuth` struct shared by both
// programs.  Neither `owner_eth_addr` nor `owner_pubkey` is part of the
// signed payload — they're hardcoded constants in the respective programs.
function buildAuthBytes({ selector, toBytes, amount, nonce, expiry }) {
    const out = new Uint8Array(1 + 32 + 8 + 8 + 4); // 53
    let o = 0;
    out[o] = selector; o += 1;
    out.set(toBytes, o); o += 32;
    out.set(u64LE(amount), o); o += 8;
    out.set(u64LE(nonce), o); o += 8;
    out.set(u32LE(expiry), o); o += 4;
    return out;
}

// Emit the byte array in Leo `[u8; N]` literal syntax for `leo execute`.
function toLeoByteArray(bytes) {
    return `[${Array.from(bytes, (b) => `${b}u8`).join(", ")}]`;
}

function programIdFor(mode) {
    return mode === "eth" ? "virtual_wallet_eth.aleo" : "virtual_wallet_pubkey.aleo";
}

function main() {
    const argv = process.argv.slice(2);
    const argsOnly = argv[0] === "--args-only" && argv.shift();
    const [modeArg, selectorArg, recipient, amountArg, nonceArg, expiryArg] = argv;
    if (!modeArg || !selectorArg || !recipient || !amountArg || !nonceArg || !expiryArg) {
        console.error(
            "usage: node sign.js [--args-only] <eth|pubkey> <public|public_to_private> <recipient_aleo_addr> <amount> <nonce> <expiry_block_height>",
        );
        process.exit(1);
    }

    if (modeArg !== "eth" && modeArg !== "pubkey") {
        console.error(`unknown mode "${modeArg}" (expected "eth" or "pubkey")`);
        process.exit(1);
    }
    const selector = SELECTORS[modeArg][selectorArg];
    if (selector === undefined) {
        console.error(`unknown selector "${selectorArg}" (expected "public" or "public_to_private")`);
        process.exit(1);
    }

    const privateKeyHex = process.env.SIGNER_PRIVATE_KEY;
    if (!privateKeyHex) {
        console.error("SIGNER_PRIVATE_KEY env var is required (0x-prefixed secp256k1 key).");
        process.exit(1);
    }
    const privateKey = hexToBytes(privateKeyHex);

    const ownerEth = ethAddressFromPrivateKey(privateKey);
    const ownerPubkey = compressedPubkeyFromPrivateKey(privateKey);
    const toBytes = aleoAddressToBytesLE(recipient);
    const amount = BigInt(amountArg);
    const nonce = BigInt(nonceArg);
    const expiry = Number(expiryArg);

    const auth = buildAuthBytes({ selector, toBytes, amount, nonce, expiry });
    const digest = keccak_256(auth);

    // ECDSA::verify_keccak256_{eth,raw} expects an r ‖ s ‖ v signature
    // where v ∈ {27, 28}.
    const sig = secp256k1.sign(digest, privateKey, { lowS: true });
    const sigBytes = new Uint8Array(65);
    sigBytes.set(sig.toCompactRawBytes(), 0);          // r ‖ s
    sigBytes[64] = 27 + sig.recovery;                   // v

    const programId = programIdFor(modeArg);
    const fn =
        selectorArg === "public" ? "transfer_public" : "transfer_public_to_private";

    // --args-only: one positional arg per line, no shell quoting.  Read
    // into a bash array via `while IFS= read -r line; do ...; done <
    // <(node sign.js --args-only ...)` and pass to `leo execute` without
    // `eval`.
    if (argsOnly) {
        const parts = [
            toLeoByteArray(sigBytes),
            recipient,
            `${amount}u64`,
            `${nonce}u64`,
            `${expiry}u32`,
        ];
        console.log(parts.join("\n"));
        return;
    }

    console.log(`# leo execute invocation for ${programId}/${fn}`);
    if (modeArg === "eth") {
        console.log(`# signer eth_addr = 0x${bytesToHex(ownerEth)} (must match OWNER_ETH_ADDR in eth/src/main.leo)`);
    } else {
        console.log(`# signer pubkey   = 0x${bytesToHex(ownerPubkey)} (must match OWNER_PUBKEY in pubkey/src/main.leo)`);
    }
    console.log(`# digest          = 0x${bytesToHex(digest)}`);
    console.log();
    console.log(`leo execute ${programId}/${fn} \\`);
    console.log(`  '${toLeoByteArray(sigBytes)}' \\`);
    console.log(`  '${recipient}' \\`);
    console.log(`  '${amount}u64' \\`);
    console.log(`  '${nonce}u64' \\`);
    console.log(`  '${expiry}u32'`);
}

main();
