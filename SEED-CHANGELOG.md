# Changelog

All notable changes to ClrSeed will be documented in this file.
This project adheres to [Semantic Versioning][].

Due to big amount of breaking changes in each release, this project uses two version schemas:
Internal and Semantic.

| Internal Version | Semantic Version |
|:----------------:|:----------------:|
| 2.10.5           | 210.5.0          |
| 1.5.10           | 105.10.0         |

## [unreleased][]
### Added
### Breaking Changes
### Fixed

## [0.1.1][] - 19/03/2019
### Added
* `scripts/ensure-deps.ps1` - automated scripts environment checker/fixed.
* PSSolutions based scripts dependencies auto download.
* VCS Checks:
    - **no-relative-issues-refs** Github issues relative refs in commits are prohibited.
* Envoronment Checks:
    - **PowerShell** >= 5.1
    - **PowerShellGet** >= 1.6.0 (With fix script `script/ps-environment.ps1 -Fix`), fixes https://github.com/ClrCoder/ClrSeed/issues/38
* `scripts/ensure-deps.ps1` script that checks and prepare all prerequisites for `scripts/*` (See https://github.com/ClrCoder/ClrSeed/issues/39).
### Breaking Changes
### Fixed

## [0.1.0][] - 03/03/2019
### Added
*   Documentation files:
    - `docs/tools/hg-git.md` - describes TortoiseHG/mercurial experience to work with this repository
*   Environment Checks:
    - **Node.JS** >=8.0
    - **.Net Core** >= 2.1
*   Repository Rules (checked on each commit):
    - dotnet
        - **sln-vs-version** - solution version must be totally the same as minimal solution version
        - **sln-no-anycpu-configurations** - ensures that solution contains only concrete (x86 or x64) target platforms in solution configurations. (VS always adds AnyCPU configurations which are irrelevant for most of projects)
    - Text
        - **eclint** - text files encoding (including BOM), trailing white-spaces, CRLF/LF at the end of a file, tab/spaces and indents according to .editorconfig settings
*   Editors support:
    - Visual Studio >= 2017
*   Seed dotnet solution
    - ClrSeed.sln - solution file
    - `build/build.ps1` - script for full solution build with modes: 'Dev', 'CI', 'PrePush'
    - Sample .Net Standard 2.0 project with one C# file that comply with all conventions
    - StyleCop Analyzers tool (through Directory.Build.props)
    - R# Team-Shared configuration
    - `build/clean-pkg-cache.ps1` - cleans all project.assets.json (sometimes it helps to resolve problems of dotnet restore)
*   `pre-push.ps1` - helps to prepare your contribution to comply with all repository rules
*   `azure-pipelines.yaml` - CI build configurations (Windows and Linux)
*   `build/environment-check.ps1` - verifies execution environment satisfies all requirements of scripts and tools from this repository
*   `.editorconfig` root file
*   Common scripts that are based on a mixture of Node.JS and PowerShell
    - `gulpfile.ts` - eclint-fix, eclint-check tasks and repo-search.ps1 backend.
    - `fast-npm-update.ps1` - Helps skip npm update if nothing has changed in the package.json
    - `repo-search.ps1` - Helps to search across repository files with gulp globbing pattern and repo status mask (a - added, m - modified, c - unchanged, ? - unknown, ! - ignored)
    - `sln-vsversion.ps1` - tool to workaround "Visual Studio Version" drift in the *.sln files
    - `sln-configurations.ps1` - gets solution configurations or removes specified configurations
*   High level folders structure
```
root
│   README.md
│   .gitattributes
│   ...
└───docs                // various documentation
└───build               // build scripts, artifacts, and build output
|   └───ci                  // CI related scripts and artifacts
|   └───rules               // repository conventions and rules scripts
└───modules             // Git submodules
└───scripts             // general scripts
└───src                 // Source code
└───test                // Tests
```
*   project org files
    - SEED-CHANGELOG.md
    - README.md
    - LICENSE
*   standard git repository files and hg-git/mercurial repo files:
    - `.gitattributes`
    - `.gitignore`
    - `.hgeol`
*   Windows, Linux checkout support
*   support for using this repository through TortoiseHG/mercurial/hg-git (see [`doc/toolset/hg-git.md`](doc/toolset/hg-git.md))


### Breaking Changes
### Fixed
