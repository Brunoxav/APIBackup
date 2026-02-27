@echo off
chcp 65001 >nul
title Projeto 3 - Automacao de Backup
cd /d "%~dp0"

echo.
echo ============================================
echo   Projeto 3 - Automacao de Backup
echo ============================================
echo.

where python >nul 2>&1
if %errorlevel% equ 0 (
    set PY=python
    goto :run
)
where py >nul 2>&1
if %errorlevel% equ 0 (
    set PY=py
    goto :run
)

echo [ERRO] Python nao encontrado.
echo.
echo Instale o Python em: https://www.python.org/downloads/
echo Marque a opcao "Add Python to PATH" na instalacao.
echo.
pause
exit /b 1

:run
echo Executando backup (origem e destino padrao)...
echo Para usar pastas proprias: %PY% backup.py "C:\Origem" "D:\Backup"
echo.
%PY% backup.py
set EXITCODE=%errorlevel%
echo.
if %EXITCODE% equ 0 (
    echo Backup concluido. Verifique a pasta 'logs' para o arquivo de log.
) else (
    echo Backup finalizado com erros. Veja o log acima.
)
echo.
pause
exit /b %EXITCODE%
