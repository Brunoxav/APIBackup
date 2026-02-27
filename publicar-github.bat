@echo off
chcp 65001 >nul
cd /d "%~dp0"

where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Git nao encontrado. Instale em: https://git-scm.com/download/win
    pause
    exit /b 1
)

if not exist ".git" (
    echo Inicializando repositorio Git...
    git init
    git add .
    git commit -m "Projeto 3: Automacao de Backup"
    git branch -M main
    echo Commit inicial criado.
) else (
    git add -A
    git status --short | findstr /r "." >nul 2>&1
    if %errorlevel% equ 0 (
        git commit -m "Atualizacao: Projeto 3 Automacao de Backup"
        echo Commit criado.
    ) else (
        echo Nenhuma alteracao pendente.
    )
)

git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo Enviando para GitHub...
    git push -u origin main
    echo Push concluido.
    pause
    exit /b 0
)

echo.
echo Nenhum remote configurado.
echo 1. Crie um repo em https://github.com/new (ex: backup-automacao)
echo 2. Nao marque "Initialize with README"
echo 3. Copie a URL e execute:
echo.
echo   git remote add origin https://github.com/SEU_USUARIO/backup-automacao.git
echo   git push -u origin main
echo.
echo Ou execute: publicar-github.ps1 -Url "https://github.com/SEU_USUARIO/backup-automacao.git"
echo.
pause
