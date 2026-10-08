# Network Drive Mapping

## Goal

Map a normal SMB share into the `LASIK` Windows session before DIS starts, without storing a password in the permanent mapping script.

The tested production pattern is:

```text
LASIK logon
  -> UserInit.cmd
  -> custom MapNetworkDrive.cmd
  -> H: becomes available
  -> DIS starts
  -> export works
```

## Why this must run under LASIK

Windows network mappings and Windows Credential Manager entries are per-user.

A drive mapped under `TECHNIK` is not a reliable substitute for a drive created inside the LASIK session.

Likewise, a credential stored under TECHNIK is not automatically available to LASIK.

## Files

Production script:

```text
scripts\MapNetworkDrive.cmd
```

Recommended installed path:

```text
C:\WaveLight\Custom\MapH.cmd
```

One-time credential bootstrap example:

```text
samples\BootstrapNetworkCredential.example.cmd
```

## Production script configuration

Edit only the configuration block at the top of the production script.

Example:

```cmd
set "TARGET_USER=LASIK"
set "DRIVE=H:"
set "SHARE=\\192.168.25.145\Topolyzer"
set "LOG=%TEMP%\WaveLight_MapH.log"
set "MAXTRY=6"
```

No username or password belongs in the production script.

## One-time credential bootstrap

### When it is needed

Use the bootstrap only if:

- the SMB server or username changed;
- the LASIK profile does not yet contain the correct credential;
- the mapping is readable but not writable;
- `copy` / `mkdir` fail with `Access is denied`.

### Important security rule

Do not commit a real password.

The provided file:

```text
samples\BootstrapNetworkCredential.example.cmd
```

contains placeholders only.

Recommended workflow:

1. Copy it locally to:
   `BootstrapNetworkCredential.local.cmd`
2. Edit the local copy.
3. Transfer it to the Topolyzer by USB.
4. Temporarily call it from `UserInit.cmd`, so that it runs in the LASIK context.
5. Boot once as LASIK.
6. Confirm the credential is stored.
7. Remove the bootstrap call.
8. Delete the temporary credential script from the Topolyzer.
9. Delete or securely store the local copy.
10. Never commit the `.local.cmd` file.

The repository `.gitignore` excludes `*.local.cmd`.

## Temporary bootstrap integration

A safe temporary order is:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\BootstrapNetworkCredential.local.cmd"
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

After the credential is stored and tested, remove the bootstrap line:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

## Production integration point

The tested permanent integration point in:

```text
C:\Users\Default\Scripts\UserInit.cmd
```

is:

```cmd
call :ServerActions
call "C:\WaveLight\Custom\MapH.cmd"
call :UserSetup
```

## Why the production script retries

The workstation can reach SMB even when an immediate boot-time ping fails.

The tested production script therefore does not depend on ping.

It retries the actual `net use` operation up to six times.

Default behavior:

```text
6 attempts
1 second between attempts
```

## Why `/persistent:no` is intentional

The production design recreates the mapping at every LASIK login.

It does not depend on a remembered disconnected drive becoming active later.

This makes the mapping state deterministic before DIS starts.

## Logging

The mapping log is intentionally small and non-accumulating.

Each LASIK login overwrites the previous log:

```text
%TEMP%\WaveLight_MapH.log
```

This provides a single-session recovery record without slowly filling the embedded system.

## Verifying the stored credential

A maintenance diagnostic can show credentials visible to the current user:

```cmd
cmdkey /list
```

Do not copy passwords into logs.

`cmdkey /list` displays target and username, not the password.

## Verifying the mapping

Useful checks:

```cmd
net use
net use H:
dir H:\
```

For a definitive write test:

```cmd
echo test > "%TEMP%\test.txt"
copy /Y "%TEMP%\test.txt" "H:\test.txt"
md "H:\test-directory"
```

Remove test artifacts after confirmation.

## Tested result

After the correct writable SMB credential was stored in the LASIK profile:

- H: mapped successfully;
- H: was visible in DIS;
- LASIK could read the share;
- LASIK could write files;
- LASIK could create directories;
- DIS exported examinations directly to H: successfully.
