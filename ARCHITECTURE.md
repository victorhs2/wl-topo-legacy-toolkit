# Topolyzer Legacy Workstation Architecture

## 1. Scope

This document records the working technical model established while investigating one legacy WaveLight Topolyzer workstation.

The exact Topolyzer hardware revision and exact DIS software version were not confirmed. All conclusions below are therefore divided into:

- **What we learned**
- **How we established it**

The goal is not to reconstruct every internal WaveLight design decision. The goal is to preserve enough verified knowledge to maintain or recover this workstation later.

---

## 2. Operating system and workstation role

### What we learned

The workstation runs Windows 7 Embedded / Windows 7 SP1. A command prompt reported:

```text
Microsoft Windows [Version 6.1.7601]
```

The system is configured as a highly restricted appliance rather than a general-purpose PC.

The normal operating experience is:

1. Windows starts.
2. The standard user is logged in.
3. Vendor startup logic prepares the WaveLight environment.
4. The DIS / Topolyzer software takes over the screen.
5. Ordinary Windows shell access is intentionally restricted.

### How we established it

Direct Windows access was initially unavailable. Standard escape methods such as `Ctrl+Alt+Del`, `Ctrl+Shift+Esc`, `Alt+F4`, `Win+R`, `Win+E`, and related shortcuts did not provide useful access from the normal operating session.

A native Windows folder-selection dialog exposed parts of the filesystem, which demonstrated that Windows Explorer components were present but controlled.

Later, maintenance access was obtained through the vendor's service / maintenance path.

---

## 3. Windows users

### What we learned

The machine has at least two important Windows users:

- `LASIK`
- `TECHNIK` / Technician

The observed local SIDs on the tested workstation were:

```text
LASIK   -> S-1-5-21-1711651294-2711305044-341736250-1000
TECHNIK -> S-1-5-21-1711651294-2711305044-341736250-1001
```

These SID values are machine-specific and must not be assumed to be identical on another image or workstation.

### LASIK

`LASIK` is the normal operational Windows user.

Its environment is intentionally locked down:

- no ordinary Windows desktop workflow;
- no useful interactive CMD access;
- no normal Explorer workflow;
- many executables and shortcuts are hidden or blocked;
- the WaveLight application is started automatically;
- taskbar / Start interaction is suppressed.

### TECHNIK

`TECHNIK` is the maintenance Windows user.

Important nuance:

> TECHNIK is not an unrestricted conventional administrator desktop.

The account was observed as a member of `BUILTIN\Administrators`, and the command prompt could run at High Mandatory Level. However, several administrative tools were still blocked by policy.

Examples observed under TECHNIK:

- `gpedit.msc` -> Access denied
- `rsop.msc` -> Access denied
- `reg query ...` -> "Registry editing has been disabled by your administrator"

TECHNIK can nevertheless access normal drives, use Explorer, map network drives, copy files, and run useful maintenance commands.

### How we established it

`whoami`, `whoami /groups`, `gpresult /r`, filesystem inspection, and direct comparison of the two login environments were used.

---

## 4. Application-level service access

### What we learned

The WaveLight software has a service-level login distinct from the normal Windows user context.

The service login allowed access to deeper application settings that were unavailable to the normal application user.

No passwords are stored in this repository.

### How we established it

A WaveLight Oculyzer II service manual from the same product family documented both a Windows maintenance user and an application-level `service` login.

The documented application service login was experimentally accepted by the Topolyzer software.

Because this was learned from a related WaveLight product manual rather than a confirmed model-specific Topolyzer service manual, treat the relationship as historically useful evidence, not as a universal rule for every Topolyzer revision.

---

## 5. Multiple Local Group Policy Objects (MLGPO)

### What we learned

The workstation uses Windows Multiple Local Group Policy Objects.

There is:

- a general Local Group Policy;
- user-specific local policy material;
- a user-specific policy for TECHNIK;
- a user-specific policy for LASIK.

Observed policy storage paths include:

```text
C:\Windows\System32\GroupPolicy\
C:\Windows\System32\GroupPolicyUsers\
```

Typical files:

```text
C:\Windows\System32\GroupPolicy\Machine\Registry.pol
C:\Windows\System32\GroupPolicy\User\Registry.pol

C:\Windows\System32\GroupPolicyUsers\<SID>\User\Registry.pol
```

On the tested machine, the LASIK and TECHNIK policy files were materially larger than the general user policy file, confirming substantial per-user configuration.

### How we established it

`gpresult /r` under TECHNIK showed both:

```text
Local Group Policy
Local Group Policy\TECHNIK
```

Filesystem inspection then revealed `GroupPolicyUsers` SID-specific directories.

`wmic useraccount get name,sid` was used to associate the SID directories with LASIK and TECHNIK.

---

## 6. LASIK drive-hiding policy

### What we learned

The LASIK-specific `Registry.pol` contains:

```text
NoDrives
```

The DWORD value was decoded as:

```text
0x0000000F
```

which is decimal `15`.

For the Windows `NoDrives` bitmask:

- bit 0 = A:
- bit 1 = B:
- bit 2 = C:
- bit 3 = D:

Therefore:

> `NoDrives = 15` hides A:, B:, C:, and D:.

The LASIK policy did **not** contain `NoViewOnDrive`.

This is a key distinction:

- the system hides A-D from normal drive presentation;
- the specific policy inspected did not globally block access to all other drives.

This explains why:

- local C: and D: are hidden in the LASIK user experience;
- a USB flash drive appearing as E: is visible;
- a custom mapped H: drive can also be visible.

### How we established it

Because Registry tools were blocked, the raw LASIK `Registry.pol` was read from disk using PowerShell.

The binary file was searched for the Unicode string `NoDrives`. A manual hex inspection of the PReg entry showed:

- type: `REG_DWORD`
- data length: 4 bytes
- value: `0F 00 00 00`

A separate string test confirmed:

```text
NoViewOnDrive -> False
NoDrives      -> True
```

---

## 7. Other LASIK restrictions

### What we learned

The LASIK policy contained several additional restrictive policy names, including items such as:

```text
NoRun
NoSetFolders
NoUserFolderInStartMenu
DisallowRun
DisableRegistryTools
DisallowCpl
```

The system also exhibited these operational behaviors:

- shortcuts to `notepad.exe` and `cmd.exe` could disappear from a folder visible to LASIK;
- LASIK could navigate portions of the directory tree but ordinary files were not normally exposed in the same way;
- Registry tools were blocked;
- shell access was tightly controlled.

### Important limit

The exact individual policy responsible for every visible shell behavior was **not** exhaustively mapped.

Do not assume that one specific policy above explains every file-hiding or shell-hiding effect.

Some restrictions are implemented by policy, while others are implemented by vendor startup software.

### How we established it

The policy names were extracted from the LASIK `Registry.pol`.

Behavioral observations were made through the WaveLight file dialog and temporary test shortcuts.

---

## 8. The startup chain

### What we learned

The standard Windows Startup folders were empty.

The important startup path is policy-driven.

The general user policy contains an Explorer Run entry that invokes:

```text
C:\Users\Default\Scripts\UserInit.cmd
```

This script is a WaveLight / Alcon startup script.

The script header identifies it as a user-specific startup configuration script for WPS / DIS notebooks, with a WaveLight/Alcon history extending across multiple revisions.

The high-level flow observed in the script is:

```cmd
call :OptRollBack
call :CheckPartitionSpace
call :ServerActions
call :UserSetup
```

### How we established it

The general `Registry.pol` was read as Unicode strings.

The following path appeared in the policy material:

```text
C:\Users\Default\Scripts\UserInit.cmd
```

The script was then read directly under TECHNIK.

---

## 9. `UserInit.cmd`

### What we learned

`UserInit.cmd` is the main vendor startup orchestrator relevant to this project.

Important responsibilities observed:

- optional rollback / WaveLight helper startup;
- disk-space checks;
- server-related startup actions;
- user-specific setup;
- launching WaveLight applications;
- suppressing the ordinary Windows shell for LASIK.

### Server discovery

The script checks WaveLight configuration material such as:

```text
C:\WaveLight\Wickie\Wickie.ini
C:\WaveLight\DIS.ini
```

If no other configured server is available, legacy logic uses a WaveLight-network default in the `192.168.5.x` range.

### Network readiness

The script history contains a change specifically intended to ensure that the network is available before server actions start.

This is consistent with the observed boot-time network behavior: SMB could work even when an immediate ICMP ping failed.

### LASIK-specific setup

Within `:UserSetup`, logic is conditioned on:

```cmd
if [%username%] == [LASIK] (
    ...
)
```

The LASIK branch starts WaveLight components such as Wickie / DIS.

It also invokes:

```text
killStart.exe
```

with a comment indicating that it disables the taskbar / Start environment.

### How we established it

The full script was inspected under TECHNIK using PowerShell / CMD.

---

## 10. `WLconnectDrvW.cmd`

### What we learned

The vendor script:

```text
C:\Users\Default\Scripts\WLconnectDrvW.cmd
```

is responsible for establishing the WaveLight network drive `W:`.

The key architectural point is:

> W: is actively created during startup; it is not merely a remembered Explorer mapping.

The script includes:

- server-availability checks;
- deletion of a previous W: mapping;
- recreation of W:;
- vendor authentication logic;
- time synchronization against the WaveLight server.

The current runtime state on the tested workstation showed the legacy W: mapping associated with:

```text
\\192.168.5.1\VDisc
```

The old WaveNet endpoint was often unavailable in the present clinic network.

### Security note

The vendor script contains vendor-supplied authentication material.

This repository does not reproduce those credentials.

### How we established it

The script was read directly.

`net use` output was also collected under LASIK and TECHNIK.

---

## 11. Why the custom mapping belongs in the startup chain

### What we learned

A network drive mapped manually under TECHNIK does not automatically exist in the LASIK user context.

Windows network mappings and Windows Credential Manager entries are user-specific.

A remembered mapping can also appear as disconnected until something actively accesses it.

Therefore, for a reliable DIS startup:

> the custom mapping must be established inside the LASIK logon context before DIS starts.

### Tested integration point

The custom script call was inserted:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

This preserves the vendor order:

1. WaveLight server actions;
2. custom mapping;
3. LASIK application startup.

### How we established it

A mapping created under TECHNIK was not usable as a ready-to-write mapping by LASIK.

A mapping created by a custom script running inside the LASIK startup context was visible to the DIS file dialog.

---

## 12. USB behavior

### What we learned

A USB flash drive is accepted by the workstation and is normally assigned:

```text
E:
```

Under LASIK:

- E: is visible;
- examination export to the USB drive works.

This behavior is fully consistent with:

```text
NoDrives = 15
```

because E: is outside the hidden A-D range.

### How we established it

A physical USB drive was inserted and used to export examinations successfully.

---

## 13. DIS and mapped network drives

### What we learned

DIS can display a custom mapped network drive in its export dialog.

A custom H: mapping to a normal SMB share was visible.

At one stage, DIS export failed even though:

- H: existed;
- H: could be read;
- files on H: could be listed by the startup script.

The failure was initially suspicious because the DIS error message did not resemble a simple Windows mapping error.

However, later testing proved the real cause:

> the LASIK SMB credential could read the share but could not write to it.

Once the correct writable SMB credential was stored under LASIK:

- H: remained visible;
- LASIK could create files;
- LASIK could create directories;
- DIS successfully exported examinations to H:.

Therefore:

> the tested DIS version is capable of exporting to the custom mapped network drive.

No special drive-letter exception was required.

### How we established it

The investigation progressed through these stages:

1. map H: under LASIK;
2. verify `net use H:` -> Status OK;
3. verify `dir H:\` -> successful;
4. observe DIS export failure;
5. test write operations with `copy` and `mkdir`;
6. observe explicit `Access is denied`;
7. compare stored SMB credentials under TECHNIK and LASIK;
8. replace the LASIK stored credential;
9. repeat write tests;
10. verify file and directory creation on the server;
11. repeat DIS export;
12. export succeeded.

---

## 14. SMB credentials: the critical discovery

### What we learned

The same SMB server had different stored Windows credentials under different Windows users.

Under TECHNIK, the working credential was associated with one account.

Under LASIK, a different credential was initially stored.

The initial LASIK credential:

- allowed directory listing;
- did not allow file creation;
- did not allow directory creation.

The correct writable credential:

- allowed mapping;
- allowed reading;
- allowed `copy`;
- allowed `mkdir`;
- allowed DIS export.

### Important rule

> Never assume that a credential stored under TECHNIK is available to LASIK.

Credential Manager state is per user.

### Production design

The final production mapping script contains **no username or password**.

It relies on a credential already stored under the LASIK profile.

### How we established it

`cmdkey /list` was run in both user contexts.

The two users showed different credentials for the same server address.

A one-time credential bootstrap under the LASIK startup context solved the write problem.

---

## 15. Why ping is not used as the production gate

### What we learned

During several successful SMB sessions, this command failed:

```text
ping 192.168.25.145
```

with:

```text
PING: transmit failed. General failure.
```

At the same time:

- `net use` succeeded;
- `dir` succeeded;
- file creation later succeeded.

Therefore ICMP reachability is not a reliable proxy for SMB readiness on this workstation.

### Production design

The final custom mapping script simply attempts the `net use` operation repeatedly.

It retries up to six times with one-second delays.

### How we established it

Boot-time logs repeatedly showed failed ping followed by successful SMB access.

---

## 16. Logging strategy

### What we learned

The workstation should not accumulate indefinite diagnostic logs.

The production script therefore:

- uses a small text log in `%TEMP%`;
- overwrites the previous log on every LASIK login;
- records only the latest mapping attempt.

This is sufficient because the intended recovery workflow is:

1. observe a LASIK failure;
2. log in as TECHNIK;
3. inspect the latest log immediately.

### Tested log path

```text
%TEMP%\WaveLight_MapH.log
```

When run as LASIK this resolves inside the LASIK profile.

---

## 17. Final tested custom architecture

```text
Windows 7 Embedded
        |
        v
LASIK automatic login / restricted user environment
        |
        v
Local Group Policy / Explorer Run
        |
        v
C:\Users\Default\Scripts\UserInit.cmd
        |
        +--> WaveLight checks / server actions
        |
        +--> C:\WaveLight\Custom\MapH.cmd
        |       |
        |       +--> remove stale H:
        |       +--> net use H: \\server\share
        |       +--> use credential already stored for LASIK
        |       +--> retry on failure
        |       +--> overwrite one small log
        |
        +--> :UserSetup
                |
                +--> Wickie / DIS
                +--> killStart.exe
                +--> restricted operational UI
```

---

## 18. Confirmed current tested values

These values describe the workstation at the end of the project and are not universal defaults:

```text
Computer name: TOPO020
Operational Windows user: LASIK
Maintenance Windows user: TECHNIK
Custom drive: H:
Custom SMB share: \\192.168.25.145\Topolyzer
USB drive letter: E:
Legacy WaveLight drive: W:
Observed legacy W endpoint: \\192.168.5.1\VDisc
```

No password is recorded here.

---

## 19. Things deliberately not changed

The successful solution did **not** require:

- disabling the LASIK Group Policy lockdown;
- changing `NoDrives`;
- adding `NoViewOnDrive`;
- enabling Explorer for LASIK;
- enabling CMD for LASIK;
- changing the vendor W: script;
- replacing DIS;
- changing the USB behavior;
- making LASIK an administrator.

This is important for future maintenance:

> prefer the smallest additive change that preserves the original appliance model.

---

## 20. Open questions and future investigation

### Exact product/software revision

The exact Topolyzer model revision and exact DIS / examination software version were not confirmed.

### Complete LASIK policy map

Only the policies relevant to this investigation were inspected.

A full semantic decode of every entry in the LASIK `Registry.pol` was not performed.

### File visibility behavior

LASIK could navigate some folder trees while ordinary files or executable shortcuts were not presented normally.

The exact combination of Group Policy settings and vendor shell behavior responsible for every aspect of this behavior remains unresolved.

### `killStart.exe`

Its role is strongly indicated by the startup script comment, but the executable itself was not reverse-engineered.

### Wickie

Wickie configuration participates in server discovery / startup behavior, but its internal architecture was not explored.

### Legacy WaveNet W:

The original W: path is part of the WaveLight design but the historical WaveNet server was not the target of this project.

### Boot-time ICMP failure

SMB worked while ping failed with "General failure."

The exact Windows networking component causing this difference was not investigated because it did not block the final solution.

### Full disaster recovery

A full disk-image backup / restoration procedure for the embedded workstation was not developed.

That would be a valuable future addition.
