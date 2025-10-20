#!/bin/bash
set -e

echo "======================================================"
echo "CONFIGURANDO NODO PRIMARIO PARA REPLICACIÓN"
echo "======================================================"

# Crear usuario de replicación
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'replicator') THEN
            CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator123';
            RAISE NOTICE '✓ Usuario replicator creado';
        ELSE
            RAISE NOTICE '✓ Usuario replicator ya existe';
        END IF;
    END
    \$\$;
EOSQL

# Configurar pg_hba.conf
echo ""
echo "Configurando pg_hba.conf..."
cat >> "${PGDATA}/pg_hba.conf" <<EOF

# Reglas de replicación
host    replication     replicator      0.0.0.0/0               md5
host    all             all             0.0.0.0/0               md5
EOF

echo "✓ pg_hba.conf configurado"

# Crear directorio para WAL archive
mkdir -p /backups/wal_archive
chmod 700 /backups/wal_archive
chown postgres:postgres /backups/wal_archive
echo "✓ Directorio WAL archive creado"

echo ""
echo "======================================================"
echo "CONFIGURACIÓN COMPLETADA"
echo "======================================================"
