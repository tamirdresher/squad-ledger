# Decisions

> Team decisions that all agents must respect. Append-only — managed by Scribe.
> 
> Each entry has **Scope** and **Lifecycle** metadata for branch tracking.

---

## Decision: Adopt Squad Ledger Pattern
- **Scope:** `global`
- **Lifecycle:** `permanent`
- **Date:** 2026-07-22
- **Author:** Picard

Squad agent state (decisions, routing, history) lives in a dedicated ledger repo 
(`squad-ledger`) on a `squad/state` branch. The code repo contains only a pointer 
file (`.squad/ledger.json`). Sync is automated via GitHub Actions on push, PR merge, 
and PR close events. See `docs/upstream-squad-state-sync-design.md` for full design.

---
