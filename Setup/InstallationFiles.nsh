# Dependencies
!include "Util\GetSectionNames.nsh"
!include "Util\StrContains.nsh"
!include MUI2.nsh
!include LogicLib.nsh
!include FileFunc.nsh
!include ErrorHandling.nsh
!insertmacro Locate

!macro RequiredFiles SourcePath OutPath 
    ;Note: OutPath is a path leading to the %LOCALAPPDATA%\ProjectX\Versions\version-xxxxx folder
    SectionGroup "-Required"
        Section "-Roshade"
            SectionIn 1 RO

            SetOutPath $INSTDIR
            CreateDirectory ${PRESETFOLDER}
            File "Graphics\AppIcon.ico"
            WriteUninstaller "${UninstallerExe}"

            CreateDirectory "$SMPROGRAMS\${NAME}"
            CreateShortCut "$SMPROGRAMS\${NAME}\Uninstall ${NAME}.lnk" "$INSTDIR\${UninstallerExe}" "" "${APPICON}"
            
            CreateDirectory "$PICTURES\${NAME}"
        SectionEnd
        Section "-Reshade" ReshadeSection
            SectionIn 1 RO

            CreateDirectory ${TEMPFOLDER}
            
            SetOutPath $TEMP
            ${Explode} $2 "," $Repositories
            ${For} $3 1 $2
                pop $0
                ${Explode} $0 "@" $0
                Call InstallShadersAsync
            ${Next}

            FindFirst $0 $1 "${PRESETTEMPFOLDER}\*.ini"
            !define PRESETID ${__LINE__}
            loop_${PRESETID}:
                StrCmp $1 "" done_${PRESETID}
                Delete "${PRESETFOLDER}\$1"
                Rename "${PRESETTEMPFOLDER}\$1" "${PRESETFOLDER}\$1"
                !insertmacro ToLog $LOGFILE "Output" "Moving $1 to ${PRESETFOLDER}."
                FindNext $0 $1
                GoTo loop_${PRESETID}
            done_${PRESETID}:
            !undef PRESETID
            FindClose $0
            RMDir /r ${PRESETTEMPFOLDER}

            
            RMDir /r "$RobloxPath\pekoshade"
            CreateDirectory "$RobloxPath\pekoshade"
            SetOutPath "$RobloxPath\pekoshade"
            File /r "${PEKOSHADESOURCE}\*"
            !insertmacro ToLog $LOGFILE "Output" "Moving Pekoshade files to $RobloxPath\pekoshade."

            ; Loops through in every roblox folder inside the pekora versions folder
            
            FindFirst $0 $1 "$RobloxPath\*"
            !define VERSIONLOOPID ${__LINE__}
            loop_${VERSIONLOOPID}:
                ; Skip files and the special '.' and '..' directories
                StrCmp $1 "" done_${VERSIONLOOPID}
                StrCmp $1 "." next_${VERSIONLOOPID}
                StrCmp $1 ".." next_${VERSIONLOOPID}

                ${If} ${FileExists} "$RobloxPath\$1\${ROBLOXCLIENT}"
                    push "$RobloxPath\$1"
                    Call InstallReshadeToClient
                ${EndIf}
            next_${VERSIONLOOPID}:
                FindNext $0 $1
                GoTo loop_${VERSIONLOOPID}
            done_${VERSIONLOOPID}:
            !undef VERSIONLOOPID
            FindClose $0

            #Write uninstaller registry
            ReadRegStr $1 HKCU "${ROBLOXREGLOC}" "curPlayerVer" ; reads the current version of pekora client
            !insertmacro RegStrPrint "${SELFREGLOC}" "RobloxVersion" $1
            !insertmacro RegStrPrint "${SELFREGLOC}" "Version" "${VERSION}"
            !insertmacro RegStrPrint "${SELFREGLOC}" "RobloxPath" $RobloxPath
            !insertmacro RegStrPrint "${SELFREGLOC}" "DisplayName" '"${NAME} - ${MANUFACTURER}"'
            !insertmacro RegStrPrint "${SELFREGLOC}" "UninstallString" '"$INSTDIR\${UninstallerExe}"'
            !insertmacro RegStrPrint "${SELFREGLOC}" "DisplayIcon" '"${APPICON}"'
            !insertmacro RegStrPrint "${SELFREGLOC}" "Publisher" "${MANUFACTURER}"
            !insertmacro RegStrPrint "${SELFREGLOC}" "HelpLink" "${HELPLINK}"
            !insertmacro RegStrPrint "${SELFREGLOC}" "URLInfoAbout" "${ABOUTLINK}"
            !insertmacro RegStrPrint "${SELFREGLOC}" "URLUpdateInfo" "${UPDATELINK}"
            !insertmacro RegStrPrint "${SELFREGLOC}" "DisplayVersion" "${VERSION}"
            WriteRegDWORD HKCU "${SELFREGLOC}" "NoModify" 1
            WriteRegDWORD HKCU "${SELFREGLOC}" "NoRepair" 1

            NScurl::wait /TAG "Shader" /END
            FindFirst $0 $1 "${TEMPFOLDER}\*.zip"
            !define SHADERID ${__LINE__}
            loop_${SHADERID}:
                StrCmp $1 "" done_${SHADERID}
                !insertmacro Unzip $1
                FindNext $0 $1
                GoTo loop_${SHADERID}
            done_${SHADERID}:
            !undef SHADERID
            FindClose $0
            RMDir /r ${TEMPFOLDER}

            SetOutPath "$RobloxPath\reshade-shaders\Textures"
            File /r "..\Files\Textures\*"
        SectionEnd
    SectionGroupEnd
!macroend

!macro MoveShaderFiles SourceName Destination Search
    !insertmacro ToLog $LOGFILE "Output" "Moving contents of ${TEMPFOLDER}\${SourceName} to ${Destination}"
    !insertmacro MoveFolder "${TEMPFOLDER}\${SourceName}\Shaders\${Search}" "${Destination}\Shaders" "*.fx"
    !insertmacro MoveFolder "${TEMPFOLDER}\${SourceName}\Shaders\${Search}" "${Destination}\Shaders" "*.fxh"
    !insertmacro MoveFolder "${TEMPFOLDER}\${SourceName}\Textures\${Search}" "${Destination}\Textures" "*"
!macroend

!macro InstallToTemp SourcePath ZipName
    SetOutPath $TEMP
!macroend

!macro Unzip ZipName
    !define ID ${__LINE__}
    start_${ID}:
    nsisunz::UnzipToStack "${TEMPFOLDER}\${ZipName}" ${TEMPFOLDER}
    Pop $R0
    StrCpy $R2 "$R0: ${ZipName}"
    !insertmacro ToLog $LOGFILE "nsisunz" "Unzipping ${ZipName} with response: $R0."
    StrCmp $R0 "success" +3
    MessageBox MB_ABORTRETRYIGNORE|MB_ICONEXCLAMATION $R2 IDIGNORE end_${ID} IDRETRY start_${ID}
        Abort

    Pop $R1
    ${Explode} $R1 "\" $R1
    pop $R1
    ${Explode} $R2 "." ${ZipName}
    pop $R2
    ReadINIStr $R3 ${SHADERSINI} $R2 "search"
    !insertmacro MoveShaderFiles $R1 $ShaderDir $R3
    end_${ID}:
    Delete "${TEMPFOLDER}\${ZipName}"
    !undef ID
!macroend

Function InstallShadersAsync
    pop $R7
    pop $R1
    ReadINIStr $R0 ${SHADERSINI} $R7 "alwaysinstall"
    StrCmp $R0 "" 0 install
    ReadINIStr $R0 ${SHADERSINI} $R7 "techniques"
    StrCpy $Techniques ""
    StrCpy $R6 ""
    FindFirst $R8 $R9 "${PRESETTEMPFOLDER}\*.ini"
    !define PRESETID ${__LINE__}
    loop_${PRESETID}:
        StrCmp $R9 "" done_${PRESETID}
        ReadINIStr $Techniques "${PRESETTEMPFOLDER}\$R9" "GENERAL" "Techniques"
        ${Explode} $R2 "," $Techniques
        ${For} $R3 1 $R2
            pop $R4
            ${Explode} $R5 "@" $R4
            IntCmp $R5 2 0 +7
            pop $R4
            pop $R4
            StrCpy $R5 ""
            ${StrContains} $R5 $R4 $R0
            StrCmp $R5 "" +4
            StrCmp $R6 "" 0 +3
            StrCpy $R6 $R5
            !insertmacro ToLog $LOGFILE "Output" "$R6 ($R7) found in $R9."
        ${Next}
        FindNext $R8 $R9
        GoTo loop_${PRESETID}
    done_${PRESETID}:
    !undef PRESETID
    FindClose $R8
    StrCmp $R6 "" skip
    install:
    ReadINIStr $R0 ${SHADERSINI} $R7 "branch"
    StrCmp $R0 "" 0 +2
    StrCpy $R0 "master"
    NScurl::http GET "https://github.com/$R1/archive/refs/heads/$R0.zip" "${TEMPFOLDER}/$R7.zip" /BACKGROUND /TAG "Shader" /END
    pop $R2
    !insertmacro ToLog $LOGFILE "NScurl" "Adding installation of $R1 to a background thread. ($R2)"
    DetailPrint "$R1 GET"
    skip:
FunctionEnd

Function InstallReshadeToClient
    Push $R0
    Push $0
    Push $1

    Exch 3
    Pop $R0

    MessageBox MB_YESNO|MB_ICONQUESTION "Install reshade to $R0?" IDYES continue
        goto done
    continue:

    !insertmacro ToLog $LOGFILE "Output" "Installing Reshade to client folder: $R0"

    StrCpy $ShaderDir "$RobloxPath\reshade-shaders"
    CreateDirectory $ShaderDir

    Delete "$R0\opengl32.dll"
    Delete "$R0\d3d9.dll"
    Delete "$R0\dxgi.dll"

    SetOutPath $PLUGINSDIR
    File "${RESHADESOURCE}\Reshade.ini"

    SetOutPath $R0
    File "${RESHADESOURCE}\reshade.dll"
    !insertmacro ToLog $LOGFILE "Output" "Rendering API for $R0: ${RENDERAPI}."
    Rename "$R0\reshade.dll" "$R0\${RENDERAPI}"

    ${If} ${FileExists} "$R0\Reshade.ini"
        !insertmacro ToLog $LOGFILE "Output" "Existing Reshade settings have been found."
        ReadINIStr $0 "$R0\Reshade.ini" "INPUT" "KeyEffects"
        ReadINIStr $1 "$R0\Reshade.ini" "INPUT" "KeyOverlay"
        ${IfNot} $0 == $KeyEffects
        ${OrIfNot} $1 == $KeyOverlay
            push $1
            push $0
            Call SettingsExistingError
        ${Else}
            !insertmacro ToLog $LOGFILE "Output" "Existing settings match the chosen settings."
        ${EndIf}
    ${EndIf}

    !insertmacro IniPrint "$PLUGINSDIR\Reshade.ini" "INPUT" "KeyEffects" $KeyEffects
    !insertmacro IniPrint "$PLUGINSDIR\Reshade.ini" "INPUT" "KeyOverlay" $KeyOverlay
    !insertmacro IniPrint "$PLUGINSDIR\Reshade.ini" "SCREENSHOT" "SavePath" "$PICTURES\${NAME}"
    !insertmacro ToLog $LOGFILE "Output" "Screenshot path set to $PICTURES\${NAME}."
    Delete "$R0\Reshade.ini"
    
    !insertmacro IniPrint "$PLUGINSDIR\Reshade.ini" "GENERAL" "PresetPath" "${PRESETFOLDER}\ReshadePreset.ini"
    !insertmacro ToLog $LOGFILE "Output" "Preset path set to ${PRESETFOLDER}."
    !insertmacro MoveFile "$PLUGINSDIR\Reshade.ini" "$R0\Reshade.ini"

    !insertmacro ToLog $LOGFILE "Output" "Moving Reshade.ini to $R0."

    nsExec::Exec 'icacls "$R0\Reshade.ini" /grant "Everyone:(F)"'

    done:
    # Restore registers in reverse order to leave the stack clean before returning.
    Pop $1
    Pop $0
    Pop $R0
    Return
FunctionEnd