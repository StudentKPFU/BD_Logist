--
-- PostgreSQL database cluster dump
--

\restrict W1fPrcjZDbmvxUsNywkfJ1hcCj9Gw8SvRBb3jrieMl8pskt2xFQpnedI9XIzus0

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:fAUhAtHhQlE11u4dDag5HQ==$SCbejo1daIi2OK7ASNf6mJbbEaRZH7PnUFe7CbN241A=:rQUXF03RCBtN64XLUAenbUZDqg+ocr6YSfhewpgA69s=';

--
-- User Configurations
--








\unrestrict W1fPrcjZDbmvxUsNywkfJ1hcCj9Gw8SvRBb3jrieMl8pskt2xFQpnedI9XIzus0

--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

\restrict dBVVHbRbc81tmzluM5a33YnMG9jmQxGlmFcpBsnCULefgVS4Lz52GLqetOcWrrQ

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict dBVVHbRbc81tmzluM5a33YnMG9jmQxGlmFcpBsnCULefgVS4Lz52GLqetOcWrrQ

--
-- Database "LogistDB" dump
--

--
-- PostgreSQL database dump
--

\restrict Pt8zlgaMUGrh02kw4EtEaBAoFu9AzdIP6Xw97IZhTZAIvh26ZyKW7vdcyven3uU

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: LogistDB; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE "LogistDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE "LogistDB" OWNER TO postgres;

\unrestrict Pt8zlgaMUGrh02kw4EtEaBAoFu9AzdIP6Xw97IZhTZAIvh26ZyKW7vdcyven3uU
\encoding SQL_ASCII
\connect -reuse-previous=on "dbname='LogistDB'"
\restrict Pt8zlgaMUGrh02kw4EtEaBAoFu9AzdIP6Xw97IZhTZAIvh26ZyKW7vdcyven3uU

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: calc_avg_payment_for_order(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_avg_payment_for_order(p_order_id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sum   NUMERIC;
    v_cnt   INT;
    v_avg   NUMERIC;
BEGIN
    SELECT COALESCE(SUM(amount), 0), COUNT(*)
    INTO v_sum, v_cnt
    FROM payments
    WHERE order_id = p_order_id;

    BEGIN
        v_avg := v_sum / v_cnt;  
    EXCEPTION
        WHEN division_by_zero THEN
            RAISE NOTICE 'Для заказа % нет платежей', p_order_id;
            v_avg := NULL;
    END;

    RETURN v_avg;
END;
$$;


ALTER FUNCTION public.calc_avg_payment_for_order(p_order_id integer) OWNER TO postgres;

--
-- Name: categorize_client_by_contracts(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.categorize_client_by_contracts(p_client_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_contracts_count INT;
    v_category        VARCHAR(20);
BEGIN
    SELECT COUNT(*)
    INTO v_contracts_count
    FROM contracts
    WHERE client_id = p_client_id;

    IF v_contracts_count = 0 THEN
        v_category := 'Новый';
    ELSIF v_contracts_count BETWEEN 1 AND 3 THEN
        v_category := 'Постоянный';
    ELSE
        v_category := 'Ключевой';
    END IF;

    RETURN v_category;
END;
$$;


ALTER FUNCTION public.categorize_client_by_contracts(p_client_id integer) OWNER TO postgres;

--
-- Name: categorize_vehicle_by_mileage(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.categorize_vehicle_by_mileage(p_vehicle_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_mileage  NUMERIC(10,2);
    v_category VARCHAR(20);
BEGIN
    -- Получаем пробег машины
    SELECT mileage
    INTO v_mileage
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    -- Категоризируем с помощью CASE
    v_category := CASE
        WHEN v_mileage IS NULL THEN 'Неизвестно'
        WHEN v_mileage < 50000 THEN 'Новый'
        WHEN v_mileage BETWEEN 50000 AND 200000 THEN 'В эксплуатации'
        ELSE 'Требует обновления'
    END;

    RETURN v_category;
END;
$$;


ALTER FUNCTION public.categorize_vehicle_by_mileage(p_vehicle_id integer) OWNER TO postgres;

--
-- Name: check_order_exists(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_order_exists(p_order_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM orders WHERE order_id = p_order_id) THEN
        RAISE EXCEPTION 'Заказ % не найден', p_order_id;
    ELSE
        RAISE NOTICE 'Заказ % существует', p_order_id;
    END IF;
END;
$$;


ALTER FUNCTION public.check_order_exists(p_order_id integer) OWNER TO postgres;

--
-- Name: create_test_routes(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_test_routes(IN p_count integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= p_count LOOP
        INSERT INTO routes (departure_city, arrival_city, distance_km, estimated_time)
        VALUES (
            'Test City ' || i,
            'Test Dest ' || i,
            100 * i,
            make_interval(hours => i)
        );

        i := i + 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.create_test_routes(IN p_count integer) OWNER TO postgres;

--
-- Name: increment_vehicle_mileage(integer, integer, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.increment_vehicle_mileage(IN p_vehicle_id integer, IN p_steps integer, IN p_increment numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    i INT := 0;
BEGIN
    WHILE i < p_steps LOOP
        UPDATE vehicles
        SET mileage = COALESCE(mileage, 0) + p_increment
        WHERE vehicle_id = p_vehicle_id;

        i := i + 1;
    END LOOP;
END;
$$;


ALTER PROCEDURE public.increment_vehicle_mileage(IN p_vehicle_id integer, IN p_steps integer, IN p_increment numeric) OWNER TO postgres;

--
-- Name: report_orders_stats(); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.report_orders_stats()
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cnt_orders  INT;
    v_sum_total   NUMERIC;
BEGIN
    SELECT COUNT(*), COALESCE(SUM(total_cost), 0)
    INTO v_cnt_orders, v_sum_total
    FROM orders;

    RAISE NOTICE 'Всего заказов: %, суммарная стоимость: %', v_cnt_orders, v_sum_total;
END;
$$;


ALTER PROCEDURE public.report_orders_stats() OWNER TO postgres;

--
-- Name: safe_insert_client(character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.safe_insert_client(IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    BEGIN
        INSERT INTO clients (name)
        VALUES (p_name);

        RAISE NOTICE 'Клиент "%" успешно создан', p_name;
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'Клиент "%" уже существует, пропускаем вставку', p_name;
    END;
END;
$$;


ALTER PROCEDURE public.safe_insert_client(IN p_name character varying) OWNER TO postgres;

--
-- Name: trg_block_update_delivered(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_block_update_delivered() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF OLD.status = 'Доставлен' THEN
        RAISE EXCEPTION 'Нельзя менять доставленный заказ';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_block_update_delivered() OWNER TO postgres;

--
-- Name: trg_cargo_mass_delete(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_cargo_mass_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO cargo_delete_batch_log(info)
    VALUES ('Mass delete on cargos table');
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.trg_cargo_mass_delete() OWNER TO postgres;

--
-- Name: trg_check_cargo_weight(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_check_cargo_weight() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Weight must be positive';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_check_cargo_weight() OWNER TO postgres;

--
-- Name: trg_check_weight(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_check_weight() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Вес груза должен быть положительным';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_check_weight() OWNER TO postgres;

--
-- Name: trg_create_invoice_document(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_create_invoice_document() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO documents(order_id, issued_date, document_type)
    VALUES (NEW.order_id, CURRENT_DATE, 'invoice');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_create_invoice_document() OWNER TO postgres;

--
-- Name: trg_log_mass_update_orders(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_mass_update_orders() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO order_mass_update_log(user_name)
    VALUES (current_user);
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.trg_log_mass_update_orders() OWNER TO postgres;

--
-- Name: trg_log_status_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_log_status_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (NEW.order_id, 'Изменён статус: ' || NEW.status, CURRENT_USER);
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_log_status_change() OWNER TO postgres;

--
-- Name: trg_orders_default_cost(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_orders_default_cost() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.total_cost IS NULL THEN
        NEW.total_cost := 0;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_orders_default_cost() OWNER TO postgres;

--
-- Name: trg_tracking_set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_tracking_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_tracking_set_updated_at() OWNER TO postgres;

--
-- Name: trg_update_vehicle_mileage(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_vehicle_mileage() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE dist NUMERIC;
BEGIN
    SELECT distance_km INTO dist FROM routes WHERE route_id = NEW.route_id;

    UPDATE vehicles SET mileage = mileage + dist
    WHERE vehicle_id = NEW.vehicle_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_vehicle_mileage() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cargo_delete_batch_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cargo_delete_batch_log (
    deleted_at timestamp without time zone DEFAULT now(),
    info text
);


ALTER TABLE public.cargo_delete_batch_log OWNER TO postgres;

--
-- Name: cargos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cargos (
    cargo_id integer NOT NULL,
    order_id integer NOT NULL,
    description text,
    weight double precision NOT NULL,
    package_type character varying(50) NOT NULL,
    price numeric(12,2)
);


ALTER TABLE public.cargos OWNER TO postgres;

--
-- Name: cargos_cargo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cargos_cargo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cargos_cargo_id_seq OWNER TO postgres;

--
-- Name: cargos_cargo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cargos_cargo_id_seq OWNED BY public.cargos.cargo_id;


--
-- Name: client_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client_contacts (
    client_id integer NOT NULL,
    phone character varying(50),
    email character varying(100),
    address text
);


ALTER TABLE public.client_contacts OWNER TO postgres;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    client_id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clients_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clients_client_id_seq OWNER TO postgres;

--
-- Name: clients_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clients_client_id_seq OWNED BY public.clients.client_id;


--
-- Name: contracts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contracts (
    contract_id integer NOT NULL,
    client_id integer NOT NULL,
    contract_date date NOT NULL,
    valid_until date,
    terms text
);


ALTER TABLE public.contracts OWNER TO postgres;

--
-- Name: contracts_contract_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.contracts_contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.contracts_contract_id_seq OWNER TO postgres;

--
-- Name: contracts_contract_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.contracts_contract_id_seq OWNED BY public.contracts.contract_id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    document_id integer NOT NULL,
    order_id integer NOT NULL,
    file_link text,
    issued_date date NOT NULL,
    document_type character varying(50)
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: documents_document_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.documents_document_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.documents_document_id_seq OWNER TO postgres;

--
-- Name: documents_document_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.documents_document_id_seq OWNED BY public.documents.document_id;


--
-- Name: drivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drivers (
    driver_id integer NOT NULL,
    license_number character varying(50) NOT NULL,
    license_category character varying(10),
    vehicle_id integer NOT NULL
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    employee_id integer NOT NULL,
    full_name character varying(255) NOT NULL,
    phone character varying(50),
    hire_date date,
    notes text
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employees_employee_id_seq OWNED BY public.employees.employee_id;


--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    invoice_id integer NOT NULL,
    order_id integer NOT NULL,
    invoice_date date DEFAULT CURRENT_DATE NOT NULL,
    amount numeric(12,2) NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_invoice_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.invoices_invoice_id_seq OWNER TO postgres;

--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.invoices_invoice_id_seq OWNED BY public.invoices.invoice_id;


--
-- Name: order_mass_update_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_mass_update_log (
    updated_at timestamp without time zone DEFAULT now(),
    user_name text
);


ALTER TABLE public.order_mass_update_log OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id integer NOT NULL,
    tariff_id integer,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    delivery_date date,
    status character varying(20) NOT NULL,
    total_cost numeric(12,2),
    notes text,
    client_id integer NOT NULL,
    trip_id integer
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    payment_id integer NOT NULL,
    order_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_date date NOT NULL,
    method character varying(50) NOT NULL,
    status character varying(20) NOT NULL
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_payment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_payment_id_seq OWNER TO postgres;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    route_id integer NOT NULL,
    departure_city character varying(100) NOT NULL,
    arrival_city character varying(100) NOT NULL,
    distance_km numeric(10,2) NOT NULL,
    estimated_time interval NOT NULL
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: routes_route_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.routes_route_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.routes_route_id_seq OWNER TO postgres;

--
-- Name: routes_route_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.routes_route_id_seq OWNED BY public.routes.route_id;


--
-- Name: tariffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tariffs (
    tariff_id integer NOT NULL,
    type character varying(50) NOT NULL,
    price_per_km numeric(10,2) NOT NULL,
    price_per_kg numeric(10,2) NOT NULL
);


ALTER TABLE public.tariffs OWNER TO postgres;

--
-- Name: tariffs_tariff_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tariffs_tariff_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tariffs_tariff_id_seq OWNER TO postgres;

--
-- Name: tariffs_tariff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tariffs_tariff_id_seq OWNED BY public.tariffs.tariff_id;


--
-- Name: tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tracking (
    tracking_id integer NOT NULL,
    order_id integer NOT NULL,
    status character varying(50) NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    location integer
);


ALTER TABLE public.tracking OWNER TO postgres;

--
-- Name: tracking_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tracking_tracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tracking_tracking_id_seq OWNER TO postgres;

--
-- Name: tracking_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tracking_tracking_id_seq OWNED BY public.tracking.tracking_id;


--
-- Name: trips; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trips (
    trip_id integer NOT NULL,
    route_id integer NOT NULL,
    vehicle_id integer,
    departure_datetime timestamp without time zone,
    arrival_datetime timestamp without time zone,
    notes text,
    driver_id integer
);


ALTER TABLE public.trips OWNER TO postgres;

--
-- Name: trips_trip_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.trips_trip_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trips_trip_id_seq OWNER TO postgres;

--
-- Name: trips_trip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.trips_trip_id_seq OWNED BY public.trips.trip_id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    vehicle_id integer NOT NULL,
    type character varying(50) NOT NULL,
    plate_number character varying(20) NOT NULL,
    capacity numeric(10,2),
    status character varying(20) NOT NULL,
    mileage numeric(10,2) DEFAULT 0
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNER TO postgres;

--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vehicles_vehicle_id_seq OWNED BY public.vehicles.vehicle_id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    warehouse_id integer NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    capacity numeric(10,2),
    type character varying(50) NOT NULL,
    manager_id integer
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_warehouse_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_warehouse_id_seq OWNER TO postgres;

--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_warehouse_id_seq OWNED BY public.warehouses.warehouse_id;


--
-- Name: cargos cargo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargos ALTER COLUMN cargo_id SET DEFAULT nextval('public.cargos_cargo_id_seq'::regclass);


--
-- Name: clients client_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients ALTER COLUMN client_id SET DEFAULT nextval('public.clients_client_id_seq'::regclass);


--
-- Name: contracts contract_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts ALTER COLUMN contract_id SET DEFAULT nextval('public.contracts_contract_id_seq'::regclass);


--
-- Name: documents document_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents ALTER COLUMN document_id SET DEFAULT nextval('public.documents_document_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees ALTER COLUMN employee_id SET DEFAULT nextval('public.employees_employee_id_seq'::regclass);


--
-- Name: invoices invoice_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices ALTER COLUMN invoice_id SET DEFAULT nextval('public.invoices_invoice_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: routes route_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes ALTER COLUMN route_id SET DEFAULT nextval('public.routes_route_id_seq'::regclass);


--
-- Name: tariffs tariff_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariffs ALTER COLUMN tariff_id SET DEFAULT nextval('public.tariffs_tariff_id_seq'::regclass);


--
-- Name: tracking tracking_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracking ALTER COLUMN tracking_id SET DEFAULT nextval('public.tracking_tracking_id_seq'::regclass);


--
-- Name: trips trip_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips ALTER COLUMN trip_id SET DEFAULT nextval('public.trips_trip_id_seq'::regclass);


--
-- Name: vehicles vehicle_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('public.vehicles_vehicle_id_seq'::regclass);


--
-- Name: warehouses warehouse_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN warehouse_id SET DEFAULT nextval('public.warehouses_warehouse_id_seq'::regclass);


--
-- Data for Name: cargo_delete_batch_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cargo_delete_batch_log (deleted_at, info) FROM stdin;
\.


--
-- Data for Name: cargos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cargos (cargo_id, order_id, description, weight, package_type, price) FROM stdin;
6	5	Подарок	2	Box	0.50
\.


--
-- Data for Name: client_contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.client_contacts (client_id, phone, email, address) FROM stdin;
1	+7-495-111-22-33	info@romashka.ru	г. Москва, ул. Цветочная, д.1
2	+7-812-222-33-44	sales@vector.ru	г. Санкт-Петербург, Невский пр., 10
3	+7-900-333-44-55	petrov@example.com	г. Казань, ул. Победы, 5
4	+7-495-444-55-66	\N	г. Москва, ул. Прямая, 12
5	+7-910-555-66-77	ivanov@mail.ru	г. Подольск, ул. Садовая, 3
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (client_id, name) FROM stdin;
1	ООО Ромашка
2	ЗАО Вектор
3	ИП Петров
4	ООО Экспресс
5	Частное лицо Иванов
6	ConflictClient
\.


--
-- Data for Name: contracts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contracts (contract_id, client_id, contract_date, valid_until, terms) FROM stdin;
1	1	2024-01-01	2025-12-31	Годовой договор с фиксированными тарифами
2	2	2023-06-15	2024-06-14	Постоянное обслуживание (год)
3	4	2025-02-01	2026-01-31	Договор на складское хранение
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (document_id, order_id, file_link, issued_date, document_type) FROM stdin;
1	1	\N	2025-12-02	invoice
\.


--
-- Data for Name: drivers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drivers (driver_id, license_number, license_category, vehicle_id) FROM stdin;
1	D-12345	C	1
2	D-23456	B	2
3	D-34567	CE	3
\.


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employees (employee_id, full_name, phone, hire_date, notes) FROM stdin;
1	Алексей Смирнов	+7-900-111-22-33	2019-03-10	Стаж 6 лет
2	Мария Иванова	+7-900-222-33-44	2020-06-01	\N
3	Дмитрий Кузнецов	+7-900-333-44-55	2018-11-20	Водитель-экспедитор
4	Ольга Петрова	\N	2021-01-15	Менеджер склада
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (invoice_id, order_id, invoice_date, amount) FROM stdin;
2	1	2025-12-02	1500.00
\.


--
-- Data for Name: order_mass_update_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_mass_update_log (updated_at, user_name) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, tariff_id, created_at, delivery_date, status, total_cost, notes, client_id, trip_id) FROM stdin;
5	1	2025-10-07 16:45:00	\N	new	50.00	Мелкий отправитель	5	\N
6	2	2025-10-10 11:00:00	2025-10-12	cancelled	0.00	Отменён клиентом	1	\N
1	1	2025-12-02 23:30:17.284661	\N	Pending	0.00	\N	2	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (payment_id, order_id, amount, payment_date, method, status) FROM stdin;
6	5	100.00	2025-11-23	card	completed
7	5	200.00	2025-11-24	cash	completed
8	5	300.00	2025-11-25	transfer	completed
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (route_id, departure_city, arrival_city, distance_km, estimated_time) FROM stdin;
3	Test City 1	Test Dest 1	100.00	01:00:00
4	Test City 2	Test Dest 2	200.00	02:00:00
5	Test City 3	Test Dest 3	300.00	03:00:00
\.


--
-- Data for Name: tariffs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tariffs (tariff_id, type, price_per_km, price_per_kg) FROM stdin;
1	Эконом	0.50	0.20
2	Стандарт	1.00	0.50
3	Экспресс	2.00	1.00
\.


--
-- Data for Name: tracking; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tracking (tracking_id, order_id, status, updated_at, location) FROM stdin;
\.


--
-- Data for Name: trips; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.trips (trip_id, route_id, vehicle_id, departure_datetime, arrival_datetime, notes, driver_id) FROM stdin;
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (vehicle_id, type, plate_number, capacity, status, mileage) FROM stdin;
2	Van	B456CD77	3000.00	in_service	0.00
3	Trailer	C789EF77	25000.00	available	0.00
102	passenger_van	B456CD99	8.00	in_service	85000.00
103	refrigerated_truck	C789EF78	18.00	maintenance	230000.00
104	sedan	D321GH50	4.50	assigned	47000.00
105	box_truck	E654IJ01	15.00	available	96000.00
110	cargo_truck	A123BC28	12.50	available	10000.00
101	cargo_truck	A123BC78	12.50	assigned	120000.00
1	Truck	A123BC77	20000.00	available	150.00
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (warehouse_id, name, address, capacity, type, manager_id) FROM stdin;
1	Склад Москва	г. Москва, ул. Ленина, 10	50000.00	городской	4
2	Склад СПб	г. Санкт-Петербург, Невский пр., 20	30000.00	трансфер	2
\.


--
-- Name: cargos_cargo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cargos_cargo_id_seq', 1, false);


--
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clients_client_id_seq', 3, true);


--
-- Name: contracts_contract_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contracts_contract_id_seq', 1, false);


--
-- Name: documents_document_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.documents_document_id_seq', 1, true);


--
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employees_employee_id_seq', 1, true);


--
-- Name: invoices_invoice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.invoices_invoice_id_seq', 2, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 1, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 8, true);


--
-- Name: routes_route_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.routes_route_id_seq', 5, true);


--
-- Name: tariffs_tariff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tariffs_tariff_id_seq', 1, false);


--
-- Name: tracking_tracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tracking_tracking_id_seq', 1, false);


--
-- Name: trips_trip_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.trips_trip_id_seq', 1, false);


--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vehicles_vehicle_id_seq', 1, false);


--
-- Name: warehouses_warehouse_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_warehouse_id_seq', 1, false);


--
-- Name: cargos cargos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargos
    ADD CONSTRAINT cargos_pkey PRIMARY KEY (cargo_id);


--
-- Name: client_contacts client_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT client_contacts_pkey PRIMARY KEY (client_id);


--
-- Name: clients clients_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_name_key UNIQUE (name);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (contract_id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (document_id);


--
-- Name: drivers drivers_license_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_license_number_key UNIQUE (license_number);


--
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (driver_id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (invoice_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: routes routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (route_id);


--
-- Name: tariffs tariffs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tariffs
    ADD CONSTRAINT tariffs_pkey PRIMARY KEY (tariff_id);


--
-- Name: tracking tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracking
    ADD CONSTRAINT tracking_pkey PRIMARY KEY (tracking_id);


--
-- Name: trips trips_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_pkey PRIMARY KEY (trip_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_plate_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_plate_number_key UNIQUE (plate_number);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (warehouse_id);


--
-- Name: orders after_update_log_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_update_log_status AFTER UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_log_status_change();


--
-- Name: cargos before_insert_check_weight; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_insert_check_weight BEFORE INSERT ON public.cargos FOR EACH ROW EXECUTE FUNCTION public.trg_check_weight();


--
-- Name: orders before_update_block_delivered; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER before_update_block_delivered BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_block_update_delivered();


--
-- Name: cargos trg_cargo_mass_delete_log; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cargo_mass_delete_log AFTER DELETE ON public.cargos FOR EACH STATEMENT EXECUTE FUNCTION public.trg_cargo_mass_delete();


--
-- Name: cargos trg_cargo_weight; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_cargo_weight BEFORE INSERT OR UPDATE ON public.cargos FOR EACH ROW EXECUTE FUNCTION public.trg_check_cargo_weight();


--
-- Name: orders trg_default_order_cost; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_default_order_cost BEFORE INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.trg_orders_default_cost();


--
-- Name: invoices trg_invoice_doc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_invoice_doc AFTER INSERT ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.trg_create_invoice_document();


--
-- Name: orders trg_orders_mass_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_orders_mass_update AFTER UPDATE ON public.orders FOR EACH STATEMENT EXECUTE FUNCTION public.trg_log_mass_update_orders();


--
-- Name: tracking trg_tracking_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_tracking_updated_at BEFORE UPDATE ON public.tracking FOR EACH ROW EXECUTE FUNCTION public.trg_tracking_set_updated_at();


--
-- Name: trips trg_trip_update_vehicle; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_trip_update_vehicle AFTER INSERT ON public.trips FOR EACH ROW EXECUTE FUNCTION public.trg_update_vehicle_mileage();


--
-- Name: cargos cargos_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cargos
    ADD CONSTRAINT cargos_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: client_contacts client_contacts_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client_contacts
    ADD CONSTRAINT client_contacts_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- Name: contracts contracts_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- Name: documents documents_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: drivers drivers_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.employees(employee_id);


--
-- Name: drivers drivers_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: orders orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON DELETE CASCADE;


--
-- Name: orders orders_tariff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_tariff_id_fkey FOREIGN KEY (tariff_id) REFERENCES public.tariffs(tariff_id) ON DELETE SET NULL;


--
-- Name: orders orders_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(trip_id) ON DELETE CASCADE;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: tracking tracking_location_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracking
    ADD CONSTRAINT tracking_location_fkey FOREIGN KEY (location) REFERENCES public.warehouses(warehouse_id) ON DELETE SET NULL;


--
-- Name: tracking tracking_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tracking
    ADD CONSTRAINT tracking_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: trips trips_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(driver_id) ON DELETE CASCADE;


--
-- Name: trips trips_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.routes(route_id) ON DELETE CASCADE;


--
-- Name: trips trips_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trips
    ADD CONSTRAINT trips_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(vehicle_id) ON DELETE SET NULL;


--
-- Name: warehouses warehouses_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES public.employees(employee_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict Pt8zlgaMUGrh02kw4EtEaBAoFu9AzdIP6Xw97IZhTZAIvh26ZyKW7vdcyven3uU

--
-- Database "auc" dump
--

--
-- PostgreSQL database dump
--

\restrict 8SHZ5wzI4VaxQ459CdzpDL7ClYvINoU5yuExXsYsgHHmzov0Vnl9no1DboetfRr

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auc; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE auc WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE auc OWNER TO postgres;

\unrestrict 8SHZ5wzI4VaxQ459CdzpDL7ClYvINoU5yuExXsYsgHHmzov0Vnl9no1DboetfRr
\connect auc
\restrict 8SHZ5wzI4VaxQ459CdzpDL7ClYvINoU5yuExXsYsgHHmzov0Vnl9no1DboetfRr

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: get_current_price(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_current_price(listing_id integer) RETURNS numeric
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    current_price numeric;
BEGIN
    SELECT COALESCE((SELECT MAX(amount) FROM bids WHERE bids.listing_id = get_current_price.listing_id),
                    (SELECT starting_price FROM listings WHERE id = get_current_price.listing_id))
    INTO current_price;
    RETURN current_price;
END;
$$;


ALTER FUNCTION public.get_current_price(listing_id integer) OWNER TO postgres;

--
-- Name: get_highest_bid(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_highest_bid(p_listing_id integer) RETURNS TABLE(bid_id integer, bidder_id integer, amount numeric, bid_time timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    -- Return the highest bid for the listing
    RETURN QUERY
        SELECT b.id, b.bidder_id, b.amount, b.bid_time
        FROM bids b
        WHERE b.listing_id = p_listing_id
        ORDER BY b.amount DESC, b.id DESC
        LIMIT 1;

    -- If no rows returned by the above SELECT, the function returns NULL record.
END;
$$;


ALTER FUNCTION public.get_highest_bid(p_listing_id integer) OWNER TO postgres;

--
-- Name: revoke_token_chain(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.revoke_token_chain(IN start_token_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    WITH RECURSIVE token_chain AS (SELECT id
                                   FROM refresh_tokens
                                   WHERE id = start_token_id
                                   UNION ALL
                                   SELECT rt.id
                                   FROM refresh_tokens rt
                                            INNER JOIN token_chain tc ON rt.replaced_by_token_id = tc.id)
    UPDATE refresh_tokens
    SET revoked_at = NOW()
    WHERE id IN (SELECT id FROM token_chain);
END;
$$;


ALTER PROCEDURE public.revoke_token_chain(IN start_token_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: balance_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.balance_transactions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    amount numeric(15,2) NOT NULL,
    running_balance numeric(15,2) NOT NULL,
    type character varying(30) NOT NULL,
    related_bid integer,
    status character varying(20) DEFAULT 'completed'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    note text,
    CONSTRAINT balance_transactions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[]))),
    CONSTRAINT balance_transactions_type_check CHECK (((type)::text = ANY ((ARRAY['deposit'::character varying, 'withdrawal'::character varying, 'bid_place'::character varying, 'bid_refund'::character varying, 'auction_win'::character varying, 'auction_fee'::character varying, 'admin_adjustment'::character varying, 'auction_sale'::character varying])::text[])))
);


ALTER TABLE public.balance_transactions OWNER TO postgres;

--
-- Name: balance_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.balance_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.balance_transactions_id_seq OWNER TO postgres;

--
-- Name: balance_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.balance_transactions_id_seq OWNED BY public.balance_transactions.id;


--
-- Name: bids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bids (
    id integer NOT NULL,
    listing_id integer NOT NULL,
    bidder_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    bid_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT bids_amount_check CHECK ((amount > (0)::numeric))
);


ALTER TABLE public.bids OWNER TO postgres;

--
-- Name: bids_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bids_id_seq OWNER TO postgres;

--
-- Name: bids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bids_id_seq OWNED BY public.bids.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    parent_id integer
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.images (
    id integer NOT NULL,
    listing_id integer NOT NULL,
    url text NOT NULL,
    is_primary boolean DEFAULT false,
    upload_order integer DEFAULT 0
);


ALTER TABLE public.images OWNER TO postgres;

--
-- Name: images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.images_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.images_id_seq OWNER TO postgres;

--
-- Name: images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.images_id_seq OWNED BY public.images.id;


--
-- Name: listing_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.listing_categories (
    listing_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE public.listing_categories OWNER TO postgres;

--
-- Name: listings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.listings (
    id integer NOT NULL,
    seller_id integer NOT NULL,
    title character varying(100) NOT NULL,
    description text NOT NULL,
    starting_price numeric(12,2) NOT NULL,
    end_time timestamp with time zone NOT NULL,
    status character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    views_count integer DEFAULT 0,
    winner_id integer,
    CONSTRAINT listings_starting_price_check CHECK ((starting_price > (0)::numeric)),
    CONSTRAINT listings_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'closed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.listings OWNER TO postgres;

--
-- Name: listings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.listings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.listings_id_seq OWNER TO postgres;

--
-- Name: listings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.listings_id_seq OWNED BY public.listings.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    type character varying(20) NOT NULL,
    content text NOT NULL,
    related_listing integer,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['bid'::character varying, 'outbid'::character varying, 'win'::character varying, 'end_soon'::character varying, 'message'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: refresh_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    hash text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    replaced_by_token_id integer NOT NULL
);


ALTER TABLE public.refresh_tokens OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_id_seq OWNED BY public.refresh_tokens.id;


--
-- Name: refresh_tokens_replaced_by_token_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.refresh_tokens_replaced_by_token_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.refresh_tokens_replaced_by_token_id_seq OWNER TO postgres;

--
-- Name: refresh_tokens_replaced_by_token_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.refresh_tokens_replaced_by_token_id_seq OWNED BY public.refresh_tokens.replaced_by_token_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    salt character varying(127) NOT NULL,
    role character varying(20) DEFAULT 'user'::character varying NOT NULL,
    balance numeric(15,2) DEFAULT 0.00 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_balance_check CHECK ((balance >= (0)::numeric))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: watchlist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.watchlist (
    user_id integer NOT NULL,
    listing_id integer NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.watchlist OWNER TO postgres;

--
-- Name: balance_transactions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_transactions ALTER COLUMN id SET DEFAULT nextval('public.balance_transactions_id_seq'::regclass);


--
-- Name: bids id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bids ALTER COLUMN id SET DEFAULT nextval('public.bids_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Name: images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images ALTER COLUMN id SET DEFAULT nextval('public.images_id_seq'::regclass);


--
-- Name: listings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listings ALTER COLUMN id SET DEFAULT nextval('public.listings_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('public.refresh_tokens_id_seq'::regclass);


--
-- Name: refresh_tokens replaced_by_token_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens ALTER COLUMN replaced_by_token_id SET DEFAULT nextval('public.refresh_tokens_replaced_by_token_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: balance_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.balance_transactions (id, user_id, amount, running_balance, type, related_bid, status, created_at, note) FROM stdin;
\.


--
-- Data for Name: bids; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bids (id, listing_id, bidder_id, amount, bid_time) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, parent_id) FROM stdin;
1	Электроника	\N
2	Транспорт	\N
3	Мода и стиль	\N
4	Дом и сад	\N
5	Коллекционирование	\N
6	Спорт и отдых	\N
7	Искусство и антиквариат	\N
8	Игры и хобби	\N
9	Другое	\N
10	Смартфоны	1
11	Ноутбуки и ПК	1
12	Телевизоры и видео	1
13	Аудиотехника	1
14	Фото и видеокамеры	1
15	Игровые консоли	1
16	Аксессуары	1
17	Автомобили	2
18	Мотоциклы	2
19	Велосипеды	2
20	Запчасти и аксессуары	2
21	Водный транспорт	2
22	Одежда	3
23	Обувь	3
24	Сумки и аксессуары	3
25	Часы	3
26	Украшения	3
27	Мебель	4
28	Бытовая техника	4
29	Посуда и кухонные принадлежности	4
30	Инструменты и ремонт	4
31	Декор и интерьер	4
32	Сад и огород	4
33	Монеты	5
34	Марки	5
35	Банкноты	5
36	Открытки	5
37	Фигурки и миниатюры	5
38	Редкие книги	5
39	Спортивная одежда	6
40	Туризм и кемпинг	6
41	Фитнес и тренировки	6
42	Велоспорт	6
43	Зимние виды спорта	6
44	Рыбалка и охота	6
45	Живопись	7
46	Скульптуры	7
47	Антиквариат	7
48	Фотографии	7
49	Декоративное искусство	7
50	Настольные игры	8
51	Конструкторы и модели	8
52	Игрушки	8
53	Музыкальные инструменты	8
54	Коллекционные карточки	8
\.


--
-- Data for Name: images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.images (id, listing_id, url, is_primary, upload_order) FROM stdin;
\.


--
-- Data for Name: listing_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.listing_categories (listing_id, category_id) FROM stdin;
\.


--
-- Data for Name: listings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.listings (id, seller_id, title, description, starting_price, end_time, status, created_at, views_count, winner_id) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, content, related_listing, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_tokens (id, user_id, hash, created_at, expires_at, revoked_at, replaced_by_token_id) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, password_hash, salt, role, balance, created_at) FROM stdin;
\.


--
-- Data for Name: watchlist; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.watchlist (user_id, listing_id, added_at) FROM stdin;
\.


--
-- Name: balance_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.balance_transactions_id_seq', 1, false);


--
-- Name: bids_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bids_id_seq', 1, false);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 54, true);


--
-- Name: images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.images_id_seq', 1, false);


--
-- Name: listings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.listings_id_seq', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 1, false);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_id_seq', 1, false);


--
-- Name: refresh_tokens_replaced_by_token_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.refresh_tokens_replaced_by_token_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: balance_transactions balance_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_transactions
    ADD CONSTRAINT balance_transactions_pkey PRIMARY KEY (id);


--
-- Name: bids bids_listing_id_amount_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_listing_id_amount_key UNIQUE (listing_id, amount);


--
-- Name: bids bids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_pkey PRIMARY KEY (id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: images images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);


--
-- Name: listing_categories listing_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listing_categories
    ADD CONSTRAINT listing_categories_pkey PRIMARY KEY (listing_id, category_id);


--
-- Name: listings listings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: watchlist watchlist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchlist
    ADD CONSTRAINT watchlist_pkey PRIMARY KEY (user_id, listing_id);


--
-- Name: balance_transactions balance_transactions_related_bid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_transactions
    ADD CONSTRAINT balance_transactions_related_bid_fkey FOREIGN KEY (related_bid) REFERENCES public.bids(id) ON DELETE SET NULL;


--
-- Name: balance_transactions balance_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.balance_transactions
    ADD CONSTRAINT balance_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bids bids_bidder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_bidder_id_fkey FOREIGN KEY (bidder_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: bids bids_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: categories categories_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id);


--
-- Name: images images_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: listing_categories listing_categories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listing_categories
    ADD CONSTRAINT listing_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE;


--
-- Name: listing_categories listing_categories_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listing_categories
    ADD CONSTRAINT listing_categories_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: listings listings_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: listings listings_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_winner_id_fkey FOREIGN KEY (winner_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_related_listing_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_related_listing_fkey FOREIGN KEY (related_listing) REFERENCES public.listings(id);


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_replaced_by_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_replaced_by_token_id_fkey FOREIGN KEY (replaced_by_token_id) REFERENCES public.refresh_tokens(id);


--
-- Name: refresh_tokens refresh_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_tokens
    ADD CONSTRAINT refresh_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: watchlist watchlist_listing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchlist
    ADD CONSTRAINT watchlist_listing_id_fkey FOREIGN KEY (listing_id) REFERENCES public.listings(id) ON DELETE CASCADE;


--
-- Name: watchlist watchlist_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.watchlist
    ADD CONSTRAINT watchlist_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 8SHZ5wzI4VaxQ459CdzpDL7ClYvINoU5yuExXsYsgHHmzov0Vnl9no1DboetfRr

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

\restrict c20FgnNsT9OHimdU1dgaSVkuwqqAJoeAkPWfrkd1iRxOaxhgTqHUGqgHZEDSdsM

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

\unrestrict c20FgnNsT9OHimdU1dgaSVkuwqqAJoeAkPWfrkd1iRxOaxhgTqHUGqgHZEDSdsM

--
-- Database "rental" dump
--

--
-- PostgreSQL database dump
--

\restrict g55Y72CgjZ4Dh5meFIGKDxdQzEBNHsQGC3zGu7MUbad8gGwFIyqkXh1MPS9LaM2

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: rental; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE rental WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE rental OWNER TO postgres;

\unrestrict g55Y72CgjZ4Dh5meFIGKDxdQzEBNHsQGC3zGu7MUbad8gGwFIyqkXh1MPS9LaM2
\connect rental
\restrict g55Y72CgjZ4Dh5meFIGKDxdQzEBNHsQGC3zGu7MUbad8gGwFIyqkXh1MPS9LaM2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bookings" (
    "Id" uuid NOT NULL,
    "CarId" uuid NOT NULL,
    "ClientId" uuid NOT NULL,
    "StartDate" timestamp with time zone NOT NULL,
    "Duration" interval NOT NULL
);


ALTER TABLE public."Bookings" OWNER TO postgres;

--
-- Name: Cars; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Cars" (
    "Id" uuid NOT NULL,
    "Model" character varying(50) NOT NULL
);


ALTER TABLE public."Cars" OWNER TO postgres;

--
-- Name: Clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Clients" (
    "Id" uuid NOT NULL,
    "FullName" character varying(100) NOT NULL,
    "Email" character varying(256) NOT NULL,
    "PhoneNumber" character varying(32) NOT NULL
);


ALTER TABLE public."Clients" OWNER TO postgres;

--
-- Name: LogEntries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."LogEntries" (
    "Id" uuid NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    "Level" character varying(20) NOT NULL,
    "Category" character varying(256) NOT NULL,
    "Message" text NOT NULL,
    "Exception" text,
    "EventId" character varying(64)
);


ALTER TABLE public."LogEntries" OWNER TO postgres;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO postgres;

--
-- Data for Name: Bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Bookings" ("Id", "CarId", "ClientId", "StartDate", "Duration") FROM stdin;
\.


--
-- Data for Name: Cars; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Cars" ("Id", "Model") FROM stdin;
\.


--
-- Data for Name: Clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Clients" ("Id", "FullName", "Email", "PhoneNumber") FROM stdin;
\.


--
-- Data for Name: LogEntries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."LogEntries" ("Id", "CreatedAt", "Level", "Category", "Message", "Exception", "EventId") FROM stdin;
a193045e-4851-4b0f-8618-22d1591aaf32	2025-12-02 14:16:17.424521+03	Information	Microsoft.Hosting.Lifetime	Now listening on: http://localhost:5026	\N	ListeningOnAddress
b69736e7-a332-4b52-8b2b-18910687b4d5	2025-12-02 14:16:17.52866+03	Information	Microsoft.Hosting.Lifetime	Application started. Press Ctrl+C to shut down.	\N	\N
3c42e2ba-a7a4-499a-a71b-79df08334058	2025-12-02 14:16:17.531732+03	Information	Microsoft.Hosting.Lifetime	Hosting environment: Development	\N	\N
ada326e6-9831-420e-a57b-824bb54f3466	2025-12-02 14:16:17.532778+03	Information	Microsoft.Hosting.Lifetime	Content root path: /Users/alim/kpv/rental/WebRental	\N	\N
5377016a-0238-496a-8839-6de6e663e308	2025-12-02 14:16:23.665706+03	Information	Microsoft.Hosting.Lifetime	Application is shutting down...	\N	\N
3275fbf3-122c-44f3-be44-7d67ddae50fd	2025-12-02 14:17:53.861497+03	Information	Microsoft.Hosting.Lifetime	Now listening on: http://localhost:5026	\N	ListeningOnAddress
334cb794-ae95-40ce-84bb-47dacc263c82	2025-12-02 14:17:54.046639+03	Information	Microsoft.Hosting.Lifetime	Application started. Press Ctrl+C to shut down.	\N	\N
b8f7ed76-3b60-4c9c-9453-12e500bc77aa	2025-12-02 14:17:54.049174+03	Information	Microsoft.Hosting.Lifetime	Hosting environment: Development	\N	\N
b74b658b-642b-4eb7-b536-46e34aeeb9a9	2025-12-02 14:17:54.050681+03	Information	Microsoft.Hosting.Lifetime	Content root path: /Users/alim/kpv/rental/WebRental	\N	\N
3322193d-4406-4a29-bcbc-ba9f93e5080a	2025-12-02 14:19:11.501648+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
2e1bf583-741e-4716-abc5-f90a6e14955a	2025-12-02 14:22:22.973453+03	Information	Microsoft.Hosting.Lifetime	Application is shutting down...	\N	\N
a6ffb6d1-7deb-4603-9bdf-dd5def2d1e36	2025-12-02 14:22:33.136714+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
94be0d35-0cad-4a98-a1fc-4ac100ceee3d	2025-12-02 14:22:52.454659+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
b1f19acb-5920-4bf8-bd53-793347a6e3bd	2025-12-02 14:22:53.338658+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
d11ffcac-b584-494c-98a2-bc5c696c50a0	2025-12-02 14:22:56.327526+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
03fdf0f6-4da3-4336-85af-1adb45d1dcff	2025-12-02 14:23:29.828754+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
accb04dd-df91-4c0b-81b6-bc13333ff875	2025-12-02 14:23:30.607642+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
708a134a-5e60-4804-8044-88aca30a7b3c	2025-12-02 14:23:34.72843+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
8476346d-cf48-4da4-91fb-1bc91bf6f4d5	2025-12-02 14:23:45.304576+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
6708adde-732d-48fb-b4ae-fdded8da4005	2025-12-02 14:23:46.071192+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
831576b1-ed24-4877-8286-a20acfa1bec9	2025-12-02 14:23:47.013961+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
3b085281-1039-4f39-84d4-0eb2f082e753	2025-12-02 14:23:47.837483+03	Information	WebRental.Controllers.BookingsController	Returned 0 bookings	\N	\N
a8956260-b4be-4792-9e24-ede785e23dba	2025-12-02 14:34:06.901288+03	Information	WebRental.Controllers.BookingsController	Returned cars	\N	\N
771c0de1-7e39-4dd4-9b4e-0dcd298ac82a	2025-12-02 14:34:45.345925+03	Information	WebRental.Controllers.CarsController	Returned cars	\N	\N
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20251118130356_InitialCreate	9.0.10
20251118130850_AddLogEntry	9.0.10
\.


--
-- Name: Bookings PK_Bookings; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bookings"
    ADD CONSTRAINT "PK_Bookings" PRIMARY KEY ("Id");


--
-- Name: Cars PK_Cars; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Cars"
    ADD CONSTRAINT "PK_Cars" PRIMARY KEY ("Id");


--
-- Name: Clients PK_Clients; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Clients"
    ADD CONSTRAINT "PK_Clients" PRIMARY KEY ("Id");


--
-- Name: LogEntries PK_LogEntries; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."LogEntries"
    ADD CONSTRAINT "PK_LogEntries" PRIMARY KEY ("Id");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- Name: IX_Bookings_CarId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Bookings_CarId" ON public."Bookings" USING btree ("CarId");


--
-- Name: IX_Bookings_ClientId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IX_Bookings_ClientId" ON public."Bookings" USING btree ("ClientId");


--
-- Name: Bookings FK_Bookings_Cars_CarId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bookings"
    ADD CONSTRAINT "FK_Bookings_Cars_CarId" FOREIGN KEY ("CarId") REFERENCES public."Cars"("Id") ON DELETE CASCADE;


--
-- Name: Bookings FK_Bookings_Clients_ClientId; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bookings"
    ADD CONSTRAINT "FK_Bookings_Clients_ClientId" FOREIGN KEY ("ClientId") REFERENCES public."Clients"("Id") ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict g55Y72CgjZ4Dh5meFIGKDxdQzEBNHsQGC3zGu7MUbad8gGwFIyqkXh1MPS9LaM2

--
-- Database "test_job" dump
--

--
-- PostgreSQL database dump
--

\restrict Jj9ZWJXWOMRKFKLEYyeYnrQ3fsdJXG8waOxVDtYe18FNdfASJU6DZHPOHDDHi1k

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: test_job; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE test_job WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


ALTER DATABASE test_job OWNER TO postgres;

\unrestrict Jj9ZWJXWOMRKFKLEYyeYnrQ3fsdJXG8waOxVDtYe18FNdfASJU6DZHPOHDDHi1k
\connect test_job
\restrict Jj9ZWJXWOMRKFKLEYyeYnrQ3fsdJXG8waOxVDtYe18FNdfASJU6DZHPOHDDHi1k

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employer_trust; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employer_trust (
    employer_id uuid NOT NULL,
    target_employer_id uuid NOT NULL,
    weight numeric(5,4) NOT NULL,
    CONSTRAINT employer_trust_weight_check CHECK (((weight >= (0)::numeric) AND (weight <= (1)::numeric)))
);


ALTER TABLE public.employer_trust OWNER TO postgres;

--
-- Name: reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviews (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    task_id uuid NOT NULL,
    author_id uuid NOT NULL,
    target_user_id uuid NOT NULL,
    score integer NOT NULL,
    comment text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reviews_score_check CHECK (((score >= 1) AND (score <= 5)))
);


ALTER TABLE public.reviews OWNER TO postgres;

--
-- Name: task_responses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.task_responses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    task_id uuid NOT NULL,
    performer_id uuid NOT NULL,
    message text DEFAULT ''::text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT task_responses_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])))
);


ALTER TABLE public.task_responses OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tasks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    employer_id uuid NOT NULL,
    performer_id uuid,
    budget numeric(12,2) DEFAULT 0 NOT NULL,
    work_date date NOT NULL,
    work_start_time time without time zone NOT NULL,
    work_end_time time without time zone NOT NULL,
    work_type text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    attachment_path text,
    completion_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT tasks_status_check CHECK ((status = ANY (ARRAY['open'::text, 'inprogress'::text, 'completed'::text]))),
    CONSTRAINT tasks_work_type_check CHECK ((work_type = ANY (ARRAY['physical'::text, 'mental'::text, 'creative'::text, 'communication'::text, 'information'::text, 'engineering'::text])))
);


ALTER TABLE public.tasks OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    salt text NOT NULL,
    role text NOT NULL,
    display_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    avatar_path text DEFAULT '/static/img/cat_icon.png'::text NOT NULL,
    CONSTRAINT users_role_check CHECK ((role = ANY (ARRAY['employer'::text, 'performer'::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: employer_trust; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employer_trust (employer_id, target_employer_id, weight) FROM stdin;
59ae7c34-5a12-4674-8a41-702808233aaf	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	1.0000
b8fe372b-06ce-40b9-9327-4351301365b6	59ae7c34-5a12-4674-8a41-702808233aaf	0.0000
b8fe372b-06ce-40b9-9327-4351301365b6	f8d0537c-0ede-4d25-b68d-25533bae086d	0.8000
b8fe372b-06ce-40b9-9327-4351301365b6	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	0.5000
f8d0537c-0ede-4d25-b68d-25533bae086d	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	0.0000
f8d0537c-0ede-4d25-b68d-25533bae086d	b8fe372b-06ce-40b9-9327-4351301365b6	1.0000
89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	b8fe372b-06ce-40b9-9327-4351301365b6	0.1000
89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	f8d0537c-0ede-4d25-b68d-25533bae086d	0.1000
89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	59ae7c34-5a12-4674-8a41-702808233aaf	0.7000
f3ad5ce2-5686-4ad3-92e9-469046857678	838b4594-74f4-48cf-a1ce-06ca6da86ced	0.0000
f3ad5ce2-5686-4ad3-92e9-469046857678	830caa4e-a129-479c-a6ad-da5b030a5986	0.0000
f3ad5ce2-5686-4ad3-92e9-469046857678	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	0.0000
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviews (id, task_id, author_id, target_user_id, score, comment, created_at) FROM stdin;
b2d585dd-0dfb-4610-b455-37e245e716e6	ed98dee4-cdfc-43e8-b6df-ec9703b2b998	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	5	молодец	2025-11-20 03:47:51.596634+03
5076afd4-7e5a-48df-9142-241f2353b6b8	ed98dee4-cdfc-43e8-b6df-ec9703b2b998	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	5	норм условия	2025-11-20 03:51:25.636548+03
33d70bd8-14a4-4fc4-8ce1-df3da99d3a40	6a67b112-9cfd-4064-abf9-bab2daac8520	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	4	d	2025-11-20 03:53:27.79007+03
62aeeeea-8b06-4282-8df4-cf6d9e3eef52	06db6a09-d56d-4ceb-8c12-ddb25d956436	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	3	ddd	2025-11-20 03:53:48.790121+03
3a842013-8c0b-4e59-9e78-6be6e1351e2a	766b0cb8-e455-4f3e-9916-d6485b173cae	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	5	нормально	2025-11-22 11:40:34.309306+03
f4885831-c6a8-4073-92ea-c83b0f66e1bf	db9ac63c-d9e7-436d-a3d7-16940e08e28a	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	1	a	2025-11-22 11:45:54.292635+03
5e6c0a03-7565-45a3-bfc2-e4f64acf16a7	0710d219-fc4e-4669-b146-cb86794cff42	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	2	2	2025-11-22 11:46:09.093023+03
0160f025-5a1a-4f66-9c34-ae900d222d92	9d032b68-0882-4e4c-9f75-276a7070cba5	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	1	1	2025-11-22 12:11:58.732137+03
279afdef-446a-4b62-b155-a0183e7e2fe1	2eed1800-997c-4f35-9686-f4a063168860	b8fe372b-06ce-40b9-9327-4351301365b6	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	4	пойдет	2025-11-22 12:14:29.664982+03
87729fa0-d704-45b1-bc49-882c441d7c73	4654cea1-a5b8-4d7e-8562-b6b6ea883db6	b8fe372b-06ce-40b9-9327-4351301365b6	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	5	yjhv	2025-11-22 12:15:10.661399+03
1ee8d5ad-03ee-4cd0-b2cd-edcc5f07b8cc	91295896-6c1b-43f0-9c56-ce9f598ee5cc	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	5	111	2025-11-24 21:27:11.304728+03
17ed6cd9-e8ec-4242-9bcf-4edc88dbb5d4	d0214d86-f053-4b94-96ec-f0f9b3b80bcf	f3ad5ce2-5686-4ad3-92e9-469046857678	51ada384-ed7c-4b43-8358-fa7f8139a34f	5	убрал, молодец	2025-11-29 11:02:13.837868+03
\.


--
-- Data for Name: task_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.task_responses (id, task_id, performer_id, message, status, created_at) FROM stdin;
3094f894-f9e2-4fdf-bda2-21ca140a30a2	ed98dee4-cdfc-43e8-b6df-ec9703b2b998	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	привет	pending	2025-11-20 03:11:29.3144+03
2e482f60-b049-4e49-a7b0-1817f9df7ef1	ed98dee4-cdfc-43e8-b6df-ec9703b2b998	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-20 03:13:13.933582+03
8c1bd3c1-8fe2-4b8a-888f-81b7ccbd33d7	6a67b112-9cfd-4064-abf9-bab2daac8520	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-20 03:51:42.032672+03
77b2c824-bd23-4a1a-a7a9-2e9a315fc094	06db6a09-d56d-4ceb-8c12-ddb25d956436	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-20 03:51:53.271388+03
fe5a62ce-5c55-4492-805d-5613fdff00fa	9d032b68-0882-4e4c-9f75-276a7070cba5	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		pending	2025-11-20 15:02:51.94639+03
e49ddd80-216d-4a11-b505-10a5d8e0f26b	9d032b68-0882-4e4c-9f75-276a7070cba5	7981afd4-8b1a-49a0-84ac-a3f6bc716679	aaaaaaa	pending	2025-11-20 21:46:34.60006+03
b820249f-f353-417e-8013-d4b473aa39ea	9d032b68-0882-4e4c-9f75-276a7070cba5	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-20 21:41:02.204529+03
1abe1588-1f40-42cc-8abb-cc3f50bab150	766b0cb8-e455-4f3e-9916-d6485b173cae	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		accepted	2025-11-22 05:33:54.263023+03
6bc739d6-da78-45d4-b8e4-1c07a4a1d503	db9ac63c-d9e7-436d-a3d7-16940e08e28a	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-22 11:45:08.198927+03
36d1a2f2-429b-4240-86ec-25ddfd445ffe	0710d219-fc4e-4669-b146-cb86794cff42	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-22 11:45:12.622718+03
0a1e4c21-2d1d-4bea-958b-adf6fcd7a572	4654cea1-a5b8-4d7e-8562-b6b6ea883db6	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-22 12:13:35.906347+03
7692ab79-7de6-4115-bcdc-654ea0148e66	2eed1800-997c-4f35-9686-f4a063168860	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		accepted	2025-11-22 12:13:39.491174+03
b2997abc-3c44-4290-a71e-d46eb70a10ce	6972f6b6-ec6a-4bcf-928b-029914d349ed	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	Предложено нанимателем	accepted	2025-11-22 13:11:59.792829+03
776bfca9-060d-4211-9fd6-5163a1775926	405d7a60-0772-4923-b189-adbf05b11997	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		pending	2025-11-22 13:13:47.419898+03
d1f2ac04-0dff-4bc3-b2ce-a75a63b89c37	405d7a60-0772-4923-b189-adbf05b11997	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1		pending	2025-11-22 13:40:49.003815+03
75c67a68-5519-4e05-b2d8-fbb14a7f9a54	92df3d50-abce-4c44-b899-4dcf1bf75209	b0fc9f7e-98df-4f2e-8d87-3af680ec4e34		pending	2025-11-22 20:57:30.08302+03
b974c743-be4b-438d-a3b3-6918d7af1b00	92df3d50-abce-4c44-b899-4dcf1bf75209	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		pending	2025-11-22 16:13:06.351612+03
5073ec79-724d-4054-ae04-3f3172e19b73	7cf78165-e696-4ccf-90d3-8d2271660078	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		pending	2025-11-24 11:54:32.405163+03
986d26ed-eac9-43c3-9908-8d39b549ae5a	91295896-6c1b-43f0-9c56-ce9f598ee5cc	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	Предложено нанимателем	pending	2025-11-24 21:24:53.673231+03
55b09442-1f11-4e0e-ad6e-1eaf51a5887a	91295896-6c1b-43f0-9c56-ce9f598ee5cc	c1a3bff6-454b-4893-a082-adfdd0e5a6d6		accepted	2025-11-24 21:24:44.012989+03
dad6f71c-d2e0-44dd-8e7b-824cc37d39e6	d0214d86-f053-4b94-96ec-f0f9b3b80bcf	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	Предложено нанимателем	pending	2025-11-29 10:57:58.205993+03
5f1440ee-d434-416a-bf84-ec59379e396c	5d01b0c0-fdd8-47e5-9319-2d53002974f5	51ada384-ed7c-4b43-8358-fa7f8139a34f		pending	2025-11-29 11:00:03.28957+03
c5b7b86e-3868-49a1-87a2-639f4c4f6293	d0214d86-f053-4b94-96ec-f0f9b3b80bcf	51ada384-ed7c-4b43-8358-fa7f8139a34f		accepted	2025-11-29 11:00:11.764061+03
81699453-93a3-4319-bbd5-490d963738d3	8aefd6bb-a023-4a11-8b12-3169f697a717	51ada384-ed7c-4b43-8358-fa7f8139a34f		pending	2025-11-29 11:08:26.33553+03
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tasks (id, title, description, employer_id, performer_id, budget, work_date, work_start_time, work_end_time, work_type, status, attachment_path, completion_notes, created_at, completed_at) FROM stdin;
ed98dee4-cdfc-43e8-b6df-ec9703b2b998	перегрузка	по лестнице перетаскать 80 ящиков по 30кг	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	10000.00	2025-11-20	12:00:00	16:00:00	physical	completed	\N		2025-11-20 01:17:53.696841+03	2025-11-20 03:17:11.906997+03
6a67b112-9cfd-4064-abf9-bab2daac8520	Водитель	проехать по определенному маршруту	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	5000.00	2025-11-22	08:00:00	20:00:00	engineering	completed	\N		2025-11-20 01:20:34.093463+03	2025-11-20 03:53:19.075455+03
06db6a09-d56d-4ceb-8c12-ddb25d956436	Кондитер	быстро испечь 20 тортов с авторским дизайном	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	30000.00	2025-11-22	08:00:00	21:00:00	creative	completed	\N		2025-11-20 01:21:31.362263+03	2025-11-20 03:53:42.138363+03
9d032b68-0882-4e4c-9f75-276a7070cba5	сломать стену	...	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	1000.00	2025-11-20	11:11:00	22:22:00	physical	completed	\N		2025-11-20 03:56:11.046239+03	2025-11-22 05:22:15.198369+03
766b0cb8-e455-4f3e-9916-d6485b173cae	Сделать дз	быстро выполнить семестровую работу	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	2400.00	2025-11-22	10:00:00	15:00:00	mental	completed	\N		2025-11-22 04:23:39.234331+03	2025-11-22 11:40:16.825887+03
db9ac63c-d9e7-436d-a3d7-16940e08e28a	aa	aa	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	111.00	2025-11-22	11:11:00	22:22:00	physical	completed	\N		2025-11-22 11:43:43.485148+03	2025-11-22 11:45:43.829286+03
0710d219-fc4e-4669-b146-cb86794cff42	aa	aa	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	11.00	2025-11-22	11:22:00	22:22:00	physical	completed	\N		2025-11-22 11:43:58.327038+03	2025-11-22 11:46:04.085677+03
2eed1800-997c-4f35-9686-f4a063168860	a	a	b8fe372b-06ce-40b9-9327-4351301365b6	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	11.00	2025-11-26	11:22:00	11:23:00	physical	completed	\N		2025-11-22 12:12:46.061525+03	2025-11-22 12:14:14.694885+03
4654cea1-a5b8-4d7e-8562-b6b6ea883db6	33	12	b8fe372b-06ce-40b9-9327-4351301365b6	71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	34.00	2025-11-22	22:11:00	22:22:00	physical	completed	\N		2025-11-22 12:13:05.154237+03	2025-11-22 12:14:35.482131+03
6972f6b6-ec6a-4bcf-928b-029914d349ed	11	11	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	111.00	2025-11-22	11:22:00	22:22:00	physical	completed	\N		2025-11-22 13:11:51.017733+03	2025-11-22 13:12:37.65214+03
405d7a60-0772-4923-b189-adbf05b11997	aa	aa	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	\N	1122.00	2025-11-27	11:22:00	12:22:00	physical	open	\N	\N	2025-11-22 13:13:37.695682+03	\N
92df3d50-abce-4c44-b899-4dcf1bf75209	ss	sss	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	\N	111.00	2025-11-22	11:22:00	22:11:00	physical	open	\N	\N	2025-11-22 15:47:47.982439+03	\N
7cf78165-e696-4ccf-90d3-8d2271660078	Стройка	йцукенг	feabebf2-5b0b-4059-989a-1dc8aac11934	\N	1234.00	2025-11-24	11:22:00	22:22:00	physical	open	\N	\N	2025-11-24 11:54:17.510959+03	\N
91295896-6c1b-43f0-9c56-ce9f598ee5cc	hello	123456	89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	c1a3bff6-454b-4893-a082-adfdd0e5a6d6	123456.00	2025-11-24	11:11:00	22:22:00	communication	completed	\N		2025-11-24 21:24:31.71337+03	2025-11-24 21:27:01.020404+03
5d01b0c0-fdd8-47e5-9319-2d53002974f5	1234	ewer	830caa4e-a129-479c-a6ad-da5b030a5986	\N	123.00	2025-11-28	02:22:00	12:22:00	physical	open	\N	\N	2025-11-28 21:41:03.120797+03	\N
d0214d86-f053-4b94-96ec-f0f9b3b80bcf	убрать казашки	насрано пипец, воняет невероятно	f3ad5ce2-5686-4ad3-92e9-469046857678	51ada384-ed7c-4b43-8358-fa7f8139a34f	80.00	2025-12-29	10:59:00	23:12:00	creative	completed	\N	пиздуй работать опта	2025-11-29 10:57:15.762672+03	2025-11-29 11:01:51.335555+03
8aefd6bb-a023-4a11-8b12-3169f697a717	построить сарай	надо очень пжпжпжпжпжпжп	f3ad5ce2-5686-4ad3-92e9-469046857678	\N	10000.00	2025-12-12	01:59:00	04:44:00	engineering	open	\N	\N	2025-11-29 11:05:47.165182+03	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, salt, role, display_name, created_at, avatar_path) FROM stdin;
89a5ac1c-5f65-49ac-9e4a-4384a35c3a50	gerkariy1@gmail.com	100000.nNCT/5V4Qq6x/hB543dNGuyblEkKp6zzyaO5mziT6GI=	8jtLmfY0rqyX/c7SSR3xhQ==	employer	Alim	2025-11-20 01:16:07.669359+03	/static/img/cat_icon.png
c1a3bff6-454b-4893-a082-adfdd0e5a6d6	gggeeeerr1@gmail.com	100000.yzKL1l+NXA3K0ZOvkjfb54rRdqMJkSbvBpOZkihsE0c=	vUOb9jzZ9Po7hWUjXQnH9Q==	performer	ann	2025-11-20 02:51:57.747286+03	/static/img/cat_icon.png
71ec88ac-1d1d-4b8e-bf07-4b6342f498a1	gerrrrr1@gmail.com	100000.JclQaQehHJ+GtcvhSlf+N/uKX/EZDgQnzWCpl2BYkVY=	7UifdFCzF8rWNPLz4t2Nkw==	performer	agg	2025-11-20 03:12:14.406702+03	/static/img/cat_icon.png
7981afd4-8b1a-49a0-84ac-a3f6bc716679	gedfdfd@gmail.com	100000.FMCendm2OGu4/5bPf4wbq4cYd6JzpWoINfzdvHo+jh4=	t0G8hD6SumahHMC5D4Zfrg==	performer	dddd	2025-11-20 21:46:07.588175+03	/static/img/cat_icon.png
59ae7c34-5a12-4674-8a41-702808233aaf	aggggg1@gmailc.com	100000.lBU6HWtxdOnmDrfnj0Dz5Skx9uKLa6BhMxw9lxvt/d4=	Ks1YrX0yHALDLFvH3EzD4A==	employer	adddd	2025-11-22 11:37:45.488216+03	/static/img/cat_icon.png
b8fe372b-06ce-40b9-9327-4351301365b6	aaaaa1@gmail.com	100000.oABiCJ1DJ+RvLmi95Xc4y+X7Xaxjp+EDdOvuHaus8F4=	SQDC0Pyqp3zK2RVI5X0ahQ==	employer	globus	2025-11-22 11:41:15.860113+03	/static/img/cat_icon.png
f8d0537c-0ede-4d25-b68d-25533bae086d	gagagaga1@gmail.com	100000.LLMNTUr6U1B10yKshU/QQYRJYrFZrv1gSEGZAjwohwA=	qrT3WhfJ04Me8M3DNvjeQw==	employer	bear	2025-11-22 12:00:27.136601+03	/static/img/cat_icon.png
9541ac30-d9e5-44ff-a34c-3d1255280215	dsdfdsdjsfnasjnfdajlsnfdslajknf1@gmail.com	100000.zzLLxITi44AIBK5nzu4ibCeYlHsfzkcgWWSnFJx3T70=	lardjdPvKLvzHxuBgQ7emA==	employer	aaaaa1	2025-11-22 20:31:04.131244+03	/static/img/cat_icon.png
7dd8839d-5473-4d08-a1a1-e1ce688ef872	asdfghjk1@gmail.com	100000.NSewWkbcn/tnb+81ZYl01drDHh8XYxc9cAG2dwM/BIc=	YneHlCvUTXQcweYCduBApw==	employer	asdfghjk	2025-11-22 20:49:47.813061+03	/static/img/cat_icon.png
2e8d9d9b-559c-42c7-a64e-a8047b5d34c9	sdfgh1@gmail.com	100000.Pwbul/5I2vpQ8BxZ5iWBrMXolxSFlnOloasds/MzdQQ=	tugIP9j4LhtBqCPRHu+z7w==	employer	sdfghj	2025-11-22 20:50:40.666914+03	/static/img/monkey_icon.png
b0fc9f7e-98df-4f2e-8d87-3af680ec4e34	sdfghjkmd1@gmail.com	100000.4aW1+5RlrXplLfWEVxYb49CtgWBqJukfT3re191gAr0=	qVKvVuKYIQqmcUV5wLjlHw==	performer	adsfd	2025-11-22 20:57:11.93943+03	/static/img/cat_icon.png
d114809d-dbcc-4c9c-96a4-a2b2ee5ed508	qwertyui1@gmail.com	100000.i/Fi88FP6bDAn80ArKB2WYArCpq+odynlLWq366XQQE=	pOeqy1J5EK2uYOj2nWoQjQ==	employer	asdfghj	2025-11-24 11:49:04.152757+03	/static/img/bird_icon.png
0010ad39-11ea-4e65-8d58-82804fba743c	qwertyuio1@gmail.com	100000.KPtqANvnbp0v+R6ckdJqdStjuKaZsaWcor5p4z0fhzw=	OZ51hPuaekxpAj2HpTdFtw==	employer	qwertyu	2025-11-24 11:49:27.373556+03	/static/img/dog_icon.png
818d7685-4dad-4f8a-b106-6c9f376e2b15	qwertyuio123@gmail.com	100000.Cg5+h7GbiCdZMZYLQbfkaLYhsHyxWRmoDPoVjGdo3ds=	vJ//HQs39mXDqRiXMzVQow==	employer	qwertyuiop1234567890	2025-11-24 11:49:47.405528+03	/static/img/bird_icon.png
feabebf2-5b0b-4059-989a-1dc8aac11934	qwertyuiop1@gmail.com	100000.VNIvpj4MM2c+AXhZo+NkyXoWDaotNumBfJNyirlBd8k=	b7cWOzhU7APi/ry6RCEMUQ==	employer	qwer	2025-11-24 11:50:07.608027+03	/static/img/bird_icon.png
830caa4e-a129-479c-a6ad-da5b030a5986	asdf1@gmail.com	100000.0E9Ok1EQ28ECJn8uR2if0AyEtF17j1p903PlaGjZU/Y=	zh5AP6qgun/abkdDG4sduA==	employer	12345	2025-11-28 21:40:33.559511+03	/static/img/dog_icon.png
838b4594-74f4-48cf-a1ce-06ca6da86ced	jhgfdarty@gmail.com	100000.d7FhaE53vjJexz0cu+Eh+V9dHCVrE2l7geDsRUiFNjc=	hcqGSU6g/S22wIIbuNOWbg==	employer	валерчик	2025-11-29 10:48:29.210781+03	/static/img/monkey_icon.png
f3ad5ce2-5686-4ad3-92e9-469046857678	valerchik@gmail.com	100000.Ge6GtWfLTsUgA3Gz4GsM+UgHw5rGKWYWh0RIgPdIj+E=	kRpMMkG2Q8ZiboKCZcKRTQ==	employer	valerchik	2025-11-29 10:49:41.681405+03	/static/img/monkey_icon.png
51ada384-ed7c-4b43-8358-fa7f8139a34f	zhenek@gmail.com	100000.673OmUI/YZeHMLtvDqGyTRtbd7Qfkd4klev0HYP6+6c=	HmmTNjxlREyfqbXAkFsAFQ==	performer	женёк	2025-11-29 10:59:28.381902+03	/static/img/cat_icon.png
\.


--
-- Name: employer_trust employer_trust_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer_trust
    ADD CONSTRAINT employer_trust_pkey PRIMARY KEY (employer_id, target_employer_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: task_responses task_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_responses
    ADD CONSTRAINT task_responses_pkey PRIMARY KEY (id);


--
-- Name: task_responses task_responses_task_id_performer_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_responses
    ADD CONSTRAINT task_responses_task_id_performer_id_key UNIQUE (task_id, performer_id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_responses_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_responses_task ON public.task_responses USING btree (task_id);


--
-- Name: idx_reviews_task; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reviews_task ON public.reviews USING btree (task_id);


--
-- Name: idx_tasks_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tasks_status ON public.tasks USING btree (status);


--
-- Name: uq_reviews_task_author_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_reviews_task_author_target ON public.reviews USING btree (task_id, author_id, target_user_id);


--
-- Name: employer_trust employer_trust_employer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer_trust
    ADD CONSTRAINT employer_trust_employer_id_fkey FOREIGN KEY (employer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: employer_trust employer_trust_target_employer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer_trust
    ADD CONSTRAINT employer_trust_target_employer_id_fkey FOREIGN KEY (target_employer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reviews reviews_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: reviews reviews_target_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES public.users(id);


--
-- Name: reviews reviews_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: task_responses task_responses_performer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_responses
    ADD CONSTRAINT task_responses_performer_id_fkey FOREIGN KEY (performer_id) REFERENCES public.users(id);


--
-- Name: task_responses task_responses_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.task_responses
    ADD CONSTRAINT task_responses_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_employer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_employer_id_fkey FOREIGN KEY (employer_id) REFERENCES public.users(id);


--
-- Name: tasks tasks_performer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_performer_id_fkey FOREIGN KEY (performer_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict Jj9ZWJXWOMRKFKLEYyeYnrQ3fsdJXG8waOxVDtYe18FNdfASJU6DZHPOHDDHi1k

--
-- PostgreSQL database cluster dump complete
--

