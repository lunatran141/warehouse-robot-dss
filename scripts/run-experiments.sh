#!/usr/bin/env bash
set -euo pipefail

mkdir -p experiments/results

docker compose run --rm netlogo bash -lc '"$NETLOGO_HOME/netlogo-headless.sh" --model /workspace/model/WarehouseRobot.nlogox --setup-file /workspace/experiments/experiments.xml --experiment smoke-test --table /workspace/experiments/results/smoke-test.csv --threads 1'

echo "Smoke test passed."
echo "Result: experiments/results/smoke-test.csv"