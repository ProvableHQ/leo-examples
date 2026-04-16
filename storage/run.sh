#!/bin/bash
# Demonstrates storage singletons, vectors, and external storage access in Leo.
# Run from the storage/ directory.
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
             --consensus-heights "0,1,2,3,4,5,6,7,8,9,10,11,12,13"
             --consensus-version 14)

# ─── Local demos (no devnode required) ────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 1: Local execution (no devnode needed)"
echo "═══════════════════════════════════════════════"

echo ""
echo "── treasury.aleo: storage singletons & vectors ─"
cd treasury

echo ""
echo "  Initialize treasury (sets balance, config, frozen flag):"
$LEO run initialize

echo ""
echo "  Deposit 5000 tokens (unwrap_or handles uninitialized storage):"
$LEO run deposit 5000u64

echo ""
echo "  Deposit 3000 tokens:"
$LEO run deposit 3000u64

echo ""
echo "  Withdraw 1000 tokens:"
$LEO run withdraw 1000u64

echo ""
echo "  Update fee config (struct storage):"
$LEO run update_config 500u64 25u64

echo ""
echo "  Freeze treasury:"
$LEO run freeze

echo ""
echo "  Unfreeze treasury:"
$LEO run unfreeze

cd ..

# ─── Devnode deployment and external storage access ───────────────────────────

echo ""
echo "═══════════════════════════════════════════════"
echo " PART 2: Deployment and external storage access"
echo "         (requires leo devnode)"
echo "═══════════════════════════════════════════════"

echo ""
echo "── Step 1: Deploy treasury.aleo and auditor.aleo ─"
echo "   (auditor lists treasury as a local dependency,"
echo "    so Leo deploys treasury first, then auditor)"
cd auditor
$LEO deploy "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 2: Initialize treasury ──────────────"
cd treasury
$LEO execute treasury.aleo/initialize "${COMMON_OPTS[@]}"

echo ""
echo "── Step 3: Deposit 5000 tokens ──────────────"
echo "   (writes balance, increments count, pushes to vector)"
$LEO execute treasury.aleo/deposit 5000u64 "${COMMON_OPTS[@]}"

echo ""
echo "── Step 4: Deposit 3000 tokens ──────────────"
$LEO execute treasury.aleo/deposit 3000u64 "${COMMON_OPTS[@]}"

echo ""
echo "── Step 5: Update fee config ────────────────"
echo "   (writes struct to storage)"
$LEO execute treasury.aleo/update_config 500u64 25u64 "${COMMON_OPTS[@]}"

cd ..

echo ""
echo "── Step 6: Take snapshot (read external singletons) ─"
echo "   Reads treasury.aleo::balance, ::deposit_count, ::is_frozen"
cd auditor
$LEO execute auditor.aleo/take_snapshot "${COMMON_OPTS[@]}"

echo ""
echo "── Step 7: Check fee config (read external struct) ─"
echo "   Reads treasury.aleo::config, verifies rate ≤ 10%"
$LEO execute auditor.aleo/check_fee_config "${COMMON_OPTS[@]}"

echo ""
echo "── Step 8: Check deposits (read external vector) ─"
echo "   Reads treasury.aleo::deposit_log.len() and .get(0)"
$LEO execute auditor.aleo/check_deposits "${COMMON_OPTS[@]}"

cd ..

echo ""
echo "── Step 9: Freeze treasury ──────────────────"
cd treasury
$LEO execute treasury.aleo/freeze "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 10: Snapshot detects freeze ─────────"
echo "   auditor reads is_frozen = true, sets is_alert = true"
cd auditor
$LEO execute auditor.aleo/take_snapshot "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "── Step 11: Reset treasury ──────────────────"
echo "   Clears all storage to none, clears vector"
cd treasury
$LEO execute treasury.aleo/reset "${COMMON_OPTS[@]}"
cd ..

echo ""
echo "Done!  The auditor read treasury storage cross-program"
echo "and detected the freeze — all without direct function calls."
