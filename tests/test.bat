@echo off
REM Usage: tests\test.bat [webhook-url]
REM Default is the n8n TEST url. It listens for ONE call, so click
REM "Execute workflow" in n8n before each request (the script pauses for you).
set URL=%1
if "%URL%"=="" set URL=http://localhost:5678/webhook-test/lead-intake
set DIR=%~dp0..

echo.
echo == Hot lead (expect HTTP 200, priority hot, Slack alert) ==
pause
curl -X POST "%URL%" -H "Content-Type: application/json" -d "@%DIR%\samples\valid-lead.json" -w "\nHTTP %%{http_code}\n"

echo.
echo == Cold lead (expect HTTP 200, priority cold, no Slack alert) ==
pause
curl -X POST "%URL%" -H "Content-Type: application/json" -d "@%DIR%\samples\cold-lead.json" -w "\nHTTP %%{http_code}\n"

echo.
echo == Invalid lead (expect HTTP 400, status rejected) ==
pause
curl -X POST "%URL%" -H "Content-Type: application/json" -d "@%DIR%\samples\invalid-lead.json" -w "\nHTTP %%{http_code}\n"
