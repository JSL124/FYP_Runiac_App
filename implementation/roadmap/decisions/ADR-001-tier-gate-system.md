# ADR-001 - Tier Gate System

## Context

Runiac needs a deterministic approval model for AI-assisted work. The model must prevent irreversible setup, external service changes, production pollution, and accidental implementation while still allowing small reviewable changes to proceed efficiently.

## Decision

Classify work by reversibility and blast radius. Higher-risk work requires stronger approval before execution.

## Tier Definitions

### Tier 1 - Irreversible or external (Human approval required)

Basis:
Cannot be undone with git revert.

Examples:
- flutter create
- firebase init
- flutterfire configure
- production Firebase connection
- Cloud Functions deployment
- GPS permission requests
- cost-affecting changes

### Tier 2 - Reviewable code change (Codex + review checklist)

Basis:
git revert possible, but logic changes.

Examples:
- new feature capsule
- existing logic modification
- test addition/change
- refactor including file moves
- dependency addition

### Tier 3 - Mechanical (Self-approved with commit message log)

Basis:
No functional impact, automatable.

Examples:
- dart format
- import sorting
- typo/comment fix
- lint auto-fix
- patch version bump (semver patch only)

## Classification Basis

Classification is based on whether the change can be reversed by git, whether it touches external systems, whether it changes runtime behavior, and whether it can affect user privacy, cost, security, or assessment deliverables.

## Why Reversibility/Blast-Radius Classification Was Chosen

This basis is simple for agents to apply, maps directly to repository safety, and avoids relying on subjective labels such as "small" or "simple." It also keeps production service operations distinct from ordinary file edits.

## Consequences

- Tier 1 work pauses until explicit human approval exists.
- Tier 2 work requires Codex review/checklist evidence before Ready for commit.
- Tier 3 work can proceed with concise evidence and a clear commit-message log.
- If classification is ambiguous, use the higher tier until resolved.
