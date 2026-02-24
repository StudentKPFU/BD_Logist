BEGIN;

-- Чтобы генерация была быстрой
SET synchronous_commit = off;

-- 1) Справочники (малые таблицы)
INSERT INTO public.tariffs(type, price_per_km, price_per_kg)
SELECT
  'T' || gs,
  (random()*10 + 1)::numeric(10,2),
  (random()*5 + 0.5)::numeric(10,2)
FROM generate_series(1, 20) gs
ON CONFLICT DO NOTHING;

INSERT INTO public.routes(departure_city, arrival_city, distance_km, estimated_time)
SELECT
  'City_' || (1 + (random()*50)::int),
  'City_' || (1 + (random()*50)::int),
  (50 + random()*2000)::numeric(10,2),
  make_interval(hours => (1 + (random()*40)::int))
FROM generate_series(1, 2000)
ON CONFLICT DO NOTHING;

INSERT INTO public.employees(full_name, phone, hire_date, notes)
SELECT
  'Employee ' || gs,
  '+7' || (9000000000 + (random()*999999999)::bigint)::text,
  (CURRENT_DATE - (random()*3650)::int),
  CASE WHEN random() < 0.1 THEN NULL ELSE 'note ' || gs END
FROM generate_series(1, 5000) gs
ON CONFLICT DO NOTHING;

INSERT INTO public.vehicles(type, plate_number, capacity, status, mileage)
SELECT
  (ARRAY['truck','van','car'])[1 + (random()*2)::int],
  'PLATE-' || gs,                    -- высокая селективность (уникальное)
  (500 + random()*5000)::numeric(10,2),
  (ARRAY['active','repair','retired'])[1 + (random()*2)::int],  -- низкая селективность
  (random()*500000)::numeric(10,2)
FROM generate_series(1, 20000) gs
ON CONFLICT DO NOTHING;

INSERT INTO public.drivers(driver_id, license_number, license_category, vehicle_id)
SELECT
  e.employee_id,
  'LIC-' || e.employee_id,           -- высокая селективность
  (ARRAY['B','C','CE'])[1 + (random()*2)::int],
  1 + (random()*19999)::int
FROM public.employees e
WHERE NOT EXISTS (SELECT 1 FROM public.drivers d WHERE d.driver_id = e.employee_id)
LIMIT 15000;

INSERT INTO public.warehouses(name, address, capacity, type, manager_id)
SELECT
  'WH-' || gs,
  'Address ' || gs,
  (1000 + random()*100000)::numeric(10,2),
  (ARRAY['hub','local','cold'])[1 + (random()*2)::int],
  1 + (random()*4999)::int
FROM generate_series(1, 300) gs
ON CONFLICT DO NOTHING;

-- Клиенты: сделаем много для высокой кардинальности, но с перекосом в заказах позже
INSERT INTO public.clients(name)
SELECT 'Client ' || gs
FROM generate_series(1, 200000) gs
ON CONFLICT DO NOTHING;

INSERT INTO public.client_contacts(client_id, phone, email, address)
SELECT
  c.client_id,
  CASE WHEN random() < 0.15 THEN NULL ELSE '+7' || (9000000000 + (random()*999999999)::bigint)::text END, -- 15% NULL
  'client' || c.client_id || '@mail.test',   -- почти уникально (высокая селективность)
  CASE WHEN random() < 0.10 THEN NULL ELSE 'Street ' || (1 + (random()*9999)::int) END
FROM public.clients c
WHERE NOT EXISTS (SELECT 1 FROM public.client_contacts cc WHERE cc.client_id = c.client_id);

-- Trips (умеренно)
INSERT INTO public.trips(route_id, vehicle_id, departure_datetime, arrival_datetime, notes, driver_id)
SELECT
  1 + (random()*1999)::int,
  1 + (random()*19999)::int,
  now() - (random()*1000000)::int * interval '1 minute',
  now() - (random()*1000000)::int * interval '1 minute' + (1 + (random()*48)::int) * interval '1 hour',
  CASE WHEN random() < 0.2 THEN NULL ELSE 'trip notes ' || gs END,
  (SELECT driver_id FROM public.drivers ORDER BY random() LIMIT 1)
FROM generate_series(1, 100000) gs
ON CONFLICT DO NOTHING;

-- 2) Основные таблицы (3–4 таблицы ~250k+ каждая)
-- Orders: 300k (перекос по client_id + низкая селективность status)
-- client_id сделаем Zipf-like: много заказов у "маленького" набора клиентов.
WITH ord AS (
  INSERT INTO public.orders(tariff_id, created_at, delivery_date, status, total_cost, notes, client_id, trip_id)
  SELECT
    1 + (random()*19)::int, -- uniform по тарифам (почти равномерно)
    now() - (random()*365)::int * interval '1 day',
    CASE WHEN random() < 0.15 THEN NULL ELSE (CURRENT_DATE + (random()*30)::int) END, -- 15% NULL
    (ARRAY['new','in_transit','delivered','cancelled'])[1 + (random()*3)::int], -- 4 значения (низкая селективность)
    (random()*50000)::numeric(12,2),
    CASE WHEN random() < 0.2 THEN NULL ELSE 'order note ' || gs END,
    -- skew: 70% заказов в топ-10% клиентов
    CASE WHEN random() < 0.70
         THEN 1 + (random()*20000)::int      -- топ 20k клиентов
         ELSE 1 + (random()*199999)::int     -- остальные
    END,
    1 + (random()*99999)::int
  FROM generate_series(1, 300000) gs
  RETURNING order_id
)
SELECT count(*) FROM ord;

-- cargos: 300k (по одному на заказ, weight = skewed, package_type low-card)
INSERT INTO public.cargos(order_id, description, weight, package_type, price)
SELECT
  o.order_id,
  'cargo for order ' || o.order_id,
  -- skewed: экспоненциально-образное (много маленьких, мало больших)
  (1 + (-ln(greatest(random(), 1e-9)) * 10))::double precision,
  (ARRAY['box','pallet','envelope','container','other'])[1 + (random()*4)::int], -- 5 значений (низкая селективность)
  (random()*20000)::numeric(12,2)
FROM public.orders o
ORDER BY o.order_id
LIMIT 300000;

-- order_logs: 300k (одна запись на заказ)
INSERT INTO public.order_logs(order_id, action, user_name, created_at)
SELECT
  o.order_id,
  (ARRAY['create','update_status','assign_trip','invoice','close'])[1 + (random()*4)::int],
  'user_' || (1 + (random()*5000)::int),
  o.created_at + (random()*1440)::int * interval '1 minute'
FROM public.orders o
LIMIT 300000;

-- tracking: 300k (одна запись на заказ)
INSERT INTO public.tracking(order_id, status, updated_at, location)
SELECT
  o.order_id,
  (ARRAY['warehouse','loaded','on_route','delivered'])[1 + (random()*3)::int],
  o.created_at + (random()*10080)::int * interval '1 minute',
  CASE WHEN random() < 0.2 THEN NULL ELSE 1 + (random()*299)::int END -- 20% NULL
FROM public.orders o
LIMIT 300000;

-- 3) Payments/Invoices/Documents (дополнительно, но умеренно)
INSERT INTO public.invoices(order_id, invoice_date, amount)
SELECT
  o.order_id,
  (o.created_at::date),
  (random()*50000)::numeric(12,2)
FROM public.orders o
WHERE random() < 0.6;

INSERT INTO public.payments(order_id, amount, payment_date, method, status)
SELECT
  o.order_id,
  (random()*50000)::numeric(12,2),
  (o.created_at::date + (random()*10)::int),
  (ARRAY['card','cash','bank_transfer'])[1 + (random()*2)::int], -- low-card
  (ARRAY['pending','paid','failed'])[1 + (random()*2)::int]      -- low-card
FROM public.orders o
WHERE random() < 0.7;

INSERT INTO public.documents(order_id, file_link, issued_date, document_type)
SELECT
  o.order_id,
  'https://files.local/doc/' || o.order_id,
  (o.created_at::date),
  (ARRAY['invoice','waybill','contract'])[1 + (random()*2)::int]
FROM public.orders o
WHERE random() < 0.4;

-- 4) search_docs (fulltext + jsonb + array + range)
INSERT INTO public.search_docs(order_id, tags, meta, amount_range, content)
SELECT
  o.order_id,
  ARRAY['tag' || (1 + (random()*20)::int), 'tag' || (1 + (random()*20)::int)],
  jsonb_build_object(
    'client_id', o.client_id,
    'status', o.status,
    'tariff_id', o.tariff_id,
    'cost', o.total_cost
  ),
  int4range((random()*1000)::int, (1000 + random()*9000)::int, '[]'),
  'Order ' || o.order_id || ' for client ' || o.client_id || ' status ' || o.status || ' notes ' || coalesce(o.notes,'')
FROM public.orders o
WHERE random() < 0.5;

COMMIT;