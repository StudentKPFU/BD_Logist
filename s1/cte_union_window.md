# 1. CTE

``` sql
WITH order_totals AS (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
)
SELECT c.client_id, c.name, ot.total_sum
FROM clients c
JOIN order_totals ot ON c.client_id = ot.client_id;
```

<img width="473" height="112" alt="Снимок экрана 2025-11-12 084423" src="https://github.com/user-attachments/assets/f55d9f10-51c2-4e76-b2ac-9eae9fb2f838" />


``` sql
WITH cargo_avg AS (
    SELECT order_id, AVG(weight) AS avg_weight
    FROM cargos
    GROUP BY order_id
)
SELECT o.order_id, o.total_cost, ca.avg_weight
FROM orders o
JOIN cargo_avg ca ON o.order_id = ca.order_id;
```

<img width="461" height="107" alt="Снимок экрана 2025-11-12 084442" src="https://github.com/user-attachments/assets/86cf3c50-9488-4edb-9f6a-62c8f759cc61" />


``` sql
WITH heavy_orders AS (
    SELECT order_id
    FROM cargos
    GROUP BY order_id
    HAVING SUM(weight) > 500
)
SELECT * FROM orders
WHERE order_id IN (SELECT order_id FROM heavy_orders);
```

<img width="954" height="113" alt="Снимок экрана 2025-11-12 084504" src="https://github.com/user-attachments/assets/5de4bc28-eff5-4fb8-ba3e-531eaa387a65" />


``` sql
WITH client_income AS (
    SELECT client_id, SUM(total_cost) AS total_income
    FROM orders
    GROUP BY client_id
)
SELECT * FROM clients
WHERE client_id IN (
    SELECT client_id
    FROM client_income
    WHERE total_income > 10000
);
```

<img width="367" height="110" alt="Снимок экрана 2025-11-12 084539" src="https://github.com/user-attachments/assets/c46a988a-8988-48e3-91c9-406c05559e97" />


``` sql
WITH last_orders AS (
    SELECT client_id, MAX(created_at) AS last_order_date
    FROM orders
    GROUP BY client_id
)
SELECT c.name, o.order_id, o.created_at
FROM orders o
JOIN last_orders lo ON o.client_id = lo.client_id AND o.created_at = lo.last_order_date
JOIN clients c ON c.client_id = o.client_id;
```

<img width="579" height="110" alt="Снимок экрана 2025-11-12 084609" src="https://github.com/user-attachments/assets/526cfa21-f615-429c-8640-82fccb020cd7" />


# 2. UNION

``` sql
SELECT name FROM clients WHERE client_id < 3
UNION
SELECT name FROM clients WHERE client_id > 2;
```

<img width="247" height="166" alt="Снимок экрана 2025-11-12 084706" src="https://github.com/user-attachments/assets/fb71cc6f-6434-4dca-a4a5-f18d094f4feb" />


``` sql
SELECT plate_number FROM vehicles WHERE status = 'В рейсе'
UNION
SELECT plate_number FROM vehicles WHERE status = 'Ремонт';
```

<img width="242" height="107" alt="Снимок экрана 2025-11-12 084720" src="https://github.com/user-attachments/assets/6b0dad65-3a99-47ae-bd4b-57681c8c4954" />


``` sql
SELECT status FROM orders WHERE total_cost > 10000
UNION
SELECT status FROM orders WHERE delivery_date IS NOT NULL;
```

<img width="238" height="108" alt="Снимок экрана 2025-11-12 084735" src="https://github.com/user-attachments/assets/580cd4c6-5bc8-485d-b89c-f150ae62d09f" />


# 3. INTERSECT

``` sql
SELECT client_id FROM orders WHERE total_cost > 5000
INTERSECT
SELECT client_id FROM orders WHERE status = 'Доставлен';
```

<img width="149" height="78" alt="Снимок экрана 2025-11-12 084821" src="https://github.com/user-attachments/assets/ceea34d8-239f-4ed2-9322-6c7cdd21d0be" />


``` sql
SELECT vehicle_id FROM vehicles WHERE type = 'Грузовик'
INTERSECT
SELECT vehicle_id FROM trips;
```

<img width="160" height="111" alt="Снимок экрана 2025-11-12 084838" src="https://github.com/user-attachments/assets/c41448a1-6bf8-4ad6-b87e-65708eb48b27" />


``` sql
SELECT order_id FROM cargos WHERE package_type = 'Контейнер'
INTERSECT
SELECT order_id FROM cargos WHERE weight > 500;
```

<img width="150" height="80" alt="Снимок экрана 2025-11-12 084857" src="https://github.com/user-attachments/assets/38a337aa-aa03-447b-a802-06c462c81f87" />


# 4. EXCEPT

``` sql
SELECT client_id FROM clients
EXCEPT
SELECT client_id FROM orders;
```

<img width="146" height="111" alt="Снимок экрана 2025-11-12 084914" src="https://github.com/user-attachments/assets/a03595e5-6e14-4638-909d-7b633ee9deb6" />


``` sql
SELECT vehicle_id FROM vehicles
EXCEPT
SELECT vehicle_id FROM trips;
```

<img width="157" height="113" alt="Снимок экрана 2025-11-12 084931" src="https://github.com/user-attachments/assets/ab8302ae-7eda-4699-ba91-b25ab73023bb" />


``` sql
SELECT vehicle_id FROM vehicles
EXCEPT
SELECT vehicle_id FROM drivers;
```

<img width="156" height="110" alt="Снимок экрана 2025-11-12 085150" src="https://github.com/user-attachments/assets/fa225c55-d8c2-414a-be69-36f3e7a129c8" />


# 5. PARTITION BY

``` sql
SELECT 
    client_id, 
    order_id, 
    SUM(total_cost) OVER (PARTITION BY client_id) AS client_total
FROM orders;
```

<img width="377" height="113" alt="Снимок экрана 2025-11-12 085244" src="https://github.com/user-attachments/assets/c69c9df1-fc05-48e3-b0d0-dfae2b2148f0" />


``` sql
SELECT 
    package_type, 
    weight, 
    AVG(weight) OVER (PARTITION BY package_type) AS avg_weight
FROM cargos;
```

<img width="543" height="109" alt="Снимок экрана 2025-11-12 085304" src="https://github.com/user-attachments/assets/2c83a494-fc6e-43bb-8ee6-f990eab149a0" />


# 6. PARTITION BY + ORDER BY

``` sql
SELECT 
    client_id, 
    order_id, 
    total_cost,
    SUM(total_cost) OVER (PARTITION BY client_id ORDER BY created_at) AS running_total
FROM orders;
```

<img width="421" height="190" alt="Снимок экрана 2025-11-12 в 09 43 58" src="https://github.com/user-attachments/assets/becd113f-2b9b-4910-8ab0-0b9c1ff7130a" />

``` sql
SELECT 
    route_id, 
    distance_km,
    ROW_NUMBER() OVER (PARTITION BY route_id ORDER BY distance_km DESC) AS rank_per_route
FROM routes;
```

<img width="355" height="115" alt="Снимок экрана 2025-11-12 в 09 44 24" src="https://github.com/user-attachments/assets/e568cf7b-a829-4f7b-aff8-f0ee8880ac11" />

# 7. ROWS и RANGE

``` sql
SELECT 
    client_id,
    order_id,
    total_cost,
    SUM(total_cost) OVER (PARTITION BY client_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders;
```

<img width="420" height="189" alt="Снимок экрана 2025-11-12 в 09 45 15" src="https://github.com/user-attachments/assets/906bb52f-ceba-40c7-8bb3-873bbde01f65" />

``` sql
SELECT 
    client_id,
    order_id,
    total_cost,
    ROUND(AVG(total_cost) OVER (PARTITION BY client_id ORDER BY created_at ROWS BETWEEN 1 PRECEDING AND CURRENT ROW), 2) AS moving_avg
FROM orders;
```

<img width="418" height="188" alt="Снимок экрана 2025-11-12 в 09 47 21" src="https://github.com/user-attachments/assets/78ad6359-00dc-4394-bda9-8224f3d0742c" />

``` sql
SELECT 
    client_id,
    order_id,
    total_cost,
    SUM(total_cost) OVER (PARTITION BY client_id ORDER BY total_cost RANGE BETWEEN 1000 PRECEDING AND CURRENT ROW) AS sum_range
FROM orders;
```

<img width="411" height="186" alt="Снимок экрана 2025-11-12 в 09 47 59" src="https://github.com/user-attachments/assets/e4d98908-9cb1-4c26-a14c-a77b123143ff" />

``` sql
SELECT 
    client_id,
    order_id,
    total_cost,
    ROUND(AVG(total_cost) OVER (PARTITION BY client_id ORDER BY total_cost RANGE BETWEEN 500 PRECEDING AND 500 FOLLOWING), 2) AS avg_range
FROM orders;
```

<img width="410" height="190" alt="Снимок экрана 2025-11-12 в 09 48 36" src="https://github.com/user-attachments/assets/ac93ad10-c8a9-4698-91ce-5e7cbb9a8af4" />

# 8. Ранжирующие функции

``` sql
SELECT order_id, client_id, ROW_NUMBER() OVER (PARTITION BY client_id ORDER BY total_cost DESC) AS rn
FROM orders;
```

<img width="278" height="188" alt="Снимок экрана 2025-11-12 в 09 49 18" src="https://github.com/user-attachments/assets/987defb3-19d7-420a-8005-50762e59721e" />

``` sql
SELECT order_id, client_id, RANK() OVER (PARTITION BY client_id ORDER BY total_cost DESC) AS rnk
FROM orders;
```

<img width="273" height="188" alt="Снимок экрана 2025-11-12 в 09 49 46" src="https://github.com/user-attachments/assets/15234683-e454-46be-a1ee-e6269db5e43e" />

``` sql
SELECT order_id, client_id, DENSE_RANK() OVER (PARTITION BY client_id ORDER BY total_cost DESC) AS drnk
FROM orders;
```

<img width="272" height="190" alt="Снимок экрана 2025-11-12 в 09 50 13" src="https://github.com/user-attachments/assets/3340cf62-4812-4c12-ab0f-fa3fc13e8954" />

``` sql
SELECT order_id, client_id, NTILE(4) OVER (PARTITION BY client_id ORDER BY total_cost DESC) AS quartile
FROM orders;
```

<img width="284" height="187" alt="Снимок экрана 2025-11-12 в 09 50 43" src="https://github.com/user-attachments/assets/0769327e-d3d2-43f9-8f30-fb554a61b37a" />

# 9. Функции смещения

``` sql
SELECT order_id, client_id, total_cost,
       LAG(total_cost, 1) OVER (PARTITION BY client_id ORDER BY created_at) AS prev_cost
FROM orders;
```

<img width="400" height="189" alt="Снимок экрана 2025-11-12 в 09 51 50" src="https://github.com/user-attachments/assets/08a31882-2075-4900-8370-8b154fa7cd37" />

``` sql
SELECT order_id, client_id, total_cost,
       LEAD(total_cost, 1) OVER (PARTITION BY client_id ORDER BY created_at) AS next_cost
FROM orders;
```

<img width="400" height="187" alt="Снимок экрана 2025-11-12 в 09 52 15" src="https://github.com/user-attachments/assets/141beff2-22b8-4515-b396-8d1f4423805a" />

``` sql
SELECT order_id, client_id, total_cost,
       FIRST_VALUE(total_cost) OVER (PARTITION BY client_id ORDER BY created_at) AS first_order_cost
FROM orders;
```

<img width="435" height="189" alt="Снимок экрана 2025-11-12 в 09 52 42" src="https://github.com/user-attachments/assets/ef071bfd-0a15-40d0-b19e-88cf0ecb20ce" />

``` sql
SELECT order_id, client_id, total_cost,
       LAST_VALUE(total_cost) OVER (PARTITION BY client_id ORDER BY created_at ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_cost
FROM orders;
```

<img width="434" height="189" alt="Снимок экрана 2025-11-12 в 09 53 04" src="https://github.com/user-attachments/assets/7384d3ca-a818-41da-b7a8-2691ebe358b4" />
