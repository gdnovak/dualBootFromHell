# Mac Mini Dual Boot Project

Hello, Codex. This readme file shall serve as your context for what we are doing here. The file log.md will be where we save our progress (see log.md for instructions on how to use it). Please read this document in the order it is written, and in the context provided.

## Big Picture

Our goal is to dual-boot MacOS and Fedora KDE Plasma on a 2018 Mac Mini, where MacOS was previously deleted in favor of letting Fedora have the entire internal storage (~450GB), and where we want to preserve my fedora kde plasma and all of its files in the process.

## Context & Background

### System Specs

The following are the specifications of the computer we are working with:

 - Model: Apple Mac mini (Macmini8,1, 2018)
 - CPU: Intel Core i7-8700B (6 cores / 12 threads)
 - RAM: 16 GiB
 - GPU: Intel UHD Graphics 630
 - T2: Apple iBridge (T2 present)
 - Storage: Apple NVMe SSD 512 GB (APPLE SSD AP0512M)
 - OS: Fedora Linux 43 (KDE Plasma Desktop Edition), Wayland
 - Kernel: 6.18.7-210.t2.fc43.x86_64
 - Firmware: Apple 2092.0.0.0.0 (iBridge 23.16.10350.0.0,0), 2025-08-05
 - Bootloader: GRUB 2.12 (systemd-boot not installed)
 - Secure Boot: disabled
 - Disk layout (internal): EFI (/boot/efi, vfat), /boot (ext4), LUKS -> Btrfs (root + /home subvols; label "fedora")
 - Network: Broadcom BCM4364 Wi-Fi, Broadcom BCM57766 GbE
 - Thunderbolt: Titan Ridge + Alpine Ridge controllers present
 
 (Codex, 2026-02-06 00:17 EST)


### Available Hardware/Software

The following are hardware, software, or systems that we have at our immediate disposal. I would prefer not to purchase anything, as it is night time and I'd like the system to be ready for school in the morning. Thus, assume this is *all* we have, and that I am not listing minutia like what cables are connected where (unnecessary for this project). The stuff:

- Hardware
    - Mac Mini
        - See "System Specs" above for full details. (Codex, 2026-02-06 00:17 EST)
    - 64GB USB drive
        - needs formatting, has fedora live WS on it, but so does the bigger Ventoy drive below
        - this is tentatively what we will backup our system to, as it appears my entire OS + all downloaded / created data is about 30-40GB (I also trust Sandisk more than Gigastone, maker of next item)
    - 256GB usb drive
        - has Ventoy, with Fedora live WS, as well as rescuezilla, ubuntu-server, debian, and a few others. 
        - preferably we use this as-is, but if extra space is needed we can swap the 64GB and 256GB drives' roles, as there is only about 40GB on the bigger one.
    - Macbook Pro, 2020
        - this can be used for ssh, testing backups, etc. It's a mac. We may NOT wipe this one, though.
    - 2TB external SSD
        - this is the only external drive I have larger than the 256GB USB drive
        - It is currently connected to NAS system, would prefer not to use if unnecessary - only necessary if encryption prevents us from creating a usable backup and we need to simply clone the entire system.
        - See "trueNas" in software section for more
    - 5TB external HDD
        - See "trueNas" in section below.

- Software
    - backups are handled with the script at path '/home/tdj/bin/rsync_to_truenas.sh'
        - this is executed via taskbar shortcut for application "TrueNAS Backup Now"
        - said application is titled "truenas_backup" (not sure exactly where it is)
        - application (not the script itself) runs the following:
        ```
        -e bash -lc '$HOME/bin/rsync_to_truenas.sh; echo; echo '\''Done. Press Enter to close...'\''; read'
        ```
        - double check all of that for specificity, correct where needed, but the gist is that there's a shortcut leading to an application that utilizes the .sh script above
        - The script sends backups to dataset on a local NAS, running TrueNAS
        - **UNLESS WE DECIDE OTHERWISE, "BACKUP" REFERS TO A FINAL "complete" BACKUP MADE USING THIS SETUP**
    - Ventoy with fedora live workstation and rescuezilla
        - as previously mentioned, the 256GB usb drive is configured with Ventoy and has quite a few .iso's. If possible, we will either produce a .iso that it can load from my backups, or we will use one of its OS's to load our backup. 
        - rescuezilla is semi-tested... as in I got it to begin a backup, but it was 450GB and estimated to take 2hrs, so I stopped it 2% done. Rescuezilla may be considered our backup backup here.
    - TrueNAS
        - there is an external computer on the local network running ProxMox with TrueNAS and Tailscale. The tailscale node is broken, but truenas is working fine, and is its main purpose. 
        - this is where the backups go, to dataset on "veyDisk" titled fedoraBackups. The script uses SSH and rSync to make backups. I likely need not explain the script to you, since the path was provided. "veyDisk" is the name for the 2TB external SSD that we may need to use if neither the 64 nor 256 gb usb drives suffice. 
        - The other disk on the nas is titled "oyPool" and it is a 5tb *3.5in hard drive*. Hence, more valuable data is stored on the 2TB "veyDisk", but because the 5tb disk has thus far been unproblematic, I am fine temporarily transferring the contents of veyDisk to oyPool in order to use it as an external drive for the mac mini.
        - due to read/write speed, the 5tb disk is not an option for the final installation spot for Fedora.
    - MacOS
        - as previously mentioned, I have a 2020 Macbook Pro (intel). I also have a rather old (2015) Razer Blade that we can test the backups on (as in loading the os + restoring from backup). I'd prefer to use the razer, but if no data is being installed on the internal storage >60GB the Mac is fine. 
        - *the* system we are using is a mac mini 2018, and its BIOS is thus (seemingly - haven't tested) capable of reinstalling MacOS. 
    - {Fill in any other software you feel is relevant here}
- *Systems*
    - this is less of an inventory and more of a description of my setups
    - The mac-mini is the workhorse and subject of our project 
        - running fedora currently. 
        - It is connected to ethernet, as well as a Dell WD19 hub, connecting it to the mouse, keyboard, two monitors, and the ventoy 256 usb drive. 
        - The 64gb is plugged in directly. 
        - A thunderbolt DP monitor is connected (three displays total), along with another USB hub in the thunderbolt ports. There is an open thunderbolt port on the mac itself, as well as the dell hub. There is one on the usb hub but not to be relied on.
    - homelab
        - the homelab is crippled at the moment as I've been too lazy to activate the other two nodes (older razer and ancient macbook air)
        - it is currently just the 2017 razer blade running proxmox, which runs trueNAS. This is connected to a smart switch by ethernet, as is the mac-mini, which connects both to the internet via ethernet port on the wall. The, modem/main router is inaccessible at this hour (someone is sleeping in the room it is in)


### How to Read My Writing

#### How to read the "Problems" Section

The problems section will describe, in the order in which they need solving, the various "problems" involved in achieving our goal - where I mean "problems" in the sense of "exam problems" more than this is a currently problematic issue. However it may be. Due to the ambiguity of a general "to-do" list, I will do my best to mark my writing with the following tags:

- **General Definitions**:
    - **priority** - When I write "priority" I mean importance to the project, to me. I do not mean it is to be done in any specific order.  
        - In other words, high priority means that *I value* the results and the problem must be solved or task must be done in order for the project to meet expectations. 
        - When I do not specify priority, decide for yourself
        - If I specify *low priority* (either explicitly somewhere, or a tag indicates as such), then we may consider something to be unimportant to the final result.
        - For example...
            - ...backup integrity is of *high priority* to me because I am quite happy with my Fedora KDE Plasma setup as-is, and do not wish to reinstall everything. 
            - ...of *low priority* is the efficiency of my truenas backups since that system is another project entirely, and tonight is not a great time to learn networking.
    - You may interpret instructions "creatively" only where they are not explicitly stated. Example: If I say "X is Y" that means that "X is always Y" but that does not mean "X is not Z". 
        - Think "all squares are rectangles" - you would not give me a 3x5in rectangle if asked for a square, but may give me a 3x3in square if asked for a rectangle. 
        - **In general, assume that despite my inexperience with Linux and system administration, that I am very good at choosing my words.** Fun fact, since you are a language model at heart: I was raised by two lawyers. Specificity is like my sixth sense. 


### How You (Codex) Are to Write

- please mark changes to this document or the log with (Codex, [date and time added]). No need to overuse. If you, for example, write a long paragraph or add a large code block, and then explain said codeblock, a simple (codex, time/date) somewhere around there would help. 
- Do not assume that I know anything other than the most basic of linux principles. I am very new to this, please explain what you are doing concisely, but do not prioritize explanations. For example, if you write "added ~/tdj/xyz to backup" do not assume I know what that directory is. Additionally I know **fuck-all** about BIOS and low-level systems, so please be sure to keep me informed.
- Assume that my writing is always properly phrased, but recall that I am a human who just took his (prescribed) Klonopin for bedtime. (You can tell it's getting later as I write. Assume I wrote this top to bottom in chronological order, and scrutinize appropriately)

## Problems 

### Problem 1 - PLANNING, BACKUP AND TESTING

#### preliminary

We must first determine *how* we will get macOS back on this mac mini. Most likely method is via recovery, so the reinstallation is likely to wipe the entire internal storage, as well as use the entire internal storage itself. 

Target macOS size (if reinstall does not require a full wipe): **200 GB** to cover OS + Office + 100 GB spare. (Codex, 2026-02-06 06:25 EST)

#### Tasks

1. Answer the following preliminary questions:
- Is installing MacOS via recovery mode our only option (that does not involve purchasing a new copy of it)? **If not, stop work and discuss**
    - I have another Mac on hand (2020 Macbook Pro) - would it help?
- Answer the following if recovery mode is our best or the most feasible method of installing macos:
    - When installing MacOS from recovery mode, *must* we wipe the entire disk?
    - When installing MacOS from recovery mode, *must* it use the entirety of the internal storage?

2. Testing backup
    2.1 Make complete backup using script method (mentioned in software)
    2.2 Test this backup somehow. TBD. I assume via rescuezilla or fedora workstation. Need advice here.
    2.3 Determine whether backup is sufficient to restore fully functional "copy" of my current system.
        2.3.4 If backup is insufficient, determine new method, return to 2.2. Otherwise proceed to 2.3.5
        2.3.5 If backup and restore work to our liking, determine whether dualboot requires any installations PRIOR to MacOS install. If yes, do so now.

### Problem 2. Reinstallation of MacOS

#### preliminary

DO NOT PROCEED TO THIS STEP UNTIL WE ARE CERTAIN THE BACKUP WORKED

#### tasks

1. Reinstall MacOS
    1.1 CONFIRM BACKUP WAS MADE. CODEX WILL CEASE FUNCTION AT THIS POINT. using method determined in task 1, reinstall MacOS on system. 
    1.2 Codex will no longer function on this system, so it will be opened remotely. I will enter what I am doing by hand - (unless you have an easier idea)
2. configure MacOS (TBD - this may involve making the space we need for fedora on the internal storage, or simply configuring it as usual and rebooting...)
3. This step is complete when we have a functioning MacOS installation on this system.

### Problem 3 - DualBoot Fedora KDE Plasma

#### preliminary

Not sure whether codex may be installed again at this step, but will try if possible. I don't think it can on intel macs unless something has changed.

#### tasks

1. Configure Dualboot and Reinstall Fedora
    1.1 If dualboot system was previously configured, skip. Otherwise, determine now how to dualboot fedora with macos. I will determine which OS gets how much space and where.
    1.2 If necessary install blank slate Fedora KDE Plasma
2. Restore from backup
   
