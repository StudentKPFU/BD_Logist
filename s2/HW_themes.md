ClickHouse
<img alt="screen" src="img/Снимок экрана 2026-05-05 в 22.08.15.png" />


Cassandra

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 23.21.15.png" />

``` sql
INSERT INTO users_by_id (user_id, email, name) 
VALUES (123e4567-e89b-12d3-a456-426614174000, 'test@example.com', 'Alex');

INSERT INTO users_by_email (email, user_id, name) 
VALUES ('test@example.com', 123e4567-e89b-12d3-a456-426614174000, 'Alex');

SELECT * FROM users_by_id WHERE user_id = 123e4567-e89b-12d3-a456-426614174000; 
SELECT * FROMusers_by_email WHERE email = 'test@example.com';

UPDATE users_by_id SET name = 'Alexander' WHERE user_id = 123e4567-e89b-12d3-a456-426614174000; 
UPDATE users_by_email SET name = 'Alexander' WHERE email = 'test@example.com';

DELETE FROM users_by_email WHERE email = 'test@example.com';
```

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 23.39.46.png" />

ожидаемая ошибка

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 23.45.28.png" />

проверка отказоустойчивости

``` shell
docker stop cassandra3
```

после отключения

<img alt="screen" src="img/Снимок экрана 2026-05-05 в 23.55.23.png" />
ElasticSearch

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 00.22.58.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 00.23.12.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 00.23.20.png" />

InfluxDB

``` shell
curl -X POST "http://localhost:8181/api/v2/write?org=myorg&bucket=mydb" \
  -H "Authorization: Bearer my-super-secret-token" \
  -H "Content-Type: text/plain; charset=utf-8" \
  --data-raw "temperature,location=room1 value=23
temperature,location=room2 value=21
temperature,location=room1 value=24
temperature,location=room2 value=22"
```


``` sql
SELECT * FROM "temperature" 
WHERE time >= now() - interval '5 minutes';
```

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 01.45.54.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 01.45.58.png" />

``` sql
SELECT 
    location, 
    AVG(value) as avg_temperature 
FROM "temperature" 
WHERE time >= now() - interval '5 minutes' 
GROUP BY location;
```

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 01.46.06.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 01.46.10.png" />


MongoDB

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.02.55.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.03.03.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.03.12.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.03.19.png" />

Neo4j

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.22.00.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.22.23.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.22.53.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.24.22.png" />


<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.24.36.png" />


<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.24.47.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.25.32.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.25.49.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.26.03.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.26.19.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.26.33.png" />

Qdrant

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 02.54.10.png" />

Redis

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 08.31.02.png" />

<img alt="screen" src="img/Снимок экрана 2026-05-06 в 08.31.17.png" />


<img alt="screen" src="img/Снимок экрана 2026-05-06 в 08.32.14.png" />

