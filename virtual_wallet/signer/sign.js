// Off-chain ECDSA signer for virtual_wallet.aleo.
//
// Usage:
//   node sign.js <selector> <recipient_aleo_address> <amount> <nonce> <expiry>
//
//   selector: "public" or "public_to_private"
//
// The custodian's ETH private key is read from the SIGNER_PRIVATE_KEY env var
// (0x-prefixed hex).  The script prints a block of `leo execute` flags with
// the signature and owner_eth ready to paste.

import { keccak_256 } from "@noble/hashes/sha3";
import { secp256k1 } from "@noble/curves/secp256k1";
import { Address } from "@provablehq/sdk/testnet.js";

const SELECTOR_PUBLIC = 1;
const SELECTOR_PUBLIC_TO_PRIVATE = 2;

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
function ethAddressFromPrivateKey(privateKey) {
    const pub = secp256k1.getPublicKey(privateKey, false); // 65 bytes (0x04 ‖ x ‖ y)
    const hash = keccak_256(pub.slice(1));                 // keccak of x ‖ y
    return hash.slice(12);                                 // last 20 bytes
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
// virtual_wallet.aleo computes on-chain via:
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

function buildAuthBytes({
    selector,
    ownerEth,
    toBytes,
    amount,
    nonce,
    expiry,
}) {
    const out = new Uint8Array(1 + 20 + 32 + 8 + 8 + 4); // 73
    let o = 0;
    out[o] = selector; o += 1;
    out.set(ownerEth, o); o += 20;
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

function main() {
    const argv = process.argv.slice(2);
    const argsOnly = argv[0] === "--args-only" && argv.shift();
    const [selectorArg, recipient, amountArg, nonceArg, expiryArg] = argv;
    if (!selectorArg || !recipient || !amountArg || !nonceArg || !expiryArg) {
        console.error(
            "usage: node sign.js [--args-only] <public|public_to_private> <recipient_aleo_addr> <amount> <nonce> <expiry_block_height>",
        );
        process.exit(1);
    }

    const privateKeyHex = process.env.SIGNER_PRIVATE_KEY;
    if (!privateKeyHex) {
        console.error("SIGNER_PRIVATE_KEY env var is required (0x-prefixed secp256k1 key).");
        process.exit(1);
    }
    const privateKey = hexToBytes(privateKeyHex);

    const selector =
        selectorArg === "public" ? SELECTOR_PUBLIC :
        selectorArg === "public_to_private" ? SELECTOR_PUBLIC_TO_PRIVATE :
        null;
    if (selector === null) {
        console.error(`unknown selector "${selectorArg}" (expected "public" or "public_to_private")`);
        process.exit(1);
    }

    const ownerEth = ethAddressFromPrivateKey(privateKey);
    const toBytes = aleoAddressToBytesLE(recipient);
    const amount = BigInt(amountArg);
    const nonce = BigInt(nonceArg);
    const expiry = Number(expiryArg);

    const auth = buildAuthBytes({ selector, ownerEth, toBytes, amount, nonce, expiry });
    const digest = keccak_256(auth);

    // ECDSA::verify_keccak256_eth expects an r ‖ s ‖ v signature where v ∈ {27, 28}.
    const sig = secp256k1.sign(digest, privateKey, { lowS: true });
    const sigBytes = new Uint8Array(65);
    sigBytes.set(sig.toCompactRawBytes(), 0);          // r ‖ s
    sigBytes[64] = 27 + sig.recovery;                   // v

    const fn =
        selector === SELECTOR_PUBLIC
            ? "transfer_public"
            : "transfer_public_to_private";

    // --args-only: one positional arg per line, no shell quoting.  Designed
    // to be read into a bash array via `mapfile -t ARGS < <(node sign.js --args-only ...)`
    // so the values can be passed to `leo execute` without `eval`.
    if (argsOnly) {
        const parts = [
            toLeoByteArray(ownerEth),
            toLeoByteArray(sigBytes),
            recipient,
            `${amount}u64`,
            `${nonce}u64`,
            `${expiry}u32`,
        ];
        console.log(parts.join("\n"));
        return;
    }

    console.log(`# leo execute invocation for virtual_wallet.aleo/${fn}`);
    console.log(`# owner_eth = 0x${bytesToHex(ownerEth)}`);
    console.log(`# digest     = 0x${bytesToHex(digest)}`);
    console.log();
    console.log(`leo execute virtual_wallet.aleo/${fn} \\`);
    console.log(`  '${toLeoByteArray(ownerEth)}' \\`);
    console.log(`  '${toLeoByteArray(sigBytes)}' \\`);
    console.log(`  '${recipient}' \\`);
    console.log(`  '${amount}u64' \\`);
    console.log(`  '${nonce}u64' \\`);
    console.log(`  '${expiry}u32'`);
}

main();
