# Триггеры с NEW

**Первый пример**

Автозаполнение total_cost, если оно NULL

``` sql
CREATE FUNCTION trg_fill_cost()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_cost IS NULL THEN
        NEW.total_cost := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_fill_cost
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_fill_cost();
```

<img width="528" height="62" alt="Снимок экрана 2025-12-03 093307" src="https://github.com/user-attachments/assets/359c31ae-52fc-4e3d-b183-4b6898c97a3b" />

<img width="515" height="87" alt="Снимок экрана 2025-12-03 093329" src="https://github.com/user-attachments/assets/e72a4694-ee31-45f0-b825-b401685a1d2e" />

<img width="493" height="77" alt="Снимок экрана 2025-12-03 093334" src="https://github.com/user-attachments/assets/2e504068-7173-40d4-b097-8f83e1e4a3b3" />


**Второй пример**

Логирование создания заказа

``` sql
CREATE FUNCTION trg_log_new_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (NEW.order_id, 'Создан заказ', CURRENT_USER);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_log_order
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_new_order();
```

<img width="642" height="57" alt="Снимок экрана 2025-12-03 093415" src="https://github.com/user-attachments/assets/d27feff7-ed10-45b3-9c2d-aafbb2dfa5ff" />

<img width="262" height="33" alt="Снимок экрана 2025-12-03 094202" src="https://github.com/user-attachments/assets/45de549c-af14-4748-b748-8696fc295b48" />

<img width="738" height="108" alt="Снимок экрана 2025-12-03 093513" src="https://github.com/user-attachments/assets/12dfbcfc-f522-488e-a806-4141236af36f" />


# Триггеры с OLD

**Первый пример**

Архивируем удаляемый заказ

``` sql
CREATE FUNCTION trg_archive_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO orders_archive(order_id, old_status, old_cost)
    VALUES (OLD.order_id, OLD.status, OLD.total_cost);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_archive_order
BEFORE DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_archive_order();
```

<img width="818" height="59" alt="Снимок экрана 2025-12-03 093608" src="https://github.com/user-attachments/assets/be0d2774-1da1-4ad5-8172-6600c8517b09" />

<img width="313" height="31" alt="Снимок экрана 2025-12-03 093632" src="https://github.com/user-attachments/assets/2173e420-23ae-40d3-bfcd-0cebeaf6ddf5" />


**Второй пример**

Логирование удаления

``` sql
CREATE FUNCTION trg_log_delete_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (OLD.order_id, 'Удалён заказ', CURRENT_USER);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_log_order
AFTER DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_delete_order();
```

<img width="267" height="31" alt="Снимок экрана 2025-12-03 093730" src="https://github.com/user-attachments/assets/2af237db-4173-4be6-a7fb-e96e8dc50ab7" />

<img width="739" height="30" alt="Снимок экрана 2025-12-03 093743" src="https://github.com/user-attachments/assets/aeb4a7ec-6c58-40d6-ad65-77c90b2aea3b" />


# BEFORE триггеры

**Первый пример**

Нельзя менять стоимость доставленного заказа

``` sql
CREATE FUNCTION trg_block_update_delivered()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'Доставлен' THEN
        RAISE EXCEPTION 'Нельзя менять доставленный заказ';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_block_delivered
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_block_update_delivered();
```

<img width="641" height="59" alt="Снимок экрана 2025-12-03 093817" src="https://github.com/user-attachments/assets/0412e578-75d3-4d52-a276-d36fac470b23" />

<img width="280" height="76" alt="Снимок экрана 2025-12-03 093856" src="https://github.com/user-attachments/assets/62a0181f-06cb-4217-9e9f-5cc256b5b298" />

<img width="764" height="125" alt="Снимок экрана 2025-12-03 093852" src="https://github.com/user-attachments/assets/ed33f293-80b4-4665-a259-fad210ce8287" />


**Второй пример**

Проверка корректности веса

``` sql
CREATE FUNCTION trg_check_weight()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Вес груза должен быть положительным';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_check_weight
BEFORE INSERT ON cargos
FOR EACH ROW
EXECUTE FUNCTION trg_check_weight();
```

<img width="758" height="55" alt="Снимок экрана 2025-12-03 094023" src="https://github.com/user-attachments/assets/7646df6d-696c-4972-91ac-8a2548b00267" />

<img width="673" height="145" alt="Снимок экрана 2025-12-03 094033" src="https://github.com/user-attachments/assets/9db77f33-af49-42be-99a3-b7e204323a11" />


# AFTER триггеры

**Первый пример**

Логирование обновления статуса

``` sql
CREATE FUNCTION trg_log_status_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (NEW.order_id, 'Изменён статус: ' || NEW.status, CURRENT_USER);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_log_status
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_status_change();
```

<img width="813" height="80" alt="Снимок экрана 2025-12-03 094142" src="https://github.com/user-attachments/assets/035eb121-9e30-4d83-aa49-845d32bd2e8b" />

<img width="262" height="33" alt="Снимок экрана 2025-12-03 094202" src="https://github.com/user-attachments/assets/011fdd43-d4ed-44c2-ac5b-c5f7cbbd9a36" />

<img width="804" height="30" alt="Снимок экрана 2025-12-03 094213" src="https://github.com/user-attachments/assets/53d4b510-07a0-4f13-b0bf-e3a393386e61" />


AFTER INSERT: создание документа после счёта (invoice)

``` sql
CREATE OR REPLACE FUNCTION trg_create_invoice_document()
RETURNS trigger AS $$
BEGIN
    INSERT INTO documents(order_id, issued_date, document_type)
    VALUES (NEW.order_id, CURRENT_DATE, 'invoice');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invoice_doc
AFTER INSERT ON invoices
FOR EACH ROW
EXECUTE FUNCTION trg_create_invoice_document();
```

``` sql
INSERT INTO invoices(invoice_id, order_id, amount)
VALUES (2001, 1, 500.00);
```
<img width="417" height="69" alt="Снимок экрана 2025-12-03 в 10 36 27" src="https://github.com/user-attachments/assets/8792ceb3-960a-4a4e-8339-1ae29e25cad3" />

<img width="415" height="93" alt="Снимок экрана 2025-12-03 в 10 36 47" src="https://github.com/user-attachments/assets/3d1e507b-9d49-45a9-980e-5c5134b98587" />

# Row level

Проверка веса груза

``` sql
CREATE OR REPLACE FUNCTION trg_check_cargo_weight()
RETURNS trigger AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Weight must be positive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cargo_weight
BEFORE INSERT OR UPDATE ON cargos
FOR EACH ROW
EXECUTE FUNCTION trg_check_cargo_weight();
```

``` sql
INSERT INTO cargos(cargo_id, weight, description)
VALUES (3001, 0, 'Паллет с товарами');
```

<img width="485" height="61" alt="Снимок экрана 2025-12-03 в 10 41 09" src="https://github.com/user-attachments/assets/fb5dbf8c-6054-4b10-826a-09fd3f4b1d5b" />

``` sql
UPDATE cargos
SET weight = -5
WHERE cargo_id = 6;
```

<img width="529" height="65" alt="Снимок экрана 2025-12-03 в 10 45 04" src="https://github.com/user-attachments/assets/7640144e-1389-4a9d-9827-3529c3dd5cb4" />

Авто-обновление mileage машины при поездке

``` sql
CREATE OR REPLACE FUNCTION trg_update_vehicle_mileage()
RETURNS trigger AS $$
DECLARE dist NUMERIC;
BEGIN
    SELECT distance_km INTO dist FROM routes WHERE route_id = NEW.route_id;

    UPDATE vehicles SET mileage = mileage + dist
    WHERE vehicle_id = NEW.vehicle_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trip_update_vehicle
AFTER INSERT ON trips
FOR EACH ROW
EXECUTE FUNCTION trg_update_vehicle_mileage();
```

``` sql
INSERT INTO trips(trip_id, route_id, vehicle_id, departure_datetime,  arrival_datetime, notes, driver_id)
VALUES (1, 3, 1, CURRENT_DATE, CURRENT_DATE + interval '1 day', 'no', 1);
```

<img width="793" height="68" alt="Снимок экрана 2025-12-03 в 10 51 58" src="https://github.com/user-attachments/assets/037ae08b-ed85-43c9-93cb-b2b16d939211" />

<img width="793" height="65" alt="Снимок экрана 2025-12-03 в 10 52 20" src="https://github.com/user-attachments/assets/640dd511-ceed-444e-b673-80cae4ea97eb" />


# statement level

Логирование массового обновления таблицы orders

``` sql
CREATE TABLE order_mass_update_log(
    updated_at TIMESTAMP DEFAULT now(),
    user_name TEXT
);
```

``` sql
CREATE OR REPLACE FUNCTION trg_log_mass_update_orders()
RETURNS trigger AS $$
BEGIN
    INSERT INTO order_mass_update_log(user_name)
    VALUES (current_user);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_mass_update
AFTER UPDATE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION trg_log_mass_update_orders();
```

``` sql
UPDATE orders
SET total_cost = total_cost * 1.05
WHERE status = 'Новый';
```

<img width="323" height="82" alt="Снимок экрана 2025-12-03 в 10 55 39" src="https://github.com/user-attachments/assets/9958ee26-3c7f-4db9-b1b1-66d91b57763d" />

<img width="325" height="63" alt="Снимок экрана 2025-12-03 в 10 55 44" src="https://github.com/user-attachments/assets/557e38d9-7078-452d-9191-4e59985e3517" />


Логирование массового удаления из cargos

``` sql
CREATE TABLE cargo_delete_batch_log(
    deleted_at TIMESTAMP DEFAULT now(),
    info TEXT
);

CREATE OR REPLACE FUNCTION trg_cargo_mass_delete()
RETURNS trigger AS $$
BEGIN
    INSERT INTO cargo_delete_batch_log(info)
    VALUES ('Mass delete on cargos table');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cargo_mass_delete_log
AFTER DELETE ON cargos
FOR EACH STATEMENT
EXECUTE FUNCTION trg_cargo_mass_delete();
```

<img width="281" height="83" alt="Снимок экрана 2025-12-03 в 10 57 21" src="https://github.com/user-attachments/assets/dfcb6a42-13cb-4ca0-8a70-e32613ce7627" />

<img width="397" height="67" alt="Снимок экрана 2025-12-03 в 10 57 50" src="https://github.com/user-attachments/assets/91dbaf1b-344c-4a44-ad1f-5222fbe25a3e" />


# Запрос на просмотр триггеров

``` sql
SELECT event_object_table,
       trigger_name,
       event_manipulation,
       action_timing,
       action_statement
FROM information_schema.triggers
ORDER BY event_object_table;
```

<img width="780" height="269" alt="image" src="https://github.com/user-attachments/assets/6e7a1184-56e5-435e-bea1-1a582f0d4dda" />

<img width="905" height="315" alt="Снимок экрана 2025-12-02 в 23 46 29" src="https://github.com/user-attachments/assets/bcbd0460-9235-4356-bbfa-5f46a332e194" />
