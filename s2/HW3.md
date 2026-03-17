GIN
``` sql
CREATE INDEX idx_orders_metadata_gin ON orders USING gin (metadata);
```

``` sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE metadata @> '{"tags": ["urgent"]}'; 
EXPLAIN ANALYZE SELECT * FROM orders WHERE metadata ? 'tags'; 
EXPLAIN ANALYZE SELECT * FROM orders WHERE metadata @> '{"tags": ["fragile", "insured"]}'; 
EXPLAIN ANALYZE SELECT * FROM orders WHEREmetadata @> '{"tags": ["liquid"]}' AND NOT metadata @> '{"tags": ["urgent"]}'; 
EXPLAIN ANALYZE SELECT * FROM orders WHERE metadata @>'{"status_code": 200}';
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.28.43.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.29.14.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.29.29.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.29.43.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.29.53.png" />

GIST
``` sql
CREATE EXTENSION IF NOT EXISTS pg_trgm; 
CREATEINDEX idx_orders_notes_gist ON orders USING gist (notes gist_trgm_ops);
```

``` sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE notes % 'Test order batch 500';

EXPLAIN ANALYZE SELECT * FROM orders ORDER BY notes <-> 'Test order info' LIMIT 10;

EXPLAIN ANALYZE SELECT * FROM orders WHERE notes LIKE '%batch 888%';

EXPLAIN ANALYZE SELECT * FROM orders WHERE notes ILIKE '%TEST%';

EXPLAIN ANALYZE SELECT * FROM orders WHERE notes ~ 'batch 10[0-9]';
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.51.23.png" />

**<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.51.31.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.51.38.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.51.49.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 18.51.57.png" />

JOIN
``` sql
EXPLAIN ANALYZE 
SELECT o.order_id, c.name FROM orders o JOIN clients c ON o.client_id = c.client_id;

EXPLAIN ANALYZE 
SELECT t.trip_id, r.departure_city, d.license_number 
FROM trips t 
JOIN routes r ON t.route_id = r.route_id
JOIN drivers d ON t.driver_id = d.driver_id;

EXPLAIN ANALYZE 
SELECT o.order_id, i.amount FROM orders o LEFT JOIN invoices i ON o.order_id = i.order_id;

EXPLAIN ANALYZE 
SELECT o.order_id, SUM(c.weight) as total_weight
FROM orders o JOIN cargos c ON o.order_id = c.order_id GROUP BY o.order_id;

EXPLAIN ANALYZE 
SELECT o.order_id, c.name FROM orders o JOIN clients c ON o.client_id = c.client_id 
WHERE o.total_cost > 49000;
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 19.01.28.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 19.02.04.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 19.04.56.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 19.02.38.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 19.02.53.png" />
