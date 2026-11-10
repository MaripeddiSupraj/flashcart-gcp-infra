## What and why
<!-- One stack per PR. Explain the infrastructure change and business reason. -->

## Stack and environment
- [ ] Stack path: `stacks/...`
- [ ] Environments affected: `dev` / `staging` / `prod`

## Shift-left & policy evidence
- [ ] `terraform fmt` & `terraform validate` passed
- [ ] PR Plan output reviewed (no unexpected destroys)
- [ ] TFLint, Checkov, and Conftest OPA rules clean (or documented exceptions)

## Rollback plan
<!-- How to undo: revert this PR, or manual mitigation steps if stateful. -->

## Prod change gate
- Change ticket / Jira:
- Verified in `dev` & `staging` on:
