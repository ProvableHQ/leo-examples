#!/bin/bash
# Demonstrates the virtual_wallet example end-to-end for both ECDSA
# variants:
#
#   PART A — virtual_wallet_eth.aleo     (verifies a 20-byte eth address)
#   PART B — virtual_wallet_pubkey.aleo  (verifies a 33-byte compressed pubkey)
#
# Run from the virtual_wallet/ directory.
#
# Prerequisites:
#   leo devnode must be running in a separate terminal:
#     leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
#   The signer must have its deps installed:
#     (cd signer && npm install)

set -euo pipefail

LEO=${LEO:-leo}

# The Aleo account that funds the wallets and relays user-signed payloads.
RELAYER_PRIVATE_KEY="APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH"

# The ECDSA (Ethereum) private key of the custodian who authorizes
# transfers.  Well-known test key; the same secp256k1 keypair backs both
# `OWNER_ETH_ADDR` (in eth/src/main.leo) and `OWNER_PUBKEY` (in
# pubkey/src/main.leo).
export SIGNER_PRIVATE_KEY="0x4646464646464646464646464646464646464646464646464646464646464646"

# Program addresses.  Derived deterministically from each program name via
# the Aleo SDK; recompute with the snippet at the bottom of this script if
# the program names change.
WALLET_ETH_ADDR="aleo19azy9ghvqt7dsy00crc3633dd6r92r93zf03czz9fplae5yg2syqxz9qs3"
WALLET_PUBKEY_ADDR="aleo14xle67xcugak8zqzz5u8t5hmr6uxasn5957rduazrpl2kaum6c8snglumx"

# Recipient of the demo transfers.
RECIPIENT="aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px"

ENDPOINT="http://localhost:${LEO_DEVNODE_PORT:-3030}"
COMMON_OPTS=(-y --disable-update-check --broadcast
             --network testnet
             --endpoint "$ENDPOINT"
             --private-key "$RELAYER_PRIVATE_KEY"
             --consensus-heights "0,1,2,3,4,5,6,7,8,9,10,11,12,13")

# Populate SIGN_ARGS with the five positional args produced by sign.js.
# `while read` is used instead of `mapfile` so the script runs under
# macOS's bash 3.2.
sign_args() {
    SIGN_ARGS=()
    while IFS= read -r line; do
        SIGN_ARGS+=("$line")
    done < <(node signer/sign.js --args-only "$@")
}

banner() {
    echo ""
    echo "═══════════════════════════════════════════════"
    echo " $*"
    echo "═══════════════════════════════════════════════"
}

# Run a transition expected to be rejected on-chain (e.g. nonce replay) and
# assert that the chain rejects it.  `leo execute` returns exit 0 even when
# a tx is rejected during finalize, so we match the CLI's confirmation line.
expect_rejected() {
    local label="$1"; shift
    local out
    out=$("$LEO" "$@" 2>&1) || true
    echo "$out" | tail -10
    echo ""
    if echo "$out" | grep -q "Transaction rejected"; then
        echo "$label: rejected as expected."
    elif echo "$out" | grep -q "Transaction accepted"; then
        echo "FAIL: $label was accepted — protection did not trigger."
        exit 1
    else
        echo "FAIL: could not determine $label outcome from CLI output."
        exit 1
    fi
}

# demo_variant <mode> <wallet_program_addr> <selector_label_for_demo>
#   mode:                "eth" | "pubkey"
#   wallet_program_addr: aleo1… of the program whose balance we drain
demo_variant() {
    local mode="$1"
    local wallet_addr="$2"
    local program="virtual_wallet_${mode}.aleo"
    local path="$mode"

    banner "[$mode] PART 1: Deploy ${program}"
    $LEO deploy --path "$path" "${COMMON_OPTS[@]}"

    banner "[$mode] PART 2: Pre-fund the wallet (1 000 000 microcredits)"
    echo "destination = ${wallet_addr}"
    $LEO execute credits.aleo/transfer_public "$wallet_addr" 1000000u64 \
        --path "$path" "${COMMON_OPTS[@]}"

    banner "[$mode] PART 3: Custodian signs a transfer_public off-chain"
    node signer/sign.js "$mode" public "$RECIPIENT" 1000 42 999999

    banner "[$mode] PART 4: Relayer submits the signed payload"
    sign_args "$mode" public "$RECIPIENT" 1000 42 999999
    $LEO execute "${program}/transfer_public" \
        "${SIGN_ARGS[@]}" --path "$path" "${COMMON_OPTS[@]}"

    echo ""
    echo "─── ${program} wallet balance after transfer ───"
    curl -s "$ENDPOINT/testnet/program/credits.aleo/mapping/account/${wallet_addr}"; echo

    banner "[$mode] PART 5: Replay the same payload — should be REJECTED"
    sign_args "$mode" public "$RECIPIENT" 1000 42 999999
    expect_rejected "[$mode] replay" \
        execute "${program}/transfer_public" \
        "${SIGN_ARGS[@]}" --path "$path" "${COMMON_OPTS[@]}"

    banner "[$mode] PART 6: transfer_public_to_private with fresh nonce"
    sign_args "$mode" public_to_private "$RECIPIENT" 500 43 999999
    $LEO execute "${program}/transfer_public_to_private" \
        "${SIGN_ARGS[@]}" --path "$path" "${COMMON_OPTS[@]}"
}

#####################################################################
# PART A — eth-address-flavored wallet
#####################################################################
banner "PART A — virtual_wallet_eth.aleo (ECDSA::verify_keccak256_eth)"
demo_variant eth "$WALLET_ETH_ADDR"

#####################################################################
# PART B — compressed-pubkey-flavored wallet
#####################################################################
banner "PART B — virtual_wallet_pubkey.aleo (ECDSA::verify_keccak256_raw)"
demo_variant pubkey "$WALLET_PUBKEY_ADDR"

echo ""
echo "Done!  Both virtual_wallet variants exercised end-to-end."

# To recompute the WALLET_*_ADDR constants if the program names change:
#
#   node -e '
#     import("@provablehq/sdk/testnet.js").then((sdk) => {
#       for (const name of ["virtual_wallet_eth.aleo", "virtual_wallet_pubkey.aleo"]) {
#         const src = `program ${name};\n\nfunction f:\n    output 0u8 as u8.public;\n`;
#         console.log(name, "=>", sdk.Program.fromString(src).address().to_string());
#       }
#     });
#   '
