@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================================
:: Diagnóstico e Otimização Segura de Rede para Jogos - Windows 11
:: ============================================================================

title Diagnostico e Otimizacao de Rede - Jogos Windows 11
color 0B

:: 1. Verificacao e Auto-Elevacao de Privilegios Administrativos via UAC
net session >nul 2>&1
if not "%errorlevel%"=="0" (
    echo.
    echo [!] Solicitando privilegios de Administrador...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

set "LOG=%USERPROFILE%\Desktop\Diagnostico_Rede_Jogos.txt"

:MENU
cls
echo ================================================================
echo   DIAGNÓSTICO E OTIMIZAÇÃO DE REDE PARA JOGOS - WINDOWS 11
echo ================================================================
echo.
echo  [1] Diagnosticar conexao completa e salvar relatorio detalhado
echo  [2] Limpeza rapida: Limpar cache DNS (ipconfig /flushdns)
echo  [3] Renovacao completa: FlushDNS + Release + Renew de IP
echo  [4] Redefinir catalogo Winsock e pilha TCP/IP (Requer reboot)
echo  [5] Abrir ultimo relatorio gerado na Area de Trabalho
echo  [6] Sair
echo.
echo ================================================================
choice /c 123456 /n /m "Escolha uma opcao [1-6]: "

if errorlevel 6 goto FIM
if errorlevel 5 goto ABRIR_LOG
if errorlevel 4 goto RESET_REDE
if errorlevel 3 goto RENOVAR_IP
if errorlevel 2 goto FLUSH_DNS
if errorlevel 1 goto DIAGNOSTICO

:DIAGNOSTICO
cls
echo ================================================================
echo   EXECUTANDO DIAGNÓSTICO DE REDE (LATÊNCIA, JITTER E ROTAS)
echo ================================================================
echo.
echo    [!] O QUE ESTE TESTE FAZ:
echo    ----------------------------------------------------------
echo    1. Mede estabilidade com seu roteador local (cabo/Wi-Fi).
echo    2. Dispara 30 pacotes para Cloudflare (1.1.1.1) medindo jitter.
echo    3. Dispara 15 pacotes para Google (8.8.8.8) para comparacao.
echo    4. Mapeia a rota ate o destino para achar saltos com lag.
echo.
echo    [!] ARQUIVO DE LOG:
echo    ----------------------------------------------------------
echo    Gravando relatorio em tempo real em:
echo    %LOG%
echo.
echo    Tempo estimado: 1 a 2 minutos. Aguarde...
echo ================================================================
echo.

(
    echo ================================================================
    echo RELATÓRIO DE DIAGNÓSTICO DE REDE PARA JOGOS
    echo Data e Hora: %date% %time%
    echo Computador: %COMPUTERNAME% ^| Usuario: %USERNAME%
    echo ================================================================
    echo.
    echo [1] CONFIGURACAO DE ADAPTADORES E IP
    echo ----------------------------------------------------------------
    ipconfig /all
    echo.
) > "%LOG%"

echo [Etapa 1/4] Identificando Gateway Local (Roteador)...
set "GW="
for /f "tokens=3" %%A in ('route print 0.0.0.0 2^>nul ^| findstr /c:" 0.0.0.0 "') do (
    if not defined GW set "GW=%%A"
)

(
    echo [2] TESTE DE COMUNICAÇÃO LOCAL (ROTEADOR / GATEWAY)
    echo ----------------------------------------------------------------
) >> "%LOG%"

if defined GW (
    echo  -^> Gateway detectado no IP: %GW%
    echo  -^> Disparando 30 pacotes para teste de jitter local...
    (
        echo Gateway: %GW%
        ping -n 30 %GW%
        echo.
    ) >> "%LOG%"
    echo   [OK] Concluido.
) else (
    echo  [!] Gateway padrao nao encontrado automaticamente.
    (
        echo [!] Gateway padrao nao encontrado.
        echo.
    ) >> "%LOG%"
)

echo.
echo [Etapa 2/4] Testando latencia com a Internet (Cloudflare 1.1.1.1)...
echo  -^> Disparando 30 pacotes...
(
    echo [3] TESTE DE LATENCIA E PERDA EXTERNA (Cloudflare 1.1.1.1)
    echo ----------------------------------------------------------------
    ping -n 30 1.1.1.1
    echo.
) >> "%LOG%"
echo   [OK] Concluido.

echo.
echo [Etapa 3/4] Testando latencia com DNS alternativo (Google 8.8.8.8)...
echo  -^> Disparando 15 pacotes...
(
    echo [4] TESTE DE LATENCIA E PERDA EXTERNA (Google 8.8.8.8)
    echo ----------------------------------------------------------------
    ping -n 15 8.8.8.8
    echo.
) >> "%LOG%"
echo   [OK] Concluido.

echo.
echo [Etapa 4/4] Rastreando rota de pacotes (Tracert 1.1.1.1)...
echo  -^> Mapeando saltos da operadora (pode levar 30 segundos)...
(
    echo [5] RASTREAMENTO DE SALTOS E ROTAS (Tracert 1.1.1.1)
    echo ----------------------------------------------------------------
    tracert -d -h 20 -w 700 1.1.1.1
    echo.
    echo ================================================================
    echo FIM DO DIAGNÓSTICO
    echo ================================================================
) >> "%LOG%"
echo   [OK] Concluido.

echo.
echo ================================================================
echo  [OK] Diagnostico concluido com sucesso!
echo  Arquivo salvo em: %LOG%
echo ================================================================
echo.
choice /c SN /n /m "Deseja abrir o relatorio agora? [S/N]: "
if errorlevel 2 goto MENU
start notepad "%LOG%"
goto MENU

:FLUSH_DNS
cls
echo ================================================================
echo   LIMPEZA DE CACHE DNS
echo ================================================================
echo.
echo Limpando a tabela de resolucao de nomes DNS local...
ipconfig /flushdns
echo.
echo [OK] Cache DNS limpo com sucesso.
echo (Nota: Isso resolve problemas de conexao com servidores, mas nao reduz ping em partidas em andamento).
echo.
pause
goto MENU

:RENOVAR_IP
cls
echo ================================================================
echo   RENOVAÇÃO DE ENDEREÇO IP E CACHE DNS
echo ================================================================
echo.
echo 1. Limpando cache DNS...
ipconfig /flushdns >nul
echo 2. Liberando conexao atual (Release)...
ipconfig /release >nul
echo 3. Solicitando novo endereco ao roteador (Renew)...
ipconfig /renew >nul
echo.
echo [OK] Configuracoes de IP e DNS renovadas com sucesso!
echo.
pause
goto MENU

:RESET_REDE
cls
echo ================================================================
echo   REDEFINIÇÃO DO WINSOCK E PILHA TCP/IP
echo ================================================================
echo.
echo [ATENÇÃO]
echo Esta acao redefine a pilha de protocolos de rede e o catalogo Winsock.
echo Ela e recomendada para corrigir falhas graves de comunicacao, conflitos
echo com VPNs antigas ou quedas frequentes de pacotes.
echo.
echo * Salve suas tarefas abertas.
echo * O computador precisara ser reiniciado ao final.
echo.
choice /c SN /n /m "Deseja realmente continuar? [S/N]: "
if errorlevel 2 goto MENU

echo.
echo Executando 'netsh winsock reset'...
netsh winsock reset
echo.
echo Executando 'netsh int ip reset'...
netsh int ip reset
echo.
echo [CONCLUÍDO] Catalogo e pilha de rede redefinidos com sucesso.
echo.
choice /c SN /n /m "Deseja reiniciar o computador agora? [S/N]: "
if errorlevel 2 (
    echo.
    echo Lembre-se de reiniciar manualmente mais tarde para aplicar as mudancas.
    pause
    goto MENU
)
shutdown /r /t 5 /c "Reiniciando para aplicar a redefinicao de rede..."
exit /b 0

:ABRIR_LOG
if exist "%LOG%" (
    start notepad "%LOG%"
) else (
    echo.
    echo [!] Nenhum relatorio foi gerado ainda. Execute a opcao [1] primeiro.
    pause
)
goto MENU

:FIM
endlocal
exit /b 0
