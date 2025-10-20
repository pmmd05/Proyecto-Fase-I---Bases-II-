-- ====================================================
-- CREACIÓN DE TABLAS Y DATOS DE PRUEBA
-- ====================================================

\echo '======================================================'
\echo 'Creando tablas para Pollo Sanjuanero...'
\echo '======================================================'

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precio DECIMAL(10,2),
    stock INTEGER,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de ventas
CREATE TABLE IF NOT EXISTS ventas (
    id SERIAL PRIMARY KEY,
    producto_id INTEGER REFERENCES productos(id),
    cantidad INTEGER,
    total DECIMAL(10,2),
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    direccion TEXT,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

\echo ''
\echo 'Insertando datos de prueba...'

-- Insertar productos
INSERT INTO productos (nombre, categoria, precio, stock) VALUES
('Pollo Entero', 'Aves', 45.50, 100),
('Pechuga de Pollo', 'Aves', 65.00, 80),
('Muslos de Pollo', 'Aves', 38.00, 120),
('Alitas de Pollo', 'Aves', 42.00, 90),
('Pollo Marinado', 'Aves', 55.00, 60),
('Pollo en Trozos', 'Aves', 48.00, 75),
('Caldo de Pollo', 'Sopas', 25.00, 50),
('Nuggets de Pollo', 'Procesados', 35.00, 100)
ON CONFLICT DO NOTHING;

-- Insertar clientes
INSERT INTO clientes (nombre, telefono, direccion) VALUES
('Restaurant El Buen Sabor', '2234-5678', 'Zona 10, Ciudad'),
('Comedor María', '2345-6789', 'Zona 1, Ciudad'),
('Super Pollo Express', '2456-7890', 'Zona 4, Ciudad'),
('Pollo Campero', '2567-8901', 'Zona 9, Ciudad'),
('Restaurante La Granja', '2678-9012', 'Zona 15, Ciudad')
ON CONFLICT DO NOTHING;

\echo ''
\echo '======================================================'
\echo 'DATOS INSERTADOS CORRECTAMENTE'
\echo '======================================================'
\echo ''

-- Mostrar resumen
SELECT 'Productos registrados: ' || COUNT(*) AS resumen FROM productos;
SELECT 'Clientes registrados: ' || COUNT(*) AS resumen FROM clientes;

\echo ''