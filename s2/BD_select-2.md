# 1)Выборка всех данных

```sql
SELECT * FROM clients;
```

<img width="294" height="164" alt="Снимок экрана 2025-10-15 в 10 46 45" src="https://github.com/user-attachments/assets/d6b9d754-9c39-420d-bbef-e61e8c088377" />


```sql
SELECT * FROM orders;
```

<img width="1029" height="189" alt="Снимок экрана 2025-10-15 в 10 46 56" src="https://github.com/user-attachments/assets/5eb51680-1bae-40f1-9374-58e557236f8a" />


# 2)Выборка отдельных столбцов

```sql
SELECT client_id, name FROM clients;
```

<img width="291" height="164" alt="Снимок экрана 2025-10-15 в 10 47 09" src="https://github.com/user-attachments/assets/fc1f98f9-d8fc-45b8-a7cf-a105d96c9e9a" />

```sql
SELECT order_id, created_at, status FROM orders;
```

<img width="471" height="189" alt="Снимок экрана 2025-10-15 в 10 47 37" src="https://github.com/user-attachments/assets/2ef08468-d3b9-4a5e-9299-754cc5784f2f" />


# 3) Присвоение новых имён столбцам

```sql
SELECT client_id AS id, name AS "ИМЯ" FROM clients;
```

<img width="268" height="166" alt="Снимок экрана 2025-10-15 в 10 47 51" src="https://github.com/user-attachments/assets/443169ff-d4de-4332-a5ad-97ea8f58eeb8" />

```sql
SELECT order_id AS id, total_cost AS cost, created_at AS time FROM orders;
```

<img width="407" height="187" alt="Снимок экрана 2025-10-15 в 10 48 13" src="https://github.com/user-attachments/assets/c8c933d4-14f0-4aa8-8dce-2396628e71af" />


# 4) Выборка данных с созданием вычисляемого столбца

```sql
SELECT cargo_id, order_id, weight, price, (weight * price)::numeric(12,2) AS total_price
FROM cargos;
```

<img width="545" height="185" alt="Снимок экрана 2025-10-15 в 10 57 08" src="https://github.com/user-attachments/assets/499498d0-7ba0-4a52-bd64-43e368c7dab3" />

```sql
SELECT order_id, delivery_date, (delivery_date - CURRENT_DATE) AS days_to_delivery
FROM orders;
```

<img width="356" height="186" alt="Снимок экрана 2025-10-15 в 10 57 47" src="https://github.com/user-attachments/assets/c7b5740d-9605-42a7-9b5d-ab9ad22eda97" />

# 5) Математические функции
```sql
SELECT invoice_id, amount, ROUND(amount, 2) AS rounded_amount, POWER(amount::numeric, 1) AS pow1
FROM invoices;
```

<img width="501" height="110" alt="Снимок экрана 2025-10-15 в 11 00 22" src="https://github.com/user-attachments/assets/48550071-5a48-4edf-86b3-6a1efb33a2f3" />

```sql
SELECT vehicle_id, capacity,
       FLOOR(COALESCE(capacity,0)) AS floored_capacity,
       CEIL(COALESCE(capacity,0)) AS ceiled_capacity
FROM vehicles;
```

<img width="476" height="115" alt="Снимок экрана 2025-10-15 в 11 01 10" src="https://github.com/user-attachments/assets/6d9f95c0-b52b-459c-ac2c-576c006f2063" />

# 6) логические функции

```sql
SELECT c.client_id, c.name, COALESCE(cc.phone, 'нет телефона') AS phone
FROM clients c
LEFT JOIN client_contacts cc ON c.client_id = cc.client_id;
```

<img width="420" height="167" alt="Снимок экрана 2025-10-15 в 11 04 03" src="https://github.com/user-attachments/assets/fd63e42b-c924-4705-ac20-aa506af57fa2" />

```sql
SELECT client_id,
       NULLIF(email, '') AS email_or_null
FROM client_contacts;
```

<img width="270" height="163" alt="Снимок экрана 2025-10-15 в 11 04 26" src="https://github.com/user-attachments/assets/b28a0c6e-9503-4f99-9dba-63bf772199da" />

# 7) Выборка данных по условию

```sql
SELECT order_id, client_id, status FROM orders WHERE status = 'delivered';
```
<img width="362" height="64" alt="Снимок экрана 2025-10-15 в 11 06 01" src="https://github.com/user-attachments/assets/809a7634-afef-4abd-9e8f-6870c6a2cced" />

```sql
SELECT cargo_id, order_id, weight FROM cargos WHERE weight > 100;
```

<img width="331" height="87" alt="Снимок экрана 2025-10-15 в 11 06 28" src="https://github.com/user-attachments/assets/2780b07f-bfb7-4ba1-baf5-062fb27212b9" />

# 8) Логические операции
```sql
SELECT * FROM orders
WHERE client_id = 5 AND status <> 'cancelled' AND total_cost > 500;
```

<img width="958" height="122" alt="Снимок экрана 2025-10-15 в 11 07 47" src="https://github.com/user-attachments/assets/4f3ba55d-24af-429c-adf2-16c65577d72b" />

```sql
SELECT * FROM payments
WHERE method = 'card' OR status = 'pending';
```

<img width="722" height="92" alt="Снимок экрана 2025-10-15 в 11 08 15" src="https://github.com/user-attachments/assets/f048067b-c3ca-4530-9253-0d5f89045450" />

# 9) Операторы BETWEEN, IN
```sql
SELECT order_id, created_at FROM orders
WHERE created_at::date BETWEEN (CURRENT_DATE - INTERVAL '30 days')::date AND CURRENT_DATE;
```
<img width="326" height="188" alt="Снимок экрана 2025-10-15 в 11 09 03" src="https://github.com/user-attachments/assets/ca63be57-be5b-455f-a31f-96d70b59a5d3" />

```sql
SELECT order_id, status FROM orders
WHERE status IN ('new', 'processing', 'shipped');
```
<img width="286" height="138" alt="Снимок экрана 2025-10-15 в 11 09 26" src="https://github.com/user-attachments/assets/034d9389-e648-4aa8-9b25-f7ca4b18eeed" />

# 10) С сортировкой (ORDER BY)
```sql
SELECT order_id, created_at, total_cost FROM orders
ORDER BY created_at DESC
LIMIT 20;
```
<img width="431" height="187" alt="Снимок экрана 2025-10-15 в 11 10 13" src="https://github.com/user-attachments/assets/c193c284-6aa5-4ed0-82ad-aab67909842e" />

```sql
SELECT client_id, name FROM clients
ORDER BY name ASC;
```
<img width="292" height="164" alt="Снимок экрана 2025-10-15 в 11 10 36" src="https://github.com/user-attachments/assets/1437212b-9045-4da7-96e4-176792283a2f" />

# 11) Оператор LIKE
```sql
SELECT client_id, name FROM clients WHERE name LIKE 'A%';
```

<img width="292" height="131" alt="Снимок экрана 2025-10-15 в 11 11 53" src="https://github.com/user-attachments/assets/76c70497-8350-47ee-8a40-796ecdf4e3a5" />

```sql
SELECT vehicle_id, plate_number FROM vehicles WHERE plate_number LIKE '%456%';
```

<img width="288" height="66" alt="Снимок экрана 2025-10-15 в 11 13 29" src="https://github.com/user-attachments/assets/9da6f113-b98a-4acb-a107-f05566d8088d" />

# 12) Выбор уникальных элементов столбца
```sql
SELECT DISTINCT status FROM orders;
```

<img width="195" height="164" alt="Снимок экрана 2025-10-15 в 11 14 15" src="https://github.com/user-attachments/assets/51324ae3-804b-450d-873f-0cc2fd9fa596" />

```sql
SELECT DISTINCT package_type FROM cargos;
```

<img width="192" height="137" alt="Снимок экрана 2025-10-15 в 11 14 36" src="https://github.com/user-attachments/assets/764c09da-bb07-4ac0-8214-9e0abffe91c5" />

# 13) Выбор ограниченного количества возвращаемых строк
```sql
SELECT * FROM vehicles LIMIT 10;
```
<img width="686" height="111" alt="Снимок экрана 2025-10-15 в 11 15 20" src="https://github.com/user-attachments/assets/7805f93a-5a65-4688-b575-4456b34e3ce0" />

# 14) Соединение INNER JOIN

```sql
SELECT o.order_id, o.status, c.client_id, c.name
FROM orders o
INNER JOIN clients c ON o.client_id = c.client_id;
```

<img width="496" height="187" alt="Снимок экрана 2025-10-15 в 11 16 42" src="https://github.com/user-attachments/assets/af0ad63e-7194-48c0-8cef-c5a8cf782d3a" />

```sql
SELECT t.trip_id, t.departure_datetime, r.departure_city, r.arrival_city
FROM trips t
INNER JOIN routes r ON t.route_id = r.route_id;
```

<img width="613" height="112" alt="Снимок экрана 2025-10-15 в 11 17 01" src="https://github.com/user-attachments/assets/3ebc917a-e568-493b-9086-14aa56d2611a" />


# 15) Внешнее соединение LEFT и RIGHT OUTER JOIN
```sql
SELECT o.order_id, o.total_cost, i.invoice_id, i.amount
FROM orders o
LEFT JOIN invoices i ON o.order_id = i.order_id;
```

<img width="421" height="191" alt="Снимок экрана 2025-10-15 в 11 17 47" src="https://github.com/user-attachments/assets/d4e71405-65c6-40c6-8c6f-3b3f25504cf9" />

```sql
SELECT c.client_id, c.name, ctr.contract_id, ctr.contract_date
FROM clients c
RIGHT JOIN contracts ctr ON c.client_id = ctr.client_id;
```

<img width="472" height="117" alt="Снимок экрана 2025-10-15 в 11 18 04" src="https://github.com/user-attachments/assets/2033632f-6f8b-4de0-b011-bd1d578ecbeb" />

# 16) Перекрёстное соединение CROSS JOIN
```sql
SELECT c.client_id, c.name, w.warehouse_id, w.name AS warehouse_name
FROM clients c
CROSS JOIN warehouses w
LIMIT 50;
```

<img width="533" height="287" alt="Снимок экрана 2025-10-15 в 11 18 47" src="https://github.com/user-attachments/assets/b66300ad-7d60-4111-b60f-fdca3ff9c85c" />

```sql
SELECT c.client_id, v.vehicle_id, c.name, v.plate_number
FROM clients c
CROSS JOIN vehicles v
LIMIT 50;
```

<img width="507" height="417" alt="Снимок экрана 2025-10-15 в 11 19 13" src="https://github.com/user-attachments/assets/e3aa3d32-eafa-4ee1-94f1-37fbdaf5a399" />


# 17) Запросы на выборку из нескольких таблиц
```sql
SELECT o.order_id, c.name AS client_name, o.total_cost, COALESCE(SUM(p.amount),0) AS paid_amount
FROM orders o
JOIN clients c ON o.client_id = c.client_id
LEFT JOIN payments p ON o.order_id = p.order_id
GROUP BY o.order_id, c.name, o.total_cost;
```

<img width="484" height="191" alt="Снимок экрана 2025-10-15 в 11 19 53" src="https://github.com/user-attachments/assets/742b13b7-a3ba-409c-aae4-9a9299655c77" />
