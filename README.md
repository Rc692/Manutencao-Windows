# ⚡ Scripts de TI e Manutenção do Windows

Conjunto de scripts automatizados e interativos para suporte, limpeza profunda e manutenção de sistemas Windows.

## 🛠️ Manutencao_Windows.bat

Script interativo via linha de comando para limpeza, integridade, reparo e otimização do sistema operacional utilizando exclusivamente ferramentas nativas do Windows.

### Recursos:
- **Auto-elevação**: Solicita permissões de Administrador automaticamente se necessário via UAC.
- **Interface Terminal Clássica**: Visual limpo, responsivo e padronizado em `color 0B` (Aqua).
- **Ordem Técnica Otimizada**: Segue a sequência oficial recomendada pela Microsoft para reparo (RestoreHealth → SFC → ComponentCleanup).
- **Confirmação Passo a Passo**: Permite aprovar ou pular cada etapa individualmente com `[S/N]`.
- **Módulos Disponíveis**:
    1. **Rotina Completa**: Executa todos os módulos na sequência técnica recomendada.
    2. **Temporários (%TEMP% e Windows\Temp)**: Remove arquivos e subpastas residuais.
    3. **Cache do Windows Update**: Libera gigabytes na pasta `SoftwareDistribution\Download`.
    4. **Esvaziar Lixeira**: Limpa lixeiras de todos os discos silenciosamente.
    5. **Reparo de Imagem (DISM RestoreHealth)**: Baixa componentes limpos para corrigir a imagem.
    6. **Verificação de Integridade (SFC /scannow)**: Restaura arquivos de sistema corrompidos.
    7. **Otimização de Componentes (DISM WinSxS)**: Remove versões antigas de atualizações.
    8. **Otimização TRIM / Defrag**: Otimiza SSDs com comando TRIM e desfragmenta HDDs.
    9. **Varredura Online de Disco (CHKDSK /scan)**: Analisa integridade do NTFS sem reiniciar o PC.
    10. **Limpeza de Cache DNS**: Resolve problemas de resolução de nomes e navegação.
    11. **Diagnóstico de Rede e Latência**: Mede estabilidade local (Gateway), internet (Cloudflare/Google) e rotas (Tracert) para jogos.
    12. **Redefinir Winsock e Pilha TCP/IP**: Corrige falhas severas de rede e conflitos com opção de reinício assistido.
- **Geração de Log**: Salva relatório detalhado na Área de Trabalho ao término (`Manutencao_YYYYMMDD_HHMMSS.log`).

### Como Executar:
1. Clique duas vezes no arquivo `Manutencao_Windows.bat` (ou execute pelo terminal).
2. Conceda a permissão de Administrador quando solicitado.
3. Digite o número da opção desejada e pressione Enter.

---

## 🎮 Diagnostico_Rede_Jogos.bat

Script especializado para testes de latência, estabilidade (jitter), perda de pacotes e reparo de pilha de rede para jogos online no Windows 11.

### Recursos:
- **Auto-elevação UAC**: Solicita automaticamente privilégios administrativos.
- **Diagnóstico Completo**:
  - Testa comunicação local com o Gateway padrão (roteador) com 30 disparos.
  - Testa latência e perda externa com Cloudflare (`1.1.1.1`) e Google (`8.8.8.8`).
  - Mapeia saltos de rota com `tracert` para identificar engargalos na operadora.
  - Salva relatório formatado direto na Área de Trabalho (`Diagnostico_Rede_Jogos.txt`).
- **Limpeza Rápida de Cache DNS**: `ipconfig /flushdns`.
- **Renovação de IP**: FlushDNS + Release + Renew de concessão DHCP.
- **Restauração de Rede (Winsock + TCP/IP)**: Redefine catálogos e pilha de rede com opção de reinício assistido.

