1 задание

``` sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```
вывел seq scan, как ожидалось
<img width="937" height="251" alt="Снимок экрана 2026-04-01 в 10 52 55" src="https://github.com/user-attachments/assets/109af584-ec12-4b95-a767-9fb204cbb179" />

безтолковые индексы для данного запроса:
idx_store_checks_payment_type,
idx_store_checks_total_sum_hash

почему именно такой план:
нету фильтров

свой индекс подходящий:
``` sql
CREATE INDEX idx_store_checks_shop_id_sold_at
ON store_checks (shop_id, sold_at);
```
выполнил повторно для обновления статистики:
``` sql
ANALYZE store_checks;
```

и снова запускаем запрос с EXPLAIN:

``` sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

теперь уже INDEX SCAN
<img width="972" height="214" alt="Снимок экрана 2026-04-01 в 10 57 07" src="https://github.com/user-attachments/assets/da1bdb1e-1ba0-487e-a043-f47d98d24f52" />

из за того что не было подходящего индекса мы перебирали всю таблицу(seq scan), но добавив idx_store_checks_shop_id_sold_at пробегаем ток по индексу(index scan)

2 задание

``` sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

используется HASH JOIN
<img width="867" height="287" alt="Снимок экрана 2026-04-01 в 11 05 08" src="https://github.com/user-attachments/assets/f8f5157a-9b68-4b32-afb3-106fc3fa493d" />

рочему HASH JOIN:
большая таблица
есть фильтр visit_at

индексы:
idx_club_visits_visit_at чуть чутб полезен, потому что фильтр по дате
idx_club_members_full_name для этого запроса не полезен

улучшение, создание своего индекса:
``` sql
CREATE INDEX idx_club_members_member_level
ON club_members (member_level);
```

потом 
``` sql
ANALYZE club_members;
ANALYZE club_visits;
```

и вуаля
``` sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

<img width="859" height="643" alt="Снимок экрана 2026-04-01 в 11 16 16" src="https://github.com/user-attachments/assets/f4606523-a912-45a8-a342-514fb8ce0fe2" />

после добавления индекса можем дешевле отбирать premium пользователей до join

вроде если в BUFFERS преобладает shared hit, значит данные читались в основном из памяти; если shared read, то больше было физического чтения с диска

3 задание

``` sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

<img width="432" height="119" alt="Снимок экрана 2026-04-01 в 11 22 50" src="https://github.com/user-attachments/assets/c13b0b05-70e3-4165-93d6-dd498f327fb0" />

``` sql
UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```
После UPDATE у строки с id = 1 появляется новая версия: у новой версии будет новый xmin, а старая версия получит xmax, указывающий на транзакцию, которая её заменила.
ctid тоже изменится, потому что PostgreSQL(суть MVCC) создаёт новый tuple, а не переписывает старый на месте

<img width="430" height="114" alt="Снимок экрана 2026-04-01 в 11 23 59" src="https://github.com/user-attachments/assets/ad0bca2b-06c7-45d9-ad96-54ef7787b221" />

``` sql
DELETE FROM warehouse_items
WHERE id = 3;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```
После DELETE текущая версия строки помечается как удалённая, поэтому из обычного SELECT строка исчезает, хотя физически она может ещё оставаться в таблице до VACUUM

<img width="434" height="91" alt="Снимок экрана 2026-04-01 в 11 25 03" src="https://github.com/user-attachments/assets/731d6b39-3db2-4788-b379-e2e28b4349ec" />

VACUUM очищает мёртвые строки, autovacuum делает это автоматически, а VACUUM FULL переписывает таблицу целиком и только он может полностью блокировать таблицу.


<img width="338" height="69" alt="Снимок экрана 2026-04-01 в 11 38 19" src="https://github.com/user-attachments/assets/426f81e1-832c-4914-9693-28fd52947539" />
