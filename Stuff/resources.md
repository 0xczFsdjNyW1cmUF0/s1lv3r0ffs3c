# Ресурсы

Плагины, словари, утилиты и ссылки, которые реально в работе. Фильтр тот же, что и для скриптов: сюда попадает то, чем пользуюсь постоянно, остальное вычищаю.

## Burp Suite

| Плагин | Зачем |
|---|---|
| Turbo Intruder | race conditions и single-packet attack. Мой шаблон гонки — в разборе [partial construction](../WriteUps/PortSwigger/labs/partial-construction-race.md) |
| Param Miner | скрытые параметры и заголовки. Гонять до dirbusting — иногда находит больше, чем перебор каталогов |
| Active Scan++ | расширение встроенного сканера: кеш, DNS, каверзные заголовки |
| Collaborator Everywhere | OOB-коллбеки пассивно на весь трафик — ловит то, что руками забудешь проверить |

Collaborator для точечных проверок встроен в Burp Pro; в Community выручает [interactsh](https://github.com/projectdiscovery/interactsh) из консоли.

## Словари

| Словарь | Когда |
|---|---|
| [SecLists](https://github.com/danielmiessler/SecLists) `raft-small-words` | первый проход по директориям — быстрый и почти всегда достаточный |
| SecLists `raft-large-words` | если малый не дал ничего сочного, а время есть |
| Burp `burp-parameter-names` | перебор параметров там, где Param Miner молчит |
| `rockyou` | только лабы и CTF |

## CyberChef

Выручают конкретные рецепты, а не весь репертуар:

- **Magic** — первый заход на непонятную строку, сам угадывает цепочку декодирования.
- **From Base64url → JSON Beautify** — разобрать JWT по частям: смотрим структуру, не подпись.
- **From Hex → XOR** — деобфускация строк в макросах (стадия 4 в [Squid Game](../WriteUps/THM/squid-game.md)).
- **From Base64 → Gunzip → From Base64** — типовая матрёшка в шеллкодах оттуда же.

## Утилиты вне Burp

- `feroxbuster` — dirbusting, обёрнут в [ferox-wrap.py](./scripts/ferox-wrap.py).
- `ffuf` — фаззинг параметров и значений, когда dirbusting не то.
- `sqlmap` — добор данных по уже найденной инъекции (см. [sqli.md](./sqli.md)).
- `interactsh-client` — OOB-коллбеки без Burp.

## Ссылки

- [GTFOBins](https://gtfobins.github.io) / [LOLBAS](https://lolbas-project.github.io) — privesc через легитимные бинарники; пары для [lin-quick.sh](./scripts/lin-quick.sh) и [win-quick.ps1](./scripts/win-quick.ps1).
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) — когда нужен нестандартный пейлоад под конкретный фильтр.
- [HackTricks](https://book.hacktricks.xyz) — искать точечно, читать целиком бесполезно.
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) — единственный источник по вебу, который не протухает. Блог — в особенности.
- [CyberChef](https://gchq.github.io/CyberChef/) — как сайт; для CTF без сети держать локальную копию.
