
|                     |  __Rules__         |   __x64 Debug__    |   __x64 Release__  |
|:-------------------:|:------------------:|:------------------:|:------------------:|
| __Windows__         | [![bs][w_r]][b]    | [![bs][w_x64d]][b] | [![bs][w_x64r]][b] |
| __Linux__           | [![bs][l_r]][b]    | [![bs][l_x64d]][b] | [![bs][l_x64r]][b] |

[b]:https://dev.azure.com/dmitriyse/dmitriyse/_build/latest?definitionId=1&branchName=master

[w_r]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=windows-rules "The status of the Repository rules check on Windows"
[l_r]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=linux-rules "The status of the Repository rules check on Linux"
[w_x64d]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=windows-x64-debug "The status of the 'Windows-x64 Debug' build"
[l_x64d]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=linux-x64-debug "The status of the 'Linux-x64 Debug' build"
[w_x64r]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=windows-x64-release "The status of the 'Windows-x64 Release' build"
[l_x64r]:https://dev.azure.com/dmitriyse/dmitriyse/_apis/build/status/ClrCoder.ClrSeed?branchName=master&jobName=Job&configuration=linux-x64-release "The status of the 'Linux-x64 Release' build"

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
