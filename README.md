# wl-topo-legacy-toolkit

Private maintenance and recovery notes for a legacy WaveLight Topolyzer / DIS workstation running Windows 7 Embedded.

**Author:** Victor Schnor <victorschnor@gmail.com>  
**GitHub:** `victorhs2`

## Purpose

This repository documents the system behavior, restrictions, startup chain, network-drive handling, and recovery procedures that were experimentally established on one legacy WaveLight Topolyzer workstation.

Its main practical goal is:

> Make it possible to reconfigure the workstation later without repeating the full reverse-engineering process.

The tested production customization is a network-drive mapping for the standard `LASIK` Windows user. The mapping is established during the existing WaveLight startup sequence and uses a credential already stored in the `LASIK` Windows Credential Manager. No password is stored in the production mapping script.

## Start here

1. Read [`docs/QUICKSTART.md`](docs/QUICKSTART.md).
2. For the tested network-drive workflow, read [`docs/NETWORK-DRIVE-MAPPING.md`](docs/NETWORK-DRIVE-MAPPING.md).
3. For the complete technical model of the machine, read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).
4. For policy details, read [`docs/GROUP-POLICY-NOTES.md`](docs/GROUP-POLICY-NOTES.md).
5. For failures and diagnostics, read [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md).

## Repository layout

```text
wl-topo-legacy-toolkit/
├── README.md
├── .editorconfig
├── .gitattributes
├── .gitignore
├── docs/
│   ├── QUICKSTART.md
│   ├── ARCHITECTURE.md
│   ├── NETWORK-DRIVE-MAPPING.md
│   ├── GROUP-POLICY-NOTES.md
│   ├── TROUBLESHOOTING.md
│   └── SOURCES.md
├── scripts/
│   ├── MapNetworkDrive.cmd
│   └── NetworkDriveDiagnostics.cmd
├── samples/
│   ├── BootstrapNetworkCredential.example.cmd
│   └── UserInit.integration.example.txt
└── tools/
    └── InspectRegistryPol.ps1
```

## Safety and scope

This was tested on one specific legacy workstation. The exact Topolyzer hardware revision and DIS software version were not confirmed.

This repository intentionally does **not** contain passwords or service credentials.

Before changing the system:

- keep an offline copy of the original WaveLight startup scripts;
- use the `TECHNIK` Windows account for maintenance;
- avoid changing Group Policy unless it is truly necessary;
- prefer additive, reversible changes;
- do not alter the vendor `WLconnectDrvW.cmd` mapping logic;
- test changes with the normal `LASIK` startup path before considering them production-ready.

No public software license is attached to this repository.
