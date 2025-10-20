#!/bin/bash
# ====================================================
# SCRIPT DE FULL BACKUP SEMANAL
# ====================================================

set -e

BACKUP_DIR="/backups/full"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="full_backup_${DATE}"
LOG_FILE="/backups/backup.log"

echo "$(date): Iniciando full backup..." | tee -a "$LOG_FILE"

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Ejecutar pg_basebackup
echo "$(date): Ejecutando pg_basebackup..." | tee -a "$LOG_FILE"
pg_basebackup -h postgres-primary -U replicator -D "${BACKUP_DIR}/${BACKUP_NAME}" \
    -Fp -Xs -P -v 2>&1 | tee -a "$LOG_FILE"

# Comprimir el backup
echo "$(date): Comprimiendo backup..." | tee -a "$LOG_FILE"
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

# Mostrar tamaño del backup
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
echo "$(date): Backup completado: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})" | tee -a "$LOG_FILE"

# Listar backups actuales
echo "$(date): Backups actuales:" | tee -a "$LOG_FILE"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tee -a "$LOG_FILE" || echo "No hay backups previos"

echo "$(date): Full backup finalizado exitosamente" | tee -a "$LOG_FILE"