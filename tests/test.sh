#!/usr/bin/env bash
# Usage: ./tests/test.sh [webhook-url]
# Default is the n8n TEST url (click "Execute workflow" in n8n before each run).
# For the production url, activate the workflow and use .../webhook/lead-intake
URL="${1:-http://localhost:5678/webhook-test/lead-intake}"
DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "== Valid lead (expect HTTP 200, status accepted) =="
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -d @"$DIR/samples/valid-lead.json"

echo
echo "== Invalid lead (expect HTTP 400, status rejected) =="
curl -s -w "\nHTTP %{http_code}\n" -X POST "$URL" \
  -H "Content-Type: application/json" -d @"$DIR/samples/invalid-lead.json"
