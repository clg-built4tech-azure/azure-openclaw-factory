# Contributing

Thanks for your interest in contributing! This document explains how to propose
changes to this repository.

## Getting started

1. Fork the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/your-feature
   ```
2. Make your changes, following the existing code and naming conventions.
3. Validate your changes locally (see below).
4. Commit with a clear, descriptive message.
5. Open a pull request against `main`.

## Branch & PR workflow

- `main` is protected. All changes land via pull request.
- PRs require at least one approving review and must pass status checks.
- Keep PRs focused and reasonably small; one logical change per PR.

## Validating changes

This is an Infrastructure-as-Code project. Before opening a PR:

- **Bicep:** run `az bicep build --file <template>.bicep` to lint and compile.
- **Scripts:** run `shellcheck` on modified shell scripts.
- **Smoke tests:** run the relevant scripts in `smoke-tests/` where applicable.

## Security

- Never commit secrets, credentials, connection strings, or tokens.
- Prefer OIDC / Workload Identity Federation over stored credentials.
- Report vulnerabilities privately — see [SECURITY.md](SECURITY.md).

## Code style

- Match the conventions already present in the files you edit.
- Keep resource naming consistent with existing patterns.
- Document non-obvious decisions in code comments or the PR description.

## Reporting issues

Use the issue templates for bug reports and feature requests. Include enough
context to reproduce the problem (with any secrets redacted).
