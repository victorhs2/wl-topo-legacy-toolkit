# Troubleshooting

## First rule

Do not start by changing Group Policy.

The tested network-drive solution works while preserving the original LASIK lockdown.

## 1. H: is not visible in DIS

Check the latest LASIK mapping log:

```text
C:\Users\LASIK\AppData\Local\Temp\WaveLight_MapH.log
```

or equivalently:

```text
%TEMP%\WaveLight_MapH.log
```

when running as LASIK.

Remember that TECHNIK and LASIK have separate per-user mapping state.

## 2. Mapping log says all retries failed

Possible causes:

- network not ready;
- server unreachable;
- share path changed;
- stored LASIK credential is missing;
- stored LASIK credential is wrong;
- SMB server unavailable.

Run:

```text
scripts\NetworkDriveDiagnostics.cmd
```

## 3. H: is visible and readable, but DIS export fails

Do not assume DIS has a drive-letter restriction.

This exact symptom occurred during the project when the LASIK SMB credential had read access but no write access.

Test actual writing:

```cmd
echo test > "%TEMP%\WL_LOCAL_TEST.txt"
copy /Y "%TEMP%\WL_LOCAL_TEST.txt" "H:\WL_WRITE_TEST.txt"
md "H:\WL_WRITE_TEST_DIR"
```

If either remote operation returns:

```text
Access is denied.
```

inspect the LASIK credential.

## 4. Compare stored credentials

Under the relevant Windows user:

```cmd
cmdkey /list
```

Important:

> The credential shown under TECHNIK can differ from the credential stored under LASIK.

This difference was the decisive issue in the original project.

## 5. Read works, write fails

Likely causes:

- wrong SMB identity;
- a credential with read-only server permissions;
- credential target mismatch;
- server-side share / NTFS permissions.

Before changing server permissions, compare the identity used by a known-working Windows user.

## 6. `ping` fails but SMB works

Observed behavior:

```text
PING: transmit failed. General failure.
```

while:

```text
net use
dir H:\
```

worked.

Do not use ping as the only test of SMB availability on this workstation.

The production script retries `net use` directly.

## 7. USB works but custom network mapping does not

USB normally appears as E: and works under LASIK.

Do not immediately conclude that DIS only accepts removable drives.

In the original investigation, the network drive also worked after the SMB write credential was corrected.

## 8. C: and D: are missing under LASIK

Expected.

The LASIK `NoDrives` policy was decoded as:

```text
0x0000000F
```

which hides A-D.

Do not remove this policy merely to expose a custom drive.

Use E: or a later letter such as H:.

## 9. `reg query`, `gpedit.msc`, or `rsop.msc` fail under TECHNIK

Also expected on the tested image.

The TECHNIK account is privileged but still policy-restricted.

For read-only policy inspection, use the policy files directly and the helper in:

```text
tools\InspectRegistryPol.ps1
```

## 10. The application starts before the custom drive is ready

Verify the custom call is placed before:

```cmd
call :UserSetup
```

Recommended order:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

The production mapper already retries six times.

## 11. The log grows indefinitely

The production and diagnostic scripts in this repository overwrite their logs.

The first write uses:

```cmd
>"%LOG%"
```

to truncate the previous log.

## 12. Need to restore original behavior

As TECHNIK:

1. remove the custom call from `UserInit.cmd`;
2. restore the backed-up original `UserInit.cmd` if necessary;
3. leave `WLconnectDrvW.cmd` unchanged;
4. reboot and verify the normal LASIK startup.

The custom mapping design is additive and does not require altering vendor Group Policy.
