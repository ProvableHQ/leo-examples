#!/bin/bash
# Demonstrates dynamic records and dynamic dispatch in Leo.
# Run from the dynamic_records/ directory.
#
# Prerequisites:
#   leo devnode must be running in a separate terminal:
#     leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH

set -euo pipefail

LEO=${LEO:-leo}

OWNER="aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px"
PRIVATE_KEY="APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH"
COMMON_OPTS=(-y --disable-update-check --broadcast
             --network testnet
             --endpoint "http://localhost:${LEO_DEVNODE_PORT:-3030}"
             --private-key "$PRIVATE_KEY"
             --consensus-heights "0,1,2,3,4,5,6,7,8,9,10,11,12,13")

# ─── Part 1: Local execution (no devnode required) ────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════"
echo " PART 1: Local execution (no devnode needed)"
echo "═══════════════════════════════════════════════════════"

echo ""
echo "── gold_token.aleo ──────────────────────────────────────"
echo "   The Token record carries a purity field beyond the interface minimum."
cd gold_token
echo "   1 000 mg at 24-karat (pure gold):"
$LEO run mint_custom "$OWNER" 1000u64 24u64
echo ""
echo "   500 mg at 18-karat:"
$LEO run mint_custom "$OWNER" 500u64 18u64
cd ..

echo ""
echo "── silver_token.aleo ────────────────────────────────────"
echo "   The Token record carries a grade field — a different extra field"
echo "   from GoldToken, yet both satisfy the same TokenStandard interface."
cd silver_token
echo "   2 000 mg at sterling grade (3):"
$LEO run mint_custom "$OWNER" 2000u64 3u64
echo ""
echo "   800 mg at industrial grade (0):"
$LEO run mint_custom "$OWNER" 800u64 0u64
cd ..

# ─── Part 2: Deployment and dynamic dispatch ──────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════"
echo " PART 2: Deployment and dynamic dispatch"
echo "         (requires leo devnode)"
echo "═══════════════════════════════════════════════════════"

echo ""
echo "── Step 1: Deploy gold_token.aleo ───────────────────────"
echo "   (defines TokenStandard interface + gold implementation)"
cd gold_token
$LEO deploy "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 2: Deploy silver_token.aleo ─────────────────────"
echo "   (silver implementation of TokenStandard)"
cd silver_token
$LEO deploy "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 3: Deploy token_router.aleo ─────────────────────"
echo "   (dynamic dispatch hub — no token logic of its own)"
cd token_router
$LEO deploy "${COMMON_OPTS[@]}"

echo ""
echo "── Step 4: demo_transfer — mint then route in one dynamic call ──"
echo "   The router dispatches two calls in sequence without ever knowing"
echo "   the concrete record type (GoldToken has 'purity'; SilverToken has 'grade')."

echo ""
echo "   Minting 1 000 mg gold (purity=24) then routing to owner:"
$LEO execute token_router.aleo/demo_transfer "'gold_token'" "$OWNER" 1000u64 "$OWNER" "${COMMON_OPTS[@]}"

echo ""
echo "   Minting 2 000 mg silver (grade=3) then routing to owner:"
$LEO execute token_router.aleo/demo_transfer "'silver_token'" "$OWNER" 2000u64 "$OWNER" "${COMMON_OPTS[@]}"

echo ""
echo "── Step 5: route_transfer and read_balance (manual) ────────"
echo "   These functions accept a dyn record from a previous mint."
echo "   Capture a record ciphertext from step 4 above, then run:"
echo ""
echo "   leo execute token_router.aleo/read_balance \\"
echo "     \"'gold_token'\" <record-ciphertext> ${COMMON_OPTS[*]}"
echo ""
echo "   leo execute token_router.aleo/route_transfer \\"
echo "     \"'gold_token'\" <record-ciphertext> \"$OWNER\" ${COMMON_OPTS[*]}"

cd ..

echo ""
echo "Done!  token_router.aleo routed mints and transfers to GoldToken and"
echo "SilverToken without knowing either record's concrete field layout."
