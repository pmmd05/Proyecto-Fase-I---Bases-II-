# ====================================================
# SCRIPT PARA EJECUTAR BACKUP MANUAL DESDE POWERSHELL
# ====================================================

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "EJECUTANDO BACKUP MANUAL" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el contenedor esté corriendo
$containerStatus = docker ps --filter "name=pg-backup-scheduler" --format "{{.Names}}"

if (-not $containerStatus) {
    Write-Host "ERROR: El contenedor pg-backup-scheduler no está corriendo" -ForegroundColor Red
    Write-Host "Ejecuta primero: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "Ejecutando full backup..." -ForegroundColor Green
docker exec pg-backup-scheduler /backup-scripts/backup-full.sh

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "BACKUP COMPLETADO" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para ver el log completo:" -ForegroundColor Yellow
Write-Host "  Get-Content backups\backup.log" -ForegroundColor White
Write-Host ""
Write-Host "Para listar los backups:" -ForegroundColor Yellow
Write-Host "  Get-ChildItem backups\full\" -ForegroundColor White
