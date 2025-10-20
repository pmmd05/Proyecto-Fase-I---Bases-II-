#!/bin/bash
# ====================================================
# SCRIPT DE LIMPIEZA DE BACKUPS ANTIGUOS
# Retención: 7 días
# ====================================================

set -e

BACKUP_DIR="/backups/full"
WAL_ARCHIVE_DIR="/backups/wal_archive"
LOG_FILE="/backups/backup.log"
RETENTION_DAYS=7

echo "$(date): Iniciando limpieza de backups antiguos..." | tee -a "$LOG_FILE"

# Limpiar full backups mayores a 7 días
if [ -d "$BACKUP_DIR" ]; then
    echo "$(date): Buscando full backups mayores a ${RETENTION_DAYS} días..." | tee -a "$LOG_FILE"
    
    DELETED_COUNT=0
    while IFS= read -r -d '' file; do
        echo "$(date): Eliminando: $(basename "$file")" | tee -a "$LOG_FILE"
        rm -f "$file"
        ((DELETED_COUNT++))
    done < <(find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +${RETENTION_DAYS} -print0)
    
    echo "$(date): Full backups eliminados: ${DELETED_COUNT}" | tee -a "$LOG_FILE"
else
    echo "$(date): Directorio de backups no existe" | tee -a "$LOG_FILE"
fi

# Limpiar archivos WAL mayores a 7 días
if [ -d "$WAL_ARCHIVE_DIR" ]; then
    echo "$(date): Buscando archivos WAL mayores a ${RETENTION_DAYS} días..." | tee -a "$LOG_FILE"
    
    WAL_DELETED_COUNT=0
    while IFS= read -r -d '' file; do
        ((WAL_DELETED_COUNT++))
    done < <(find "$WAL_ARCHIVE_DIR" -type f -mtime +${RETENTION_DAYS} -delete -print0)
    
    echo "$(date): Archivos WAL eliminados: ${WAL_DELETED_COUNT}" | tee -a "$LOG_FILE"
else
    echo "$(date): Directorio WAL archive no existe" | tee -a "$LOG_FILE"
fi

# Mostrar espacio usado
echo "$(date): Espacio usado en /backups:" | tee -a "$LOG_FILE"
du -sh /backups/* 2>/dev/null | tee -a "$LOG_FILE" || echo "No hay datos de uso"

# Mostrar backups restantes
echo "$(date): Backups actuales después de limpieza:" | tee -a "$LOG_FILE"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | tee -a "$LOG_FILE" || echo "No hay backups"

echo "$(date): Limpieza completada" | tee -a "$LOG_FILE"