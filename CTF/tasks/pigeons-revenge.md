# PigeonsRevenge: стук портов, бэкдор Webmin и SETENV-инъекция

**Таск:** PigeonsRevenge (aclabs.pro, сезон 5, web/linux, 3 флага)
**Цепочка:** exiftool → port knocking → бэкдор Webmin → root в контейнере → ligolo → SSH → SETENV + инъекция через переменную окружения → root хоста.

## Разведка

Только 80, nginx — сайт с видео и «планом мести». Фаззинг пустой, и это сигнал: подсказка не в директориях. Метаданные видео — exiftool выдаёт код стука портов: 2, 8, 10.

```bash
sudo nmap -Pn -p 2,8,10 <ip>
sudo nmap -Pn -sV <ip>   # после стука открылся 10000 — Webmin 1.910
```

## Root в контейнере

Webmin 1.910 — бэкдор в `password_change.cgi` (CVE-2019-15107), unauth. Метасплойт `linux/http/webmin_backdoor` с `set ssl true` — реверс сразу uid=0. Но вокруг контейнер, флаг только первый.

## Пивот

В `/root/.bash_history` — попытка `ssh sparrow@172.18.0.1`. ligolo-ng в сеть докера, ssh под sparrow с паролем из сюжета таска. Флаг в home sparrow.

## SETENV-инъекция

`sudo -l`: `(root) SETENV: NOPASSWD: /usr/bin/pigeon_root --crumbs /root/root`. SETENV — можно пронести переменные окружения. Ghidra: бинарник берёт `PIGEON_SEEDS`, вырезает служебные символы и пробел, остаток уходит в `system()`. Пробел в фильтре есть, таба нет:

```bash
sudo PIGEON_SEEDS=$'cat\t/root/root' /usr/bin/pigeon_root --crumbs /root/root
```

Чтение флага — так. Полный рут — тем же способом со скриптом-реверсом в переменной.

## Как поймать

SETENV в sudoers — конфиг-ошибка уровня «зачем»: любое NOPASSWD с SETENV — это инъекция окружения к руту, диф sudoers должен алертиться сам. Port knocking в логах не виден — только во флоу трафика.

## Заметка

Два приёма в копилку. Первый: если фаззинг пустой — это не тупик, а намёк смотреть в метаданные и стилистику таска; exiftool раньше брута. Второй: таб — whitespace, который фильтры пропускают мимо глаз. И отдельное правило: строку sudoers читать до конца — одно слово SETENV в ней меняет всё.
