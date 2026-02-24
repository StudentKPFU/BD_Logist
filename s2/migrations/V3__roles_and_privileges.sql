-- V3__roles_and_privileges.sql

-- Flyway сам умеет транзакции; но BEGIN/COMMIT можно оставить.
BEGIN;

-- 1) роли
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app') THEN
    CREATE ROLE app LOGIN PASSWORD 'app_pass' CONNECTION LIMIT 10;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'readonly') THEN
    CREATE ROLE readonly LOGIN PASSWORD 'readonly_pass' CONNECTION LIMIT 10;
  END IF;
END $$;

-- 2) таймауты
ALTER ROLE app SET statement_timeout = '30s';
ALTER ROLE readonly SET statement_timeout = '30s';

-- 3) CONNECT на конкретную БД (ВАЖНО: имя, не функция)
GRANT CONNECT ON DATABASE "Logist" TO app, readonly;

-- 4) права на схему
GRANT USAGE ON SCHEMA public TO app, readonly;

-- 5) права на таблицы
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- 6) права на sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly;

-- 7) default privileges (для будущих объектов)
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT USAGE, SELECT ON SEQUENCES TO app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON SEQUENCES TO readonly;

-- 8) гигиена
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

COMMIT;