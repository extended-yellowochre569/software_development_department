# Changelog

This repository's current changelog entrypoint is `CHANGELOG.md`.

Detailed internal release history and architectural remediation notes live in
[`docs/internal/CHANGELOG.md`](docs/internal/CHANGELOG.md).

## [v1.40.0] - 2026-04-19

- Standardized the `/ui-spec` skill name so routing matches the skill directory and invocation path.
- Restored the missing `brainstorm` product concept template at `.claude/docs/templates/product-concept.md`.
- Rewrote `gate-check`, `launch-checklist`, and `release-checklist` from game-oriented release gates to software delivery and go-live validation workflows.
