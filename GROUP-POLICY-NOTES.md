# Group Policy Notes

## Summary

The workstation uses Multiple Local Group Policy Objects (MLGPO).

Policy is one part of the appliance lockdown, but it is not the entire lockdown. Vendor startup scripts and helper executables also shape the LASIK environment.

## Relevant locations

General Local Group Policy:

```text
C:\Windows\System32\GroupPolicy\
```

Per-user Local Group Policy:

```text
C:\Windows\System32\GroupPolicyUsers\
```

Typical policy files:

```text
C:\Windows\System32\GroupPolicy\Machine\Registry.pol
C:\Windows\System32\GroupPolicy\User\Registry.pol
C:\Windows\System32\GroupPolicyUsers\<SID>\User\Registry.pol
```

## Known SIDs on the tested workstation

```text
LASIK   -> S-1-5-21-1711651294-2711305044-341736250-1000
TECHNIK -> S-1-5-21-1711651294-2711305044-341736250-1001
```

These are machine-specific.

To identify accounts on another image:

```cmd
wmic useraccount get name,sid
```

## Why normal Group Policy tools were not used

Under TECHNIK:

```text
gpedit.msc -> Access denied
rsop.msc   -> Access denied
reg query  -> Registry editing has been disabled by your administrator
```

Therefore the investigation used direct read-only inspection of `Registry.pol`.

## LASIK `NoDrives`

The LASIK policy contains:

```text
NoDrives
```

Decoded value:

```text
0x0000000F
```

Meaning:

```text
A: hidden
B: hidden
C: hidden
D: hidden
```

E: and later letters are not hidden by this value.

This matched observed behavior:

- C: and D: do not appear normally to LASIK;
- USB on E: is visible;
- H: is visible when mapped.

## `NoViewOnDrive`

The inspected LASIK policy did not contain:

```text
NoViewOnDrive
```

That was directly checked in the policy file.

This was important because it showed that the custom H: drive was not globally blocked by that policy.

## Other policy names observed

The LASIK policy included restrictive entries such as:

```text
NoRun
NoSetFolders
NoUserFolderInStartMenu
DisallowRun
DisableRegistryTools
DisallowCpl
```

These are consistent with the appliance-style user experience.

However, the exact policy responsible for every hidden file, hidden shortcut, or blocked shell action was not fully attributed.

## Read-only inspection helper

See:

```text
tools\InspectRegistryPol.ps1
```

It is intentionally a read-only helper.

It can:

- check whether a Unicode policy name exists in a `.pol` file;
- report the byte position;
- dump nearby bytes for manual inspection.

It does not modify Group Policy or the Registry.

## Example usage

```powershell
.\InspectRegistryPol.ps1 `
  -Path "C:\Windows\System32\GroupPolicyUsers\<LASIK-SID>\User\Registry.pol" `
  -Needle "NoDrives"
```

## Caution

Do not edit `Registry.pol` merely to make maintenance easier.

The successful network-drive solution did not require changing LASIK policy.

Preserving the original lockdown reduces the chance of disturbing the medical-device workflow.
