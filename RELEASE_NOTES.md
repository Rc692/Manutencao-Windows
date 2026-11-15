# 🚀 Release Notes - v2.2.0

## 📦 Central de Manutenção do Windows & Diagnóstico de Rede para Jogos

Esta versão traz uma grande expansão nas ferramentas de **Diagnóstico de Conexão, Redução de Latência (Lag/Jitter) e Reparo da Pilha de Rede** para o Windows 11, além de correções de robustez técnica em todos os scripts.

---

### ✨ Novidades e Recursos Adicionados

#### 🌐 1. Diagnóstico de Rede e Latência para Jogos (Módulo 11)
* **Comunicação Local (Gateway/Roteador):** Testa a estabilidade do cabo ou Wi-Fi disparando 30 pacotes para o seu roteador, identificando se a oscilação de conexão está dentro de casa.
* **Latência e Perda Externa (Cloudflare e Google):** Dispara 30 pacotes para `1.1.1.1` e 15 pacotes para `8.8.8.8` para medir a média de ping e detectar perda de pacotes (*packet loss*).
* **Mapeamento de Rotas (`tracert`):** Analisa os saltos intermediários da sua operadora (ISP) até a internet, ajudando a identificar se o lag em jogos é problema de rota.
* **Registro Completo em Log:** Todo o relatório é automaticamente registrado no log na Área de Trabalho com data e hora.

#### 🔄 2. Redefinição de Catálogo Winsock e Pilha TCP/IP (Módulo 12)
* Executa a redefinição profunda da pilha de rede (`netsh winsock reset` e `netsh int ip reset`).
* Soluciona problemas de conexão causados por resíduos de VPNs, falhas de DHCP ou travamentos misteriosos de adaptadores.
* Pergunta de forma assistida se o usuário deseja reiniciar o computador ao término.

#### 🎮 3. Novo Script Dedicado: `Diagnostico_Rede_Jogos.bat`
* Script independente e portátil projetado especificamente para gamers executarem antes ou durante partidas competitivas.
* Menu direto para:
  1. Diagnóstico completo com salvamento de relatório na Área de Trabalho.
  2. Limpeza rápida de cache DNS (`ipconfig /flushdns`).
  3. Renovação completa de concessão DHCP (`FlushDNS + Release + Renew`).
  4. Redefinição de rede (Winsock/TCP-IP).
  5. Abertura direta do último relatório gerado.

---

### 🔧 Correções e Melhorias Técnicas

* **Detecção Ultrarrápida de Gateway:** Substituição de chamadas lentas do PowerShell pela consulta direta à tabela de rotas nativa do Windows (`route print 0.0.0.0`), eliminando falhas de parênteses no interpretador CMD.
* **Auto-Elevação UAC Inteligente:** Ambos os scripts solicitam privilégios de Administrador automaticamente via UAC caso abertos por clique duplo comum.
* **Proteção contra Redirecionamento de Arquivos:** Ajuste em todos os caracteres de seta do terminal (`-^>`), evitando a criação acidental de arquivos temporários no diretório.
* **Feedback Visual em Tempo Real:** Tela informativa antes do início do diagnóstico de rede detalhando o que será testado, o tempo estimado e a localização exata do arquivo de log.
* **Ajuste Responsivo de Terminal:** Dimensões ajustadas para `cols=75 lines=36` para exibir o menu completo com 12 módulos sem barras de rolagem.

---

### 📥 Como Executar

1. Baixe o código ou clone o repositório:
   ```bash
   git clone https://github.com/Rc692/Manutencao-Windows.git
   ```
2. Para a suíte completa de manutenção e reparo do Windows, execute:
   * **`Manutencao_Windows.bat`**
3. Para diagnósticos e ajustes específicos de conexão e jogos, execute:
   * **`Diagnostico_Rede_Jogos.bat`**
4. Confirme a solicitação de Administrador na tela e escolha a opção desejada.
