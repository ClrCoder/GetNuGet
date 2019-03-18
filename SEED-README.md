# ClrSeed
## Introduction
This is the dev-workflows infrastructure template for a .Net based software project.  

For a new project - fork this repo and start your new project!  
For an existing project - merge this repo!

Then receive new features through merging of commits from this repo.

#### Supported Operating Systems
* Windows >= 10
* Linux (PowerShell Core 6.0+ should be installed)

#### Supported Editors snd IDEs
* Visual Studio 2017
* Visual Studio 2019

#### Supported CI engines
* Azure Pipelines

#### Supported VCS
* GIT
* Mercurial 

### Automated "Repository Rules" checks/auto-fixers
Use `pre-push.ps1` script to ensure that your working copy complies with the "Repository Rules".
#### Execution environment requirements
* **PowerShellGet** >= 1.6.0
* **Node.JS** >= 8.0
* **.Net Core** >= 2.1

#### VCS
* **no-relative-issues-refs** - Github issues relative refs in commits are prohibited.
#### Text
* **eclint** - Checks basic `.editorconfig` rules:
    - Encoding
    - BOM
    - EOL at the end of a file
    - Trailing white-spaces
#### .Net
*   **sln-vsversion** - checks that current visual studio version in `*.sln` equals to 'minimal visual studio version'
*   **sln-no_anycpu_configurations** - checks that `*.sln` does not contains unwanted "Any CPU" configurations.
#### C#
* **StyleCop Analyzers** - verifies StyleCop rules on every build.
### See Also
* [CHANGELOG](SEED-CHANGELOG.md)
* [LICENSE](LICENSE)
#### Toolset
* [TortoiseHG + hg-git](doc/toolset/hg-git.md)
