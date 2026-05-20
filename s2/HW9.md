
**1. Выбор 3 аналитических вопросов к проекту:**

- **Вопрос 1:** Какова динамика логистической активности (количество событий с грузами) по дням?
    
- **Вопрос 2:** Какие склады отправления генерируют наибольшую суммарную выручку (price)?
    
- **Вопрос 3:** Какова конверсия доставок (сколько грузов перешло из статуса `Created` в статус `Delivered`)?
    

**2. Определение главного факта:**

- Главной таблицей фактов будет **`fact_shipment_events`** (Факт события с грузом). Эта таблица позволит нам отслеживать движение грузов во времени и считать финансовые метрики на каждом этапе.
    

**3. Определение зерна факта (Grain):**

- **Зерно:** 1 строка = **1 событие изменения статуса** конкретного груза.


Создание измерений (Dimensions) и схемы OLAP
``` sql
CREATE SCHEMA olap;

CREATE TABLE olap.dim_date (
    date_id int PRIMARY KEY, -- Формат YYYYMMDD
    full_date date,
    year int,
    month int,
    day int,
    is_weekend boolean
);

CREATE TABLE olap.dim_user (
    user_sk serial PRIMARY KEY, -- Суррогатный ключ DWH
    user_id int,                -- Бизнес-ключ из OLTP
    name text,
    role text
);

CREATE TABLE olap.dim_warehouse (
    warehouse_sk serial PRIMARY KEY,
    warehouse_id int,
    city text
);

CREATE TABLE olap.fact_shipment_events (
    event_id int PRIMARY KEY, -- Бизнес-ключ события
    date_id int REFERENCES olap.dim_date(date_id),
    user_sk int REFERENCES olap.dim_user(user_sk),
    warehouse_sk int REFERENCES olap.dim_warehouse(warehouse_sk),
    shipment_id int,
    status text,
    weight numeric,
    price numeric
);
```

Заполнение OLAP-таблиц из OLTP (Процесс ETL)
``` sql
-- 1. Заполняем измерение времени с помощью генерации серии дат (за май 2026)
INSERT INTO olap.dim_date (date_id, full_date, year, month, day, is_weekend)
SELECT 
    to_char(d, 'YYYYMMDD')::int,
    d::date,
    EXTRACT(year FROM d),
    EXTRACT(month FROM d),
    EXTRACT(day FROM d),
    EXTRACT(isodow FROM d) IN (6, 7)
FROM generate_series('2026-05-01'::date, '2026-05-31'::date, '1 day'::interval) d;

-- 2. Заполняем измерение пользователей
INSERT INTO olap.dim_user (user_id, name, role)
SELECT id, name, role FROM public.users;

-- 3. Заполняем измерение складов
INSERT INTO olap.dim_warehouse (warehouse_id, city)
SELECT id, city FROM public.warehouses;

-- 4. Заполняем таблицу Фактов (Денормализация)
-- Здесь мы собираем данные из нескольких OLTP-таблиц (события + грузы) и связываем их с суррогатными ключами измерений.
INSERT INTO olap.fact_shipment_events (
    event_id, date_id, user_sk, warehouse_sk, shipment_id, status, weight, price
)
SELECT 
    se.id AS event_id,
    to_char(se.event_time, 'YYYYMMDD')::int AS date_id,
    du.user_sk,
    dw.warehouse_sk,
    s.id AS shipment_id,
    se.status,
    s.weight,
    s.price
FROM public.shipment_events se
JOIN public.shipments s ON se.shipment_id = s.id
JOIN olap.dim_user du ON s.sender_id = du.user_id
JOIN olap.dim_warehouse dw ON s.origin_wh_id = dw.warehouse_id;
```

### Написание аналитических запросов

Динамика логистической активности по дням
``` sql
SELECT 
    d.full_date,
    COUNT(f.event_id) AS total_events
FROM olap.fact_shipment_events f
JOIN olap.dim_date d ON f.date_id = d.date_id
GROUP BY d.full_date
ORDER BY d.full_date;
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 04.06.33.png" />

Самые доходные города отправления
``` sql
SELECT 
    w.city,
    SUM(f.price) AS total_revenue,
    SUM(f.weight) AS total_weight_kg
FROM olap.fact_shipment_events f
JOIN olap.dim_warehouse w ON f.warehouse_sk = w.warehouse_sk
WHERE f.status = 'Created'
GROUP BY w.city
ORDER BY total_revenue DESC;
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 04.07.19.png" />

Базовая конверсия
``` sql
SELECT 
    COUNT(CASE WHEN status = 'Created' THEN 1 END) AS created_shipments,
    COUNT(CASE WHEN status = 'Delivered' THEN 1 END) AS delivered_shipments,
    ROUND(
        COUNT(CASE WHEN status = 'Delivered' THEN 1 END)::numeric / 
        COUNT(CASE WHEN status = 'Created' THEN 1 END) * 100, 
    2) AS delivery_conversion_pct
FROM olap.fact_shipment_events;
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 04.08.09.png" />

