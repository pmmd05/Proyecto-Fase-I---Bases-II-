# ====================================================
# SCRIPT PARA VERIFICAR BACKUPS DESDE POWERSHELL
# ====================================================

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "VERIFICANDO BACKUPS" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el contenedor esté corriendo
$containerStatus = docker ps --filter "name=pg-backup-scheduler" --format "{{.Names}}"

if (-not $containerStatus) {
    Write-Host "ERROR: El contenedor pg-backup-scheduler no está corriendo" -ForegroundColor Red
    Write-Host "Ejecuta primero: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Ejecutar verificación dentro del contenedor
docker exec pg-backup-scheduler /backup-scripts/verify-backups.sh

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "Para ver el historial completo de backups:" -ForegroundColor Yellow
Write-Host "  Get-Content backups\backup.log" -ForegroundColor White
Write-Host "======================================================" -ForegroundColor Cyan