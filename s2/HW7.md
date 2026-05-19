1
``` sql
CREATE TABLE sales_range (id serial, amount numeric, sale_date date) PARTITION BY RANGE (sale_date);
CREATE TABLE sales_jan PARTITION OF sales_range FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE INDEX idx_sales_jan ON sales_jan(sale_date);
INSERT INTO sales_range (amount, sale_date) VALUES (100, '2026-01-15');

EXPLAIN ANALYZE SELECT * FROM sales_range WHERE sale_date = '2026-01-15';

CREATE TABLE users_list (id int, region text) PARTITION BY LIST (region);
CREATE TABLE users_eu PARTITION OF users_list FOR VALUES IN ('EU');
INSERT INTO users_list VALUES (1, 'EU');

EXPLAIN ANALYZE SELECT * FROM users_list WHERE region = 'EU';

CREATE TABLE logs_hash (id int, msg text) PARTITION BY HASH (id);
CREATE TABLE logs_p0 PARTITION OF logs_hash FOR VALUES WITH (MODULUS 2, REMAINDER 0);
CREATE TABLE logs_p1 PARTITION OF logs_hash FOR VALUES WITH (MODULUS 2, REMAINDER 1);
INSERT INTO logs_hash VALUES (1, 'A'), (2, 'B');

EXPLAIN ANALYZE SELECT * FROM logs_hash WHERE id = 2;
```

<img alt="screen" src="img/Снимок экрана 2026-05-19 в 23.57.25.png" />

2
``` shell
docker exec -it phys_replica psql -U admin -d hw_db

\d+ sales_range
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 00.08.24.png" />

3
``` shell
docker exec -it shard1 psql -U admin -d hw_db
```

``` sql

CREATE TABLE sales_range (id serial, amount numeric, sale_date date);

CREATE SUBSCRIPTION sub_sales CONNECTION 'host=router port=5432 user=admin dbname=hw_db' PUBLICATION pub_sales;

SELECT * FROM sales_range;
\q
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 00.50.55.png" />

4
``` sql
CREATE EXTENSION postgres_fdw;

CREATE SERVER s1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'shard1', port '5432', dbname 'hw_db');
CREATE SERVER s2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'shard2', port '5432', dbname 'hw_db');

CREATE USER MAPPING FOR admin SERVER s1 OPTIONS (user 'admin', password 'admin');
CREATE USER MAPPING FOR admin SERVER s2 OPTIONS (user 'admin', password 'admin');

CREATE TABLE users_sharded (id int, name text) PARTITION BY HASH (id);
CREATE FOREIGN TABLE users_shard_1 PARTITION OF users_sharded FOR VALUES WITH (MODULUS 2, REMAINDER 0) SERVER s1 OPTIONS (table_name 'users_data');
CREATE FOREIGN TABLE users_shard_2 PARTITION OF users_sharded FOR VALUES WITH (MODULUS 2, REMAINDER 1) SERVER s2 OPTIONS (table_name 'users_data');

INSERT INTO users_sharded VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie'), (4, 'David');

EXPLAIN SELECT * FROM users_sharded;

EXPLAIN SELECT * FROM users_sharded WHERE id = 1;
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 00.56.43.png" />
