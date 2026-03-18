# LSN до и после INSERT

``` sql
SELECT pg_current_wal_lsn() AS lsn_before;

INSERT INTO orders (tariff_id, delivery_date, status, total_cost, notes, client_id, trip_id)
VALUES (1, '2026-03-20', 'pending', 1500.00, 'Тестовый заказ', 1, NULL);

SELECT pg_current_wal_lsn() AS lsn_after;
```

<img width="137" height="71" alt="Снимок экрана 2026-03-18 в 00 29 28" src="https://github.com/user-attachments/assets/5980a217-cc7a-4eb2-a688-5808f3865016" />

<img width="161" height="74" alt="Снимок экрана 2026-03-18 в 00 30 42" src="https://github.com/user-attachments/assets/049161a9-0d95-44c4-8bb7-4f3c94e60828" />

# LSN до и после COMMIT

``` sql
BEGIN;
INSERT INTO orders (tariff_id, delivery_date, status, total_cost, notes, client_id, trip_id)
VALUES (1, '2026-03-20', 'pending', 1500.00, 'Тестовый заказ', 1, NULL);
SELECT pg_current_wal_lsn() AS lsn_before_commit;
COMMIT;
SELECT pg_current_wal_lsn() AS lsn_after_commit;
```

<img width="183" height="70" alt="Снимок экрана 2026-03-18 в 00 32 16" src="https://github.com/user-attachments/assets/06149294-1a2b-43e4-bb1f-27048fd8ef06" />

<img width="182" height="75" alt="Снимок экрана 2026-03-18 в 00 32 35" src="https://github.com/user-attachments/assets/99697f76-86a9-4d1e-8447-ed372c487e63" />

# Анализ WAL размера после массовой операции

размер WAL до

``` sql
SELECT pg_size_pretty(sum(size)) AS wal_size_before
FROM pg_ls_waldir();
```

<img width="171" height="71" alt="Снимок экрана 2026-03-18 в 00 43 22" src="https://github.com/user-attachments/assets/f838c13b-aae0-4407-b9c0-c6be75165b97" />

вставка 1_000_000 значений

``` sql
INSERT INTO tariffs (type, price_per_km, price_per_kg)
SELECT 
    'tariff_' || gs,
    10.0,
    2.0
FROM generate_series(1, 1000000) AS gs;
```

размер WAL после

``` sql
SELECT pg_size_pretty(sum(size)) AS wal_size_after
FROM pg_ls_waldir();
```

<img width="172" height="73" alt="Снимок экрана 2026-03-18 в 00 45 36" src="https://github.com/user-attachments/assets/18f99b82-fd39-4852-9f7c-d2f706a4b5ad" />

# Дамп

Дамп только структуры, файл приложен

``` bash
pg_dump -h localhost -p 5432 -U postgres -d " LogistDB" --schema-only > db_schema.sql
```

Дамп одной таблицы, файл приложен

``` bash
pg_dump -h localhost -p 5432 -U postgres -d " LogistDB" -t "cargos" --schema-only > table_dump.sql
```

# seed, просто через sql код

добавление тестовых данных 

``` sql
INSERT INTO clients(name)
SELECT 'user_' || n
FROM generate_series(1, 1000) AS n;
```

проверка идемпотентности seed (ON CONFLICT и др)

``` sql
INSERT INTO client_contacts (client_id, phone, email, address)
VALUES 
(3, '+7-495-123-45-67', 'info@romashka.ru', 'Москва, ул. Ленина, 1'),
(4, '+7-495-765-43-21', 'ivanov@mail.ru', 'Москва, ул. Тверская, 10'),
(5, '+7-495-111-22-33', 'tech@technopark.ru', 'СПб, Невский пр., 20')
ON CONFLICT (client_id) DO NOTHING;
```

``` sql
INSERT INTO clients (client_id, name) VALUES (1, 'Новое имя')
ON CONFLICT (client_id) DO UPDATE SET name = EXCLUDED.name;
```
