[CmdletBinding()]
param(
    [switch]$Member,
    [switch]$Help
)

$ErrorActionPreference = "Continue"
$courseRoot = Split-Path -Parent $PSScriptRoot
$mode = if ($Member) { "member" } else { "public" }

if ($Help) {
    Write-Host "Usage: .\setup\check.ps1 [-Member]"
    Write-Host ""
    Write-Host "Run without -Member for the public course."
    Write-Host "Use -Member to require access to the team member repository."
    exit 0
}

function Show-Result {
    param(
        [string]$Label,
        [bool]$Result
    )
    if ($Result) {
        Write-Host "[PASS] $Label" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $Label" -ForegroundColor Red
    }
}

function Test-NativeCommand {
    param(
        [string]$Command,
        [string[]]$Arguments = @()
    )
    & $Command @Arguments *> $null
    return $LASTEXITCODE -eq 0
}

$gitCommand = Get-Command git -ErrorAction SilentlyContinue
$gitInstalled = $null -ne $gitCommand
$gitIdentity = $false
if ($gitInstalled) {
    $gitName = & $gitCommand.Source config --global --get user.name 2>$null
    $gitEmail = & $gitCommand.Source config --global --get user.email 2>$null
    $gitIdentity = -not [string]::IsNullOrWhiteSpace($gitName) -and
        -not [string]::IsNullOrWhiteSpace($gitEmail)
}
Show-Result "Git is installed" $gitInstalled
Show-Result "Git name and email are configured" $gitIdentity

$ghCommand = Get-Command gh -ErrorAction SilentlyContinue
$githubCli = $null -ne $ghCommand
$githubAuthenticated = $false
$publicRepoAccess = $false
$teamAccess = if ($Member) { $false } else { "not_required" }
if ($githubCli) {
    $githubAuthenticated = Test-NativeCommand $ghCommand.Source @(
        "auth", "status", "--hostname", "github.com"
    )
    if ($githubAuthenticated) {
        $publicRepoAccess = Test-NativeCommand $ghCommand.Source @(
            "repo", "view", "KSU-Electric-Vehicle-Team/ROB-Teensy"
        )
        if ($Member) {
            $teamAccess = Test-NativeCommand $ghCommand.Source @(
                "repo", "view", "KSU-Electric-Vehicle-Team/evt-knowledge"
            )
        }
    }
}
Show-Result "GitHub CLI is installed" $githubCli
Show-Result "GitHub CLI is authenticated" $githubAuthenticated
Show-Result "Public KSU EVT repository access works" $publicRepoAccess
if ($Member) {
    Show-Result "Team member repository access works" ([bool]$teamAccess)
}

$codeFromPath = Get-Command code -ErrorAction SilentlyContinue
$codeCandidates = @(
    $(if ($codeFromPath) { $codeFromPath.Source }),
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
    "$env:ProgramFiles\Microsoft VS Code\bin\code.cmd",
    "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
$codeCli = $codeCandidates | Select-Object -First 1
$vscode = $null -ne $codeCli
$extensionPack = $false
$pythonExtension = $false
$platformioExtension = $false
$githubExtension = $false
$markdownExtension = $false
if ($vscode) {
    $extensions = @(& $codeCli --list-extensions 2>$null) | ForEach-Object {
        $_.ToLowerInvariant()
    }
    $extensionPack = [bool]($extensions | Where-Object {
        $_ -match '^ksu-evt\.ksu-evt-(lite|full)-windows$'
    })
    $pythonExtension = $extensions -contains "ms-python.python"
    $platformioExtension = $extensions -contains "platformio.platformio-ide"
    $githubExtension = $extensions -contains "github.vscode-pull-request-github"
    $markdownExtension = $extensions -contains "davidanson.vscode-markdownlint"
}
Show-Result "VS Code is installed and its command works" $vscode
Show-Result "The matching KSU EVT extension pack is installed" $extensionPack
Show-Result "The Python extension is installed" $pythonExtension
Show-Result "The PlatformIO extension is installed" $platformioExtension
Show-Result "The GitHub Pull Requests extension is installed" $githubExtension
Show-Result "The markdownlint extension is installed" $markdownExtension

$pythonCommand = $null
$pythonArguments = @()
$pythonFromPath = Get-Command python -ErrorAction SilentlyContinue
$pyLauncher = Get-Command py -ErrorAction SilentlyContinue
if ($pythonFromPath) {
    $pythonCommand = $pythonFromPath.Source
} elseif ($pyLauncher) {
    $pythonCommand = $pyLauncher.Source
    $pythonArguments = @("-3")
}

$pythonRuntime = $false
$pip = $false
if ($pythonCommand) {
    $pythonRuntime = Test-NativeCommand $pythonCommand ($pythonArguments + @("--version"))
    if ($pythonRuntime) {
        $pip = Test-NativeCommand $pythonCommand ($pythonArguments + @("-m", "pip", "--version"))
    }
}
Show-Result "Python runs" $pythonRuntime
Show-Result "pip runs through Python" $pip

$pioFromPath = Get-Command pio -ErrorAction SilentlyContinue
$pioCandidates = @(
    $(if ($pioFromPath) { $pioFromPath.Source }),
    "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe",
    "$env:USERPROFILE\.platformio\penv\Scripts\platformio.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique
$pioCli = $pioCandidates | Select-Object -First 1
$platformioCli = $false
$cppBuild = $false
if ($pioCli) {
    $platformioCli = Test-NativeCommand $pioCli @("--version")
    if ($platformioCli) {
        Write-Host ""
        Write-Host "Compiling the no-hardware Teensy smoke project. This may download the toolchain."
        & $pioCli run `
            --project-dir "$courseRoot\lessons\01-setup\smoke" `
            --environment teensy41
        $cppBuild = $LASTEXITCODE -eq 0
    }
}
Show-Result "PlatformIO Core runs" $platformioCli
Show-Result "The Teensy smoke project compiles" $cppBuild

$checks = [ordered]@{
    git_installed        = $gitInstalled
    git_identity         = $gitIdentity
    github_cli           = $githubCli
    github_authenticated = $githubAuthenticated
    public_repo_access   = $publicRepoAccess
    team_access          = $teamAccess
    vscode               = $vscode
    extension_pack       = $extensionPack
    python_extension     = $pythonExtension
    platformio_extension = $platformioExtension
    github_extension     = $githubExtension
    markdown_extension   = $markdownExtension
    python_runtime       = $pythonRuntime
    pip                  = $pip
    platformio_cli       = $platformioCli
    cpp_build            = $cppBuild
}

$requiredChecks = @(
    "git_installed",
    "git_identity",
    "github_cli",
    "github_authenticated",
    "public_repo_access",
    "vscode",
    "extension_pack",
    "python_extension",
    "platformio_extension",
    "github_extension",
    "markdown_extension",
    "python_runtime",
    "pip",
    "platformio_cli",
    "cpp_build"
)
$complete = $true
foreach ($checkName in $requiredChecks) {
    if (-not $checks[$checkName]) {
        $complete = $false
    }
}
if ($Member -and -not [bool]$teamAccess) {
    $complete = $false
}

$report = [ordered]@{
    schema_version = 1
    generated_at   = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    platform       = "windows"
    mode           = $mode
    checks         = $checks
    complete       = $complete
}
$progressDirectory = Join-Path $courseRoot "progress"
New-Item -ItemType Directory -Force -Path $progressDirectory | Out-Null
$reportPath = Join-Path $progressDirectory "setup-report.json"
$report | ConvertTo-Json -Depth 4 | Set-Content -Encoding utf8 $reportPath

Write-Host ""
Write-Host "Setup report: $reportPath"
if ($complete) {
    Write-Host "Lesson 1 complete. Commit the report and push it to GitHub." -ForegroundColor Green
    exit 0
}

Write-Host "Setup is incomplete. Follow the troubleshooting section in README.md, then run this checker again." -ForegroundColor Yellow
exit 1
