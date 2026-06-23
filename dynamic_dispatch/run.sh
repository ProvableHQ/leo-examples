#!/bin/bash
# Demonstrates interfaces and dynamic dispatch in Leo.
# Run from the dynamic_dispatch/ directory.
#
# Prerequisites:
#   leo devnode must be running in a separate terminal:
#     leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH

set -euo pipefail

LEO=${LEO:-leo}

PRIVATE_KEY="APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH"
COMMON_OPTS=(-y --disable-update-check --broadcast
             --network testnet
             --endpoint "http://localhost:${LEO_DEVNODE_PORT:-3030}"
             --private-key "$PRIVATE_KEY"
             --consensus-heights "0,1,2,3,4,5,6,7,8,9,10,11,12,13")

# ─── Local demos (no devnode required) ────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 1: Local execution (no devnode needed)"
echo "═══════════════════════════════════════════════"

echo ""
echo "── voting_power.aleo: linear strategy ─────────"
cd voting_power
echo "  10 000 tokens → linear voting power:"
$LEO run compute_power 10000u64
echo "    100 tokens → linear voting power:"
$LEO run compute_power 100u64
cd ..

echo ""
echo "── quadratic_power.aleo: quadratic strategy ───"
cd quadratic_power
echo "  10 000 tokens → quadratic voting power (expected: 100):"
$LEO run compute_power 10000u64
echo "    100 tokens → quadratic voting power (expected: 10):"
$LEO run compute_power 100u64
cd ..

# ─── Devnode deployment and dynamic dispatch ──────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 2: Deployment and dynamic dispatch"
echo "         (requires leo devnode)"
echo "═══════════════════════════════════════════════"

echo ""
echo "── Step 1: Deploy voting_power.aleo ───────────"
echo "   (defines VotingStrategy interface + linear implementation)"
cd voting_power
$LEO deploy "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 2: Deploy quadratic_power.aleo ────────"
echo "   (quadratic implementation of VotingStrategy)"
cd quadratic_power
$LEO deploy "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 3: Deploy governance.aleo ─────────────"
echo "   (dynamic dispatch hub — no voting logic of its own)"
cd governance
$LEO deploy "${COMMON_OPTS[@]}"

echo ""
echo "── Step 4: get_voting_power with variable identifier ─"
echo "   The same function routes to different programs at runtime."

echo ""
echo "   strategy = 'voting_power'  (linear), balance = 10 000"
$LEO execute governance.aleo/get_voting_power "'voting_power'" 10000u64 "${COMMON_OPTS[@]}"

echo ""
echo "   strategy = 'quadratic_power'  (quadratic), balance = 10 000"
$LEO execute governance.aleo/get_voting_power "'quadratic_power'" 10000u64 "${COMMON_OPTS[@]}"

echo ""
echo "── Step 5: proposal_passes — diverging outcomes ─"
echo "   Whale: 1 000 000 tokens for  vs  Regular voter: 10 000 tokens against"

echo ""
echo "   Linear strategy — whale wins by 100x margin:"
$LEO execute governance.aleo/proposal_passes "'voting_power'" 1000000u64 10000u64 "${COMMON_OPTS[@]}"

echo ""
echo "   Quadratic strategy — whale wins by 10x margin (1000 vs 100):"
$LEO execute governance.aleo/proposal_passes "'quadratic_power'" 1000000u64 10000u64 "${COMMON_OPTS[@]}"

echo ""
echo "── Step 6: compare_strategies (identifier literals) ─"
echo "   Single call dispatches to both built-in targets."
$LEO execute governance.aleo/compare_strategies 10000u64 "${COMMON_OPTS[@]}"

cd ..

echo ""
echo "Done!  Dynamic dispatch routed governance.aleo to different"
echo "VotingStrategy implementations without any contract redeployment."
