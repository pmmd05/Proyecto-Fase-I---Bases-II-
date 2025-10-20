#!/bin/bash
# ====================================================
# SCRIPT DE VERIFICACIÓN DE BACKUPS
# ====================================================

set -e

BACKUP_DIR="/backups/full"
WAL_ARCHIVE_DIR="/backups/wal_archive"
LOG_FILE="/backups/backup.log"

echo "======================================================" | tee -a "$LOG_FILE"
echo "$(date): VERIFICACIÓN DE BACKUPS" | tee -a "$LOG_FILE"
echo "======================================================" | tee -a "$LOG_FILE"

# Verificar que exista al menos un full backup
echo ""
echo "Verificando full backups..." | tee -a "$LOG_FILE"

if [ -d "$BACKUP_DIR" ]; then
    BACKUP_COUNT=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo "✓ Full backups encontrados: ${BACKUP_COUNT}" | tee -a "$LOG_FILE"
        
        # Mostrar información de backups
        echo "" | tee -a "$LOG_FILE"
        echo "Lista de full backups:" | tee -a "$LOG_FILE"
        find "$BACKUP_DIR" -name "*.tar.gz" -type f -exec ls -lh {} \; | tee -a "$LOG_FILE"
        
        # Verificar backup más reciente
        LATEST_BACKUP=$(find "$BACKUP_DIR" -name "*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
        BACKUP_AGE_DAYS=$(( ($(date +%s) - $(stat -c %Y "$LATEST_BACKUP")) / 86400 ))
        
        echo "" | tee -a "$LOG_FILE"
        echo "Backup más reciente:" | tee -a "$LOG_FILE"
        echo "  Archivo: $(basename "$LATEST_BACKUP")" | tee -a "$LOG_FILE"
        echo "  Antigüedad: ${BACKUP_AGE_DAYS} días" | tee -a "$LOG_FILE"
        
        if [ "$BACKUP_AGE_DAYS" -gt 7 ]; then
            echo "⚠ ADVERTENCIA: El backup más reciente tiene más de 7 días" | tee -a "$LOG_FILE"
        else
            echo "✓ Backup reciente está dentro del periodo esperado" | tee -a "$LOG_FILE"
        fi
    else
        echo "✗ ERROR: No se encontraron full backups" | tee -a "$LOG_FILE"
    fi
else
    echo "✗ ERROR: Directorio de backups no existe" | tee -a "$LOG_FILE"
fi

# Verificar archivos WAL
echo "" | tee -a "$LOG_FILE"
echo "Verificando archivos WAL..." | tee -a "$LOG_FILE"

if [ -d "$WAL_ARCHIVE_DIR" ]; then
    WAL_COUNT=$(find "$WAL_ARCHIVE_DIR" -type f | wc -l)
    
    if [ "$WAL_COUNT" -gt 0 ]; then
        echo "✓ Archivos WAL encontrados: ${WAL_COUNT}" | tee -a "$LOG_FILE"
        
        # Espacio usado por WAL
        WAL_SIZE=$(du -sh "$WAL_ARCHIVE_DIR" | cut -f1)
        echo "  Espacio usado: ${WAL_SIZE}" | tee -a "$LOG_FILE"
    else
        echo "⚠ ADVERTENCIA: No se encontraron archivos WAL" | tee -a "$LOG_FILE"
    fi
else
    echo "✗ ERROR: Directorio WAL archive no existe" | tee -a "$LOG_FILE"
fi

# Resumen de espacio
echo "" | tee -a "$LOG_FILE"
echo "Resumen de espacio usado:" | tee -a "$LOG_FILE"
du -sh /backups/* 2>/dev/null | tee -a "$LOG_FILE" || echo "No hay datos disponibles"

# Verificar integridad del último backup (opcional, puede ser lento)
echo "" | tee -a "$LOG_FILE"
echo "Verificando integridad del último backup..." | tee -a "$LOG_FILE"

if [ -n "$LATEST_BACKUP" ] && [ -f "$LATEST_BACKUP" ]; then
    if tar -tzf "$LATEST_BACKUP" > /dev/null 2>&1; then
        echo "✓ Integridad del archivo verificada correctamente" | tee -a "$LOG_FILE"
    else
        echo "✗ ERROR: El archivo de backup está corrupto" | tee -a "$LOG_FILE"
    fi
fi

echo "" | tee -a "$LOG_FILE"
echo "======================================================" | tee -a "$LOG_FILE"
echo "$(date): VERIFICACIÓN COMPLETADA" | tee -a "$LOG_FILE"
echo "======================================================" | tee -a "$LOG_FILE"