# Projeto 3 - Automacao de Backup - Executar backup
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Projeto 3 - Automacao de Backup" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$py = $null
if (Get-Command python -ErrorAction SilentlyContinue) { $py = "python" }
elseif (Get-Command py -ErrorAction SilentlyContinue) { $py = "py" }

if (-not $py) {
    Write-Host "[ERRO] Python nao encontrado." -ForegroundColor Red
    Write-Host ""
    Write-Host "Instale em: https://www.python.org/downloads/"
    Write-Host 'Marque "Add Python to PATH" na instalacao.'
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host "Executando backup (origem e destino padrao)..." -ForegroundColor Yellow
Write-Host "Para usar pastas proprias: $py backup.py ""C:\Origem"" ""D:\Backup""" -ForegroundColor Gray
Write-Host ""

& $py backup.py
$exitCode = $LASTEXITCODE

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "Backup concluido. Verifique a pasta 'logs' para o arquivo de log." -ForegroundColor Green
} else {
    Write-Host "Backup finalizado com erros. Veja o log acima." -ForegroundColor Yellow
}
Write-Host ""
Read-Host "Pressione Enter para sair"
exit $exitCode
