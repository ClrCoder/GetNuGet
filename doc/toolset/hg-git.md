# Why TortoiseHG/mercurial/plugins are better than TortoiseGit/git in everyday usage
There are multiple advantages:
- Very useful TortoiseHG Workbench (+MQ queues) interface, it's a superpower dashboard for your working copies
- Clean mercurial CLI

# `hg-git` setup
TODO: Write me

# Ubuntu + TortoiseHG
TODO: Write me

# Windows + TortoiseHG
Main problem
----
Mercurial is builtin sometimes behave differently than the hg distributed through python/pip even if versions are the same. And sometime you need to replace builtin mercurial with your own version.

Why you cannot just build your patched TortoiseHG for windows ?
----
For windows you have two options to run TortoiseHg:
1) build your own installer and install it
2) Run `thg` from source code under python

Both ways are extremely complex due to the next reasons:
1) Currently mercurial and TortoiseHG are sitting on python 2.7 version and there are no binaries for PyQT and other dependencies.
2) Shell extensions require a big amount of windows specific tools and installation actions.
3) You need Windows 7 SDK and other very old build tools.

Where TortoiseHG searches for `hg.exe` ?
-----
For UI TortoiseHG uses mercurial package as python library from its `C:\Program Files\TortoiseHG\lib\library.zip`

For commands TortoiseHG executes `hg.exe` in a separated process, with the next search sequence:
1) `C:\Program Files\TortoiseHG\hg.exe`
2) System `hg.exe` (According to %PATH% variable)

Another requirements from TortoiseHG to `hg.exe`
-----
When TortoiseHg runs `hg.exe` it does some extra wrapping which in turn requires that `hg.exe` should have access to thg python package. If this requirements is not satisfied, the next errors rise:
```
*** failed to import extension tortoisehg.util.hgcommands: No module named tortoisehg.util.hgcommands
*** failed to import extension tortoisehg.util.partialcommit: No module named tortoisehg.util.partialcommit
*** failed to import extension tortoisehg.util.pipeui: No module named tortoisehg.util.pipeui
*** failed to import extension tortoisehg.util.win32ill: No module named tortoisehg.util.win32ill
*** failed to import extension tortoisehg.util.hgdispatch: No module named tortoisehg.util.hgdispatch
```

Instruction to replace builtin mecrurial in TortoiseHG
-----

1) Install Python 2.7
2) Create a python virtual environment for a custom mercurial
3) Instal mercurial and plugins into the virtual environment
3) Add `hg.exe` from the virtual environment to the %PATH% and rename `C:\Program Files\TortoiseHG\hg.exe` to `hg4.8.2.exe`
4) Copy `tortoisehg` python package from `thg` sources to the virtual environment `Libs\site-packages`

Example
-----
### Intall Python 2.7
1) Download latest python 2.7 (for example from https://www.python.org/ftp/python/2.7.15/python-2.7.15.amd64.msi)
2) Install it to the `C:\Python27-x64`
3) Prefer to **NOT** add this python to the PATH
4) Create `C:\Python27-x64\setup-vars.cmd`
```cmd
set PATH=c:\python27-x64;c:\python27-x64\scripts;%PATH%
```
6) upgrade pip from elevated priveleges (Administrator command prompt)
```cmd
C:\Python27-x64\setup-vars.cmd
pip install -U pip
```

### Create a python virtual envirotnment for a custom mercurial
1) Activate `C:\Python27-x64`
```cmd
C:\Python27-x64\setup-vars.cmd
```
2) Install `virtualenv` package
```cmd
pip install virtualenv
```
3) Create an virtual environment
virtualenv C:\opt\mercurial

### Install a custom mercurial in the virtual environment
1) Activate virtual environment
```cmd
c:\opt\mercurial\scripts\activate
```
2) Install mercurial
```cmd
pip install mercurial
hg --version
```
3) Install common mercurial plugins
```cmd
pip install hg-git ipaddress mercurial-keyring
```

### Replace TortoiseHG builtin mercurial with the custom mercurial
1) Move all `*.exe` files except `hg.exe` from `C:\opt\mercurial\scripts` to `C:\opt\mercurial\scripts\hide' (this step is required to avoid conflicts of the virtual environment and other python environments
2) Add `C:\opt\mercurial\scripts\hg.exe` to the PATH variable
```cmd
setx PATH C:\opt\mercurial\scripts;%PATH%
```
3) Rename `C:\Program Files\TortoiseHG\hg.exe` to `hg4.9.0.exe`
4) Check `hg --version` from the fresh command prompt

### Add `tortoisehg` python package to the virtual environment
1) Download `thg` sources from the repository https://bitbucket.org/tortoisehg/thg/src
```cmd
hg clone https://bitbucket.org/tortoisehg/thg/src -r 4.9.0 c:\opt\thg-src
```
2) Copy tortoisehg package from sources to the virtual environment
Copy folder `C:\opt\thg-src\tortoisehg` to `C:\opt\hg\Lib\site-packages`

### Test you TortoiseHG
