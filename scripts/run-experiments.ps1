$ErrorActionPreference = "Stop"

New-Item -ItemType Directory `
    -Force `
    -Path "experiments/results" | Out-Null

$netLogoCommand = '"$NETLOGO_HOME/netlogo-headless.sh" --model /workspace/model/WarehouseRobot.nlogox --setup-file /workspace/experiments/experiments.xml --experiment smoke-test --table /workspace/experiments/results/smoke-test.csv --threads 1'

docker compose run --rm netlogo bash -lc $netLogoCommand

if ($LASTEXITCODE -ne 0) {
    throw "NetLogo smoke-test failed with exit code $LASTEXITCODE"
}

Write-Host "Smoke test passed."
Write-Host "Result: experiments/results/smoke-test.csv"