:: ################################################################
:: ##               Central de Manutenção Windows                ##
:: ################################################################
:: # Author:  https://github.com/Rc692
:: # Repo:    https://github.com/Rc692/Manutencao-Windows
:: # SPDX-License-Identifier: MIT
:: # Version: 2.1.0
:: #
:: # Script interativo para suporte, limpeza e manutenção do Windows
:: # Utiliza apenas comandos e ferramentas nativas do sistema.
:: ################################################################

@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Central de Manutenção do Windows
mode con: cols=75 lines=33
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
echo      [1]  Manutencao Completa (executa todos os modulos recomendados)
echo.
echo    LIMPEZA DE DISCO E CACHES
echo      [2]  Arquivos Temporarios (Usuario e Sistema + Subpastas)
echo      [3]  Cache de Atualizacoes do Windows Update (Download)
echo      [4]  Esvaziar Lixeira do Sistema
echo.
echo    INTEGRIDADE E REPARO DO SISTEMA
echo      [5]  Reparo de Imagem do Sistema (DISM RestoreHealth)
echo      [6]  Verificacao de Arquivos Protegidos (SFC /scannow)
echo      [7]  Otimizacao de Componentes Antigos (DISM WinSxS)
echo.
echo    DESEMPENHO E REDE
echo      [8]  Otimizacao TRIM de SSD e Desfragmentacao de HDD
echo      [9]  Varredura Online de Integridade do Disco (CHKDSK)
echo      [10] Limpeza do Cache de Rede e DNS (FlushDNS)
echo.
echo      [0]  Sair
echo.
echo  +--------------------------------------------------------------+
set "opcao="
set /p "opcao=  Escolha uma opcao [1-10, 0]: "

if "%opcao%"=="1" goto rotina_completa
if "%opcao%"=="2" goto mod_temp
if "%opcao%"=="3" goto mod_winupdate
if "%opcao%"=="4" goto mod_lixeira
if "%opcao%"=="5" goto mod_dism_restore
if "%opcao%"=="6" goto mod_sfc
if "%opcao%"=="7" goto mod_dism_cleanup
if "%opcao%"=="8" goto mod_defrag
if "%opcao%"=="9" goto mod_chkdsk
if "%opcao%"=="10" goto mod_dns
if "%opcao%"=="0" goto sair
echo.
echo  Opcao invalida. Tente novamente.
timeout /t 2 >nul
goto menu

:: ========================================================
:: ROTINA COMPLETA
:: ========================================================
:rotina_completa
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^|                INICIANDO MANUTENCAO COMPLETA                 ^|
echo  +--------------------------------------------------------------+
echo.
echo    Todos os modulos serao executados na sequencia recomendada.
echo.
timeout /t 2 >nul
set "fluxo_completo=1"
call :mod_temp
call :mod_winupdate
call :mod_lixeira
call :mod_dns
call :mod_dism_restore
call :mod_sfc
call :mod_dism_cleanup
call :mod_defrag
call :mod_chkdsk
set "fluxo_completo=0"
goto finalizado

:: ========================================================
:: MODULOS INDIVIDUAIS
:: ========================================================

:mod_temp
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| ARQUIVOS TEMPORARIOS (USUARIO E SISTEMA + SUBPASTAS)          ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Remove arquivos residuais e subpastas de %%TEMP%%
echo               e da pasta C:\Windows\Temp.
echo    Seguranca: Seguro (arquivos em uso sao preservados).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Limpando arquivos e pastas temporarias...
    echo [Temporarios] Inicio: %time% >> "%LOG%"
    del /f /s /q "%TEMP%\*" >> "%LOG%" 2>&1
    for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" >> "%LOG%" 2>&1
    del /f /s /q "%windir%\Temp\*" >> "%LOG%" 2>&1
    for /d %%D in ("%windir%\Temp\*") do rd /s /q "%%D" >> "%LOG%" 2>&1
    echo [Temporarios] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Limpeza de temporarios concluida com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Temporarios >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_winupdate
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| CACHE DE ATUALIZACOES DO WINDOWS UPDATE                     ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Remove instaladores residuais de atualizacoes
echo               antigas em SoftwareDistribution\Download.
echo    Beneficio: Costuma liberar entre 5 GB e 30 GB de espaco.
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Pausando servicos de atualizacao...
    net stop wuauserv >> "%LOG%" 2>&1
    net stop bits >> "%LOG%" 2>&1
    echo  Apagando arquivos de cache do Windows Update...
    del /f /s /q "%windir%\SoftwareDistribution\Download\*.*" >> "%LOG%" 2>&1
    for /d %%D in ("%windir%\SoftwareDistribution\Download\*") do rd /s /q "%%D" >> "%LOG%" 2>&1
    echo  Reiniciando servicos de atualizacao...
    net start bits >> "%LOG%" 2>&1
    net start wuauserv >> "%LOG%" 2>&1
    echo [Windows Update Cache] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Limpeza do cache do Windows Update concluida!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Windows Update Cache >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_lixeira
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| ESVAZIAR LIXEIRA DO SISTEMA                                  ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Esvazia as lixeiras de todos os discos locais.
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Esvaziando lixeira de todas as unidades...
    echo [Lixeira] Inicio: %time% >> "%LOG%"
    powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >> "%LOG%" 2>&1
    echo [Lixeira] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Lixeira esvaziada com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Lixeira >> "%LOG%"
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
echo  ^| REPARO DE IMAGEM DO SISTEMA (DISM RESTOREHEALTH)             ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Baixa componentes novos da Microsoft para corrigir danos.
echo    Atencao:   Requer internet ativa. Tempo: 10 a 20 minutos.
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Verificando e reparando imagem do Windows - aguarde...
    echo [DISM RestoreHealth] Inicio: %time% >> "%LOG%"
    DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG%" 2>&1
    echo [DISM RestoreHealth] Concluido >> "%LOG%"
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
echo  ^| VERIFICACAO DE ARQUIVOS DO SISTEMA (SFC /SCANNOW)            ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Escaneia e restaura arquivos corrompidos do Windows.
echo    Tempo:     Medio (5 a 15 minutos).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Escaneando integridade dos arquivos do sistema...
    echo [SFC Scannow] Inicio: %time% >> "%LOG%"
    sfc /scannow >> "%LOG%" 2>&1
    echo [SFC Scannow] Concluido >> "%LOG%"
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

:mod_dism_cleanup
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| OTIMIZACAO DE COMPONENTES ANTIGOS (DISM WINSXS)              ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Limpa versoes obsoletas de atualizacoes antigas.
echo    Tempo:     Medio (3 a 8 minutos).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Otimizando componentes - aguarde alguns minutos...
    echo [DISM StartComponentCleanup] Inicio: %time% >> "%LOG%"
    DISM /Online /Cleanup-Image /StartComponentCleanup >> "%LOG%" 2>&1
    echo [DISM StartComponentCleanup] Concluido >> "%LOG%"
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

:mod_defrag
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| OTIMIZACAO TRIM DE SSD E DESFRAGMENTACAO DE HDD             ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Envia comando TRIM para SSDs (restaura velocidade)
echo               ou desfragmenta se for disco rigido tradicional.
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Otimizando unidade do sistema: %SystemDrive%...
    echo [Defrag/TRIM] Inicio: %time% >> "%LOG%"
    defrag %SystemDrive% /O >> "%LOG%" 2>&1
    echo [Defrag/TRIM] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Otimizacao da unidade concluida com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] Defrag/TRIM >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_chkdsk
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| VARREDURA ONLINE DE DISCO (CHKDSK /SCAN)                     ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Verifica a saude do sistema de arquivos do disco
echo               em segundo plano (sem precisar reiniciar o PC).
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Realizando varredura online do disco: %SystemDrive%...
    echo [CHKDSK Scan] Inicio: %time% >> "%LOG%"
    chkdsk %SystemDrive% /scan >> "%LOG%" 2>&1
    echo [CHKDSK Scan] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Varredura de disco finalizada!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] CHKDSK Scan >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:mod_dns
cls
color 0B
echo.
echo  +--------------------------------------------------------------+
echo  ^| LIMPEZA DO CACHE DE REDE E DNS (FLUSHDNS)                    ^|
echo  +--------------------------------------------------------------+
echo.
echo    Descricao: Limpa o cache do resolvedor DNS do Windows.
echo    Beneficio: Corrige problemas de sites que nao carregam.
echo.
echo  +--------------------------------------------------------------+
set "confirma="
set /p "confirma=  Executar esta etapa agora? [S/N]: "
if /i "%confirma%"=="S" (
    echo.
    echo  Limpando cache de DNS...
    echo [FlushDNS] Inicio: %time% >> "%LOG%"
    ipconfig /flushdns >> "%LOG%" 2>&1
    echo [FlushDNS] Concluido >> "%LOG%"
    color 0A
    echo.
    echo  Cache de DNS limpo com sucesso!
) else (
    color 0E
    echo.
    echo  Etapa pulada pelo usuario.
    echo [PULADO] FlushDNS >> "%LOG%"
)
echo.
pause
color 0B
if "%fluxo_completo%"=="1" exit /b
goto menu

:: ========================================================
:: FINALIZACAO
:: ========================================================
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
