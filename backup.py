"""
Projeto 3 — Automação de Backup
Script que copia arquivos de uma pasta origem para um destino e registra logs de execução.
Uso: python backup.py [origem] [destino]
Se não informar, usa pastas de exemplo dentro do projeto.
"""

import argparse
import logging
import shutil
import sys
from datetime import datetime
from pathlib import Path


def configurar_log(pasta_logs: Path) -> Path:
    """Cria pasta de logs e configura o arquivo de log com data no nome."""
    pasta_logs.mkdir(parents=True, exist_ok=True)
    nome_arquivo = f"backup_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.log"
    arquivo_log = pasta_logs / nome_arquivo

    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.FileHandler(arquivo_log, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )
    return arquivo_log


def copiar_arquivos(origem: Path, destino: Path) -> tuple[int, int, list[str]]:
    """
    Copia todos os arquivos da pasta origem para o destino (mantendo estrutura).
    Retorna (quantidade_copiada, quantidade_erros, lista_mensagens_erro).
    """
    copiados = 0
    erros = 0
    mensagens_erro: list[str] = []

    if not origem.is_dir():
        return 0, 1, [f"Origem nao e uma pasta: {origem}"]

    destino.mkdir(parents=True, exist_ok=True)

    for item in origem.rglob("*"):
        if item.is_file():
            try:
                relativo = item.relative_to(origem)
                destino_arquivo = destino / relativo
                destino_arquivo.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(item, destino_arquivo)
                copiados += 1
                logging.info("Copiado: %s -> %s", relativo, destino_arquivo)
            except Exception as e:
                erros += 1
                msg = f"{item}: {e}"
                mensagens_erro.append(msg)
                logging.error("Erro ao copiar %s: %s", item, e)

    return copiados, erros, mensagens_erro


def executar_backup(origem: Path, destino: Path, pasta_logs: Path) -> bool:
    """Executa o backup e grava o resumo no log. Retorna True se não houve erros."""
    arquivo_log = configurar_log(pasta_logs)
    logger = logging.getLogger()
    logger.info("========================================")
    logger.info("Backup iniciado")
    logger.info("Origem:  %s", origem.resolve())
    logger.info("Destino: %s", destino.resolve())
    logger.info("========================================")

    copiados, erros, mensagens_erro = copiar_arquivos(origem, destino)

    logger.info("----------------------------------------")
    logger.info("Resumo: %d arquivo(s) copiado(s), %d erro(s)", copiados, erros)
    if mensagens_erro:
        for msg in mensagens_erro:
            logger.error("  - %s", msg)
    logger.info("Log salvo em: %s", arquivo_log.resolve())
    logger.info("========================================")

    return erros == 0


def main() -> int:
    base = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(
        description="Copia arquivos da pasta origem para o destino e gera log de execução."
    )
    parser.add_argument(
        "origem",
        nargs="?",
        default=base / "exemplo_origem",
        type=Path,
        help="Pasta de origem (padrao: exemplo_origem no projeto)",
    )
    parser.add_argument(
        "destino",
        nargs="?",
        default=base / "backup_destino",
        type=Path,
        help="Pasta de destino do backup (padrao: backup_destino no projeto)",
    )
    parser.add_argument(
        "--logs",
        default=base / "logs",
        type=Path,
        help="Pasta onde salvar os arquivos de log (padrao: logs no projeto)",
    )
    args = parser.parse_args()

    # Cria pasta de exemplo se for a primeira execução
    if args.origem == base / "exemplo_origem" and not args.origem.exists():
        args.origem.mkdir(parents=True, exist_ok=True)
        (args.origem / "leia-me.txt").write_text(
            "Pasta de exemplo para o backup.\nAdicione aqui arquivos ou subpastas para testar.",
            encoding="utf-8",
        )
        (args.origem / "dados").mkdir(exist_ok=True)
        (args.origem / "dados" / "exemplo.csv").write_text(
            "nome,valor\na,1\nb,2\n",
            encoding="utf-8",
        )
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        logging.info("Pasta de exemplo criada em: %s", args.origem.resolve())

    sucesso = executar_backup(args.origem, args.destino, args.logs)
    return 0 if sucesso else 1


if __name__ == "__main__":
    sys.exit(main())
