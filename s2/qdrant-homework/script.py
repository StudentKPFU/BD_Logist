from qdrant_client import QdrantClient
from qdrant_client.models import (
    Distance, VectorParams, PointStruct, Filter,
    FieldCondition, MatchValue, Range, DatetimeRange
)
import random

# Подключение по внутреннему имени сервиса Docker Compose
client = QdrantClient(url="http://qdrant:6333")
collection_name = "articles"

# ==========================================
# 1. ПОДГОТОВКА ДАННЫХ
# ==========================================
print("Подключение успешно. Создаем коллекцию...")

# ИСПРАВЛЕНИЕ 1: Правильный способ пересоздания коллекции по новым стандартам
if client.collection_exists(collection_name=collection_name):
    client.delete_collection(collection_name=collection_name)

client.create_collection(
    collection_name=collection_name,
    vectors_config=VectorParams(size=384, distance=Distance.COSINE),
)

articles_data = [
    {"id": 1, "title": "Новые кроссовки для марафона", "content": "Обзор обуви...", "author": "Ivan", "category": "sport", "published_at": "2024-02-15T10:00:00Z", "views": 1500, "rating": 4.5},
    {"id": 2, "title": "Релиз нового процессора", "content": "Характеристики чипа...", "author": "Alex", "category": "tech", "published_at": "2024-01-20T12:00:00Z", "views": 5500, "rating": 4.8},
    {"id": 3, "title": "Как начать бегать", "content": "Советы новичкам...", "author": "Maria", "category": "sport", "published_at": "2023-11-05T08:00:00Z", "views": 3000, "rating": 4.2},
    {"id": 4, "title": "ИИ пишет код", "content": "Нейросети в программировании...", "author": "Alex", "category": "tech", "published_at": "2024-03-01T15:00:00Z", "views": 800, "rating": 3.9},
    {"id": 5, "title": "Итоги выборов", "content": "Результаты голосования...", "author": "Anna", "category": "news", "published_at": "2024-02-28T09:00:00Z", "views": 12000, "rating": 3.0},
    {"id": 6, "title": "Гаджеты для тренировок", "content": "Пульсометры и часы...", "author": "Ivan", "category": "tech", "published_at": "2024-01-10T14:00:00Z", "views": 2500, "rating": 4.1},
]

points = []
for article in articles_data:
    points.append(PointStruct(
        id=article["id"],
        vector=[random.random() for _ in range(384)],
        payload=article
    ))

client.upsert(collection_name=collection_name, points=points)
print("Данные успешно вставлены.")

# ==========================================
# 2. ИНДЕКСЫ
# ==========================================
client.create_payload_index(collection_name, field_name="category", field_schema="keyword")
client.create_payload_index(collection_name, field_name="rating", field_schema="float")
client.create_payload_index(collection_name, field_name="published_at", field_schema="datetime")
client.create_payload_index(collection_name, field_name="views", field_schema="integer")
print("Индексы созданы.\n")

# ==========================================
# 3. ПОИСК
# ==========================================
query_vector = [random.random() for _ in range(384)]

# ИСПРАВЛЕНИЕ 2: Используем query_points вместо search, аргумент называется 'query' вместо 'query_vector',
# и обращаемся к свойству .points для получения массива результатов.

print("--- Запрос 1: Простой поиск (топ-3) ---")
res1 = client.query_points(collection_name=collection_name, query=query_vector, limit=3).points
for r in res1: print(f"ID: {r.id}, Title: {r.payload['title']}, Score: {r.score:.4f}")

print("\n--- Запрос 2: Категория 'tech' и рейтинг >= 4.0 ---")
res2 = client.query_points(
    collection_name=collection_name, query=query_vector,
    query_filter=Filter(must=[
        FieldCondition(key="category", match=MatchValue(value="tech")),
        FieldCondition(key="rating", range=Range(gte=4.0))
    ]), limit=5
).points
for r in res2: print(f"ID: {r.id}, Title: {r.payload['title']}, Rating: {r.payload['rating']}")

print("\n--- Запрос 3: Дата после 2024-01-01 и просмотры > 1000 ---")
res3 = client.query_points(
    collection_name=collection_name, query=query_vector,
    query_filter=Filter(must=[
        FieldCondition(key="published_at", range=DatetimeRange(gte="2024-01-01T00:00:00Z")),
        FieldCondition(key="views", range=Range(gt=1000))
    ]), limit=5
).points
for r in res3: print(f"ID: {r.id}, Title: {r.payload['title']}, Date: {r.payload['published_at']}, Views: {r.payload['views']}")

print("\n--- Запрос 4: Сложный фильтр ---")
res4 = client.query_points(
    collection_name=collection_name, query=query_vector,
    query_filter=Filter(
        should=[
            FieldCondition(key="category", match=MatchValue(value="sport")),
            FieldCondition(key="category", match=MatchValue(value="tech"))
        ],
        must=[
            FieldCondition(key="rating", range=Range(gte=3.5)),
            FieldCondition(key="views", range=Range(gte=500, lte=5000))
        ]
    ), limit=5
).points
for r in res4: print(f"ID: {r.id}, Title: {r.payload['title']}, Category: {r.payload['category']}, Score: {r.score:.4f}")
