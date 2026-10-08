# Quick Start

This document is the shortest path to reconfiguring the tested Topolyzer workstation.

For the full technical explanation, see [`ARCHITECTURE.md`](ARCHITECTURE.md).

## Known working model

- Operating system: Windows 7 Embedded / Windows 7 SP1 (`6.1.7601`)
- Standard operational Windows user: `LASIK`
- Maintenance Windows user: `TECHNIK` / Technician
- Main WaveLight startup script:
  `C:\Users\Default\Scripts\UserInit.cmd`
- Vendor WaveNet mapping helper:
  `C:\Users\Default\Scripts\WLconnectDrvW.cmd`
- Custom scripts directory used by this project:
  `C:\WaveLight\Custom`
- Tested custom network-drive letter: `H:`
- Tested custom share:
  `\\192.168.25.145\Topolyzer`
- USB flash drive behavior: normally appears as `E:`
- Production mapping script:
  `C:\WaveLight\Custom\MapH.cmd`

## Reconfiguration procedure

### 1. Log in as TECHNIK

Use the maintenance Windows user. Do not attempt to perform the installation from the restricted `LASIK` desktop.

### 2. Back up vendor files

At minimum, copy these files to both the internal backup directory and an external USB drive:

```text
C:\Users\Default\Scripts\UserInit.cmd
C:\Users\Default\Scripts\WLconnectDrvW.cmd
```

Recommended internal location:

```text
C:\WaveLight\Custom\Backup\
```

Do not edit `WLconnectDrvW.cmd`.

### 3. Copy the production mapping script

Copy:

```text
scripts\MapNetworkDrive.cmd
```

to the workstation, for example as:

```text
C:\WaveLight\Custom\MapH.cmd
```

Edit only the configuration block at the top of the script:

```cmd
set "TARGET_USER=LASIK"
set "DRIVE=H:"
set "SHARE=\\192.168.25.145\Topolyzer"
set "LOG=%TEMP%\WaveLight_MapH.log"
set "MAXTRY=6"
```

For another server, share, or drive letter, change those variables only.

### 4. Store the SMB credential in the LASIK profile

Network credentials are per Windows user.

A credential stored under `TECHNIK` does **not** automatically become available to `LASIK`.

If the correct credential is not already stored under `LASIK`, follow the one-time bootstrap procedure in [`NETWORK-DRIVE-MAPPING.md`](NETWORK-DRIVE-MAPPING.md).

Never leave a password in the permanent startup script.

### 5. Add one call to `UserInit.cmd`

In:

```text
C:\Users\Default\Scripts\UserInit.cmd
```

place the custom call **after**:

```cmd
call :ServerActions
```

and **before**:

```cmd
call :UserSetup
```

Example:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

This was the tested integration point.

### 6. Restart and use the normal LASIK workflow

Boot the workstation normally as `LASIK`.

The mapping script will:

1. run only for the `LASIK` user;
2. remove any stale mapping for the selected drive letter;
3. recreate the mapping using the credential already stored in the LASIK profile;
4. retry up to six times if the network is not immediately ready;
5. overwrite its previous log rather than append indefinitely.

### 7. Validate in DIS

Open the usual WaveLight DIS export dialog.

The mapped drive should be visible and writable.

The tested system successfully exported examinations directly to `H:` after the correct SMB credential was stored for `LASIK`.

## If it fails

Run or temporarily call:

```text
scripts\NetworkDriveDiagnostics.cmd
```

Then inspect:

```text
%TEMP%\WaveLight_NetworkDiag.log
```

The log is overwritten each run.

See [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md).
