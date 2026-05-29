#!/bin/bash
# ============================================================
# Script: cleanup_backup.sh
# Autor: Talles Gomes
# Descrição: Remove backups antigos do datapump mantendo os
#            3 mais recentes (~6 dias considerando backup 2 em 2 dias)
# Diretório: /u01/backup/datapump/backup_datapump_CDBAGROS_SIAGRI/CDBAGROS
# ============================================================

BACKUP_DIR="/u01/backup/datapump/backup_datapump_CDBAGROS_SIAGRI/CDBAGROS"
MANTER=3
LOG="/u01/backup/datapump/cleanup_backup.log"
DATA=$(date '+%Y-%m-%d %H:%M:%S')

echo "============================================" | tee -a $LOG
echo "Início: $DATA" | tee -a $LOG
echo "Diretório: $BACKUP_DIR" | tee -a $LOG
echo "Mantendo os $MANTER backups mais recentes" | tee -a $LOG
echo "============================================" | tee -a $LOG

# Verifica se o diretório existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "ERRO: Diretório não encontrado: $BACKUP_DIR" | tee -a $LOG
    exit 1
fi

# Lista subdiretórios ordenados do mais recente para o mais antigo
SUBDIRS=$(ls -dt "$BACKUP_DIR"/*/  2>/dev/null | sed 's|/$||')
TOTAL=$(echo "$SUBDIRS" | grep -c .)

if [ "$TOTAL" -eq 0 ]; then
    echo "Nenhum backup encontrado. Nada a fazer." | tee -a $LOG
    exit 0
fi

echo "Total de backups encontrados: $TOTAL" | tee -a $LOG
echo "" | tee -a $LOG

# Lista todos os backups encontrados
echo "--- Backups existentes ---" | tee -a $LOG
echo "$SUBDIRS" | while read dir; do
    TAMANHO=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "  $dir  [$TAMANHO]" | tee -a $LOG
done
echo "" | tee -a $LOG

# Verifica se há mais do que o limite para manter
if [ "$TOTAL" -le "$MANTER" ]; then
    echo "Total ($TOTAL) <= Mínimo a manter ($MANTER). Nada será deletado." | tee -a $LOG
    echo "" | tee -a $LOG
    exit 0
fi

# Deleta os subdiretórios mais antigos
echo "--- Backups deletados ---" | tee -a $LOG
DELETADOS=0
echo "$SUBDIRS" | tail -n +$((MANTER + 1)) | while read dir; do
    TAMANHO=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "  Deletando: $dir  [$TAMANHO]" | tee -a $LOG
    rm -rf "$dir"
    DELETADOS=$((DELETADOS + 1))
done

echo "" | tee -a $LOG
echo "--- Backups mantidos ---" | tee -a $LOG
echo "$SUBDIRS" | head -n $MANTER | while read dir; do
    TAMANHO=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo "  $dir  [$TAMANHO]" | tee -a $LOG
done

echo "" | tee -a $LOG
echo "Limpeza concluída em: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a $LOG
echo "============================================" | tee -a $LOG
echo "" | tee -a $LOG
