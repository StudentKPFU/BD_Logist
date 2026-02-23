# 1. SELECT

``` sql
SELECT 
    c.name,
    (SELECT COUNT(*) FROM orders o WHERE o.client_id = c.client_id) AS total_orders
FROM clients c;
```

<img width="368" height="172" alt="Снимок экрана 2025-11-04 212320" src="https://github.com/user-attachments/assets/957c8ee5-0985-484c-a8d3-2574048aa71d" />


``` sql
SELECT 
    v.plate_number,
    (SELECT type FROM vehicles v2 WHERE v2.vehicle_id = v.vehicle_id) AS vehicle_type
FROM vehicles v;
```

<img width="425" height="174" alt="Снимок экрана 2025-11-04 212337" src="https://github.com/user-attachments/assets/f3b01f3f-4829-4773-9d21-286a1725ad60" />


``` sql
SELECT 
    o.order_id,
    (SELECT SUM(weight) FROM cargos cg WHERE cg.order_id = o.order_id) AS total_weight
FROM orders o;
```

<img width="328" height="108" alt="Снимок экрана 2025-11-04 212356" src="https://github.com/user-attachments/assets/5b6b739f-9622-4e25-95fa-a7154508db35" />


# 2. FROM

``` sql
SELECT client_id, total_sum
FROM (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
) AS order_summary
WHERE total_sum > 10000;
```

<img width="255" height="111" alt="Снимок экрана 2025-11-04 212422" src="https://github.com/user-attachments/assets/64982c64-916f-4cca-bb0d-88579844f109" />


``` sql
SELECT route_id, avg_distance
FROM (
    SELECT route_id, AVG(distance_km) AS avg_distance
    FROM routes
    GROUP BY route_id
) r
WHERE avg_distance > 300;
```

<img width="371" height="234" alt="Снимок экрана 2025-11-04 212441" src="https://github.com/user-attachments/assets/9e0f1d49-f2a3-48b4-bf81-ce71d477bb4f" />


``` sql
SELECT * 
FROM (
    SELECT payment_id, amount FROM payments WHERE method = 'Карта'
) AS card_payments
WHERE amount > 1000;
```

<img width="309" height="79" alt="Снимок экрана 2025-11-04 212456" src="https://github.com/user-attachments/assets/ea541c77-c854-4c36-bf24-6e8aeecff462" />


# 3. WHERE

``` sql
SELECT * FROM orders
WHERE client_id IN (
    SELECT client_id FROM clients WHERE name LIKE 'О%'
);
```

<img width="955" height="77" alt="Снимок экрана 2025-11-04 212619" src="https://github.com/user-attachments/assets/e37fff73-1252-446d-82d2-6bfde66f3ddd" />


``` sql
SELECT * FROM cargos
WHERE order_id IN (
    SELECT order_id FROM orders WHERE total_cost > 10000
);
```

<img width="932" height="110" alt="Снимок экрана 2025-11-04 212639" src="https://github.com/user-attachments/assets/aee949d9-4da9-4be8-b133-b956fd3ec135" />


``` sql
SELECT * FROM vehicles
WHERE vehicle_id NOT IN (
    SELECT vehicle_id FROM trips WHERE arrival_datetime IS NULL
);
```

<img width="874" height="174" alt="Снимок экрана 2025-11-04 212655" src="https://github.com/user-attachments/assets/5a33708d-aa4e-4179-bf6e-6e905ce5ec55" />


# 4. HAVING

``` sql
SELECT client_id, SUM(total_cost) AS total_sum
FROM orders
GROUP BY client_id
HAVING SUM(total_cost) > (
    SELECT AVG(total_cost) FROM orders
);
```

<img width="253" height="77" alt="Снимок экрана 2025-11-04 212709" src="https://github.com/user-attachments/assets/0a370f90-6edc-4c77-a8e7-2aec348c004a" />


``` sql
SELECT package_type, AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type
HAVING AVG(weight) > (
    SELECT AVG(weight) FROM cargos WHERE package_type = 'Паллета'
);
```

<img width="395" height="81" alt="Снимок экрана 2025-11-04 212738" src="https://github.com/user-attachments/assets/de801c8d-4bbd-403a-8090-a52aa077c9c8" />


``` sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
HAVING COUNT(*) > (
    SELECT COUNT(*) FROM orders WHERE status = 'Отменён'
);
```

<img width="320" height="111" alt="Снимок экрана 2025-11-04 212809" src="https://github.com/user-attachments/assets/d9e30840-1d4e-40ba-869c-d690d8cafa4e" />


# 5. ALL

``` sql
SELECT * FROM orders
WHERE total_cost > ALL (
    SELECT amount FROM payments WHERE status = 'Проведён'
);
```

<img width="954" height="76" alt="Снимок экрана 2025-11-04 212830" src="https://github.com/user-attachments/assets/3394706a-5bc8-4b72-b189-2b44a48e893f" />


``` sql
SELECT * FROM vehicles
WHERE capacity > ALL (
    SELECT capacity FROM vehicles WHERE status = 'Ремонт'
);
```

<img width="874" height="79" alt="Снимок экрана 2025-11-04 212845" src="https://github.com/user-attachments/assets/6dea842b-7ea3-4cbd-b3b5-fd85f2766441" />


``` sql
SELECT * FROM cargos
WHERE weight < ALL (
    SELECT weight FROM cargos WHERE package_type = 'Контейнер'
);
```
<img width="951" height="75" alt="Снимок экрана 2025-11-04 212904" src="https://github.com/user-attachments/assets/b21fcbb8-25ae-4191-9adf-88573ba1cbd0" />

# 6. IN
``` sql
SELECT * FROM clients
WHERE client_id IN (
    SELECT client_id FROM orders WHERE status = 'delivered'
);
```

<img width="291" height="67" alt="Снимок экрана 2025-11-04 в 23 41 10" src="https://github.com/user-attachments/assets/94d42a42-7f8d-4096-bbed-1fccf7f7abf6" />

``` sql
SELECT * FROM vehicles
WHERE vehicle_id IN (
    SELECT vehicle_id FROM trips WHERE departure_datetime > CURRENT_DATE - INTERVAL '30 days'
);
```

<img width="689" height="67" alt="Снимок экрана 2025-11-04 в 23 34 19" src="https://github.com/user-attachments/assets/b5d0f93c-31b7-441d-b181-4be822e904e5" />

``` sql
SELECT * FROM cargos
WHERE order_id IN (
    SELECT order_id FROM payments WHERE amount > 1000
);
```

<img width="767" height="67" alt="Снимок экрана 2025-11-04 в 23 39 17" src="https://github.com/user-attachments/assets/bfc67a81-5c75-4078-bdbc-aaf255747d93" />

# 7. ANY

``` sql
SELECT * FROM orders
WHERE total_cost > ANY (
    SELECT amount FROM payments WHERE method = 'card'
);
```

<img width="1017" height="92" alt="Снимок экрана 2025-11-04 в 23 44 37" src="https://github.com/user-attachments/assets/4ddedaf6-f6af-4c5a-8be3-680ee127e82f" />

``` sql
SELECT * FROM cargos
WHERE weight > ANY (
    SELECT weight FROM cargos WHERE package_type = 'Box'
);

```

<img width="799" height="163" alt="Снимок экрана 2025-11-04 в 23 49 29" src="https://github.com/user-attachments/assets/cce0dd83-6673-4bb1-8f0b-9fa4d03e6021" />


``` sql
SELECT * FROM vehicles
WHERE capacity < ANY (
    SELECT capacity FROM vehicles WHERE status = 'available'
);
```

<img width="687" height="92" alt="Снимок экрана 2025-11-04 в 23 50 30" src="https://github.com/user-attachments/assets/d5a4b991-8227-4d99-b435-b03d45601b7a" />

# 8. EXIST

``` sql
SELECT c.name
FROM clients c
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.client_id = c.client_id
);
```
<img width="200" height="168" alt="Снимок экрана 2025-11-04 в 23 52 02" src="https://github.com/user-attachments/assets/4d0eb4e3-465e-45be-96a6-ee51a0d4d419" />

``` sql
SELECT o.order_id
FROM orders o
WHERE EXISTS (
    SELECT 1 FROM cargos cg WHERE cg.order_id = o.order_id AND cg.weight > 100
);
```

<img width="138" height="89" alt="Снимок экрана 2025-11-04 в 23 52 42" src="https://github.com/user-attachments/assets/1a822bc5-3731-4e45-8cb9-a615d30c363e" />

``` sql
SELECT v.vehicle_id
FROM vehicles v
WHERE EXISTS (
    SELECT 1 FROM trips t WHERE t.vehicle_id = v.vehicle_id AND t.arrival_datetime IS NOT NULL
);
```

<img width="140" height="114" alt="Снимок экрана 2025-11-04 в 23 53 08" src="https://github.com/user-attachments/assets/f0056d66-4535-467e-b710-fcd2ad866778" />

# 9. Сравнение по нескольким столбцам

``` sql
SELECT order_id, client_id, total_cost
FROM orders
WHERE (client_id, total_cost) IN (
    SELECT client_id, MAX(total_cost)
    FROM orders
    GROUP BY client_id
);
```

<img width="324" height="164" alt="Снимок экрана 2025-11-04 в 23 54 50" src="https://github.com/user-attachments/assets/831affda-cc2c-473c-b2d2-d24856bf5638" />

``` sql
SELECT vehicle_id, type, capacity
FROM vehicles
WHERE (type, capacity) IN (
    SELECT type, MAX(capacity)
    FROM vehicles
    GROUP BY type
);
```

<img width="395" height="115" alt="Снимок экрана 2025-11-04 в 23 55 31" src="https://github.com/user-attachments/assets/bdd091b5-118a-4dd6-9be2-6113aff79504" />

``` sql
SELECT route_id, distance_km, estimated_time
FROM routes
WHERE (distance_km, estimated_time) IN (
    SELECT MAX(distance_km), MAX(estimated_time)
    FROM routes
);
```

<img width="361" height="65" alt="Снимок экрана 2025-11-04 в 23 56 05" src="https://github.com/user-attachments/assets/68766ede-c554-4182-a0c8-56c099f4f9e1" />

# 10. Коррелированные подзапросы

``` sql
SELECT 
    c.client_id,
    c.name,
    (SELECT COUNT(*) 
     FROM orders o 
     WHERE o.client_id = c.client_id) AS order_count
FROM clients c;
```

<img width="385" height="167" alt="Снимок экрана 2025-11-04 в 23 57 42" src="https://github.com/user-attachments/assets/3e8cee33-5401-47f1-9eda-b3d6d7b339b9" />

``` sql
SELECT 
    o.order_id,
    o.client_id,
    o.total_cost
FROM orders o
WHERE o.total_cost > (
    SELECT AVG(o2.total_cost)
    FROM orders o2
    WHERE o2.client_id = o.client_id
);
```

<img width="321" height="61" alt="Снимок экрана 2025-11-05 в 00 01 34" src="https://github.com/user-attachments/assets/d411d024-b2c3-4ef7-b94c-5f7f40bdce57" />

``` sql
SELECT o.order_id, o.total_cost
FROM orders o
WHERE EXISTS (
    SELECT 1
    FROM cargos c
    WHERE c.order_id = o.order_id
      AND c.weight > 1000
);
```

<img width="247" height="64" alt="Снимок экрана 2025-11-05 в 00 02 12" src="https://github.com/user-attachments/assets/9f8b8d18-6475-4f3d-bf0c-847e30cb173c" />

``` sql
SELECT DISTINCT c.client_id, c.name
FROM clients c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.client_id = c.client_id
      AND o.total_cost > (
          SELECT AVG(o2.total_cost)
          FROM orders o2
          WHERE o2.client_id = o.client_id
      )
);
```

<img width="294" height="67" alt="Снимок экрана 2025-11-05 в 00 06 58" src="https://github.com/user-attachments/assets/421d0428-0adf-404c-bf69-99fd643c9053" />

``` sql
SELECT 
    v.vehicle_id,
    v.type,
    v.mileage
FROM vehicles v
WHERE v.mileage > (
    SELECT AVG(v2.mileage)
    FROM vehicles v2
    WHERE v2.type = v.type
);
```

<img width="398" height="64" alt="Снимок экрана 2025-11-05 в 00 13 48" src="https://github.com/user-attachments/assets/1448050e-60a4-4585-a6bd-0b07a6b3771d" />
