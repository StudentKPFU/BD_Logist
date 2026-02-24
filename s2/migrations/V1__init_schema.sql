BEGIN;

-- 1) Базовые таблицы без внешних ключей (порядок безопасный)
CREATE TABLE IF NOT EXISTS public.clients
(
    client_id serial PRIMARY KEY,
    name varchar(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS public.client_contacts
(
    client_id integer PRIMARY KEY,
    phone varchar(50),
    email varchar(100),
    address text
);

CREATE TABLE IF NOT EXISTS public.employees
(
    employee_id serial PRIMARY KEY,
    full_name varchar(255) NOT NULL,
    phone varchar(50),
    hire_date date,
    notes text
);

CREATE TABLE IF NOT EXISTS public.vehicles
(
    vehicle_id serial PRIMARY KEY,
    type varchar(50) NOT NULL,
    plate_number varchar(20) NOT NULL UNIQUE,
    capacity numeric(10,2),
    status varchar(20) NOT NULL,
    mileage numeric(10,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.routes
(
    route_id serial PRIMARY KEY,
    departure_city varchar(100) NOT NULL,
    arrival_city varchar(100) NOT NULL,
    distance_km numeric(10,2) NOT NULL,
    estimated_time interval NOT NULL
);

CREATE TABLE IF NOT EXISTS public.tariffs
(
    tariff_id serial PRIMARY KEY,
    type varchar(50) NOT NULL,
    price_per_km numeric(10,2) NOT NULL,
    price_per_kg numeric(10,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.warehouses
(
    warehouse_id serial PRIMARY KEY,
    name varchar(255) NOT NULL,
    address text,
    capacity numeric(10,2),
    type varchar(50) NOT NULL,
    manager_id integer
);

CREATE TABLE IF NOT EXISTS public.drivers
(
    driver_id integer PRIMARY KEY,
    license_number varchar(50) NOT NULL UNIQUE,
    license_category varchar(10),
    vehicle_id integer NOT NULL
);

CREATE TABLE IF NOT EXISTS public.trips
(
    trip_id serial PRIMARY KEY,
    route_id integer NOT NULL,
    vehicle_id integer,
    departure_datetime timestamp,
    arrival_datetime timestamp,
    notes text,
    driver_id integer
);

CREATE TABLE IF NOT EXISTS public.orders
(
    order_id serial PRIMARY KEY,
    tariff_id integer,
    created_at timestamp NOT NULL DEFAULT now(),
    delivery_date date,
    status varchar(20) NOT NULL,
    total_cost numeric(12,2),
    notes text,
    client_id integer NOT NULL,
    trip_id integer
);

CREATE TABLE IF NOT EXISTS public.cargos
(
    cargo_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    description text,
    weight double precision NOT NULL,
    package_type varchar(50) NOT NULL,
    price numeric(12,2)
);

CREATE TABLE IF NOT EXISTS public.documents
(
    document_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    file_link text,
    issued_date date NOT NULL,
    document_type varchar(50)
);

CREATE TABLE IF NOT EXISTS public.invoices
(
    invoice_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    invoice_date date NOT NULL DEFAULT CURRENT_DATE,
    amount numeric(12,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payments
(
    payment_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_date date NOT NULL,
    method varchar(50) NOT NULL,
    status varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.order_logs
(
    log_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    action text NOT NULL,
    user_name text NOT NULL,
    created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.tracking
(
    tracking_id serial PRIMARY KEY,
    order_id integer NOT NULL,
    status varchar(50) NOT NULL,
    updated_at timestamp NOT NULL DEFAULT now(),
    location integer
);

-- 2) Индексы из твоего скрипта
CREATE INDEX IF NOT EXISTS client_contacts_pkey ON public.client_contacts(client_id);
CREATE INDEX IF NOT EXISTS drivers_pkey ON public.drivers(driver_id);

-- 3) Внешние ключи (в конце)
ALTER TABLE IF EXISTS public.client_contacts
    ADD CONSTRAINT client_contacts_client_id_fkey FOREIGN KEY (client_id)
    REFERENCES public.clients (client_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.contracts
    ADD COLUMN IF NOT EXISTS client_id integer; -- если contracts будет создан позже, оставим совместимость
-- contracts отсутствует в твоём порядке выше? создадим ее сейчас:
CREATE TABLE IF NOT EXISTS public.contracts
(
    contract_id serial PRIMARY KEY,
    client_id integer NOT NULL,
    contract_date date NOT NULL,
    valid_until date,
    terms text
);

ALTER TABLE IF EXISTS public.contracts
    ADD CONSTRAINT contracts_client_id_fkey FOREIGN KEY (client_id)
    REFERENCES public.clients (client_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.warehouses
    ADD CONSTRAINT warehouses_manager_id_fkey FOREIGN KEY (manager_id)
    REFERENCES public.employees (employee_id) ON DELETE SET NULL;

ALTER TABLE IF EXISTS public.drivers
    ADD CONSTRAINT drivers_driver_id_fkey FOREIGN KEY (driver_id)
    REFERENCES public.employees (employee_id) ON DELETE NO ACTION;

ALTER TABLE IF EXISTS public.drivers
    ADD CONSTRAINT drivers_vehicle_id_fkey FOREIGN KEY (vehicle_id)
    REFERENCES public.vehicles (vehicle_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.trips
    ADD CONSTRAINT trips_route_id_fkey FOREIGN KEY (route_id)
    REFERENCES public.routes (route_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.trips
    ADD CONSTRAINT trips_vehicle_id_fkey FOREIGN KEY (vehicle_id)
    REFERENCES public.vehicles (vehicle_id) ON DELETE SET NULL;

ALTER TABLE IF EXISTS public.trips
    ADD CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id)
    REFERENCES public.drivers (driver_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id)
    REFERENCES public.clients (client_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_tariff_id_fkey FOREIGN KEY (tariff_id)
    REFERENCES public.tariffs (tariff_id) ON DELETE SET NULL;

ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT orders_trip_id_fkey FOREIGN KEY (trip_id)
    REFERENCES public.trips (trip_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.cargos
    ADD CONSTRAINT cargos_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.documents
    ADD CONSTRAINT documents_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.order_logs
    ADD CONSTRAINT order_logs_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.tracking
    ADD CONSTRAINT tracking_order_id_fkey FOREIGN KEY (order_id)
    REFERENCES public.orders (order_id) ON DELETE CASCADE;

ALTER TABLE IF EXISTS public.tracking
    ADD CONSTRAINT tracking_location_fkey FOREIGN KEY (location)
    REFERENCES public.warehouses (warehouse_id) ON DELETE SET NULL;

COMMIT;