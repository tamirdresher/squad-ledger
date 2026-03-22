# Squad Ledger

> Durable record of Squad agent decisions, routing, and learning history.

## What Is This?

This repository is the **state ledger** for a Squad-powered code repository. It stores durable agent state that shouldn't live in your code PRs:

- **Decisions** — What the team decided and why
- **Agent histories** — What each agent has learned
- **Routing rules** — How work gets assigned
- **Branch context** — Research and analysis tied to feature branches

## Why a Separate Repo?

Squad agents write frequently — decisions, logs, orchestration traces. In repos with branch protection, these writes require PR approval just so an agent can *remember something*. That's friction without value.

The ledger pattern separates concerns:
- **Code repo** → code changes (PRs, reviews, CI)
- **Ledger repo** → agent state (append-only, auto-synced)

## Branch

All state lives on the `squad/state` branch. There are no other branches. This is intentional:

- Single branch = agents always know where to look
- Works with git worktrees
- Compatible with `merge=union` for append-only files
- No branch management overhead

## How Sync Works

```
Code Repo                          Ledger Repo
.squad/ ───── GitHub Action ─────→ .squad/ (squad/state branch)
              (on push/PR merge)
```

1. **Push to main** with `.squad/` changes → Action syncs state files to ledger
2. **PR merged** → Action promotes `pending-merge` decisions to `merged`
3. **PR closed (rejected)** → Action marks `pending-merge` decisions as `withdrawn`
4. **Drift check** (every 6 hours) → Ralph verifies sync is current

## State Classification

Every decision has a **Scope** and **Lifecycle**:

| Scope | Meaning | Example |
|-------|---------|---------|
| `global` | Always valid, not branch-tied | "Use structured logging everywhere" |
| `branch:<name>` | Valid only if the branch merges | "Use JWT for the auth middleware" |

| Lifecycle | Meaning |
|-----------|---------|
| `permanent` | Always active |
| `pending-merge` | Waiting for associated branch PR to merge |
| `merged` | Branch merged, decision is now permanent |
| `withdrawn` | Branch rejected, decision is inactive |
| `superseded` | Replaced by a later decision |

## Directory Structure

```
.squad/
├── decisions.md              # All team decisions (append-only)
├── decisions/
│   ├── inbox/                # New decisions awaiting processing
│   └── INDEX.md              # Decision index
├── routing.md                # Work routing rules
├── team.md                   # Team roster
├── agents/                   # Per-agent history
│   ├── picard/history.md
│   ├── data/history.md
│   └── ...
├── branches/                 # Branch-specific context
│   ├── feature-auth/         # Active branch research
│   └── _archived/            # Rejected branch context
├── knowledge/                # Promoted research
│   └── from-branches/        # Research from merged branches
└── log/                      # Orchestration logs
```

## Agent Rules

1. **Agents write to the code repo's `.squad/`** — the sync workflow publishes to the ledger
2. **Every decision must have Scope + Lifecycle** metadata
3. **Agent history is always permanent** — learning persists even if features are rejected
4. **The ledger is append-only** — entries are marked `withdrawn`, never deleted

## Design Document

Full architecture, edge cases, and implementation details:  
[`docs/upstream-squad-state-sync-design.md`](https://github.com/tamirdresher/tamresearch1/blob/main/docs/upstream-squad-state-sync-design.md)

## Naming

This repo was intentionally named "ledger" instead of "upstream" because:
- In git, "upstream" means "where I pull from" — but state flows *to* this repo
- The existing `.squad/upstream.json` already refers to parent squad relationships
- "Ledger" conveys: append-only, authoritative, timestamped records

## Related

- [squad-upstream-example](https://github.com/tamirdresher/squad-upstream-example) — Reference implementation
- [bradygaster/squad](https://github.com/bradygaster/squad) — The Squad framework
