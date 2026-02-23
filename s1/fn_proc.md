# Процедуры 3 шт + запрос просмотра всех процедур

**Первый пример**

Добавить новый заказ

``` sql
CREATE PROCEDURE add_new_order(
    p_client_id INT,
    p_tariff_id INT,
    p_status VARCHAR DEFAULT 'Новый'
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO orders (client_id, tariff_id, status)
    VALUES (p_client_id, p_tariff_id, p_status);

    INSERT INTO tracking (order_id, status)
    VALUES (currval('orders_order_id_seq'), 'В пути');
END;
$$;
```

**Второй пример**

Обновить статус автомобиля

``` sql
CREATE PROCEDURE update_vehicle_status(
    p_vehicle_id INT,
    p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE vehicles
    SET status = p_status
    WHERE vehicle_id = p_vehicle_id;
END;
$$;
```

**Третий пример**

Увеличить вместимость склада

``` sql
CREATE PROCEDURE increase_warehouse_capacity(
    p_warehouse_id INT,
    p_delta NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE warehouses
    SET capacity = COALESCE(capacity, 0) + p_delta
    WHERE warehouse_id = p_warehouse_id;
END;
$$;
```

# Запрос просмотра всех процедур

``` sql
SELECT proname AS procedure_name
FROM pg_proc
WHERE prokind = 'p';
```

<img width="280" height="142" alt="Снимок экрана 2025-11-25 212731" src="https://github.com/user-attachments/assets/d8f1ad25-3838-4e3f-9a9c-9b23660deb3b" />


# Функции 3 шт + запрос просмотра всех процедур

**Первый пример**

Получить сумму стоимости заказов клиента

``` sql
CREATE FUNCTION get_client_total_cost(p_client_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT SUM(total_cost)
        FROM orders
        WHERE client_id = p_client_id
    );
END;
$$ LANGUAGE plpgsql;
```

**Второй пример**

Получить количество грузов по заказу

``` sql
CREATE FUNCTION count_cargos_for_order(p_order_id INT)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM cargos
        WHERE order_id = p_order_id
    );
END;
$$ LANGUAGE plpgsql;
```

**Третий пример**

Получить вес груза по ID

``` sql
CREATE FUNCTION get_cargo_weight(p_cargo_id INT)
RETURNS DOUBLE PRECISION AS $$
BEGIN
    RETURN (
        SELECT weight
        FROM cargos
        WHERE cargo_id = p_cargo_id
    );
END;
$$ LANGUAGE plpgsql;
```

# Запрос просмотра всех функций

``` sql
select routine_name, routine_type
from information_schema.routines
where routine_type = 'FUNCTION' and routine_schema = 'public'
```


<img width="388" height="238" alt="image" src="https://github.com/user-attachments/assets/888e67b6-4220-40b1-9640-b4328dfcf1a8" />

# Функции с переменными 3 шт

**Первый пример**

Итоговая цена груза

``` sql
CREATE FUNCTION calculate_cargo_price(p_cargo_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_weight DOUBLE PRECISION;
    v_price_per_kg NUMERIC;
BEGIN
    SELECT weight INTO v_weight FROM cargos WHERE cargo_id = p_cargo_id;

    SELECT price_per_kg INTO v_price_per_kg
    FROM tariffs
    JOIN orders o ON o.tariff_id = tariffs.tariff_id
    JOIN cargos c ON c.order_id = o.order_id
    WHERE c.cargo_id = p_cargo_id;

    RETURN v_weight * v_price_per_kg;
END;
$$ LANGUAGE plpgsql;
```

**Второй пример**

Проверить доступность автомобиля

``` sql
CREATE FUNCTION is_vehicle_available(p_vehicle_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT status INTO v_status
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    RETURN v_status = 'Доступен';
END;
$$ LANGUAGE plpgsql;
```

**Третий пример**

Сколько заказов в маршруте

``` sql
CREATE FUNCTION count_orders_in_trip(p_trip_id INT)
RETURNS INT AS $$
DECLARE
    v_cnt INT;
BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM orders
    WHERE trip_id = p_trip_id;

    RETURN v_cnt;
END;
$$ LANGUAGE plpgsql;
```

# Блок DO 3 шт

**Первый пример**

Поднять вместимость всех складов на 10%

``` sql
DO $$
BEGIN
    UPDATE warehouses
    SET capacity = capacity * 1.1;
END $$;
```

**Второй пример**

Создать первый заказ, если нет ни одного

``` sql
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM orders;

    IF v_count = 0 THEN
        INSERT INTO orders (client_id, status)
        VALUES (1, 'Новый');
    END IF;
END $$;
```

**Третий пример**

Удалить все грузы весом меньше 1 кг

``` sql
DO $$
BEGIN
    DELETE FROM cargos
    WHERE weight < 1;
END $$;
```

# IF

``` sql
CREATE OR REPLACE FUNCTION categorize_client_by_contracts(p_client_id INT)
RETURNS VARCHAR(20)
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

SELECT categorize_client_by_contracts(1) AS client_category;
```

<img width="618" height="112" alt="Снимок экрана 2025-11-26 в 10 40 23" src="https://github.com/user-attachments/assets/dc755de9-8aba-49d6-9bf3-8609b9c215ba" />

<img width="167" height="65" alt="Снимок экрана 2025-11-26 в 10 35 24" src="https://github.com/user-attachments/assets/bf2ea0c2-4e37-4004-a5f5-dd3fef3efcb2" />

# CASE

``` sql
CREATE OR REPLACE FUNCTION categorize_vehicle_by_mileage(p_vehicle_id INT)
RETURNS VARCHAR(20)
LANGUAGE plpgsql
AS $$
DECLARE
    v_mileage  NUMERIC(10,2);
    v_category VARCHAR(20);
BEGIN
    SELECT mileage
    INTO v_mileage
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    v_category := CASE
        WHEN v_mileage IS NULL THEN 'Неизвестно'
        WHEN v_mileage < 50000 THEN 'Новый'
        WHEN v_mileage BETWEEN 50000 AND 200000 THEN 'В эксплуатации'
        ELSE 'Требует обновления'
    END;

    RETURN v_category;
END;
$$;

SELECT categorize_vehicle_by_mileage(1) AS vehicle_category;

```

<img width="618" height="66" alt="Снимок экрана 2025-11-26 в 10 41 17" src="https://github.com/user-attachments/assets/73684b30-aeaa-4d1d-a749-435fb24b3fc8" />

<img width="168" height="66" alt="Снимок экрана 2025-11-26 в 10 39 54" src="https://github.com/user-attachments/assets/1fcda690-6e37-4cba-990c-ffb04bbd3613" />


# WHILE

``` sql
CREATE OR REPLACE PROCEDURE create_test_routes(p_count INT)
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

CALL create_test_routes(3);
SELECT * FROM routes WHERE departure_city LIKE 'Test City%';
```

<img width="620" height="118" alt="Снимок экрана 2025-11-26 в 10 49 04" src="https://github.com/user-attachments/assets/8fac91dd-1747-4392-a992-436e615f5113" />

``` sql
CREATE OR REPLACE PROCEDURE increment_vehicle_mileage(
    p_vehicle_id INT,
    p_steps      INT,
    p_increment  NUMERIC
)
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

CALL increment_vehicle_mileage(1, 5, 10);  -- +50 к пробегу
```

<img width="805" height="68" alt="Снимок экрана 2025-11-26 в 10 50 37" src="https://github.com/user-attachments/assets/aca91c05-de43-4c85-86eb-a611e78787bb" />

<img width="801" height="65" alt="Снимок экрана 2025-11-26 в 10 51 21" src="https://github.com/user-attachments/assets/19adcf09-f942-4812-9cfa-75a255d5adb9" />

# EXCEPTION

``` sql
CREATE OR REPLACE PROCEDURE safe_insert_client(p_name VARCHAR)
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

CALL safe_insert_client('ООО "Ромашка"');
```

<img width="523" height="60" alt="Снимок экрана 2025-11-26 в 10 54 08" src="https://github.com/user-attachments/assets/4c6af469-b282-4941-99cb-1f72b6f4f77f" />

<img width="289" height="188" alt="Снимок экрана 2025-11-26 в 10 54 24" src="https://github.com/user-attachments/assets/403a7054-1368-4ca3-aa2a-09fd4d7af10c" />

``` sql
CREATE OR REPLACE FUNCTION calc_avg_payment_for_order(p_order_id INT)
RETURNS NUMERIC
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

SELECT ROUND (calc_avg_payment_for_order(5), 2) AS avg_payment;
```

<img width="718" height="110" alt="Снимок экрана 2025-11-26 в 11 01 04" src="https://github.com/user-attachments/assets/8afaddb8-1d1b-4055-ae48-e9659daee1ef" />

<img width="145" height="66" alt="Снимок экрана 2025-11-26 в 11 01 18" src="https://github.com/user-attachments/assets/6606ebdb-0868-4a91-8772-d721d5660319" />

# RAISE

``` sql
CREATE OR REPLACE PROCEDURE report_orders_stats()
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

CALL report_orders_stats();
```

<img width="488" height="92" alt="Снимок экрана 2025-11-26 в 11 02 13" src="https://github.com/user-attachments/assets/b8d9cf80-aaba-4b47-bc0a-1b03d8fa1de8" />

``` sql
CREATE OR REPLACE FUNCTION check_order_exists(p_order_id INT)
RETURNS VOID
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

SELECT check_order_exists(1);      
```

<img width="207" height="20" alt="Снимок экрана 2025-11-26 в 11 05 29" src="https://github.com/user-attachments/assets/8c331a3f-9432-46cd-9201-f6569d714763" />

``` sql
CREATE OR REPLACE FUNCTION check_order_exists(p_order_id INT)
RETURNS VOID
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

SELECT check_order_exists(5);      
```

<img width="217" height="30" alt="Снимок экрана 2025-11-26 в 11 06 02" src="https://github.com/user-attachments/assets/4827c7b2-bc88-4c71-ab0d-4daaf34fe24f" />
