-- =========================================================
-- Proyecto Módulo 5 (ABP) - Alke Wallet
-- Motor sugerido: MySQL 8 (p.ej. sqliteonline.com en modo MySQL 8)
-- Archivo: AlkeWallet.sql
-- =========================================================

/* 1) Crear base de datos y seleccionar uso */
CREATE DATABASE IF NOT EXISTS AlkeWallet
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE AlkeWallet;

/* 2) (Opcional) Limpieza para re-ejecutar el script */
-- DROP TABLE IF EXISTS transaccion;
-- DROP TABLE IF EXISTS usuario;
-- DROP TABLE IF EXISTS moneda;

/* 3) Tabla MONEDA */
CREATE TABLE moneda (
  currency_id     INT AUTO_INCREMENT PRIMARY KEY,
  currency_name   VARCHAR(50)  NOT NULL,
  currency_symbol VARCHAR(10)  NOT NULL,
  CONSTRAINT uq_moneda_name UNIQUE (currency_name),
  CONSTRAINT uq_moneda_symbol UNIQUE (currency_symbol)
) ENGINE=InnoDB;

/* 4) Tabla USUARIO */
CREATE TABLE usuario (
  user_id       INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(80)  NOT NULL,
  email         VARCHAR(120) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  saldo         DECIMAL(18,2) NOT NULL DEFAULT 0.00,
  currency_id   INT NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_usuario_email UNIQUE (email),
  CONSTRAINT fk_usuario_moneda
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

/* 5) Tabla TRANSACCION */
CREATE TABLE transaccion (
  transaction_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
  sender_user_id     INT NOT NULL,
  receiver_user_id   INT NOT NULL,
  currency_id        INT NOT NULL,
  importe            DECIMAL(18,2) NOT NULL,
  transaction_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_importe_pos CHECK (importe > 0),
  CONSTRAINT chk_sender_receiver CHECK (sender_user_id <> receiver_user_id),
  CONSTRAINT fk_tx_sender
    FOREIGN KEY (sender_user_id) REFERENCES usuario(user_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_tx_receiver
    FOREIGN KEY (receiver_user_id) REFERENCES usuario(user_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_tx_moneda
    FOREIGN KEY (currency_id) REFERENCES moneda(currency_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

/* 6) Índices recomendados para búsquedas */
CREATE INDEX idx_tx_sender_date   ON transaccion(sender_user_id, transaction_date);
CREATE INDEX idx_tx_receiver_date ON transaccion(receiver_user_id, transaction_date);
CREATE INDEX idx_tx_currency_date ON transaccion(currency_id, transaction_date);

/* =========================================================
   DML - Datos de prueba
   ========================================================= */

/* 7) Insertar monedas */
INSERT INTO moneda (currency_name, currency_symbol) VALUES
  ('Peso Chileno', 'CLP'),
  ('Dólar',        'USD'),
  ('Euro',         'EUR');

/* 8) Insertar usuarios */
INSERT INTO usuario (nombre, email, password_hash, saldo, currency_id) VALUES
  ('Ana Pérez',  'ana.perez@alkewallet.com',  'hash_demo_ana',  150000.00, 1),
  ('Bruno Díaz', 'bruno.diaz@alkewallet.com', 'hash_demo_bruno',  50000.00, 1),
  ('Carla Soto', 'carla.soto@alkewallet.com', 'hash_demo_carla',  1000.00,  2);

/* 9) Insertar transacciones */
INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date) VALUES
  (1, 2, 1, 10000.00, '2026-02-01 10:00:00'),
  (2, 1, 1, 2500.00,  '2026-02-02 12:30:00'),
  (1, 3, 2, 15.00,    '2026-02-03 09:15:00');

/* =========================================================
   CONSULTAS SOLICITADAS
   ========================================================= */

/* Q1) Obtener el nombre de la moneda elegida por un usuario específico */
-- Reemplaza :userId por el ID real (ej: 1)
SELECT u.user_id, u.nombre, m.currency_name AS moneda_elegida
FROM usuario u
INNER JOIN moneda m ON m.currency_id = u.currency_id
WHERE u.user_id = 1;

/* Q2) Obtener todas las transacciones registradas (con nombres) */
SELECT
  t.transaction_id,
  t.transaction_date,
  u1.nombre AS emisor,
  u2.nombre AS receptor,
  m.currency_symbol AS moneda,
  t.importe
FROM transaccion t
INNER JOIN usuario u1 ON u1.user_id = t.sender_user_id
INNER JOIN usuario u2 ON u2.user_id = t.receiver_user_id
INNER JOIN moneda  m  ON m.currency_id = t.currency_id
ORDER BY t.transaction_date DESC;

/* Q3) Obtener todas las transacciones realizadas por un usuario específico (como emisor o receptor) */
-- Reemplaza :userId por el ID real (ej: 1)
SELECT
  t.transaction_id,
  t.transaction_date,
  u1.nombre AS emisor,
  u2.nombre AS receptor,
  m.currency_symbol AS moneda,
  t.importe
FROM transaccion t
INNER JOIN usuario u1 ON u1.user_id = t.sender_user_id
INNER JOIN usuario u2 ON u2.user_id = t.receiver_user_id
INNER JOIN moneda  m  ON m.currency_id = t.currency_id
WHERE t.sender_user_id = 1 OR t.receiver_user_id = 1
ORDER BY t.transaction_date DESC;

/* Q4) DML para modificar el correo electrónico de un usuario específico */
UPDATE usuario
SET email = 'ana.perez+actualizado@alkewallet.com'
WHERE user_id = 1;

/* Q5) Sentencia para eliminar los datos de una transacción (elimina la fila completa) */
-- Reemplaza :transactionId por el ID real (ej: 2)
DELETE FROM transaccion
WHERE transaction_id = 2;

/* =========================================================
   TRANSACCIONALIDAD / ACID (ejemplo)
   =========================================================
   Caso: transferencia desde user_id=1 hacia user_id=2 por 3000.00 CLP
   - Inserta la transacción
   - Descuenta saldo al emisor y suma saldo al receptor
   - Si algo falla, ROLLBACK
   ========================================================= */

START TRANSACTION;

-- 1) Verificar saldo suficiente (en MySQL real podrías usar SELECT ... FOR UPDATE)
SELECT saldo FROM usuario WHERE user_id = 1;

-- 2) Registrar transacción
INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe)
VALUES (1, 2, 1, 3000.00);

-- 3) Actualizar saldos
UPDATE usuario SET saldo = saldo - 3000.00 WHERE user_id = 1;
UPDATE usuario SET saldo = saldo + 3000.00 WHERE user_id = 2;

-- 4) Confirmar (o revertir si corresponde)
COMMIT;

-- Si quieres probar rollback (simulación de error), reemplaza COMMIT por ROLLBACK.
