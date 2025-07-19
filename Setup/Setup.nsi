!include Attributes.nsh
!include ModernUI.nsh
!include DefaultSections.nsh
!include InstallationFiles.nsh

RequestExecutionLevel admin

# Uninstallation
Section Uninstall
    ReadRegStr $0 HKCU "${SELFREGLOC}" "RobloxPath"
    DeleteRegKey HKCU "${SELFREGLOC}"
    Delete "$INSTDIR\AppIcon.ico"
    Delete "$INSTDIR\${UninstallerExe}"
    Delete "$0\${RENDERAPI}"
    Delete "$0\Reshade.ini"
    RMDir /r "$0\reshade-shaders"
    RMDir /r "$0\roshade"
    RMDir /r $INSTDIR
SectionEnd

Function un.onInit
    MessageBox MB_YESNO|MB_ICONQUESTION "This will uninstall Reshade from your ProjectX directory. Are you sure you want to continue?" IDYES continue
        quit
    continue:
FunctionEnd

# Installation
!insertmacro PresetFiles ${PRESETSOURCE} ${PRESETTEMPFOLDER}
!insertmacro RequiredFiles ${RESHADESOURCE} $RobloxPath

# Installer Init
Function .onInit
    Var /GLOBAL LOGFILE
    System::Call 'ole32::CoCreateGuid(g .s)'
    pop $LOGFILE
    StrCpy $LOGFILE "${LOGDIRECTORY}\$LOGFILE.log"
    CreateDirectory ${LOGDIRECTORY}
    LogEx::Init "true" $LOGFILE

    InitPluginsDir
    SetOutPath $PLUGINSDIR
    File "${RESHADESOURCE}\Reshade.ini"#unextract things
    File "Shaders.ini"
    
    CreateDirectory ${PRESETTEMPFOLDER}
    !insertmacro ToLog $LOGFILE "Output" "$$INSTDIR: $INSTDIR"
    !insertmacro ToLog $LOGFILE "Output" "$$PLUGINSDIR: $PLUGINSDIR"

    #find projectx client until found
    ${Locate} "$LOCALAPPDATA\ProjectX\Versions" "/L=F /M=${ROBLOXCLIENT}" "GetRobloxPath"
    ${Locate} "$PROGRAMFILES\ProjectX\Versions" "/L=F /M=${ROBLOXCLIENT}" "GetRobloxPath"

    StrCmp $RobloxPath "" 0 +2
    call RobloxNotFoundError

    ReadRegStr $R0 HKCU ${SELFREGLOC} "Version" #idfk why they do this
    ${GetSectionNames} ${SHADERSINI} DefineRepositories
    !insertmacro ToLog $LOGFILE "Output" "Repositories: $Repositories"

    # check if client still running
    nsProcess::_FindProcess "${ROBLOXCLIENT}"
    pop $R0
    !insertmacro ToLog $LOGFILE "nsProcess" "FindProcess ${ROBLOXCLIENT} with code: $R0"
    StrCmp $R0 0 0 +2
    Call RobloxRunningError
    SectionSetSize ${ReshadeSection} 36860
FunctionEnd

Function GetRobloxPath
    StrCpy $0 StopLocate
    StrCpy $RobloxPath $R8
    push $0
FunctionEnd

Function DefineRepositories
    ReadINIStr $R1 $0 $9 "repo"
    StrCmp $R1 "" skip 0
    StrCpy $R7 "$TEMP\$9-techniques.json"
    ${If} ${FileExists} $R7
    ${AndIf} $R0 == ${VERSION}
        Goto installed
    ${EndIf}

    ReadINIStr $R2 $0 $9 "search"
    ReadINIStr $R9 $0 $9 "branch"
    StrCmp $R9 "" 0 +2
    StrCpy $R9 "master"
    StrCpy $R9 "?ref=$R9"
    StrCmp $R2 "" +2
    StrCpy $R2 "/$R2"
    NScurl::http GET "https://api.github.com/repos/$R1/contents/Shaders$R2$R9" $R7 /END
    pop $R3
    !insertmacro ToLog $LOGFILE "NScurl" "https://api.github.com/repos/$R1/contents/Shaders$R2$R9: $R3"
    StrCmp $R3 "OK" +4 0
    Delete "$TEMP\$9-techniques.json"
    WriteINIStr $0 $9 "alwaysinstall" "true"
    GoTo loopend

    installed:
    nsJSON::Set /tree $R1 /file $R7
    nsJSON::Get /tree $R1 /count /end
    pop $R2
    StrCpy $R3 -1
    StrCpy $R4 ""
    StrCpy $R5 ""
    loop:
        StrCmp $R3 $R2 loopend
        nsJSON::Get /tree $R1 /index $R3 "name"
        pop $R4
        StrCmp $R4 "" loop
        StrCpy $R5 "$R5$R4,"
        IntOp $R3 $R3 + 1
        Goto loop
    loopend:
    ReadINIStr $R6 $0 $9 "alwaysinstall"
    StrCmp $R6 "true" +2
    WriteINIStr $0 $9 "techniques" $R5
    StrCpy $Repositories "$Repositories$9@$R1,"
    skip:
    Push $0
FunctionEnd