# Como tudo funciona — Automação de Backup

Este texto explica o projeto de um jeito direto: o que cada parte faz e como uma coisa se liga na outra.

---

## A ideia geral

O script **lê uma pasta de origem**, **copia todos os arquivos** (e subpastas) para uma **pasta de destino** e **registra em um arquivo de log** o que foi feito e se houve algum erro.

Em resumo:

```
Pasta origem  →  Script (backup.py)  →  Pasta destino
                      ↓
                 Arquivo de log (logs/backup_AAAA-MM-DD_HH-MM-SS.log)
```

Cada execução gera um log novo, com data e hora no nome, para você saber quando rodou e o que aconteceu.

---

## 1. Argumentos da linha de comando (`argparse`)

O script aceita parâmetros opcionais para não depender de caminhos fixos no código.

### O que tem aqui

- **origem** (opcional): pasta de onde os arquivos serão lidos. Se não informar, usa `exemplo_origem` dentro do projeto.
- **destino** (opcional): pasta para onde os arquivos serão copiados. Se não informar, usa `backup_destino` dentro do projeto.
- **--logs** (opcional): pasta onde os arquivos de log serão salvos. Padrão: `logs` dentro do projeto.

Assim você pode rodar tanto em modo “demonstração” (sem argumentos) quanto em uso real, passando caminhos de rede ou outros discos.

### Por que isso ajuda

- **Reutilizável**: o mesmo script serve para testar e para produção.
- **Agendamento**: no Agendador de Tarefas do Windows você passa origem e destino uma vez e o backup roda sempre com os mesmos caminhos.

---

## 2. Configuração do log (`configurar_log`)

Cada execução precisa de um arquivo de log com nome único, para não sobrescrever execuções anteriores.

### O que acontece

- É criada a pasta de logs (por exemplo `logs/`) se não existir.
- O nome do arquivo usa data e hora: `backup_2025-02-26_14-30-00.log`.
- O `logging` do Python é configurado para escrever no arquivo e também no terminal (stdout). Assim você vê o andamento na tela e guarda o histórico no arquivo.
- Formato das linhas: `AAAA-MM-DD HH:MM:SS | NIVEL | Mensagem`.

### Três conceitos que valem guardar

- **Arquivo com timestamp**: evita misturar logs de execuções diferentes.
- **FileHandler + StreamHandler**: mesmo conteúdo no arquivo e no console.
- **Encoding UTF-8**: para acentos e nomes de arquivos em português saírem corretos.

---

## 3. Cópia de arquivos (`copiar_arquivos`)

Aqui está a lógica principal: percorrer a pasta de origem e copiar cada arquivo para o destino, mantendo a estrutura de subpastas.

### O que a função faz

1. Verifica se a origem é mesmo uma pasta; se não for, devolve erro.
2. Cria a pasta de destino (e subpastas) se não existir.
3. Usa `rglob("*")` para percorrer todos os arquivos (recursivo).
4. Para cada arquivo:
   - Calcula o caminho relativo em relação à origem.
   - Monta o caminho correspondente no destino.
   - Cria as subpastas necessárias no destino.
   - Usa `shutil.copy2` para copiar preservando data de modificação.
   - Registra no log cada arquivo copiado.
5. Se der exceção em algum arquivo, registra o erro no log, incrementa o contador de erros e segue para o próximo.
6. Retorna: quantidade de arquivos copiados, quantidade de erros e lista de mensagens de erro.

### Por que `shutil.copy2`

- `copy2` copia o arquivo e tenta preservar metadados (data de modificação). Em backup, isso ajuda a saber quando o arquivo foi alterado pela última vez.
- Para pastas grandes, o script não carrega tudo na memória; copia arquivo a arquivo.

---

## 4. Fluxo da execução (`executar_backup` e `main`)

### Ordem do que acontece

1. **main** lê os argumentos (origem, destino, pasta de logs).
2. Se estiver usando a pasta de exemplo e ela não existir, **main** cria `exemplo_origem` com um `leia-me.txt` e uma subpasta `dados` com um `exemplo.csv`, para a primeira execução já ter o que copiar.
3. **executar_backup** é chamada com origem, destino e pasta de logs.
4. **executar_backup** chama **configurar_log** e depois **copiar_arquivos**.
5. No log são escritos: cabeçalho (origem/destino), cada arquivo copiado, resumo (quantidade copiada e erros) e o caminho do arquivo de log.
6. **main** retorna 0 (sucesso) ou 1 (houve erros), para uso em scripts ou Agendador de Tarefas.

### Por que retornar 0 ou 1

Assim você pode usar o script em um agendador ou em outro script e saber se o backup terminou com sucesso (0) ou com falhas (1). O Agendador de Tarefas do Windows pode, por exemplo, enviar um e-mail ou registrar um evento quando o código de saída for 1.

---

## Por onde começar a ler o código

1. **backup.py** — função **main**: argumentos, criação da pasta de exemplo e chamada de **executar_backup**.
2. **executar_backup**: configuração do log e chamada de **copiar_arquivos**; resumo no final.
3. **copiar_arquivos**: loop nos arquivos, `shutil.copy2` e tratamento de exceções.
4. **configurar_log**: criação da pasta de logs e configuração do `logging`.

Assim você acompanha o fluxo completo: da linha de comando até o arquivo de log e os arquivos copiados.
