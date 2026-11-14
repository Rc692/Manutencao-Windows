# ⚡ Scripts de TI e Manutenção do Windows

Conjunto de scripts automatizados e interativos para suporte e manutenção de sistemas Windows.

## 🛠️ Manutencao_Windows.bat

Script interativo com interface moderna em terminal para limpeza, integridade e otimização do sistema operacional.

### Recursos:
- **Auto-elevação**: Solicita permissões de Administrador automaticamente se necessário.
- **Interface Visual Moderna**: Cores ANSI, ícones e caixas informativas (UTF-8).
- **Confirmação Passo a Passo**: Permite aprovar ou pular cada etapa com `[S/N]`.
- **Módulos Independentes**:
    1. Limpeza de Temporários do Usuário (`%TEMP%`)
    2. Limpeza de Temporários do Windows (`C:\Windows\Temp`)
    3. Otimização da pasta WinSxS (`DISM StartComponentCleanup`)
    4. Reparo da imagem do sistema (`DISM RestoreHealth`)
    5. Varredura e restauração de arquivos protegidos (`SFC /scannow`)
- **Geração de Log**: Salva relatório detalhado na Área de Trabalho ao término.

### Como Executar:
1. Clique duas vezes no arquivo `Manutencao_Windows.bat` (ou execute pelo terminal).
2. Conceda a permissão de Administrador quando solicitado.
3. Escolha uma opção do menu principal.