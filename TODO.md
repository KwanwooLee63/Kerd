# TODO

## Current Session
(no active session)

## Backlog
- Test sotu playbook audit on a project with a playbook
- Adopt third-person description format for skill triggers (low priority — opportunistic)
- Description optimization for skill triggers — tried skill-creator automated loop but it needs an ANTHROPIC_API_KEY; baseline eval showed 0% recall due to `claude -p` test harness limitations, not a real triggering problem. Consider retrying with API key or manual optimization if triggering issues arise in practice.

### Context
- Version is now 0.6.0
- Plugin update command is `claude plugin update kerd@kerd-marketplace`
- marketplace.json URL uses ssh format (git@github.com:) — intentional
