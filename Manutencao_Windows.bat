:: ################################################################
:: ##               Central de Manutenção Windows                ##
:: ################################################################
:: # Author:  https://github.com/Rc692
:: # Repo:    https://github.com/Rc692/Manutencao-Windows
:: # SPDX-License-Identifier: MIT
:: # Version: 1.0.0
:: #
:: # Script interativo para manutenção, limpeza de temporários,
:: # otimização e verificação de integridade do Windows via CLI.
:: # Utiliza apenas comandos e ferramentas nativas do sistema.
:: #
:: # Recursos e Módulos:
:: #   - Auto-elevação para privilégios de Administrador (UAC)
:: #   - Limpeza de arquivos temporários do usuário (%TEMP%)
:: #   - Limpeza de arquivos temporários do Windows (C:\Windows\Temp)
:: #   - Limpeza de componentes antigos (DISM StartComponentCleanup)
:: #   - Reparo da imagem do sistema (DISM RestoreHealth)
:: #   - Verificação e restauração de arquivos protegidos (SFC /scannow)
:: #
:: # Registro de Execução (Log gerado automaticamente):
:: #   %USERPROFILE%\Desktop\Manutencao_YYYYMMDD_HHMMSS.log
:: ################################################################

@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title Central de Manutenção do Windows
mode con: cols=75 lines=28

:: ========================================================
:: DEFINICAO DE CORES ANSI E ESTILOS
:: ========================================================
for /f %%a in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%a"

set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "WHITE=%ESC%[97m"
set "CYAN=%ESC%[96m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "GRAY=%ESC%[90m"

set "SEP=─────────────────────────────────────────────────────────────"

:: ========================================================
:: 1. VERIFICACAO DE ADMINISTRADOR
:: ========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo  %RED%%SEP%%RESET%
    echo   %BOLD%%RED%ACESSO NEGADO%RESET% - Privilégios de Administrador necessários.
    echo  %RED%%SEP%%RESET%
    echo.
    echo   Solicitando permissões de Administrador...
    echo.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ========================================================
:: 2. CRIACAO DO LOG NA AREA DE TRABALHO
:: ========================================================
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "DATA=%%I"
set "LOG=%USERPROFILE%\Desktop\Manutencao_%DATA%.log"
echo ============================================== > "%LOG%"
echo REGISTRO DE MANUTENÇÃO DO WINDOWS              >> "%LOG%"
echo Início: %date% %time%                          >> "%LOG%"
echo ============================================== >> "%LOG%"

:: ========================================================
:: 3. MENU PRINCIPAL
:: ========================================================
:Menu
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%Central de Manutenção do Windows%RESET%               %GRAY%v1.0.0%RESET%
echo  %CYAN%%SEP%%RESET%
echo   %GRAY%Log: %LOG%%RESET%
echo.
echo   %CYAN%[1]%RESET% %BOLD%Manutenção Completa%RESET% %GRAY%(todos os módulos)%RESET%
echo.
echo   %CYAN%[2]%RESET% Limpeza de Temporários do Usuário
echo   %CYAN%[3]%RESET% Limpeza de Temporários do Windows
echo   %CYAN%[4]%RESET% Otimização de Componentes (DISM)
echo   %CYAN%[5]%RESET% Reparo de Imagem do Sistema (DISM)
echo   %CYAN%[6]%RESET% Verificação de Integridade (SFC)
echo.
echo  %GRAY%%SEP%%RESET%
echo   %RED%[0]%RESET% %GRAY%Sair%RESET%
echo  %GRAY%%SEP%%RESET%
echo.
choice /c 1234560 /n /m "%ESC%[96mEscolha uma opção [0-6]: %ESC%[0m"

if errorlevel 7 goto :Encerrar
if errorlevel 6 goto :ApenasSFC
if errorlevel 5 goto :ApenasDISMRestore
if errorlevel 4 goto :ApenasDISMCleanup
if errorlevel 3 goto :ApenasTempWin
if errorlevel 2 goto :ApenasTempUser
if errorlevel 1 goto :RotinaCompleta

:: ========================================================
:: 4. ROTINAS DE EXECUCAO
:: ========================================================

:RotinaCompleta
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%Iniciando Manutenção Completa%RESET%
echo  %CYAN%%SEP%%RESET%
timeout /t 1 >nul
call :Executar_TempUser
call :Executar_TempWin
call :Executar_DISMCleanup
call :Executar_DISMRestore
call :Executar_SFC
goto :Finalizacao

:ApenasTempUser
call :Executar_TempUser
goto :Finalizacao

:ApenasTempWin
call :Executar_TempWin
goto :Finalizacao

:ApenasDISMCleanup
call :Executar_DISMCleanup
goto :Finalizacao

:ApenasDISMRestore
call :Executar_DISMRestore
goto :Finalizacao

:ApenasSFC
call :Executar_SFC
goto :Finalizacao

:: ========================================================
:: 5. ETAPAS INDIVIDUAIS
:: ========================================================

:Executar_TempUser
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%[1/5] Limpeza de Temporários do Usuário%RESET%
echo  %CYAN%%SEP%%RESET%
echo   Remove caches e arquivos residuais da pasta %%TEMP%%.
echo.
choice /c SN /m "%ESC%[93mExecutar esta etapa? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo   %YELLOW%[PULADO]%RESET% %GRAY%Etapa ignorada.%RESET%
    echo [PULADO] Temporários do usuário >> "%LOG%"
    timeout /t 1 >nul
    exit /b
)
echo.
echo   %CYAN%[%RESET%...%CYAN%]%RESET% Limpando arquivos temporários...
echo [1/5] Temporários do usuário - Início: %time% >> "%LOG%"
del /f /s /q "%TEMP%\*" >> "%LOG%" 2>&1
echo [1/5] Concluído >> "%LOG%"
echo   %GREEN%[ OK ]%RESET% Limpeza concluída com sucesso!
echo.
pause
exit /b

:Executar_TempWin
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%[2/5] Limpeza de Temporários do Windows%RESET%
echo  %CYAN%%SEP%%RESET%
echo   Remove arquivos temporários e instaladores em C:\Windows\Temp.
echo.
choice /c SN /m "%ESC%[93mExecutar esta etapa? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo   %YELLOW%[PULADO]%RESET% %GRAY%Etapa ignorada.%RESET%
    echo [PULADO] Temporários do Windows >> "%LOG%"
    timeout /t 1 >nul
    exit /b
)
echo.
echo   %CYAN%[%RESET%...%CYAN%]%RESET% Limpando arquivos do sistema...
echo [2/5] Temporários do Windows - Início: %time% >> "%LOG%"
del /f /s /q "%windir%\Temp\*" >> "%LOG%" 2>&1
echo [2/5] Concluído >> "%LOG%"
echo   %GREEN%[ OK ]%RESET% Limpeza concluída com sucesso!
echo.
pause
exit /b

:Executar_DISMCleanup
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%[3/5] Otimização de Componentes (DISM)%RESET%
echo  %CYAN%%SEP%%RESET%
echo   Limpa versões obsoletas na pasta WinSxS (Windows Update).
echo   %GRAY%Tempo estimado: 3 a 8 minutos.%RESET%
echo.
choice /c SN /m "%ESC%[93mExecutar esta etapa? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo   %YELLOW%[PULADO]%RESET% %GRAY%Etapa ignorada.%RESET%
    echo [PULADO] DISM StartComponentCleanup >> "%LOG%"
    timeout /t 1 >nul
    exit /b
)
echo.
echo   %CYAN%[%RESET%...%CYAN%]%RESET% Otimizando componentes (aguarde alguns minutos)...
echo [3/5] DISM StartComponentCleanup - Início: %time% >> "%LOG%"
DISM /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
echo [3/5] Concluído >> "%LOG%"
echo   %GREEN%[ OK ]%RESET% Otimização finalizada com sucesso!
echo.
pause
exit /b

:Executar_DISMRestore
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%[4/5] Reparo de Imagem do Sistema (DISM)%RESET%
echo  %CYAN%%SEP%%RESET%
echo   Verifica e repara a imagem do sistema via Windows Update.
echo   %GRAY%Requer conexão com a internet. Tempo: 10 a 20 minutos.%RESET%
echo.
choice /c SN /m "%ESC%[93mExecutar esta etapa? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo   %YELLOW%[PULADO]%RESET% %GRAY%Etapa ignorada.%RESET%
    echo [PULADO] DISM RestoreHealth >> "%LOG%"
    timeout /t 1 >nul
    exit /b
)
echo.
echo   %CYAN%[%RESET%...%CYAN%]%RESET% Verificando e reparando imagem do Windows...
echo [4/5] DISM RestoreHealth - Início: %time% >> "%LOG%"
DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
echo [4/5] Concluído >> "%LOG%"
echo   %GREEN%[ OK ]%RESET% Reparo de imagem concluído!
echo.
pause
exit /b

:Executar_SFC
cls
echo.
echo  %CYAN%%SEP%%RESET%
echo   %BOLD%%WHITE%[5/5] Verificação de Integridade (SFC)%RESET%
echo  %CYAN%%SEP%%RESET%
echo   Escaneia e restaura arquivos essenciais corrompidos do Windows.
echo   %GRAY%Tempo estimado: 5 a 15 minutos.%RESET%
echo.
choice /c SN /m "%ESC%[93mExecutar esta etapa? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo   %YELLOW%[PULADO]%RESET% %GRAY%Etapa ignorada.%RESET%
    echo [PULADO] SFC Scannow >> "%LOG%"
    timeout /t 1 >nul
    exit /b
)
echo.
echo   %CYAN%[%RESET%...%CYAN%]%RESET% Verificando arquivos protegidos do sistema...
echo [5/5] SFC Scannow - Início: %time% >> "%LOG%"
sfc /scannow >> "%LOG%" 2>&1
echo [5/5] Concluído >> "%LOG%"
echo   %GREEN%[ OK ]%RESET% Verificação finalizada com sucesso!
echo.
pause
exit /b

:: ========================================================
:: 6. TELA DE FINALIZACAO
:: ========================================================
:Finalizacao
cls
echo.
echo  %GREEN%%SEP%%RESET%
echo   %BOLD%%GREEN%Manutenção Finalizada com Sucesso!%RESET%
echo  %GREEN%%SEP%%RESET%
echo.
echo   Relatório salvo em:
echo   %CYAN%%LOG%%RESET%
echo.
echo Fim: %date% %time% >> "%LOG%"
choice /c SN /m "%ESC%[96mVoltar ao menu principal? [S/N]: %ESC%[0m"
if errorlevel 2 goto :Encerrar
goto :Menu

:Encerrar
cls
echo.
echo   %GRAY%Saindo da Central de Manutenção...%RESET%
echo.
timeout /t 1 >nul
exit
