# install-pi-extensions.ps1
# Replicates vvbz's Mac Pi setup on Windows: settings.json (no packages) + all extensions + AGENTS.md + skills.
# Secrets are NOT included - add your API key afterwards (see notes printed at the end).
# Run from a clone of this repo with:
#   powershell -ExecutionPolicy Bypass -File .\install-pi-extensions.ps1

$ErrorActionPreference = 'Continue'

if (-not (Get-Command pi -ErrorAction SilentlyContinue)) {
    Write-Host 'Pi is not installed. Install Node.js, then:  npm install -g @earendil-works/pi-coding-agent' -ForegroundColor Red
    exit 1
}
Write-Host "Pi found: $(pi --version)" -ForegroundColor Cyan

# ---- 1. Write settings.json first (pi install will append the packages array into it) ----
$agentDir = Join-Path $env:USERPROFILE '.pi\agent'
$settingsPath = Join-Path $agentDir 'settings.json'
New-Item -ItemType Directory -Force $agentDir | Out-Null

if (Test-Path $settingsPath) {
    Write-Host "settings.json already exists - leaving it untouched." -ForegroundColor Yellow
} else {
    $settings = @'
{
  "theme": "dark",
  "defaultProvider": "ollama-cloud",
  "defaultModel": "glm-5.3-flash",
  "defaultThinkingLevel": "xhigh",
  "showLastPrompt": true,
  "powerline": {
    "preset": "nerd",
    "placement": "below",
    "welcome": true,
    "customItems": [
      {
        "id": "sureforge",
        "statusKey": "sureforge",
        "position": "right",
        "color": "accent",
        "hideWhenMissing": false
      }
    ]
  },
  "hideThinkingBlock": true,
  "compaction": { "enabled": false },
  "extensions": [ "-builtin:mcp" ]
}
'@
    Set-Content -Path $settingsPath -Value $settings -Encoding UTF8
    Write-Host "Wrote $settingsPath" -ForegroundColor Green
}

# ---- 2. Install all packages (appends to the packages array in settings.json) ----
$Packages = @(
    'npm:pi-ollama-cloud',
    'git:github.com/DietrichGebert/ponytail',
    'npm:pi-fabric',
    'npm:pi-mcp-adapter',
    'npm:@ff-labs/pi-fff',
    'npm:@juicesharp/rpiv-ask-user-question',
    'npm:@juicesharp/rpiv-todo',
    'npm:pi-token-speed',
    'npm:pi-powerline-footer',
    'npm:@giladbarnea/pi-time-sense',
    'npm:@juicesharp/rpiv-advisor',
    'npm:@tintinweb/pi-subagents',
    'npm:opencode-codebase-index',
    'npm:pi-graft',
    'npm:@henryqw/pi-task-models',
    'npm:@henryqw/pi-auto-compact',
    'http://vvbzbox:3030/vvbz/sureforge-pi.git',
    'https://github.com/vvbzv/pi-i-have-adhd'
)

$ok = @(); $failed = @()
foreach ($pkg in $Packages) {
    Write-Host "`n==> Installing $pkg" -ForegroundColor Cyan
    pi install $pkg
    if ($LASTEXITCODE -eq 0) { $ok += $pkg } else { $failed += $pkg }
}

# ---- 3. AGENTS.md + skills (bundled in this repo, next to the script) ----
if (Test-Path (Join-Path $PSScriptRoot 'AGENTS.md')) {
    Copy-Item (Join-Path $PSScriptRoot 'AGENTS.md') $agentDir -Force
    Write-Host 'AGENTS.md -> %USERPROFILE%\.pi\agent\AGENTS.md' -ForegroundColor Green
}
if (Test-Path (Join-Path $PSScriptRoot 'skills')) {
    $skillsDest = Join-Path $env:USERPROFILE '.agents\skills'
    New-Item -ItemType Directory -Force $skillsDest | Out-Null
    Copy-Item (Join-Path $PSScriptRoot 'skills\*') $skillsDest -Recurse -Force
    Write-Host 'Skills -> %USERPROFILE%\.agents\skills' -ForegroundColor Green
}

Write-Host "`n===== Summary =====" -ForegroundColor Yellow
Write-Host "Packages OK: $($ok.Count) / $($Packages.Count)"
if ($failed.Count) {
    Write-Host "Failed: $($failed.Count)" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host 'Re-run this script or `pi update --extensions` to retry.'
}

Write-Host @"

Manual follow-ups:
  1. API KEY: not copied on purpose. On the Mac your key lives in ~/.pi/agent/auth.json
     (providers: ollama-cloud, kiro, opencode-go). Add the key you want here via pi's
     login/auth flow, or copy only the provider entry you need into
     %USERPROFILE%\.pi\agent\auth.json yourself.
     The default model (ollama-cloud / glm-5.3-flash) won't work until then.
  2. pi-provider-kiro: local folder on the Mac, not on npm. Copy the folder over, then:
     pi install <path-to-folder>
  3. sureforge-pi (vvbzbox:3030): only reachable from the LAN where that box lives.
"@ -ForegroundColor Magenta
