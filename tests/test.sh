#!/usr/bin/env bash
# Usage: ./tests/test.sh [webhook-url]
# Default is the n8n TEST url. It listens for ONE call, so click
# "Execute workflow" in n8n before each request (the script pauses for you).
# For the production url, activate the workflow and use .../webhook/lead-intake
URL="${1:-http://localhost:5678/webhook-test/lead-intake}"
DIR="$(cd "$(dirname "$0")/.." && pwd)"

run() {
  echo
  echo "== $1 =="
  read -r -p "Click 'Execute workflow' in n8n, then press Enter... "
  curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
    -H "Content-Type: application/json" -d @"$DIR/samples/$2"
}

run "Hot lead (expect HTTP 200, priority hot, Slack alert)" valid-lead.json
run "Cold lead (expect HTTP 200, priority cold, no Slack alert)" cold-lead.json
run "Invalid lead (expect HTTP 400, status rejected)" invalid-lead.json
