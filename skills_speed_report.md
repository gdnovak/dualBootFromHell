# Skills Acceleration Report (dualBootFromHell)

## Objective
Use Codex skills to reduce wall-clock time and risk for this project: finish dualboot tonight while preserving a fast recovery path (backup + restore + automation).

## Currently Available Local Skills

1. `skill-creator`
- Path: `/home/tdj/.codex/skills/.system/skill-creator/SKILL.md`
- Use: quickly create/update project-specific skills so repeated workflows become one-command playbooks.

2. `skill-installer`
- Path: `/home/tdj/.codex/skills/.system/skill-installer/SKILL.md`
- Use: install curated or repo-based skills into Codex quickly, including private/internal skill repos.

## High-Impact Skill Categories for This Project

1. Backup verification and restore-drill skill
- Pattern: run preflight checks, verify latest backup integrity, test restore of critical files (`fstab`, `crypttab`, boot entries), produce pass/fail summary.
- Why high impact: prevents “backup exists but restore fails” during resize/reinstall.

2. Dualboot preflight and gate skill
- Pattern: single command that validates disk layout, free space target, EFI state, bootloader status, and rollback notes before destructive steps.
- Why high impact: catches blockers before partition edits.

3. Resize execution checklist skill
- Pattern: enforced ordered checklist for Fedora/LUKS/Btrfs shrink operations with required confirmations and automatic log capture.
- Why high impact: reduces human error in the riskiest phase.

4. Post-change boot-repair skill
- Pattern: detect broken boot state and run fast recovery path for GRUB/EFI entries plus config restore from backup.
- Why high impact: fastest path back to a bootable system.

5. Backup automation ops skill
- Pattern: wrapper around repo scripts (`scripts/rsync_to_truenas.sh`, `scripts/auto_filelevel_to_truenas.sh`, `scripts/truenas_archive_rotate.sh`) with health checks, retention status, and alert-like output.
- Why high impact: makes ongoing protection reliable with less manual effort.

6. Session handoff/status skill
- Pattern: generate concise “current state + next exact command” report for context switching between sessions/devices.
- Why high impact: avoids re-discovery overhead under deadline.

## Quick Adoption Plan (Prioritized by Speed-to-Value)

### Phase 0: Immediate (30-60 min)

1. Use `skill-creator` to create `backup-restore-drill` skill.
- Scope: verify latest backup, restore-test critical files to temp path, emit green/red summary.
- Value: highest safety gain before resize.

2. Use `skill-creator` to create `dualboot-preflight` skill.
- Scope: checks for required free space, EFI health, boot entries, and logs current partition map.
- Value: fastest blocker detection.

3. Use `skill-creator` to create `resize-runbook` skill.
- Scope: ordered command checklist + guardrails + logging for shrink steps.
- Value: execution speed and consistency during risky operations.

### Phase 1: Same day (60-120 min)

1. Add `post-boot-repair` skill.
- Scope: automated GRUB/EFI repair flow and restore of key config files from backup.
- Value: minimizes outage if system fails to boot after changes.

2. Add `backup-ops` skill.
- Scope: one entry point for backup run, rotation, quick verification, and status summary.
- Value: sustained automation with fewer manual mistakes.

### Phase 2: Near-term hardening (later)

1. Use `skill-installer` to pull any proven external skills for storage checks, Linux boot repair, or runbook automation.
- Rule: only adopt if they reduce steps vs local scripts and are easy to audit.

2. Add `session-handoff` skill.
- Scope: standardized progress snapshot for rapid resume.
- Value: keeps momentum across interruptions.

## Recommended Next 3 Skills to Build First

1. `backup-restore-drill`
2. `dualboot-preflight`
3. `post-boot-repair`

These three provide the best speed/risk balance for dualboot + backup + automation under a hard deadline.
