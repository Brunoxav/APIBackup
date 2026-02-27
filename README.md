# Projeto 3 — Automação de Backup

Script em Python que copia arquivos automaticamente de uma pasta para outra e gera **logs de execução** com data e hora.

## Funcionalidades

- **Cópia automática** — Copia todos os arquivos da pasta origem para o destino (mantendo subpastas).
- **Logs de execução** — Cada execução gera um arquivo de log em `logs/` com timestamp, arquivos copiados e erros (se houver).
- **Uso prático** — Pode ser agendado no Windows (Agendador de Tarefas) para backup diário ou semanal.

## Demonstra

- ✔️ **Automação real** — Script pronto para rodar manualmente ou agendado.
- ✔️ **Uso prático para empresas** — Backup de pastas de trabalho, documentos ou dados.

## Como rodar

### Opção 1: Rodar com pastas de exemplo (primeira vez)

Na primeira execução, o script cria a pasta `exemplo_origem` com arquivos de teste e copia para `backup_destino`:

```bash
cd projeto3_backup
python backup.py
```

Ou use os atalhos:

- **Windows (PowerShell):** dê duplo clique em `rodar.ps1` ou execute `.\rodar.ps1`
- **Windows (CMD):** dê duplo clique em `rodar.bat` ou execute `rodar.bat`

### Opção 2: Especificar origem e destino

```bash
python backup.py "C:\Pasta\Origem" "D:\Backups\Destino"
```

### Opção 3: Só mudar a pasta de logs

```bash
python backup.py "C:\Origem" "D:\Backup" --logs "C:\LogsBackup"
```

## Onde ficam os logs

- Por padrão: pasta `logs/` dentro do projeto.
- Cada execução gera um arquivo: `backup_AAAA-MM-DD_HH-MM-SS.log`.
- O log mostra: data/hora, cada arquivo copiado e um resumo (quantidade copiada e erros).

## Agendar no Windows (backup automático)

1. Abra o **Agendador de Tarefas** (Taskschd.msc).
2. Criar Tarefa Básica → Nome: "Backup automático".
3. Disparo: Diariamente (ou semanalmente), no horário desejado.
4. Ação: Iniciar um programa.
5. Programa: `python` (ou caminho completo do `python.exe`).
6. Argumentos: `"C:\caminho\projeto3_backup\backup.py" "C:\Origem" "D:\Backup"`.
7. Iniciar em: `C:\caminho\projeto3_backup`.

Assim o backup roda sozinho e os logs ficam em `logs/`.

## Publicar no GitHub

### Opção rápida (com Git instalado)

1. Crie um repositório novo em **https://github.com/new** (ex.: nome: `backup-automacao`).
2. **Não** marque "Initialize this repository with a README".
3. No PowerShell, na pasta do projeto:

```powershell
.\publicar-github.ps1 -Url "https://github.com/SEU_USUARIO/backup-automacao.git"
```

(Substitua `SEU_USUARIO` pelo seu usuário do GitHub.)

Ou use o **publicar-github.bat**: ele inicializa o repositório e faz o primeiro commit; se o `origin` ainda não existir, mostra na tela os comandos para você colar (incluindo `git remote add origin ...` e `git push -u origin main`).

### Passo a passo manual

```bash
cd projeto3_backup
git init
git add .
git commit -m "Projeto 3: Automacao de Backup"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/SEU_REPO.git
git push -u origin main
```

Substitua `SEU_USUARIO` e `SEU_REPO` pelo seu usuário e nome do repositório no GitHub.
