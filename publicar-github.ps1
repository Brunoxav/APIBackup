# Publicar projeto3_backup no GitHub
# Uso: .\publicar-github.ps1
#      .\publicar-github.ps1 -Url "https://github.com/SEU_USUARIO/backup-automacao.git"

param([string]$Url)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$gitExe = "git"
if (Test-Path "C:\Program Files\Git\bin\git.exe") { $gitExe = "C:\Program Files\Git\bin\git.exe" }

function Run-Git { & $gitExe @args }

function Get-GitRemoteOrigin {
    $ErrorActionPreference = 'SilentlyContinue'
    $out = & $gitExe remote get-url origin 2>&1
    $ErrorActionPreference = 'Stop'
    if ($out -is [System.Management.Automation.ErrorRecord]) { return $null }
    $s = [string]$out
    if ([string]::IsNullOrEmpty($s) -or $s -match 'error:') { return $null }
    return $s.Trim()
}

if (-not (Get-Command $gitExe -ErrorAction SilentlyContinue) -and -not (Test-Path $gitExe)) {
    Write-Host "[ERRO] Git nao encontrado. Instale em: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

$isRepo = Test-Path ".git"
if (-not $isRepo) {
    Write-Host "Inicializando repositorio Git..." -ForegroundColor Cyan
    Run-Git init
    Run-Git add .
    Run-Git commit -m "Projeto 3: Automacao de Backup"
    Run-Git branch -M main
    Write-Host "Commit inicial criado." -ForegroundColor Green
} else {
    Run-Git add -A
    $status = Run-Git status --short
    if ($status) {
        Write-Host "Criando commit..." -ForegroundColor Cyan
        Run-Git commit -m "Atualizacao: Projeto 3 Automacao de Backup"
        Write-Host "Commit criado." -ForegroundColor Green
    }
}

$urlToUse = $Url
$remote = Get-GitRemoteOrigin

if ($remote -and -not $urlToUse) {
    Write-Host "Enviando para GitHub (origin)..." -ForegroundColor Cyan
    Run-Git push -u origin main
    Write-Host "Push concluido." -ForegroundColor Green
    exit 0
}

if ($urlToUse) {
    if ($remote) { Run-Git remote remove origin }
    Run-Git remote add origin $urlToUse
    Write-Host "Enviando para GitHub..." -ForegroundColor Cyan
    Run-Git push -u origin main
    Write-Host "Projeto publicado no GitHub." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Nenhum remote configurado. Para publicar:" -ForegroundColor Yellow
Write-Host "  1. Crie um repositorio em https://github.com/new (ex: backup-automacao)" -ForegroundColor White
Write-Host "  2. Nao marque 'Initialize with README'" -ForegroundColor White
Write-Host "  3. Execute com a URL:" -ForegroundColor White
Write-Host "     .\publicar-github.ps1 -Url 'https://github.com/SEU_USUARIO/backup-automacao.git'" -ForegroundColor Cyan
Write-Host ""
exit 0
