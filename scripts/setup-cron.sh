#!/bin/bash
# ====================================================
# SCRIPT DE CONFIGURACIÓN DE CRON
# ====================================================

set -e

echo "======================================================"
echo "CONFIGURANDO AUTOMATIZACIÓN DE BACKUPS"
echo "======================================================"

# Instalar cron si no está instalado
if ! command -v cron &> /dev/null; then
    echo "Instalando cron..."
    apt-get update -qq
    apt-get install -y -qq cron
    echo "✓ Cron instalado"
fi

# Crear archivo de crontab
CRON_FILE="/etc/cron.d/postgres-backups"

cat > "$CRON_FILE" << 'EOF'
# ====================================================
# CRON JOBS PARA BACKUPS DE POSTGRESQL
# ====================================================

# Variables de entorno necesarias
PGPASSWORD=replicator123
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Full backup cada domingo a las 2:00 AM
0 2 * * 0 root /backup-scripts/backup-full.sh >> /backups/backup.log 2>&1

# Limpieza de backups antiguos todos los días a las 3:00 AM
0 3 * * * root /backup-scripts/cleanup-old-backups.sh >> /backups/backup.log 2>&1

# Verificación de backups cada lunes a las 9:00 AM
0 9 * * 1 root /backup-scripts/verify-backups.sh >> /backups/backup.log 2>&1

EOF

# Dar permisos correctos
chmod 0644 "$CRON_FILE"

# Crear directorio para scripts
mkdir -p /backup-scripts

# Copiar scripts de backup
cp /docker-entrypoint-initdb.d/backup-full.sh /backup-scripts/
cp /docker-entrypoint-initdb.d/cleanup-old-backups.sh /backup-scripts/
cp /docker-entrypoint-initdb.d/verify-backups.sh /backup-scripts/

# Dar permisos de ejecución
chmod +x /backup-scripts/*.sh

# Iniciar cron
service cron start

echo ""
echo "✓ Cron configurado correctamente"
echo ""
echo "Tareas programadas:"
echo "  - Full backup:    Domingos 2:00 AM"
echo "  - Limpieza:       Diario 3:00 AM"
echo "  - Verificación:   Lunes 9:00 AM"
echo ""
echo "======================================================"
echo "CONFIGURACIÓN COMPLETADA"
echo "======================================================"

# Mantener cron en ejecución
tail -f /dev/null