-- ====================================================
-- GENERACIÓN DE DATOS MASIVOS PARA PRUEBAS DE REPLICACIÓN
-- ====================================================

\echo '======================================================'
\echo 'Generando 1000+ registros de prueba...'
\echo '======================================================'

-- Insertar 500 productos adicionales con variaciones
INSERT INTO productos (nombre, categoria, precio, stock)
SELECT 
    'Producto ' || serie || ' - ' || tipo,
    CASE (serie % 4)
        WHEN 0 THEN 'Aves'
        WHEN 1 THEN 'Procesados'
        WHEN 2 THEN 'Congelados'
        ELSE 'Frescos'
    END,
    (RANDOM() * 100 + 20)::DECIMAL(10,2),
    (RANDOM() * 200 + 10)::INTEGER
FROM 
    generate_series(1, 500) AS serie,
    (VALUES ('Premium'), ('Regular'), ('Económico')) AS tipos(tipo);

-- Insertar 200 clientes adicionales
INSERT INTO clientes (nombre, telefono, direccion)
SELECT 
    CASE (serie % 5)
        WHEN 0 THEN 'Restaurant '
        WHEN 1 THEN 'Comedor '
        WHEN 2 THEN 'Cafetería '
        WHEN 3 THEN 'Hotel '
        ELSE 'Supermercado '
    END || 'Nro ' || serie,
    '22' || LPAD((serie % 100)::TEXT, 2, '0') || '-' || LPAD((serie % 10000)::TEXT, 4, '0'),
    'Zona ' || ((serie % 20) + 1) || ', Ciudad de Guatemala'
FROM generate_series(1, 200) AS serie;

-- Insertar 500 ventas con datos realistas
-- Usa una subconsulta para seleccionar solo producto_id existentes
INSERT INTO ventas (producto_id, cantidad, total, fecha_venta)
SELECT 
    p.id,
    (RANDOM() * 10 + 1)::INTEGER,
    (RANDOM() * 500 + 50)::DECIMAL(10,2),
    CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '90 days')
FROM 
    generate_series(1, 500) AS serie,
    LATERAL (
        SELECT id FROM productos 
        ORDER BY RANDOM() 
        LIMIT 1
    ) AS p;

\echo ''
\echo '======================================================'
\echo 'GENERACIÓN DE DATOS COMPLETADA'
\echo '======================================================'
\echo ''

-- Mostrar estadísticas finales
SELECT 'Total de productos: ' || COUNT(*) AS estadistica FROM productos;
SELECT 'Total de clientes: ' || COUNT(*) AS estadistica FROM clientes;
SELECT 'Total de ventas: ' || COUNT(*) AS estadistica FROM ventas;

\echo ''
\echo 'Calculando totales de ventas...'
SELECT 
    'Ventas totales (monto): Q' || TO_CHAR(SUM(total), 'FM999,999,999.00') AS estadistica
FROM ventas;

\echo ''
\echo 'Productos por categoría:'
SELECT categoria, COUNT(*) as cantidad 
FROM productos 
GROUP BY categoria 
ORDER BY cantidad DESC;

\echo ''