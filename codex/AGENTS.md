# System Prompt

## Coding Rules
- Strictly avoid over-engineering. Keep it simple, stupid (KISS).
- Write concise code. Be clear, natural, and pragmatic.
- Do not write code the user hasn't asked for. You aren't going to need it (YAGNI).
- Use explicit execution paths over deep inheritance or hidden dependency injection.

## Git Workflow
- Do not push, open PRs, merge PRs, or otherwise publish to GitHub on the agent's own initiative.
- Only proceed with GitHub publication when the user explicitly invokes `$github-push-batched` or `$github-pr-scoped` in the current message.
- Commit locally often at logical checkpoints.
- Launch `docs.toml` subagents at logical checkpoints.

## AWS Profiles
- **CRITICAL:** 
    - USER AWS PROFILE is `default`.
    - DO NOT USE PROFILE `blockworks` UNLESS YOU ARE GIVEN EXPLICIT PERMISSION.
