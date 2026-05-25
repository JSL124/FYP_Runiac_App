# ADR-002 - Emulator First

## Context

Runiac will use Firebase services, but production Firebase setup and connections are high-risk during AI-assisted incremental implementation.

## Decision

Use Firebase Emulator Suite before production Firebase.

## Why

Prevent production pollution during AI-assisted incremental implementation.

## Consequences

- Need environment-switching strategy (`--dart-define` based).
- Need emulator workflow discipline.
- Production Firebase deferred until explicit Tier 1 approval.
