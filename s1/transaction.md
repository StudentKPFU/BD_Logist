# Базовые запросы. BEGIN...COMMIT;

``` sql
BEGIN;

INSERT INTO payments (payment_id, order_id, amount, payment_date, method, status)
VALUES (5, 1, 1000.00, CURRENT_DATE, 'card', 'completed');

UPDATE orders
SET status = 'cancelled'
WHERE order_id = 1;

COMMIT;
```

``` sql
BEGIN;

INSERT INTO trips (trip_id, route_id, vehicle_id, departure_datetime, arrival_datetime, notes, driver_id)
VALUES (4, 3, 101, CURRENT_DATE, CURRENT_DATE + INTERVAL '3 hours', 'эксперимент', 3);

UPDATE vehicles
SET status = 'assigned'
WHERE vehicle_id = 101;

COMMIT;
```

# Базовые запросы. BEGIN...ROLLBACK;

``` sql
BEGIN;

INSERT INTO payments (payment_id, order_id, amount, payment_date, method, status)
VALUES (6, 1, 1000.00, CURRENT_DATE, 'card', 'completed');

UPDATE orders
SET status = 'cancelled'
WHERE order_id = 1;

ROLLBACK;
```

``` sql
BEGIN;

INSERT INTO trips (trip_id, route_id, vehicle_id, departure_datetime, arrival_datetime, notes, driver_id)
VALUES (5, 3, 101, CURRENT_DATE + INTERVAL '1 hours', CURRENT_DATE + INTERVAL '3 hours', 'эксперимент', 3);

UPDATE vehicles
SET status = 'assigned'
WHERE vehicle_id = 101;

ROLLBACK;
```

# Базовые запросы. ERROR_TRANSACTION

``` sql
BEGIN;

INSERT INTO payments (payment_id, order_id, amount, payment_date, method, status)
VALUES (6, 1, 1000.00, CURRENT_DATE, 'card', 'completed');

UPDATE orders
SET status = 'cancelled'
WHERE order_id = 1;

SELECT 1 / 0

COMMIT;
```

``` sql
BEGIN;

INSERT INTO trips (trip_id, route_id, vehicle_id, departure_datetime, arrival_datetime, notes, driver_id)
VALUES (5, 3, 101, CURRENT_DATE, CURRENT_DATE + INTERVAL '3 hours', 'эксперимент', 3);

UPDATE vehicles
SET status = 'assigned'
WHERE vehicle_id = 101;

SELECT 1 / 0

COMMIT;
```

# READ UNCOMMITTED / READ COMMITTED

``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT order_id, total_cost
FROM orders
WHERE order_id = 1; 

UPDATE orders
SET total_cost = COALESCE(total_cost, 0) + 500
WHERE order_id = 1;
```

![photo_2025-11-19 10 40 17](https://github.com/user-attachments/assets/4afbc638-629a-4483-984e-fd13e5ac997f)


``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; 

SELECT route_id, distance_km
FROM routes
WHERE route_id = 1;

COMMIT;
```

#
 
``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


SELECT order_id, total_cost
FROM orders
WHERE order_id = 1; 

UPDATE orders
SET total_cost = COALESCE(total_cost, 0) + 500
WHERE order_id = 1;
```

![photo_2025-11-19 10 49 22](https://github.com/user-attachments/assets/dab85b5e-2cbe-4e84-88bb-5824929c4445)

![photo_2025-11-19 10 49 24](https://github.com/user-attachments/assets/cfbb66b9-6284-4c00-ae29-088b4f998055)



``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT order_id, total_cost
FROM orders
WHERE order_id = 1; 

COMMIT;
```

# READ COMMITTED

``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT order_id, status
FROM orders
WHERE order_id = 1; 

-- пауза

SELECT order_id, status
FROM orders
WHERE order_id = 1;

COMMIT;
```

![photo_2025-11-19 10 58 45](https://github.com/user-attachments/assets/7ed71e81-e87c-4b5b-ab97-dfe23fcb3c61)


``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE orders
SET status = 'completed'
WHERE order_id = 1; 

COMMIT;
```

![photo_2025-11-19 10 58 47](https://github.com/user-attachments/assets/373ff4fe-9484-4020-8c22-18d42611c53a)

#

``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT vehicle_id, mileage
FROM vehicles
WHERE vehicle_id = 1; 

-- пауза

SELECT vehicle_id, mileage
FROM vehicles
WHERE vehicle_id = 1;

COMMIT;
```

![photo_2025-11-19 11 00 13](https://github.com/user-attachments/assets/c7934d3c-0e11-4448-aea0-84293c0fede6)

``` sql
BEGIN;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

UPDATE vehicles
SET mileage = COALESCE(mileage, 0) + 100
WHERE vehicle_id = 1;  -- тот же id

COMMIT;
```

![photo_2025-11-19 11 00 14](https://github.com/user-attachments/assets/fffea49a-f231-43aa-a9e0-15750b089e29)

# REPEATABLE READ

**Первый пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT order_id, status FROM orders ORDER BY order_id;
```

<img width="358" height="109" alt="Снимок экрана 2025-11-19 085003" src="https://github.com/user-attachments/assets/642f12b0-61fc-4415-8ab4-75bfa9d4db1d" />


Терминал 2

``` sql
BEGIN;

UPDATE orders
SET status = 'Доставлен'
WHERE order_id = 21;

COMMIT;
```

Терминал 1

``` sql
SELECT order_id, status FROM orders ORDER BY order_id;
```

<img width="357" height="111" alt="Снимок экрана 2025-11-19 085047" src="https://github.com/user-attachments/assets/06282bbe-1a4a-40ac-aff2-eaebd8b36cb0" />


``` sql
COMMIT;
```

**Второй пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT COUNT(*) FROM cargos;
```

<img width="131" height="79" alt="Снимок экрана 2025-11-19 085528" src="https://github.com/user-attachments/assets/52350f76-5370-4e55-bc29-93f8e2e20a4b" />


Терминал 2

``` sql
BEGIN;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (23, 'Новый груз', 15.0, 'Коробка', 2000);

COMMIT;
```

Терминал 1

``` sql
SELECT COUNT(*) FROM cargos;
```

<img width="128" height="82" alt="Снимок экрана 2025-11-19 090050" src="https://github.com/user-attachments/assets/220f8964-54b0-4f5d-be6b-df5d0118c0a0" />


# SERIALIZABLE

**Первый пример**

Терминал 1

``` sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM clients WHERE name = 'Новое имя';
```

Терминал 2

``` sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM clients WHERE name = 'Новое имя';
UPDATE clients SET name = 'ConflictClient' WHERE name = 'Новое имя';
```

Терминал 2

``` sql
COMMIT;
```

Терминал 1

``` sql
UPDATE clients SET name = 'Другое имя' WHERE name = 'Новое имя';
```

<img width="663" height="108" alt="image" src="https://github.com/user-attachments/assets/152dee3a-0763-4483-96b6-e3b22203d131" />


**Второй пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT * FROM orders WHERE total_cost > 1000;
```

Терминал 2

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO orders (tariff_id, status, client_id, total_cost)
VALUES (21, 'Новый', 1, 2000);

COMMIT;
```

Терминал 1 - Ошибка

``` sql
SELECT * FROM orders WHERE total_cost > 1000;
```

<img width="693" height="175" alt="image" src="https://github.com/user-attachments/assets/e7f45989-5077-4649-a996-e0a50b5adba3" />


Терминал 1 - Откат

``` sql
ROLLBACK;
```

Терминал 1 - По правильному

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT * FROM orders WHERE total_cost > 1000;

COMMIT;
```

# SAVEPOINT

**Первый пример**

``` sql
BEGIN;

INSERT INTO payments(order_id, amount, payment_date, method, status)
VALUES (1, 1000, CURRENT_DATE, 'Карта', 'Проведён');

INSERT INTO payments(order_id, amount, payment_date, method, status)
VALUES (1, 2000, CURRENT_DATE, 'Наличные', 'Проведён');

SAVEPOINT s1;
```

<img width="417" height="90" alt="Снимок экрана 2025-11-19 090955" src="https://github.com/user-attachments/assets/ebf3cd13-814d-4122-afd7-dcc34114aa39" />


Вставка, дающая ошибку

``` sql
INSERT INTO payments(payment_id, order_id, amount, payment_date, method, status)
VALUES (1, 1, 9999, CURRENT_DATE, 'Карта', 'Проведён');
```

<img width="788" height="115" alt="Снимок экрана 2025-11-19 091029" src="https://github.com/user-attachments/assets/a1450e57-cf7a-4f52-81dd-b0be1436d931" />


Откат

``` sql
ROLLBACK TO SAVEPOINT s1;
```

<img width="401" height="86" alt="Снимок экрана 2025-11-19 091044" src="https://github.com/user-attachments/assets/cdcbc7bc-12e6-4644-af6c-94a24ddc9d2e" />


Завершение

``` sql
COMMIT;
```

<img width="391" height="103" alt="Снимок экрана 2025-11-19 091114" src="https://github.com/user-attachments/assets/bceaf32a-946a-4d1b-89ec-9597d54947a7" />


**Второй пример**

``` sql
BEGIN;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'X', 10, 'Коробка', 100);

SAVEPOINT p1;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'Y', 20, 'Коробка', 200);

SAVEPOINT p2;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'Z', 30, 'Коробка', 300);
```

<img width="404" height="94" alt="Снимок экрана 2025-11-19 091322" src="https://github.com/user-attachments/assets/96f8d208-0e7d-4719-91b5-e13b2bc8a3b3" />


Откат на p2

``` sql
ROLLBACK TO SAVEPOINT p2;
```

<img width="403" height="88" alt="Снимок экрана 2025-11-19 091347" src="https://github.com/user-attachments/assets/d73d404e-86b5-45e7-97ec-05bc5cfccd27" />


Отменяется только вставка Z.

Откат на p1

``` sql
ROLLBACK TO SAVEPOINT p1;
```

<img width="400" height="89" alt="Снимок экрана 2025-11-19 091358" src="https://github.com/user-attachments/assets/ece31077-b0bd-47ad-8a61-b0fffbdcde66" />


Отменяется вставка Y.
X остаётся.

Завершение:

``` sql
COMMIT;
```

<img width="410" height="83" alt="Снимок экрана 2025-11-19 091414" src="https://github.com/user-attachments/assets/48cd20ce-bbcb-4575-8eb6-de7d679ca440" />
