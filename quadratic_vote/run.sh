#!/bin/bash
# Quadratic Vote — full walkthrough.
# Run from the quadratic_vote/ directory.

cd governance || exit 1

echo ""
echo "=== Step 1: Alice (1 000 tokens) approves proposal 1 ==="
echo "    weight = floor(sqrt(1000)) = 31"
leo run cast_vote 1field 1000u32 true

echo ""
echo "=== Step 2: Bob (225 tokens) rejects proposal 1 ==="
echo "    weight = floor(sqrt(225)) = 15"
leo run cast_vote 1field 225u32 false

echo ""
echo "=== Step 3: Carol (10 000 tokens) approves proposal 1 ==="
echo "    weight = floor(sqrt(10000)) = 100  (hits MAX_WEIGHT cap)"
leo run cast_vote 1field 10000u32 true

echo ""
echo "=== Step 4: Credit cost of casting 5 votes (= 5² = 25) ==="
leo run qv_cost 5u32

echo ""
echo "=== Step 5: Does proposal 1 pass? (131 approvals vs 15 rejections) ==="
leo run is_passing 131u32 15u32

echo ""
echo "=== Step 6: Perfect-square check via sqrt_math::checks ==="
echo "    1024 = 32²  → true"
leo run has_perfect_sqrt 1024u32
echo "    1000 is not a perfect square  → false"
leo run has_perfect_sqrt 1000u32

echo ""
echo "=== Step 7: Unit tests (leo test) ==="
leo test
