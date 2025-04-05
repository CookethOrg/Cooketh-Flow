[Setup]
AppId=5B599538-42B1-4826-A479-AF079F21A65M
AppVersion=0.1.0
AppName=Cooketh Flow
AppPublisher=
AppPublisherURL=https://github.com/CookethOrg/Cooketh-Flow
AppSupportURL=https://github.com/CookethOrg/Cooketh-Flow
AppUpdatesURL=https://github.com/CookethOrg/Cooketh-Flow
DefaultDirName={autopf64}\cookethflow
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=cookethflow-0.1.0-windows-setup
Compression=lzma
SolidCompression=yes
SetupIconFile=
WizardStyle=modern
PrivilegesRequired=none
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]

Name: "english"; MessagesFile: "compiler:Default.isl"





























Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"






















[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "launchAtStartup"; Description: "{cm:AutoStartProgram,Cooketh Flow}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
[Files]
Source: "cookethflow-0.1.0-windows-setup_exe\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Cooketh Flow"; Filename: "{app}\cookethflow.exe"
Name: "{autodesktop}\Cooketh Flow"; Filename: "{app}\cookethflow.exe"; Tasks: desktopicon
Name: "{userstartup}\Cooketh Flow"; Filename: "{app}\cookethflow.exe"; WorkingDir: "{app}"; Tasks: launchAtStartup
[Run]
Filename: "{app}\cookethflow.exe"; Description: "{cm:LaunchProgram,Cooketh Flow}"; Flags:  nowait postinstall skipifsilent
