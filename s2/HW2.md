``` sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE total_cost > 45000;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE status = 'In_Transit';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE status IN ('New', 'Processing');

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE notes LIKE 'Test order info%';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM orders WHERE notes LIKE '%batch 500';
```


<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.22.02.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.22.11.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.22.20.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.22.29.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.22.38.png" />

добавляем индексы
``` sql
CREATE INDEX idx_orders_cost_btree ON orders USING btree (total_cost);
CREATE INDEX idx_orders_status_btree ON orders USING btree (status);
CREATE INDEX idx_orders_notes_btree ON orders USING btree (notes);
```

выполняем снова те 5 запросов

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.31.44.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.31.58.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.32.06.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.32.14.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.32.22.png" />

очищаем b tree индексы и добавляем hash
``` sql
DROP INDEX idx_orders_cost_btree;
DROP INDEX idx_orders_status_btree;
DROP INDEX idx_orders_notes_btree;

CREATE INDEX idx_orders_cost_hash ON orders USING hash (total_cost);
CREATE INDEX idx_orders_status_hash ON orders USING hash (status);
CREATE INDEX idx_orders_notes_hash ON orders USING hash (notes);
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.40.32.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.40.39.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.40.47.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.40.54.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 15.41.00.png" />