# AGENTS Rules (Project-Local)

Status note (2026-03-04):
- This file contains phase-era urgency rules from the original dualboot push window.
- For current machine/network truth, use `cleanup-mar26/SYSTEMS-DIRECTORY-2026-03-03.md`.
- For current repo operations, use `DOCS-INDEX.md`.

## !!! CANONICAL TRUTH DIRECTIVE !!!

- `~/cleanup-mar26/SYSTEMS-DIRECTORY-2026-03-03.md` is the canonical truth system for persistent lab facts.
- If you change host naming or aliases, IPs, subnets, routes, VLANs, machine roles, storage layout, VM or service placement, access paths, persistent services, or any other operator-facing topology/network/layout fact, you MUST update that file in the same session when practical.
- Do not leave the directory stale. Wrong infrastructure facts waste time and send later work in the wrong direction.

## !!! CRITICAL EXECUTION DIRECTIVE !!!

- Primary project objective for this phase: **quickly** finalize backup/recovery path, resize Fedora, and complete macOS+Fedora dualboot.
- Deadline priority: deliver working dualboot **tonight**.
- Do not allow low-value detours to delay this objective.

## Scope

- Do not fundamentally alter project scope.
- Scope is: get macOS + Fedora dualboot working quickly for user priorities.

## Speed-First Policy

- Quick is default. Prefer the fastest path that completes the task.
- If permission/tooling blocks progress, immediately state the fastest path to unblock.
- Spawn subagents whenever that is expected to reduce wall-clock completion time.
- Parallelize independent work aggressively.
- Do not hold the main thread waiting on long subagent tasks unless their output is required to proceed.

## Time Allowance Rule

- Ask user before starting any task likely to exceed 10 minutes.
- Exception window: between 3:30 and 4:30, ask only if likely to exceed 90 minutes.
- If user changes threshold (for example: 2 hours), that becomes active threshold.

## High-Risk Ask-First Rule

Ask before operations that could:
- Brick the system.
- Delete or make permanently inaccessible `/veyDisk/.vault`.

## TrueNAS/Proxmox Access Rule

- Codex has standing permission to use `ssh rb2-pve` for necessary TrueNAS work in current topology.
- Legacy alias `rb1-pve` is currently unreachable and should not be used for active operations.
- For backup/TrueNAS tasks, prefer a ready Proxmox path and run TrueNAS root actions via `qm guest exec 100 ...` when needed.
- Do not get stuck on non-root TrueNAS permission friction if Proxmox root path is available.
- Creating helper VMs on Proxmox for acceleration/orchestration is permitted when it is faster than alternatives.

## Git Rule

- Ask before push to `main` branch.
- Commit locally when useful and summarize what is pending push.

## Environment/Model Rule

- User preference is Full Access mode and correct model.
- If session is not Full Access or model seems wrong for task, notify user immediately in one concise line.

## Rule Evolution

- You may propose rule improvements, but pitch the full proposed set before adding/changing these rules.
