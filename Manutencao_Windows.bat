:: ################################################################
:: ##               Central de Manutenção Windows                ##
:: ################################################################
:: # Author:  https://github.com/Rc692
:: # Repo:    https://github.com/Rc692/Manutencao-Windows
:: # SPDX-License-Identifier: MIT
:: # Version: 2.0.0
:: #
:: # Script interativo para suporte, limpeza e manutenção do Windows
:: # Utiliza apenas comandos e ferramentas nativas do sistema.
:: ################################################################

@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Central de Manutenção do Windows
color 0B

:: 1. VERIFICACAO DE ADMINISTRADOR
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    cls
    echo.
    echo  +--------------------------------------------------------------+
    echo  ^|  ACESSO NEGADO - PRIVILEGIOS DE ADMINISTRADOR NECESSARIOS    ^|
    echo  +--------------------------------------------------------------+
    echo.
    echo    Solicitando permissao de Administrador automaticamente...
    echo.
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: 2. CRIACAO DO LOG NA AREA DE TRABALHO
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "DATA=%%I"
set "LOG=%USERPROFILE%\Desktop\Manutencao_%DATA%.log"
echo ============================================== > "%LOG%"
echo REGISTRO DE MANUTENCAO DO WINDOWS              >> "%LOG%"
echo Inicio: %date% %time%                          >> "%LOG%"
echo ============================================== >> "%LOG%"

set "fluxo_completo=0"

:menu
color 0B
cls
echo.
echo  +--------------------------------------------------------------+
echo  ^|               CENTRAL DE MANUTENCAO DO WINDOWS               ^|
echo  ^|           Limpeza, Otimizacao e Reparo do Sistema            ^|
echo  +--------------------------------------------------------------+
echo.
echo    Log: %LOG%
echo.
echo    FLUXO COMPLETO
echo      [1] Manutencao Completa (executa todos os modulos)
echo.
echo    MODULOS INDIVIDUAIS
echo      [2] Limpeza de Temporarios do Usuario (%%TEMP%%)
echo      [3] Limpeza de Temporarios do Windows (Temp)
echo      [4] Otimizacao de Componentes (DISM WinSxS)
echo      [5] Reparo de Imagem do Sistema (DISM)
echo      [6] Verificacao de Integridade (SFC /scannow)
echo.
echo      [0] Sair
echo.
echo  +--------------------------------------------------------------+
set "opcao="
set /p "opcao=  Escolha uma opcao [1-6, 0]: "

if "%opcao%"=="1" goto rotina_completa
if "%opcao%"=="2" goto mod_temp_user
if "%opcao%"=="3" goto mod_temp_win
if "%opcao%"=="4" goto mod_dism_cleanup
if "%opcao%"=="5" goto mod_dism_restore
if "%opcao%"=="6" goto mod_sfc
if "%opcao%"=="0" goto sair
echo.
echo  Opcao invalida. Tente novamente.
timeout /t 2 >nul
goto menu

:rotina_completa
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^|                INICIANDO MANUTENCAO COMPLETA                 ^|
echo  +--------------------------------------------------------------+
echo.
echo    Todos os 5 modulos serao executados passo a passo.
echo.
timeout /t 2 >nul
set "fluxo_completo=1"
call :mod_temp_user
call :mod_temp_win
call :mod_dism_cleanup
call :mod_dism_restore
call :mod_sfc
set "fluxo_completo=0"
goto finalizado

:mod_temp_user
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| [1/5] ARQUIVOS TEMPORARIOS DO USUARIO                        ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Remove caches e arquivos residuais em %%TEMP%%.
echo    Seguranca: 100%% Seguro (arquivos de uso pessoal preservados).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Limpando arquivos temporarios do usuario...
    echo [1/5] Temporarios do usuario - Inicio: %time% >> "%LOG%"
    del /f /s /q "%TEMP%\*" >> "%LOG%" 2>&1
    echo [1/5] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Limpeza do usuario concluida com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Temporarios do usuario >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_temp_win
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| [2/5] ARQUIVOS TEMPORARIOS DO SISTEMA (WINDOWS)              ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Limpa arquivos temporarios em C:\Windows\Temp.
echo    Seguranca: Seguro (arquivos em uso pelo sistema sao ignorados).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Limpando arquivos do sistema...
    echo [2/5] Temporarios do Windows - Inicio: %time% >> "%LOG%"
    del /f /s /q "%windir%\Temp\*" >> "%LOG%" 2>&1
    echo [2/5] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Limpeza do sistema concluida com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Temporarios do Windows >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_dism_cleanup
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| [3/5] OTIMIZACAO DE COMPONENTES ANTIGOS (DISM)                ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Limpa versoes obsoletas da pasta WinSxS.
echo    Tempo:     Medio (3 a 8 minutos).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Otimizando componentes - aguarde alguns minutos...
    echo [3/5] DISM StartComponentCleanup - Inicio: %time% >> "%LOG%"
    DISM /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
    echo [3/5] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Otimizacao finalizada com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] DISM StartComponentCleanup >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_dism_restore
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| [4/5] REPARO DE IMAGEM DO SISTEMA (RESTOREHEALTH)            ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Compara o sistema e baixa copias limpas da Microsoft.
echo    Atencao:   Requer internet. Tempo: 10 a 20 minutos (pode pausar).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Verificando e reparando imagem do Windows - aguarde...
    echo [4/5] DISM RestoreHealth - Inicio: %time% >> "%LOG%"
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
    echo [4/5] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Reparo de imagem concluido com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] DISM RestoreHealth >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_sfc
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| [5/5] VERIFICACAO DE INTEGRIDADE (SFC /SCANNOW)              ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Escaneia e recupera arquivos protegidos do Windows.
echo    Tempo:     Medio (5 a 15 minutos).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Escaneando integridade dos arquivos do sistema...
    echo [5/5] SFC Scannow - Inicio: %time% >> "%LOG%"
    sfc /scannow >> "%LOG%" 2>&1
    echo [5/5] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Varredura do SFC finalizada com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] SFC Scannow >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:finalizado
cls
color 0A
echo.
echo  +--------------------------------------------------------------+
echo  ^|              MANUTENCAO FINALIZADA COM SUCESSO!              ^|
echo  +--------------------------------------------------------------+
echo.
echo    O relatorio detalhado foi gravado em:
echo    %LOG%
echo.
echo  +--------------------------------------------------------------+
echo.
echo Fim: %date% %time% >> "%LOG%"
set "voltar="
set /p "voltar=  Deseja voltar ao menu principal? [S/N]: "
if /i "%voltar%"=="S" (
    color 0B
    goto menu
)
goto sair

:sair
color 07
cls
echo.
echo  Encerrando Central de Manutencao... Ate logo!
echo.
timeout /t 2 >nul
exit /b
