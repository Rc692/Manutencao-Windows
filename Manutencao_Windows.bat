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
mode con: cols=85 lines=34

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

:: Separadores Visuais
set "LINE_DOUBLE=═════════════════════════════════════════════════════════════════════════"
set "LINE_SINGLE=─────────────────────────────────────────────────────────────────────────"

:: ========================================================
:: 1. VERIFICACAO DE ADMINISTRADOR
:: ========================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo  %RED%%LINE_SINGLE%%RESET%
    echo   %BOLD%%RED%✖ ACESSO NEGADO - PRIVILÉGIOS DE ADMINISTRADOR NECESSÁRIOS%RESET%
    echo  %RED%%LINE_SINGLE%%RESET%
    echo.
    echo   %WHITE%Solicitando elevação de privilégios automaticamente...%RESET%
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
echo  %CYAN%%LINE_DOUBLE%%RESET%
echo   %BOLD%%WHITE%⚡ CENTRAL DE MANUTENÇÃO E OTIMIZAÇÃO DO WINDOWS%RESET%  %GRAY%(v1.0.0)%RESET%
echo  %CYAN%%LINE_DOUBLE%%RESET%
echo   %GRAY%Arquivo de Log:%RESET% %CYAN%%LOG%%RESET%
echo.
echo   %BOLD%%WHITE%FLUXO COMPLETO:%RESET%
echo    %CYAN%[1]%RESET% %BOLD%🚀 Manutenção Completa%RESET%  %GRAY%(Executa todos os 5 módulos com confirmação)%RESET%
echo.
echo   %BOLD%%WHITE%MÓDULOS INDIVIDUAIS:%RESET%
echo    %CYAN%[2]%RESET%  🧹 %WHITE%Limpeza de Temporários do Usuário%RESET% %GRAY%(%%TEMP%%)%RESET%
echo    %CYAN%[3]%RESET%  🗑️  %WHITE%Limpeza de Temporários do Sistema%RESET% %GRAY%(C:\Windows\Temp)%RESET%
echo    %CYAN%[4]%RESET%  📦 %WHITE%Otimização de Componentes WinSxS%RESET% %GRAY%(DISM StartComponentCleanup)%RESET%
echo    %CYAN%[5]%RESET%  🛡️  %WHITE%Reparo da Imagem do Sistema%RESET%    %GRAY%(DISM RestoreHealth)%RESET%
echo    %CYAN%[6]%RESET%  🔍 %WHITE%Verificador de Arquivos do Sistema%RESET% %GRAY%(SFC /scannow)%RESET%
echo.
echo  %GRAY%%LINE_SINGLE%%RESET%
echo   %RED%[0]%RESET%  🚪 %GRAY%Encerrar Script%RESET%
echo  %GRAY%%LINE_SINGLE%%RESET%
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
echo  %BLUE%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%🚀 INICIANDO FLUXO COMPLETO DE MANUTENÇÃO%RESET%
echo  %BLUE%%LINE_SINGLE%%RESET%
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
:: 5. CARDS DE COMPONENTES
:: ========================================================

:Executar_TempUser
cls
echo.
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%[1/5] 🧹 ARQUIVOS TEMPORÁRIOS DO USUÁRIO%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %CYAN%▌%RESET% %BOLD%O que faz:%RESET%   Remove caches, logs e arquivos de sessões antigas
echo   %CYAN%▌%RESET%             criadas por navegadores e programas no %%TEMP%%.
echo   %CYAN%▌%RESET% %BOLD%Segurança:%RESET%  %GREEN%● 100%% Seguro%RESET% (Não afeta documentos ou arquivos pessoais).
echo   %CYAN%▌%RESET% %BOLD%Tempo:%RESET%      %YELLOW%⚡ Quase instantâneo (poucos segundos)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
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
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%[2/5] 🗑️  ARQUIVOS TEMPORÁRIOS DO SISTEMA (WINDOWS)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %CYAN%▌%RESET% %BOLD%O que faz:%RESET%   Limpa instaladores residuais, relatórios de erro e
echo   %CYAN%▌%RESET%             arquivos de despejo na pasta C:\Windows\Temp.
echo   %CYAN%▌%RESET% %BOLD%Segurança:%RESET%  %GREEN%● Seguro%RESET% (Arquivos em uso pelo sistema são preservados).
echo   %CYAN%▌%RESET% %BOLD%Tempo:%RESET%      %YELLOW%⚡ Rápido (menos de 1 minuto)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
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
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%[3/5] 📦 OTIMIZAÇÃO DE COMPONENTES ANTIGOS (DISM)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %CYAN%▌%RESET% %BOLD%O que faz:%RESET%   Limpa versões obsoletas de componentes da pasta WinSxS
echo   %CYAN%▌%RESET%             deixadas por atualizações anteriores do Windows Update.
echo   %CYAN%▌%RESET% %BOLD%Benefício:%RESET%  Recupera gigabytes de espaço valioso no disco C:.
echo   %CYAN%▌%RESET% %BOLD%Tempo:%RESET%      %YELLOW%⏱️ Médio (3 a 8 minutos)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
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
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%[4/5] 🛡️  REPARO DE IMAGEM DO WINDOWS (RESTOREHEALTH)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %CYAN%▌%RESET% %BOLD%O que faz:%RESET%   Compara o repositório do sistema com os servidores da
echo   %CYAN%▌%RESET%             Microsoft e baixa cópias limpas para corrigir danos.
echo   %CYAN%▌%RESET% %BOLD%Atenção:%RESET%    %WHITE%Requer conexão com a internet ativa.%RESET%
echo   %CYAN%▌%RESET% %BOLD%Tempo:%RESET%      %YELLOW%⏳ Longo (10 a 20 minutos - normal parecer pausado)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
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
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %BOLD%%WHITE%[5/5] 🔍 VERIFICADOR DE ARQUIVOS DO SISTEMA (SFC)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
echo   %CYAN%▌%RESET% %BOLD%O que faz:%RESET%   Escaneia e restaura arquivos essenciais corrompidos
echo   %CYAN%▌%RESET%             como DLLs, drivers e serviços nativos do Windows.
echo   %CYAN%▌%RESET% %BOLD%Benefício:%RESET%  Corrige travamentos no Explorer, telas azuis e falhas do sistema.
echo   %CYAN%▌%RESET% %BOLD%Tempo:%RESET%      %YELLOW%⏱️ Médio (5 a 15 minutos)%RESET%
echo  %CYAN%%LINE_SINGLE%%RESET%
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
echo  %GREEN%%LINE_DOUBLE%%RESET%
echo   %BOLD%%WHITE%✔ PROCESSO DE MANUTENÇÃO FINALIZADO COM SUCESSO!%RESET%
echo  %GREEN%%LINE_DOUBLE%%RESET%
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
