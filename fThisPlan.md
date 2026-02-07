# fThisPlan: Stop Hand-Rolling Backup Infrastructure

## Goal
Use established backup software so this project stays focused on restoring dual boot (macOS + Fedora), not building a custom backup platform.

## Quick Reality Check (This Fedora Install)
On this machine, no common desktop backup GUI appears to be installed by default.
Local package query only surfaced `mariadb-backup` from backup-related names.

## Popular Alternatives (Practical on Fedora)

1. Vorta + Borg (`vorta`, `borgbackup`)
- Type: GUI + proven deduplicated encrypted backup engine
- Good for: Versioned backups to local or remote targets over SSH
- Strength: Reliable retention policies without writing your own rotation logic
- Tradeoff: Slight learning curve for repository/passphrase model

2. Back In Time (`backintime-qt`)
- Type: GUI snapshot-style backup (rsync + hardlinks)
- Good for: Very simple desktop restore workflow with versioned snapshots
- Strength: Easy setup, easy browsing/restoring old versions
- Tradeoff: Less feature depth than Borg/Restic ecosystems

3. Restic (`restic`)
- Type: CLI, modern encrypted deduplicated backups
- Good for: Scripted + timer-based backups with low operational overhead
- Strength: Clean restore model, strong ecosystem, easy verify/check
- Tradeoff: CLI-first unless adding external UI tooling

4. Timeshift (`timeshift`) plus user-data backup tool
- Type: System snapshot tool
- Good for: Fast rollback of system state
- Strength: Good for OS-level rollback
- Tradeoff: Not a full user-data strategy by itself; pair with one of the above

5. Deja Dup (`deja-dup`)
- Type: Very simple desktop backup GUI
- Good for: Basic scheduled backups with minimal setup
- Strength: Lowest setup friction
- Tradeoff: Less flexible for advanced Linux layout use-cases

## Fedora Availability (checked locally)
Available packages include:
- `vorta`, `borgbackup`, `restic`, `timeshift`, `deja-dup`, `backintime-qt`, `snapper`
Not found in standard Fedora repos here:
- `kopia` (would require alternate install path)

## Recommended Tonight Path

1. Keep the completed bare-metal image as disaster recovery.
2. Install `vorta` + `borgbackup` OR `backintime-qt` (pick one).
3. Configure backup destination to NAS path dedicated to file-level backups.
4. Run one full backup now.
5. Run a restore test of a few critical directories (`Documents`, dot-configs) to confirm restore workflow.
6. Freeze backup architecture work and proceed with dual-boot project steps.

## Decision Matrix (short)
- If you want easiest GUI today: choose `backintime-qt`.
- If you want strongest long-term versioned backup model: choose `vorta` + `borgbackup`.
- If you want scriptable/infra-friendly CLI: choose `restic`.

## Example Install Commands
```bash
sudo dnf install -y backintime-qt
# OR
sudo dnf install -y borgbackup vorta
# OR
sudo dnf install -y restic
```

## Why This Is Better Than Current Hand-Built Flow
- Lowers configuration complexity and operator fatigue.
- Removes fragile shell glue for rotation/retention logic.
- Gives tested restore workflows and predictable behavior.
- Keeps project scope aligned with the actual goal (dual boot).
