# Sources and Evidence

This repository is based on a combination of vendor documentation and direct experiments on the workstation.

No vendor manual is redistributed in this repository.

## Vendor documentation consulted during the investigation

### WaveLight Oculyzer II Service Manual

A WaveLight Oculyzer II service manual from the same general product generation documented:

- Windows maintenance-user behavior;
- application service login behavior;
- a service workflow that can disable Windows shutdown on application exit;
- network configuration concepts;
- WaveNet integration.

Some service credentials documented there were experimentally accepted by the Topolyzer environment.

Because the document is for a related product rather than a confirmed exact Topolyzer revision, those details were treated as clues and then validated experimentally.

Passwords are intentionally omitted from this repository.

### ALLEGRETTO WAVE EYE-Q Service Manual

A service manual from a WaveLight laser of the same broader generation demonstrated that WaveLight products of that era used hidden / service-specific startup paths and service-mode controls.

It was useful historical context but is not the basis of the final mapping implementation.

### Topolyzer operating documentation

A Topolyzer manual established the existence of deeper service / system configuration layers and the expected WaveNet / removable-media architecture.

The exact Topolyzer service manual matching this workstation was not located during the project.

## Direct workstation evidence

The final architecture was established through:

- Windows user comparison;
- command-line output;
- `gpresult`;
- SID enumeration;
- raw `Registry.pol` inspection;
- startup script inspection;
- network-mapping tests;
- Credential Manager comparison;
- read/write SMB tests;
- USB export tests;
- DIS export tests.

## Experimental findings with highest confidence

The following were directly demonstrated on the workstation:

- Windows 7 SP1 / Embedded generation;
- LASIK and TECHNIK local users;
- MLGPO policy files;
- LASIK `NoDrives = 15`;
- LASIK `NoViewOnDrive` absent in the inspected `.pol`;
- USB visible as E:;
- `UserInit.cmd` startup orchestration;
- `WLconnectDrvW.cmd` vendor W: mapping logic;
- custom H: mapping visible to DIS;
- per-user SMB credential differences;
- read-only SMB access can cause DIS export failure;
- correct LASIK SMB write credential enables successful DIS export;
- production custom mapping can run without hardcoded credentials.
