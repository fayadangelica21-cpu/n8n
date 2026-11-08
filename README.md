# Lead Intake Validation and Scoring API (n8n)

An n8n workflow that turns a webhook into a small API. It receives a lead as JSON, validates and cleans it, scores it with transparent rules, and replies with the result.

Built with AI assistance (Claude), then run, tested and reviewed by me.


## What it does

```
Webhook (POST) -> Validate and Score Lead (Code) -> Is Valid? (IF) -> 200 Accepted
                                                                  -> 400 Rejected
```

1. **Webhook**: `POST /webhook/lead-intake`. The reply is sent by a Respond to Webhook node, so the caller gets the real result.
2. **Validate and Score Lead** (Code node): trims fields, lowercases the email, checks name, email format and message length, then scores the lead 0-100:
   - business email domain: +20
   - phone number given: +30
   - buying-intent words (price, quote, demo, book, urgent, buy): +30
   - message of 50+ characters: +20
   - priority: `hot` (70+), `warm` (40-69), `cold` (below 40)
3. **Is Valid?** (IF node): valid leads get HTTP 200 with priority and score; invalid ones get HTTP 400 with a list of errors.

## Repository layout

| Path | Purpose |
|---|---|
| `workflows/lead-intake-workflow.json` | The n8n workflow (import this) |
| `samples/` | Example valid and invalid payloads |
| `tests/test.sh` | Runs both samples against the webhook |
| `docs/` | Screenshots |

## How to run it

1. Start n8n: `npx n8n` and open http://localhost:5678.
2. Workflows > Import from file > `workflows/lead-intake-workflow.json`.
3. Click **Execute workflow** (this listens on the test URL for one call).
4. Run the tests. Click **Execute workflow** before each call, because the test URL listens once.
   - Git Bash / Linux / macOS: `./tests/test.sh`
   - Windows Command Prompt:
     ```
     curl -X POST "http://localhost:5678/webhook-test/lead-intake" -H "Content-Type: application/json" -d @samples\valid-lead.json -w "\nHTTP %{http_code}\n"
     curl -X POST "http://localhost:5678/webhook-test/lead-intake" -H "Content-Type: application/json" -d @samples\invalid-lead.json -w "\nHTTP %{http_code}\n"
     ```

Expected results:

```
valid lead   -> HTTP 200 {"status":"accepted","priority":"hot","score":100,...}
invalid lead -> HTTP 400 {"status":"rejected","errors":["name is required","a valid email is required","message must be at least 10 characters"]}
```


## Screenshots

**Valid lead: the 200 branch runs**

![Valid path](docs/workflow-valid-path.jpg)

![Respond 200 node](docs/Success-Result-Workflow.png)

**Invalid lead: the 400 branch runs**

![Invalid path](docs/workflow-invalid-path.jpg)

![Respond 400 node](docs/Invalid-Result-Workflow.png)

**Terminal test results**

![Test results](docs/test-result.png)

## What I learned

- How a webhook trigger works, and why "Respond to Webhook" mode is needed to return a custom status code.
- Writing and testing logic in the Code node, then routing results with an IF node.
- Returning clear error messages from an API instead of failing silently.
- Documenting a workflow so someone else can import and run it.

## Next steps

- [ ] Slack alert when `priority` is `hot`
- [ ] Append each lead to Google Sheets or a CRM
- [ ] LLM step to classify intent or draft a reply
- [ ] Error Trigger workflow to alert on failures

## Security

No credentials are stored in this repo. Use n8n's credential manager for any API keys you add later.
