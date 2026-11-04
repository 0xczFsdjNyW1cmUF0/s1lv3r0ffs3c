# NoScope: Finding RCE — обход песочницы через `returnClass`

**Машина:** [NoScope: Finding RCE](https://tryhackme.com/room/noscoperce) (medium, web, CVE-2026-35482)
**Платформа:** Alf.io (Java/Spring Boot), админка `/admin`, креды выданы в задании.

## Уязвимость

Alf.io позволяет админу писать JS-расширения на события платформы. Исполняются они в песочнице Mozilla Rhino + валидация скрипта по deny-листу: режутся `java.lang.Runtime`, ключевые слова рефлексии и т.п.

Сломанная модель: песочница кладёт в scope живой объект `returnClass` (нужен движку для десериализации возврата). У него — метод `forName(String)`, унаследованный от `java.lang.Class`. А класс, спрятанный в строковом литерале, deny-лист не видит:

```javascript
var rt = returnClass.forName('java.lang.Runtime');
var s  = returnClass.forName('java.String');
var r  = rt.getMethod('getRuntime').invoke(null);
rt.getMethod('exec', s).invoke(r, 'id');
```

Песочница по списку слов ≠ песочница по возможностям.

## Доставка

Всё по HTTP через админ API:

1. GET на `/admin/api/*` — сеет куки `XSRF-TOKEN` и сессию.
2. POST `/authenticate` с логином/паролем и заголовком `X-CSRF-TOKEN` — 302 = вошли.
3. POST `/admin/api/extensions` ровно с телом `{path, name, enabled, script}`. Лишнее поле — 404, протухший токен — 403.
4. `path: "-"` (global scope), подписка на `EVENT_STATUS_CHANGE`. Меняем статус события — скрипт стреляет.

## Финт с эксфильтрацией

Реверс-шелл не открылся — egress с машины фильтруется, wget наружу не достаёт. Выход: эксфильтроваться через то, что уже читается. Если расширение бросает исключение, Alf.io пишет значение в лог выполнения, а `GET /admin/api/extensions/log` его отдаёт. Значит, payload читает `flag.txt` и `throw`-ит содержимое — флаг приезжает в лог по тому же API.

## Заметка

Два урока. Первый: любой биндинг, резолвящий классы по строке, убивает deny-лист — sandbox на возможностях, не на написании. Второй: RCE и эксфильтрация — разные задачи. Когда обратный коннект не открывается, ищи канал, который приложение уже выдаёт само (логи, ответы, ошибки).
