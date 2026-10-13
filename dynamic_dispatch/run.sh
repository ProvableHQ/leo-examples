#!/usr/bin/env bash
set -euo pipefail

mode=local
case "${1:-}" in
    --devnode) mode=devnode ;;
    "") ;;
    --help) echo "Usage: bash run.sh [--devnode]"; exit 0 ;;
    *) echo "Usage: bash run.sh [--devnode]" >&2; exit 2 ;;
esac
if (( $# > 1 )); then
    echo "Usage: bash run.sh [--devnode]" >&2
    exit 2
fi

leo_bin="${LEO:-leo}"
if [[ "$leo_bin" == */* && "$leo_bin" != /* ]]; then
    compiler_dir=$(cd -- "$(dirname -- "$leo_bin")" && pwd)
    leo_bin="$compiler_dir/$(basename -- "$leo_bin")"
fi
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$script_dir"

local_opts=(--network testnet --disable-update-check)
"$leo_bin" --version

for package in voting_power quadratic_power governance; do
    "$leo_bin" build --path "$package" "${local_opts[@]}"
    "$leo_bin" test --path "$package" "${local_opts[@]}"
done

echo "Variable linear target. Expected result: 10000u64."
"$leo_bin" run get_voting_power "'voting_power'" 10000u64 --path governance "${local_opts[@]}"
echo "Variable square-root target. Expected result: 100u64."
"$leo_bin" run get_voting_power "'quadratic_power'" 10000u64 --path governance "${local_opts[@]}"
echo "Linear comparison of 101 and 100. Expected result: true."
"$leo_bin" run proposal_passes "'voting_power'" 101u64 100u64 --path governance "${local_opts[@]}"
echo "Square-root comparison of 101 and 100. Expected result: false."
"$leo_bin" run proposal_passes "'quadratic_power'" 101u64 100u64 --path governance "${local_opts[@]}"
echo "Identifier literals. Expected results: 10000u64 and 100u64."
"$leo_bin" run compare_strategies 10000u64 --path governance "${local_opts[@]}"

if [[ "$mode" == devnode ]]; then
    port="${LEO_DEVNODE_PORT:-3030}"
    if [[ ! "$port" =~ ^[0-9]{1,5}$ ]] || (( 10#$port < 1 || 10#$port > 65535 )); then
        echo "LEO_DEVNODE_PORT must be an integer from 1 to 65535." >&2
        exit 2
    fi
    endpoint="http://127.0.0.1:$port"
    test_private_key="APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH"
    node_opts=("${local_opts[@]}" --endpoint "$endpoint" --private-key "$test_private_key" --devnet --broadcast --yes)

    "$leo_bin" query block --latest-height --endpoint "$endpoint" "${local_opts[@]}"
    echo "Deploy all three programs to the fresh local devnode."
    "$leo_bin" deploy --path governance "${node_opts[@]}"
    echo "Execute both variable targets on the devnode."
    "$leo_bin" execute get_voting_power "'voting_power'" 10000u64 --path governance "${node_opts[@]}"
    "$leo_bin" execute get_voting_power "'quadratic_power'" 10000u64 --path governance "${node_opts[@]}"
    echo "Execute the two comparisons. Expected results: true and false."
    "$leo_bin" execute proposal_passes "'voting_power'" 101u64 100u64 --path governance "${node_opts[@]}"
    "$leo_bin" execute proposal_passes "'quadratic_power'" 101u64 100u64 --path governance "${node_opts[@]}"
    echo "Execute the identifier literals. Expected results: 10000u64 and 100u64."
    "$leo_bin" execute compare_strategies 10000u64 --path governance "${node_opts[@]}"
fi
