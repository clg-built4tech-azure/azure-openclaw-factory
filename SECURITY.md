# Security Policy

## Supported Versions

We take security seriously. Currently, only the latest version of the `main`
branch is supported for security updates.

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please use one of the following private channels:

1. **GitHub Private Vulnerability Reporting** — use the "Report a vulnerability"
   button under the repository's **Security** tab (preferred).
2. **Email** — contact the repository owner at clgnca@gmail.com.

Please include:

- A description of the vulnerability and its potential impact
- Steps to reproduce (with any secrets redacted)
- Affected version, environment, or component

We will acknowledge receipt as soon as possible and keep you informed of the
remediation progress.

## Guidelines

This repository follows strict security practices:

- No credentials, tokens, passwords, or secrets in the repository or git history.
- GitHub Actions use OIDC / Workload Identity Federation for Azure where possible.
- Secret scanning and push protection are enabled.
- Dependabot alerts and automated security updates are enabled.
- Code scanning (CodeQL) runs on the default branch.

## Responsible Disclosure

We appreciate responsible disclosure and will acknowledge contributions where
appropriate. Please give us a reasonable amount of time to address an issue
before any public disclosure.
