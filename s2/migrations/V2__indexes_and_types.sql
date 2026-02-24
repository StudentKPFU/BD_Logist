BEGIN;

-- Расширение для текстового поиска / полезных функций
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Доп. таблица под обязательные типы: fulltext + jsonb + array + range
CREATE TABLE IF NOT EXISTS public.search_docs
(
    doc_id bigserial PRIMARY KEY,
    order_id integer NOT NULL REFERENCES public.orders(order_id) ON DELETE CASCADE,
    tags text[] NOT NULL DEFAULT '{}',                     -- массив
    meta jsonb NOT NULL DEFAULT '{}'::jsonb,               -- JSONB
    amount_range int4range,                                -- range-тип
    content text NOT NULL,                                 -- полный текст
    content_tsv tsvector GENERATED ALWAYS AS (to_tsvector('simple', content)) STORED
);

-- Индексы для производительности и разных сценариев выборки
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_client_id ON public.orders(client_id);

CREATE INDEX IF NOT EXISTS idx_order_logs_order_id ON public.order_logs(order_id);
CREATE INDEX IF NOT EXISTS idx_tracking_order_id ON public.tracking(order_id);

-- GIN для JSONB и fulltext
CREATE INDEX IF NOT EXISTS idx_search_docs_meta_gin ON public.search_docs USING GIN (meta);
CREATE INDEX IF NOT EXISTS idx_search_docs_tsv_gin ON public.search_docs USING GIN (content_tsv);
CREATE INDEX IF NOT EXISTS idx_search_docs_tags_gin ON public.search_docs USING GIN (tags);

-- Пример partial index для NULL (требование: 5–20% NULL в отдельных колонках)
-- delivery_date будет NULL у части заказов → индекс по "только с датой"
CREATE INDEX IF NOT EXISTS idx_orders_delivery_date_not_null
  ON public.orders(delivery_date)
  WHERE delivery_date IS NOT NULL;

COMMIT;