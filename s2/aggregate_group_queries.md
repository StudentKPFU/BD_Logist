# 1. COUNT()

``` sql
SELECT c.client_id, c.name, COUNT(o.order_id) AS orders_count
FROM clients c
LEFT JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```
<img width="497" height="163" alt="Снимок экрана 2025-10-29 090611" src="https://github.com/user-attachments/assets/fa4cbf6a-b0fe-4043-a779-65ffd7f902e0" />


``` sql
SELECT o.order_id, COUNT(DISTINCT cgs.package_type) AS distinct_package_types
FROM orders o
JOIN cargos cgs ON cgs.order_id = o.order_id
GROUP BY o.order_id;
```
<img width="360" height="110" alt="Снимок экрана 2025-10-29 094552" src="https://github.com/user-attachments/assets/31486099-9533-4687-afb6-284cd12ca8bb" />


# 2. SUM()

``` sql
SELECT c.client_id, c.name, SUM(o.total_cost) AS sum_total_cost
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```
<img width="504" height="108" alt="Снимок экрана 2025-10-29 094609" src="https://github.com/user-attachments/assets/1e2610ba-e897-48d4-b5ee-3fdd7ba87d7f" />


``` sql
SELECT order_id, SUM(weight) AS total_weight_kg
FROM cargos
GROUP BY order_id;
```
<img width="295" height="111" alt="Снимок экрана 2025-10-29 094625" src="https://github.com/user-attachments/assets/b4edf6c6-24fa-4bfe-a76a-7f57c0b61a5e" />


# 3. AVG()

``` sql
SELECT method, AVG(amount) AS avg_amount
FROM payments
GROUP BY method;
```
<img width="442" height="107" alt="Снимок экрана 2025-10-29 094649" src="https://github.com/user-attachments/assets/1adce24a-87bf-4699-9f97-ebd0d2b71013" />


``` sql
SELECT 'all_routes' AS scope, AVG(distance_km) AS avg_distance_km
FROM routes;
```
<img width="341" height="76" alt="Снимок экрана 2025-10-29 094704" src="https://github.com/user-attachments/assets/fff9cf88-7aa3-4f21-996b-5bac192a7d8c" />


# 4. MIN()

``` sql
SELECT c.client_id, c.name, MIN(o.delivery_date) AS first_delivery_date
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```
<img width="530" height="107" alt="Снимок экрана 2025-10-29 094718" src="https://github.com/user-attachments/assets/e60a093f-d4c4-4cff-9361-4f1995c4085e" />


``` sql
SELECT package_type, MIN(weight) AS min_weight
FROM cargos
GROUP BY package_type;
```
<img width="388" height="106" alt="Снимок экрана 2025-10-29 094734" src="https://github.com/user-attachments/assets/5a89fa25-df1d-420c-b404-b58f597b3c02" />


# 5. MAX()

``` sql
SELECT c.client_id, c.name, MAX(o.total_cost) AS max_order_cost
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```
<img width="510" height="108" alt="Снимок экрана 2025-10-29 094753" src="https://github.com/user-attachments/assets/1fbb3000-ffdb-4b4e-9adc-76b0f2e9bfa7" />


``` sql
SELECT type, MAX(capacity) AS max_capacity
FROM vehicles
GROUP BY type;
```
<img width="372" height="142" alt="Снимок экрана 2025-10-29 094809" src="https://github.com/user-attachments/assets/db928874-3031-45bb-a3a6-66f0764fcbef" />


# 6. STRING_AGG()

``` sql
SELECT d.order_id,
      STRING_AGG(DISTINCT d.document_type, ', ' ORDER BY d.document_type) AS doc_types
FROM documents d
GROUP BY d.order_id;
```
<img width="263" height="110" alt="Снимок экрана 2025-10-29 094828" src="https://github.com/user-attachments/assets/fb333fa2-c075-43eb-8ec5-21f2cf196ed3" />


``` sql
SELECT c.client_id,
       c.name,
       STRING_AGG(DISTINCT cg.package_type, ', ' ORDER BY cg.package_type) AS package_types_used
FROM clients c
JOIN orders o ON o.client_id = c.client_id
JOIN cargos cg ON cg.order_id = o.order_id
GROUP BY c.client_id, c.name;
```
<img width="540" height="109" alt="Снимок экрана 2025-10-29 094842" src="https://github.com/user-attachments/assets/40eb393d-3efa-4a76-a9ae-6e3617d1a43a" />


# 7. GROUP BY

``` sql
SELECT 
    c.client_id,
    c.name AS client_name,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```
<img width="473" height="107" alt="Снимок экрана 2025-10-29 094900" src="https://github.com/user-attachments/assets/fb8a0847-d2b9-498c-a468-3f78b80a00f5" />


``` sql
SELECT 
    package_type,
    AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type;
```
<img width="391" height="107" alt="Снимок экрана 2025-10-29 094914" src="https://github.com/user-attachments/assets/76190e9b-a1a9-4b9e-bd82-a05bb7fe4a2f" />


# 8. HAVING

``` sql
SELECT 
    c.name AS client_name,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.name
HAVING SUM(o.total_cost) > 10000;
```
<img width="353" height="111" alt="Снимок экрана 2025-10-29 094943" src="https://github.com/user-attachments/assets/e759d346-0d6c-41b4-b95e-343998764279" />


``` sql
SELECT 
    package_type,
    AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type
HAVING AVG(weight) > 100;
```
<img width="388" height="107" alt="Снимок экрана 2025-10-29 094959" src="https://github.com/user-attachments/assets/5e48f6a2-bcfb-4859-b04d-8981247ee804" />


# 9. GROUPING SETS

``` sql
SELECT 
    c.name AS client_name,
    cg.package_type,
    SUM(cg.price) AS total_price
FROM clients c
JOIN orders o ON o.client_id = c.client_id
JOIN cargos cg ON cg.order_id = o.order_id
GROUP BY GROUPING SETS ((c.name), (cg.package_type));
```
<img width="544" height="172" alt="Снимок экрана 2025-10-29 095021" src="https://github.com/user-attachments/assets/61520833-502a-4ba6-a7df-90ce91be83a1" />


``` sql
SELECT 
    c.name AS client_name,
    o.status,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY GROUPING SETS ((c.name), (o.status));
```
<img width="539" height="169" alt="image" src="https://github.com/user-attachments/assets/19f1893c-0f6c-468b-8953-b586baa65bf6" />

# 10 ROLLUP

``` sql
SELECT client_id, tariff_id, SUM(COALESCE(total_cost,0)) AS sum_cost
FROM orders
GROUP BY ROLLUP (client_id, tariff_id)
ORDER BY client_id, tariff_id;
```

<img width="276" height="312" alt="Снимок экрана 2025-10-29 в 10 40 59" src="https://github.com/user-attachments/assets/02e45503-968e-434e-89ee-ca8075d01a9b" />

``` sql
SELECT route_id, vehicle_id, COUNT(*) AS trips_count
FROM trips
GROUP BY ROLLUP (route_id, vehicle_id)
ORDER BY route_id, vehicle_id;
```

<img width="292" height="213" alt="Снимок экрана 2025-10-29 в 10 42 24" src="https://github.com/user-attachments/assets/d27f1ae5-11c4-4d2c-8251-a119215ff629" />

# 11 CUBE

``` sql
SELECT client_id, status, SUM(COALESCE(total_cost,0)) AS sum_cost
FROM orders
GROUP BY CUBE (client_id, status)
ORDER BY client_id, status;
```

<img width="350" height="461" alt="Снимок экрана 2025-10-29 в 10 43 16" src="https://github.com/user-attachments/assets/d7e21840-43a9-4483-a518-8f6fc4a16ade" />

``` sql
SELECT route_id, vehicle_id, COUNT(*) AS trips_count
FROM trips
GROUP BY CUBE (route_id, vehicle_id)
ORDER BY route_id, vehicle_id;
```

<img width="292" height="287" alt="Снимок экрана 2025-10-29 в 10 44 13" src="https://github.com/user-attachments/assets/38f47844-df43-466c-9253-0a3ba5eb5cab" />
