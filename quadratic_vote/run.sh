#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir/governance"
leo_bin="${LEO:-leo}"

run_leo() {
    "$leo_bin" "$@" --network testnet --disable-update-check
}

"$leo_bin" --version

echo "Scenario 1: balance 1000, approval. Expected weight: 31."
run_leo run cast_vote 1field 1000u32 true

echo "Scenario 2: balance 225, rejection. Expected weight: 15."
run_leo run cast_vote 1field 225u32 false

echo "Scenario 3: balance 10000, approval. Expected weight: 100."
run_leo run cast_vote 1field 10000u32 true

echo "Cost of 5 votes. Expected result: 25u32."
run_leo run qv_cost 5u32

echo "Compare supplied totals of 131 approvals and 15 rejections. Expected result: true."
run_leo run is_passing 131u32 15u32

echo "Check 1024. Expected result: true."
run_leo run has_perfect_sqrt 1024u32
echo "Check 1000. Expected result: false."
run_leo run has_perfect_sqrt 1000u32

echo "Run the tests."
run_leo test
