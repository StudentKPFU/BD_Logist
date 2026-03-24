Отдельная таблица для теста
``` sql
CREATE TABLE mvcc_test (id serial PRIMARY KEY, value text); INSERT INTO mvcc_test (value) VALUES ('Initial');
```

``` sql
SELECT ctid, xmin, xmax, * FROM mvcc_test;
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 20.04.38.png" />

``` sql
SELECT lp, t_ctid, t_xmin, t_xmax, t_infomask 
FROM heap_page_items(get_raw_page('mvcc_test', 0));
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 20.09.33.png" />


разные транзакции
1
``` sql
BEGIN;
UPDATE mvcc_test SET value = 'Updated' WHERE id = 1;
SELECT ctid, xmin, xmax, * FROM mvcc_test;
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 20.12.59.png" />
2
``` sql
SELECT ctid, xmin, xmax, * FROM mvcc_test;
```

![[Снимок экрана 2026-05-05 в 20.14.45.png]]

1
``` sql
COMMIT;
```

2
``` sql
SELECT ctid, xmin, xmax, * FROM mvcc_test;
```

![[Снимок экрана 2026-05-05 в 20.16.18.png]]

deadlock

``` sql
-- 1
BEGIN; UPDATE mvcc_test SET value = 'Lock 1' WHERE id = 1;
-- 2
BEGIN; UPDATE mvcc_test SET value = 'Lock 2' WHERE id = 2;
-- 3
UPDATE mvcc_test SET value = 'Wait 2' WHERE id = 2;
-- 4
UPDATE mvcc_test SET value = 'Wait 1' WHERE id = 1;
```

![[Снимок экрана 2026-05-05 в 20.18.56.png]]
For Share и For Update

``` sql
-- 1
BEGIN; 
SELECT * FROM mvcc_test WHERE id = 1 FOR SHARE;

-- 2(откисает)
BEGIN;
SELECT * FROM mvcc_test WHERE id = 1 FOR UPDATE;

-- 1
COMMIT;
-- 2 оживаем и забираем строку
```

![[Снимок экрана 2026-05-05 в 20.31.56.png]]

Очистка
``` sql
VACUUM VERBOSE mvcc_test;
```

![[Снимок экрана 2026-05-05 в 20.33.50.png]]
