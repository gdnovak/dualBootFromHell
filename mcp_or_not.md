# MCP or Not: Continuity Strategy (Across Devices + Unattended Windows)

## Executive Recommendation
**Do not adopt a full MCP state/task server right now. Use a hybrid now:**
- Source of truth: Git + `README.md` + `log.md` + `AGENTS.md`
- Add one small machine-readable status file (`state/current.yaml`) and one safe-run script (`scripts/unattended_guard.sh`)
- Re-evaluate MCP after 2 weeks of usage data

Why: this gets 80-90% of continuity value with minimal operational risk and almost no new infrastructure.

## Architecture Options (Short Comparison)

| Option | Continuity Across Devices | Unattended Safety | Setup/Ops Cost | Failure Risk | Verdict |
|---|---|---|---|---|---|
| 1) Git + docs/log only | Good if logging is disciplined | Medium (manual) | Very low | Low-medium (human drift) | Baseline minimum |
| 2) MCP server for state/tasks | Excellent in theory | Medium-high (needs strict policy layer) | High | Medium-high (server/tooling drift, bad automation) | Not now |
| 3) Hybrid (Git/docs + tiny structured state + guarded scripts) | Very good | High enough for current need | Low | Low | **Recommended now** |

## Recommended Implementation Plan (Minimal Tooling)

### Phase 0 (Today, 30-45 min)
- Create `state/current.yaml` with fields:
  - `goal`, `current_step`, `next_step`, `blocked_on`, `last_verified_at`, `safe_to_run_unattended`, `rollback`
- Add `scripts/unattended_guard.sh`:
  - Refuse destructive commands unless `ALLOW_DESTRUCTIVE=1`
  - Use lockfile to prevent concurrent runs
  - Add hard timeout (`timeout 20m ...`)
  - Write start/end status lines to `log.md`
- Add `scripts/handoff.sh` to print a compact handoff from `state/current.yaml` + last lines of `log.md`

### Phase 1 (This week)
- Enforce one workflow rule:
  - Start session: run `scripts/handoff.sh`
  - End session: update `state/current.yaml` + append one decision line to `log.md`
- Add `make handoff`, `make checkpoint`, `make unattended-safe` targets (or shell aliases)
- Keep unattended jobs read-only or append-only by default

### Phase 2 (Later, only if needed)
- Trigger to adopt MCP: if handoff friction remains high after 2 weeks (missed context, duplicate work, stale state)
- If triggered, start with a **thin MCP**:
  - Read/write only `state/current.yaml`, task queue, and decision log
  - No direct destructive system actions through MCP tools

## Unattended Windows (12:30-1, 3:30-5, Sleep)

### Safe operational mode
- Allowed unattended during those windows:
  - Validation checks, backups, rsync, checksum, report generation
- Not allowed unattended:
  - Partitioning, bootloader edits, LUKS/LVM/Btrfs resize, delete/overwrite operations

### Practical controls
- Use `systemd-run --user --scope` or a simple `nohup` wrapper with `timeout`
- Every unattended task must:
  - Write heartbeat/log every few minutes
  - Exit non-zero on first critical error
  - Emit a final `PASS/FAIL + next action` line
- Before sleep:
  - Prefer queueing only idempotent tasks
  - Skip any task that needs interactive recovery

## Failure Modes and Guardrails

Common failure modes:
- Stale status file causes wrong next action
- Two devices run conflicting work
- Long unattended task hangs silently
- "Adventure mode" (scope creep into risky ops)

Guardrails:
- Single-writer lock (`state/.lock`) for state updates
- Mandatory `next_step` + `rollback` fields in `state/current.yaml`
- Timeout + lockfile on all unattended scripts
- Explicit denylist in `unattended_guard.sh` for destructive commands
- End-of-session checkpoint is required before context switch/device switch

## This Week vs Later

### Do this week
- Implement hybrid baseline (state file + guard script + handoff script)
- Use it daily and tune fields/format once
- Track 3 metrics in `log.md`: handoff time, duplicate-work incidents, unattended failures

### Do later
- Add MCP only if metrics show persistent continuity pain
- Keep MCP narrow: continuity metadata first, automation last
- Revisit after dual-boot critical path is complete
