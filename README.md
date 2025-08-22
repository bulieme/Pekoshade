# Pekoshade [![Build](https://github.com/bulieme/Pekoshade/actions/workflows/nsis.yaml/badge.svg?branch=main)](https://github.com/bulieme/Pekoshade/actions/workflows/nsis.yaml) ![Downloads](https://img.shields.io/github/downloads/bulieme/Pekoshade/total) [![NSIS](https://badgen.net/badge/NSIS/3.08/cyan)](https://nsis.sourceforge.io/Download)

> [!IMPORTANT]
> ### Pekoshade IS NOT MADE FOR A NORMAL ROBLOX CLIENTS
> Pekoshade is built for Pekora clients, They have a different folder structure compared to normal Roblox client. Pekora stores its roblox clients in the following directory:
> ```python
> %LOCALAPPDATA%/ProjectX/Versions/version-xxxxxx.../
> ├── 2017L/
> │   ├──ProjectXPlayerBeta.exe
> │   └── ...
> ├── 2018L/
> │   ├──ProjectXPlayerBeta.exe
> │   └── ...
> ├── 2020L/
> │   ├──ProjectXPlayerBeta.exe
> │   └── ...
> ├── 2021M/
> │   ├──ProjectXPlayerBeta.exe
> │   └── ...
> └── ProjectXPlayerLauncher.exe # Bootstrapper when user joins in a pekora.zip game.
> ```
Pekoshade, A installation package that makes your Reshade presets & shaders installations easier to the ProjectX directory. Pekoshade can make your Pekora customizations quick and easy, without having the hassle to install Reshade for each Pekora clients.

## Key features:
- [WIP] Automatically installs Reshade's dll in every Pekora clients (e.g, from 2017L, 2018L, etc.)
- Allows you to select essential Reshade keybinds during installation.
- Uses a custom version of [Reshade v5.2.2](https://github.com/Not-Smelly-Garbage/Reshade-Unlocked/releases) to bypass network restrictions set by Reshade.
- Provides a description of system requirements for each component.
- Automatically installs the required shaders from GitHub.

## TODOs:
- [x] Make pekoshade and reshade folders outside clients
- [x] Make support for all roblox clients
- [ ] Rebrand installer, change logo and icon stuff.
- [ ] Make Pekoshade keep uninstaller when doing a non-clean uninstall (e.g. still keeping dlls based on user choice.)
- [ ] Make use of the fonts in the pekoshade folder (edit Reshade.ini)

## Getting Started
To get started with Pekoshade, you'll first need to download the latest release from the [releases](https://github.com/bulieme/Pekoshade/releases) page. Once downloaded, simply run it and follow the prompts to install Pekoshade. Once installation is complete, you'll be able to launch Pekora and start customizing your visual experience with the included Reshade presets and shaders.

If you have any questions or issues with Pekoshade, please feel free to open an issue on the GitHub repository.

## Building the source
The installer is written in [NSIS](https://nsis.sourceforge.io/Download "Download NSIS"), a popular open-source tool for creating Windows installers. To build the source, you'll need to have NSIS installed on your machine. I highly recommend reading through the [NSIS reference](https://nsis.sourceforge.io/Docs/Contents.html) before proceeding.

### Libraries
Some dependencies may be installed to the NSIS directory, or to the repository's *Setup\Util* folder. For more information on installing plugins to the NSIS directory, click [here](https://nsis.sourceforge.io/How_can_I_install_a_plugin).
##### NSIS Plugins Directory:
- [LogEx](https://nsis.sourceforge.io/LogEx_plug-in)
- [NScurl](https://github.com/negrutiu/nsis-nscurl)
- [Nsisunz](https://github.com/past-due/nsisunz)
- [NsProcess](https://nsis.sourceforge.io/mediawiki/index.php?title=NsProcess_plugin&oldid=24277)
- [TitlebarProgress](https://nsis.sourceforge.io/TitlebarProgress_plug-in)
- [TaskbarProgress](https://nsis.sourceforge.io/TaskbarProgress_plug-in)
- [nsJSON](https://nsis.sourceforge.io/NsJSON_plug-in)
- [AccessControl](https://nsis.sourceforge.io/AccessControl_plug-in)
##### Setup->Util folder:
- [MoveFileFolder](https://nsis.sourceforge.io/MoveFileFolder)
- [GetSectionNames](https://nsis.sourceforge.io/Get_all_section_names_of_INI_file)
- [Explode](https://nsis.sourceforge.io/Explode)
- [StrContains](https://nsis.sourceforge.io/StrContains)
- [ConfigRead](https://nsis.sourceforge.io/ConfigRead)

### Command Line
You can build using the command line:
```
> makensis Setup.nsi
```
For production, it is recommended to use **lzma compression**, as it offers a higher compression ratio:
```
> makensis /X"SetCompressor /FINAL lzma" Setup.nsi
```
