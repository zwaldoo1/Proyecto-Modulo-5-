# Proyecto Módulo 5 (ABP) — Alke Wallet

Este repositorio contiene el entregable del **Proyecto Módulo 5** (Fundamentos de Bases de Datos Relacionales) para el caso **Alke Wallet**, un monedero virtual que permite gestionar **usuarios**, **monedas** y **transacciones** entre usuarios.

## Objetivo
Diseñar e implementar una base de datos relacional que:
- Almacene usuarios con su **moneda principal** y **saldo**.
- Registre transacciones indicando **emisor**, **receptor**, **moneda**, **importe** y **fecha**.
- Asegure **integridad referencial** mediante llaves primarias/foráneas y restricciones.
- Permita consultas típicas (transacciones por usuario, listar todas, etc.).

## Contenido del proyecto
- `AlkeWallet.sql` — Script completo con:
  - **DDL** (CREATE DATABASE / CREATE TABLE + restricciones + índices)
  - **DML** (INSERT de datos de prueba)
  - **Consultas solicitadas (Q1–Q5)**
  - Ejemplo de **transaccionalidad (ACID)** con `START TRANSACTION / COMMIT`
- `Entregable_Proyecto_Modulo5_AlkeWallet.docx` — Documento final con explicación y secciones para evidencias (capturas).

## Modelo de datos (ERD)
**Entidades:**
- **moneda**: catálogo de monedas
- **usuario**: datos del usuario y su moneda principal
- **transaccion**: registro de transferencias entre usuarios

**Relaciones:**
- `usuario.currency_id -> moneda.currency_id` (Moneda 1 : N Usuarios)
- `transaccion.sender_user_id -> usuario.user_id` (Usuario 1 : N Transacciones como emisor)
- `transaccion.receiver_user_id -> usuario.user_id` (Usuario 1 : N Transacciones como receptor)
- `transaccion.currency_id -> moneda.currency_id` (Moneda 1 : N Transacciones)

## Requisitos
- Motor recomendado: **MySQL 8** (por ejemplo, en un entorno local o en una plataforma online que soporte MySQL 8).
- Alternativas: MariaDB (con pequeñas diferencias) o cualquier motor compatible con DDL similar (revisar `CHECK` según soporte).

## Cómo ejecutar el proyecto
### Opción A — MySQL local (recomendado)
1. Abrir un cliente MySQL (Workbench, DBeaver, CLI).
2. Ejecutar el script completo:

```sql
SOURCE /ruta/al/archivo/AlkeWallet.sql;
```

### Opción B — Plataforma online (ej. SQLiteOnline en modo MySQL 8)
1. Abrir el editor SQL.
2. Copiar y pegar todo el contenido de `AlkeWallet.sql`.
3. Ejecutar el script.

> Nota sobre el nombre de BD: el script crea `AlkeWallet` (sin espacio).  
> Si tu consigna exige “Alke Wallet” con espacio, puedes ajustar así (MySQL):

```sql
CREATE DATABASE `Alke Wallet`;
USE `Alke Wallet`;
```

## Consultas solicitadas (Q1–Q5)
Dentro del script encontrarás listas y comentadas estas consultas:
- **Q1**: moneda elegida por un usuario específico
- **Q2**: todas las transacciones registradas (con nombres de emisor/receptor)
- **Q3**: transacciones de un usuario específico (como emisor o receptor)
- **Q4**: actualizar el email de un usuario específico
- **Q5**: eliminar una transacción por `transaction_id`

## Ejemplo ACID (Transacción controlada)
El script incluye un ejemplo de transferencia:
- Inserta una transacción
- Actualiza saldos del emisor y receptor
- Confirma con `COMMIT` (o revierte con `ROLLBACK`)

## Evidencias (capturas sugeridas)
Para completar el entregable, incluye capturas de:
1. Ejecución de `CREATE DATABASE` y `USE`
2. `SHOW TABLES` y `DESCRIBE` de las tablas
3. Resultado de **Q2** (lista de transacciones)
4. Ejecución del bloque transaccional con `COMMIT` (y opcional con `ROLLBACK`)

## Datos de prueba incluidos
El script carga:
- 3 monedas (CLP, USD, EUR)
- 3 usuarios (con saldo inicial)
- 3 transacciones de ejemplo

## Autor
- **Francisco** (entregable académico — Talento Digital)

---

### Tips rápidos (si algo falla)
- Si tu motor no soporta `CHECK`, comenta temporalmente las líneas `CONSTRAINT chk_...`.
- Si hay errores por `CREATE DATABASE`, omite esas líneas y ejecuta solo `CREATE TABLE` dentro de una base ya creada.
