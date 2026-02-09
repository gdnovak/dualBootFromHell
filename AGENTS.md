# AGENTS Rules (Project-Local)

## Scope

- Do not fundamentally alter project scope.
- Scope is: get macOS + Fedora dualboot working quickly and safely enough for user priorities.

## Speed-First Policy

- Quick is default. Prefer the fastest safe path that completes the task.
- If permission/tooling blocks progress, immediately state the fastest path to unblock.

## Time Allowance Rule

- Ask user before starting any task likely to exceed 10 minutes.
- Exception window: between 3:30 and 4:30, ask only if likely to exceed 90 minutes.
- If user changes threshold (for example: 2 hours), that becomes active threshold.

## High-Risk Ask-First Rule

Ask before operations that could:
- Brick the system.
- Delete or make permanently inaccessible `/veyDisk/.vault`.

## TrueNAS/Proxmox Access Rule

- Codex has standing permission to use `ssh rb1-pve` for any necessary TrueNAS work.
- For backup/TrueNAS tasks, prefer a ready Proxmox path and run TrueNAS root actions via `qm guest exec 100 ...` when needed.
- Do not get stuck on non-root TrueNAS permission friction if Proxmox root path is available.

## Git Rule

- Ask before push to `main` branch.
- Commit locally when useful and summarize what is pending push.

## Environment/Model Rule

- User preference is Full Access mode and correct model.
- If session is not Full Access or model seems wrong for task, notify user immediately in one concise line.

## Rule Evolution

- You may propose rule improvements, but pitch the full proposed set before adding/changing these rules.
