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
mode con: cols=75 lines=32

:: ========================================================
:: DEFINICAO DE CORES ANSI E ESTILOS MODERNOS
:: ========================================================
for /f %%a in ('powershell -NoProfile -Command "[char]27"') do set "ESC=%%a"

set "RESET=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "ITALIC=%ESC%[3m"
set "UNDERLINE=%ESC%[4m"

:: Cores de Texto
set "WHITE=%ESC%[97m"
set "CYAN=%ESC%[96m"
set "BLUE=%ESC%[94m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "GRAY=%ESC%[90m"

:: Fundos (Badges)
set "BG_BLUE=%ESC%[44m"
set "BG_DARK=%ESC%[100m"

:: ========================================================
:: 1. VERIFICACAO DE ADMINISTRADOR
:: ========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo  %RED%╔═════════════════════════════════════════════════════════════════════╗%RESET%
    echo  %RED%║  ✖  ACESSO NEGADO - PRIVILÉGIOS DE ADMINISTRADOR NECESSÁRIOS        ║%RESET%
    echo  %RED%╚═════════════════════════════════════════════════════════════════════╝%RESET%
    echo.
    echo  %WHITE%Solicitando elevação de privilégios automaticamente...%RESET%
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
:: 3. MENU PRINCIPAL COM DESIGN MODERNO
:: ========================================================
:Menu
cls
echo.
echo  %CYAN%╔═════════════════════════════════════════════════════════════════════╗%RESET%
echo  %CYAN%║%BOLD%%WHITE%   ⚡ CENTRAL DE MANUTENÇÃO E OTIMIZAÇÃO DO WINDOWS               %RESET%%CYAN%║%RESET%
echo  %CYAN%╚═════════════════════════════════════════════════════════════════════╝%RESET%
echo   %GRAY%Arquivo de Log:%RESET% %CYAN%%LOG%%RESET%
echo.
echo   %BOLD%%WHITE%SELECIONE O MODO DE OPERAÇÃO:%RESET%
echo.
echo   %CYAN%[1]%RESET% %BOLD%🚀 Manutenção Completa%RESET%  %GRAY%(Passo a passo guiado com confirmação)%RESET%
echo.
echo   %GRAY%── MÓDULOS INDIVIDUAIS ──────────────────────────────────────────%RESET%
echo   %CYAN%[2]%RESET%  🧹  %WHITE%[1/5] Arquivos Temporários do Usuário%RESET% %GRAY%(%%TEMP%%)%RESET%
echo   %CYAN%[3]%RESET%  🗑️   %WHITE%[2/5] Arquivos Temporários do Windows%RESET% %GRAY%(C:\Windows\Temp)%RESET%
echo   %CYAN%[4]%RESET%  📦  %WHITE%[3/5] Limpeza de Componentes Antigos%RESET% %GRAY%(DISM WinSxS)%RESET%
echo   %CYAN%[5]%RESET%  🛡️   %WHITE%[4/5] Reparo da Imagem do Sistema%RESET%    %GRAY%(DISM RestoreHealth)%RESET%
echo   %CYAN%[6]%RESET%  🔍  %WHITE%[5/5] Verificador de Arquivos (SFC)%RESET%    %GRAY%(sfc /scannow)%RESET%
echo.
echo   %GRAY%─────────────────────────────────────────────────────────────────%RESET%
echo   %RED%[0]%RESET%  🚪  %GRAY%Encerrar Script%RESET%
echo.
choice /c 1234560 /n /m "%ESC%[96m➤ Escolha uma opção [0 a 6]: %ESC%[0m"

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
echo  %BLUE%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %BLUE%│%BOLD%%WHITE%  🚀 INICIANDO FLUXO COMPLETO DE MANUTENÇÃO                      %RESET%%BLUE%│%RESET%
echo  %BLUE%└──────────────────────────────────────────────────────────────────┘%RESET%
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
:: 5. CARDS DE COMPONENTES COM VISUAL MODERNO
:: ========================================================

:Executar_TempUser
cls
echo.
echo  %CYAN%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %CYAN%│%BOLD%%WHITE%  [1/5] 🧹 ARQUIVOS TEMPORÁRIOS DO USUÁRIO                         %RESET%%CYAN%│%RESET%
echo  %CYAN%├──────────────────────────────────────────────────────────────────┤%RESET%
echo  %CYAN%│%RESET%  %BOLD%O que faz:%RESET%   Remove caches, logs e arquivos de sessões antigas      %CYAN%│%RESET%
echo  %CYAN%│%RESET%             criadas por navegadores e programas no %%TEMP%%.          %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Segurança:%RESET%  %GREEN%● 100%% Seguro%RESET% (Não apaga fotos, vídeos ou docs).        %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Tempo:%RESET%      %YELLOW%⚡ Quase instantâneo (poucos segundos)%RESET%                  %CYAN%│%RESET%
echo  %CYAN%└──────────────────────────────────────────────────────────────────┘%RESET%
echo.
choice /c SN /m "%ESC%[93m? Deseja executar este componente agora? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo  %YELLOW%[ ↷ PULADO ]%RESET% %GRAY%Etapa ignorada pelo usuário.%RESET%
    echo [PULADO] Arquivos temporários do usuário >> "%LOG%"
    timeout /t 2 >nul
    exit /b
)
echo.
echo  %CYAN%[ ⏳ EXECUTANDO ]%RESET% Limpando diretório de temporários...
echo [1/5] Arquivos temporários do usuário - Início: %time% >> "%LOG%"
del /f /s /q "%TEMP%\*" >> "%LOG%" 2>&1
echo [1/5] Concluído >> "%LOG%"
echo  %GREEN%[ ✔ CONCLUÍDO ]%RESET% Limpeza do usuário finalizada!
echo.
pause
exit /b

:Executar_TempWin
cls
echo.
echo  %CYAN%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %CYAN%│%BOLD%%WHITE%  [2/5] 🗑️  ARQUIVOS TEMPORÁRIOS DO SISTEMA (WINDOWS)              %RESET%%CYAN%│%RESET%
echo  %CYAN%├──────────────────────────────────────────────────────────────────┤%RESET%
echo  %CYAN%│%RESET%  %BOLD%O que faz:%RESET%   Limpa instaladores residuais, relatórios de erro e     %CYAN%│%RESET%
echo  %CYAN%│%RESET%             arquivos de despejo na pasta C:\Windows\Temp.          %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Segurança:%RESET%  %GREEN%● Seguro%RESET% (Arquivos em uso pelo sistema são ignorados).   %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Tempo:%RESET%      %YELLOW%⚡ Rápido (menos de 1 minuto)%RESET%                         %CYAN%│%RESET%
echo  %CYAN%└──────────────────────────────────────────────────────────────────┘%RESET%
echo.
choice /c SN /m "%ESC%[93m? Deseja executar a limpeza do Windows Temp? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo  %YELLOW%[ ↷ PULADO ]%RESET% %GRAY%Etapa ignorada pelo usuário.%RESET%
    echo [PULADO] Arquivos temporários do Windows >> "%LOG%"
    timeout /t 2 >nul
    exit /b
)
echo.
echo  %CYAN%[ ⏳ EXECUTANDO ]%RESET% Limpando arquivos do sistema...
echo [2/5] Arquivos temporários do Windows - Início: %time% >> "%LOG%"
del /f /s /q "%windir%\Temp\*" >> "%LOG%" 2>&1
echo [2/5] Concluído >> "%LOG%"
echo  %GREEN%[ ✔ CONCLUÍDO ]%RESET% Limpeza do sistema finalizada!
echo.
pause
exit /b

:Executar_DISMCleanup
cls
echo.
echo  %CYAN%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %CYAN%│%BOLD%%WHITE%  [3/5] 📦 LIMPEZA DE COMPONENTES ANTIGOS (DISM)                   %RESET%%CYAN%│%RESET%
echo  %CYAN%├──────────────────────────────────────────────────────────────────┤%RESET%
echo  %CYAN%│%RESET%  %BOLD%O que faz:%RESET%   Limpa versões obsoletas de componentes da pasta WinSxS %CYAN%│%RESET%
echo  %CYAN%│%RESET%             deixadas por atualizações anteriores do Windows Update. %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Benefício:%RESET%  Recupera gigabytes de espaço valioso no disco C:.      %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Tempo:%RESET%      %YELLOW%⏱️ Médio (3 a 8 minutos)%RESET%                              %CYAN%│%RESET%
echo  %CYAN%└──────────────────────────────────────────────────────────────────┘%RESET%
echo.
choice /c SN /m "%ESC%[93m? Deseja limpar os componentes obsoletos? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo  %YELLOW%[ ↷ PULADO ]%RESET% %GRAY%Etapa ignorada pelo usuário.%RESET%
    echo [PULADO] DISM StartComponentCleanup >> "%LOG%"
    timeout /t 2 >nul
    exit /b
)
echo.
echo  %CYAN%[ ⏳ EXECUTANDO ]%RESET% Processando WinSxS (isto pode levar alguns minutos)...
echo [3/5] DISM StartComponentCleanup - Início: %time% >> "%LOG%"
DISM /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
echo [3/5] Concluído >> "%LOG%"
echo  %GREEN%[ ✔ CONCLUÍDO ]%RESET% Limpeza de componentes finalizada!
echo.
pause
exit /b

:Executar_DISMRestore
cls
echo.
echo  %CYAN%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %CYAN%│%BOLD%%WHITE%  [4/5] 🛡️  REPARO DE IMAGEM DO WINDOWS (RESTOREHEALTH)             %RESET%%CYAN%│%RESET%
echo  %CYAN%├──────────────────────────────────────────────────────────────────┤%RESET%
echo  %CYAN%│%RESET%  %BOLD%O que faz:%RESET%   Compara o repositório do sistema com os servidores da  %CYAN%│%RESET%
echo  %CYAN%│%RESET%             Microsoft e baixa cópias limpas para corrigir danos.   %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Atenção:%RESET%    %WHITE%Requer conexão com a internet ativa.%RESET%                  %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Tempo:%RESET%      %YELLOW%⏳ Longo (10 a 20 minutos. Normal parecer lento em 20%%)%RESET% %CYAN%│%RESET%
echo  %CYAN%└──────────────────────────────────────────────────────────────────┘%RESET%
echo.
choice /c SN /m "%ESC%[93m? Deseja executar a verificação de imagem? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo  %YELLOW%[ ↷ PULADO ]%RESET% %GRAY%Etapa ignorada pelo usuário.%RESET%
    echo [PULADO] DISM RestoreHealth >> "%LOG%"
    timeout /t 2 >nul
    exit /b
)
echo.
echo  %CYAN%[ ⏳ EXECUTANDO ]%RESET% Verificando e baixando arquivos de reparo (aguarde)...
echo [4/5] DISM RestoreHealth - Início: %time% >> "%LOG%"
DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
echo [4/5] Concluído >> "%LOG%"
echo  %GREEN%[ ✔ CONCLUÍDO ]%RESET% Verificação e reparo de imagem concluídos!
echo.
pause
exit /b

:Executar_SFC
cls
echo.
echo  %CYAN%┌──────────────────────────────────────────────────────────────────┐%RESET%
echo  %CYAN%│%BOLD%%WHITE%  [5/5] 🔍 VERIFICADOR DE ARQUIVOS DO SISTEMA (SFC)                 %RESET%%CYAN%│%RESET%
echo  %CYAN%├──────────────────────────────────────────────────────────────────┤%RESET%
echo  %CYAN%│%RESET%  %BOLD%O que faz:%RESET%   Escaneia e restaura arquivos essenciais corrompidos   %CYAN%│%RESET%
echo  %CYAN%│%RESET%             como DLLs, drivers e serviços nativos do Windows.     %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Benefício:%RESET%  Corrige travamentos no Explorer, telas azuis e falhas. %CYAN%│%RESET%
echo  %CYAN%│%RESET%  %BOLD%Tempo:%RESET%      %YELLOW%⏱️ Médio (5 a 15 minutos)%RESET%                             %CYAN%│%RESET%
echo  %CYAN%└──────────────────────────────────────────────────────────────────┘%RESET%
echo.
choice /c SN /m "%ESC%[93m? Deseja executar o SFC /scannow agora? [S/N]: %ESC%[0m"
if errorlevel 2 (
    echo.
    echo  %YELLOW%[ ↷ PULADO ]%RESET% %GRAY%Etapa ignorada pelo usuário.%RESET%
    echo [PULADO] SFC Scannow >> "%LOG%"
    timeout /t 2 >nul
    exit /b
)
echo.
echo  %CYAN%[ ⏳ EXECUTANDO ]%RESET% Escaneando integridade dos arquivos do sistema...
echo [5/5] SFC Scannow - Início: %time% >> "%LOG%"
sfc /scannow >> "%LOG%" 2>&1
echo [5/5] Concluído >> "%LOG%"
echo  %GREEN%[ ✔ CONCLUÍDO ]%RESET% Varredura do SFC finalizada com sucesso!
echo.
pause
exit /b

:: ========================================================
:: 6. TELA DE FINALIZACAO
:: ========================================================
:Finalizacao
cls
echo.
echo  %GREEN%╔═════════════════════════════════════════════════════════════════════╗%RESET%
echo  %GREEN%║%BOLD%%WHITE%   ✔ PROCESSO DE MANUTENÇÃO FINALIZADO COM SUCESSO!               %RESET%%GREEN%║%RESET%
echo  %GREEN%╚═════════════════════════════════════════════════════════════════════╝%RESET%
echo.
echo   %WHITE%O relatório completo de execução foi gravado em:%RESET%
echo   %CYAN%%LOG%%RESET%
echo.
echo Fim: %date% %time% >> "%LOG%"
choice /c SN /m "%ESC%[96m➤ Deseja voltar ao menu principal? [S/N]: %ESC%[0m"
if errorlevel 2 goto :Encerrar
goto :Menu

:Encerrar
cls
echo.
echo   %GRAY%Saindo da Central de Manutenção... Até logo!%RESET%
echo.
timeout /t 2 >nul
exit
