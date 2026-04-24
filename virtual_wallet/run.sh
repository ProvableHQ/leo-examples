#!/bin/bash
# Demonstrates virtual_wallet.aleo end-to-end.
# Run from the virtual_wallet/ directory.
#
# Prerequisites:
#   leo devnode must be running in a separate terminal:
#     leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
#   The signer must have its deps installed:
#     (cd signer && npm install)

set -euo pipefail

LEO=${LEO:-leo}

# The Aleo account that funds the wallet and relays user-signed payloads.
RELAYER_PRIVATE_KEY="APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH"

# The ECDSA (Ethereum) private key of the custodian who authorizes transfers.
# Well-known test key; the derived eth address is
# 0x9d8a62f656a8d1615c1294fd71e9cfb3e4855a4f.
export SIGNER_PRIVATE_KEY="0x4646464646464646464646464646464646464646464646464646464646464646"

# virtual_wallet.aleo's program address — the on-chain location of the
# pooled wallet balance.  Derived deterministically from the program name.
WALLET_PROGRAM_ADDR="aleo1tjsh0csglcjglgv9yrgx4fpm44y0krasl7c0jnvu8kj0j54jqgqsdg93rp"

# Recipient of the demo transfers.
RECIPIENT="aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px"

ENDPOINT="http://localhost:${LEO_DEVNODE_PORT:-3030}"
COMMON_OPTS=(-y --disable-update-check --broadcast
             --network testnet
             --endpoint "$ENDPOINT"
             --private-key "$RELAYER_PRIVATE_KEY"
             --consensus-heights "0,1,2,3,4,5,6,7,8,9,10,11,12,13")

# Populate SIGN_ARGS with the six positional args produced by sign.js, safely
# (one per line, no shell quoting, no eval).  `while read` is used instead of
# `mapfile` so the script runs under macOS's bash 3.2.
sign_args() {
    SIGN_ARGS=()
    while IFS= read -r line; do
        SIGN_ARGS+=("$line")
    done < <(node signer/sign.js --args-only "$@")
}

echo "═══════════════════════════════════════════════"
echo " PART 1: Deploy virtual_wallet.aleo"
echo "═══════════════════════════════════════════════"
$LEO deploy "${COMMON_OPTS[@]}"

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 2: Pre-fund the wallet"
echo "═══════════════════════════════════════════════"
echo "Sending 1 000 000 microcredits to ${WALLET_PROGRAM_ADDR}"
$LEO execute credits.aleo/transfer_public "$WALLET_PROGRAM_ADDR" 1000000u64 "${COMMON_OPTS[@]}"

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 3: Custodian signs a transfer_public off-chain"
echo "═══════════════════════════════════════════════"
node signer/sign.js public "$RECIPIENT" 1000 42 999999

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 4: Relayer submits the signed payload on-chain"
echo "═══════════════════════════════════════════════"
sign_args public "$RECIPIENT" 1000 42 999999
$LEO execute virtual_wallet.aleo/transfer_public "${SIGN_ARGS[@]}" "${COMMON_OPTS[@]}"

echo ""
echo "─── Wallet contract balance after transfer ────"
curl -s "$ENDPOINT/testnet/program/credits.aleo/mapping/account/${WALLET_PROGRAM_ADDR}"; echo

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 5: Replay the same payload — should be REJECTED"
echo "═══════════════════════════════════════════════"
sign_args public "$RECIPIENT" 1000 42 999999
# `leo execute` exits 0 even when the chain rejects a tx during finalize,
# so we detect the outcome by matching the CLI's "Transaction rejected." /
# "Transaction accepted." confirmation line.
replay_output=$("$LEO" execute virtual_wallet.aleo/transfer_public \
    "${SIGN_ARGS[@]}" "${COMMON_OPTS[@]}" 2>&1) || true
echo "$replay_output" | tail -10
echo ""
if echo "$replay_output" | grep -q "Transaction rejected"; then
    echo "Replay rejected as expected."
elif echo "$replay_output" | grep -q "Transaction accepted"; then
    echo "FAIL: replay was accepted — nonce protection did not trigger."
    exit 1
else
    echo "FAIL: could not determine replay outcome from CLI output."
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 6: transfer_public_to_private with fresh nonce"
echo "═══════════════════════════════════════════════"
sign_args public_to_private "$RECIPIENT" 500 43 999999
$LEO execute virtual_wallet.aleo/transfer_public_to_private "${SIGN_ARGS[@]}" "${COMMON_OPTS[@]}"

echo ""
echo "Done!  Virtual wallet demo complete."
