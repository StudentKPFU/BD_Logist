
``` sql
CREATE TYPE task_status AS ENUM ('Ready', 'Running', 'Completed', 'Failed');

CREATE TABLE shipments (
    id serial PRIMARY KEY,
    destination text,
    created_at timestamp DEFAULT now()
);

CREATE TABLE tasks (
    id serial PRIMARY KEY,
    shipment_id int REFERENCES shipments(id),
    priority int DEFAULT 0,
    status task_status DEFAULT 'Ready',
    attempts int DEFAULT 0,
    created_at timestamp DEFAULT now(),
    scheduled_at timestamp DEFAULT now(),
    updated_at timestamp DEFAULT now()
);

CREATE INDEX idx_tasks_queue ON tasks (status, priority DESC, scheduled_at ASC) 
WHERE status = 'Ready';

ALTER TABLE tasks SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_scale_factor = 0.01,
    autovacuum_vacuum_threshold = 50,
    autovacuum_analyze_threshold = 50
);
```

``` csharp
using System;  
using System.Threading;  
using System.Threading.Tasks;  
using Npgsql;  
  
namespace PgQueueApplication  
{  
    class Program  
    {  
        private const string ConnString = "Host=localhost;Port=5434;Username=admin;Password=admin;Database=logist_db";  
  
        static async Task Main(string[] args)  
        {  
            Console.WriteLine("Выберите режим: [1] Producer (Продюсер), [2] Consumer (Воркер)");  
            var input = Console.ReadLine();  
  
            if (input == "1") await RunProducer();  
            else if (input == "2") await RunConsumer();  
        }  
  
        static async Task RunProducer()  
        {  
            Console.WriteLine("Продюсер запущен. Генерируем задачи...");  
            var rnd = new Random();  
            using var conn = new NpgsqlConnection(ConnString);  
            await conn.OpenAsync();  
  
            while (true)  
            {  
                using var tx = await conn.BeginTransactionAsync();  
                try  
                {  
                    using var cmdShipment = new NpgsqlCommand("INSERT INTO shipments (destination) VALUES ('Склад А') RETURNING id;", conn, tx);  
                    var shipmentId = (int)await cmdShipment.ExecuteScalarAsync();  
  
                    int priority = rnd.Next(100) < 20 ? 100 : 0;  
                      
                    using var cmdTask = new NpgsqlCommand("INSERT INTO tasks (shipment_id, priority) VALUES (@s_id, @p);", conn, tx);  
                    cmdTask.Parameters.AddWithValue("s_id", shipmentId);  
                    cmdTask.Parameters.AddWithValue("p", priority);  
                    await cmdTask.ExecuteNonQueryAsync();  
  
                    using var cmdNotify = new NpgsqlCommand("NOTIFY new_task;", conn, tx);  
                    await cmdNotify.ExecuteNonQueryAsync();  
  
                    await tx.CommitAsync();  
                }  
                catch  
                {  
                    await tx.RollbackAsync();  
                }  
                Thread.Sleep(10); // Интенсивная генерация  
            }  
        }  
  
        static async Task RunConsumer()  
        {  
            Console.WriteLine("Воркер запущен. Ожидание задач...");  
            var rnd = new Random();  
            using var conn = new NpgsqlConnection(ConnString);  
            await conn.OpenAsync();  
  
            conn.Notification += (o, e) => { };  
            using (var cmd = new NpgsqlCommand("LISTEN new_task;", conn))  
            {  
                await cmd.ExecuteNonQueryAsync();  
            }  
  
            while (true)  
            {  
                var fetchSql = @"  
                    UPDATE tasks                    SET status = 'Running', updated_at = now()  
                    WHERE id = (                        SELECT id FROM tasks                        WHERE status = 'Ready' AND scheduled_at <= now()   
                        ORDER BY priority DESC, scheduled_at ASC   
                        FOR UPDATE SKIP LOCKED   
                        LIMIT 1  
                    )                    RETURNING id, priority, attempts;";  
  
                int? taskId = null;  
                int attempts = 0;  
  
                using (var cmd = new NpgsqlCommand(fetchSql, conn))  
                using (var reader = await cmd.ExecuteReaderAsync())  
                {  
                    if (await reader.ReadAsync())  
                    {  
                        taskId = reader.GetInt32(0);  
                        attempts = reader.GetInt32(2);  
                    }  
                }  
  
                if (taskId.HasValue)  
                {  
                    Thread.Sleep(10); // Имитация обработки груза  
                    if (rnd.Next(100) > 5)  
                    {  
                        using var cmdFinish = new NpgsqlCommand("UPDATE tasks SET status = 'Completed', updated_at = now() WHERE id = @id", conn);  
                        cmdFinish.Parameters.AddWithValue("id", taskId.Value);  
                        await cmdFinish.ExecuteNonQueryAsync();  
                        Console.WriteLine($"Задача {taskId.Value} успешно обработана.");  
                    }  
                    else  
                    {  
                        attempts++;  
                        using var cmdFail = new NpgsqlCommand(  
                            "UPDATE tasks SET status = 'Ready', attempts = @a, scheduled_at = now() + (interval '1 minute' * @a), updated_at = now() WHERE id = @id", conn);  
                        cmdFail.Parameters.AddWithValue("a", attempts);  
                        cmdFail.Parameters.AddWithValue("id", taskId.Value);  
                        await cmdFail.ExecuteNonQueryAsync();  
                        Console.WriteLine($"Ошибка обработки задачи {taskId.Value}. Отложена на повтор.");  
                    }  
                }  
                else  
                {  
                    await conn.WaitAsync(TimeSpan.FromSeconds(1));  
                }  
            }  
        }  
    }  
}
```

<img alt="screen" src="img/Снимок экрана 2026-05-20 в 02.40.31.png" />
