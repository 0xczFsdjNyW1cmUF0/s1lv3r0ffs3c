# Публичные разборы ACLabs

Разборы сезонов, в которых я участвовал, и материалы по платформе. Сохраняю их, чтобы сравнивать решения и возвращаться к отдельным техникам. На основе этих публикаций написаны конспекты в [tasks/](./tasks/); описание прохождения в них относится к автору источника.

## S7 — июнь 2026

- [GhostBusters — райтап простой машины от Aclabs.pro](https://habr.com/ru/articles/1076134), автор seobuster — SQLi в Content API → RCE через тему → эксплуатация уязвимости ядра → служба выдачи флагов. Источник для [tasks/ghostbusters.md](./tasks/ghostbusters.md).
- «Капибары и CTF» ([@capybaras_ctf](https://t.me/capybaras_ctf)) — публичные анонсы S7; сами видеоразборы доступны в закрытой группе.

## S6 — весна 2026

- [SaveWalterWhite — прохождение простой машины на платформе Aclabs.pro](https://habr.com/ru/articles/1046229), автор seobuster — LFI → RFI → RCE, резервная копия Borg, привилегированный контейнер. Источник для [tasks/savewalterwhite.md](./tasks/savewalterwhite.md).

## Сезон не указан в источнике

- [Bank — сложная машина со взломом пин-кода, пивотингом и побегом из контейнера](https://habr.com/ru/articles/1085490), автор seobuster — Windows DC → Server Operators → перебор PIN-кода как ключа HMAC → ProFTPD → docker.sock; видеоразбор — Mr. Exploit. Источник для [tasks/bank.md](./tasks/bank.md).

## S5 — весна 2026

- [Как наказать цифрового воробья — таск 5 сезона CTF на ACLabs](https://habr.com/ru/articles/1024360), автор seobuster — port knocking по подсказке в метаданных → Webmin CVE-2019-15107 → инъекция команд через переменную окружения. Источник для [tasks/pigeons-revenge.md](./tasks/pigeons-revenge.md).

## S3 и S4 — публичных разборов не нашёл

По S3 (11 тасков, 80+ участников) и S4 публичных разборов не нашёл. Сохранил официальные страницы: [S3-2025](https://aclabs.pro/seasons/S3-2025), [S4-2025](https://aclabs.pro/seasons/S4-2025). Если приведу свои заметки по этим сезонам в порядок, добавлю их в tasks/.

## Официальные материалы ACLabs

- [YouTube: Tunneling, pivoting, port forwarding on aclabs.pro](https://www.youtube.com/watch?v=ltVCYcNs1YQ), канал [Mister Exploit](https://www.youtube.com/channel/UC9w9Jz31ec-TP8NZDiN2erA)
- [Boosty ACLabs: туннелирование, пивотинг, проброс портов](https://boosty.to/aclabs/posts/c9630366-dca6-4763-be31-a9976e01d8f4)
- [CTF от Aclabs? Не, не слышал](https://habr.com/ru/articles/1003642) — обзор платформы
- Результаты сезонов: [aclabs.pro/results](https://aclabs.pro/results)

Закрытые разборы здесь не пересказываю. Ссылки на анонсы не означают, что сами материалы доступны публично.
