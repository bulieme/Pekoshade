# Important
InstallDir "$LOCALAPPDATA\Pekoshade"

# Attributes
!define VERSION "0.0.1"
!define MANUFACTURER "bulieme"
!define NAME "Pekoshade"
!define ROBLOXREGLOC "SOFTWARE\ProjectX Corporation\ProjectX"
!define SELFREGLOC "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define ROBLOXCLIENT "ProjectXPlayerBeta.exe"
!define UninstallerExe "Uninstall Pekoshade.exe"
!define HELPLINK "https://google.com/" # supposed to be a discord server
!define ABOUTLINK "https://google.com/"
!define UPDATELINK "https://github.com/bulieme/Pekoshade/releases"
!define RENDERAPI "dxgi.dll"

# Directories
!define PRESETFOLDER "$INSTDIR\presets"
!define RESHADESOURCE "..\Files\Reshade"
!define PRESETSOURCE "..\Files\Preset"
!define PRESETTEMPFOLDER "$TEMP\Presets"
!define TEMPFOLDER "$TEMP\Zeal"
!define LOGDIRECTORY "$TEMP\roshade"

# Files
!define SPLASHICON "$PLUGINSDIR\Roshade.gif"
!define SHADERSINI "$PLUGINSDIR\Shaders.ini"
!define RESHADEINI "$PLUGINSDIR\Reshade.ini"
!define APPICON "$INSTDIR\AppIcon.ico"

Var Techniques
Var Repositories
Var ShaderDir
Var RobloxPath
Var PresetPriority # Determine which preset should be loaded. Lower = higher priority.

VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${NAME}"
VIAddVersionKey "CompanyName" "${MANUFACTURER}"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2025 @bulieme"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "FileVersion" "${VERSION}"

Name "${NAME}"
Caption "$(^Name) Installation"
Outfile "..\${NAME}Setup.exe"
BrandingText "${MANUFACTURER}"
CRCCHECK force