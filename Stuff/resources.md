# Ресурсы

Плагины, словари, утилиты и ссылки для повседневной работы. Оставляю то, чем пользуюсь, остальное убираю.

## Burp Suite

| Плагин | Зачем |
|---|---|
| Turbo Intruder | race conditions и single-packet attack. Мой шаблон гонки — в разборе [partial construction](../WriteUps/PortSwigger/labs/partial-construction-race.md) |
| Param Miner | поиск скрытых параметров и заголовков; дополняет перебор каталогов |
| Active Scan++ | дополнительные проверки встроенного сканера: кеш, DNS, заголовки |
| Collaborator Everywhere | добавляет OOB-пейлоады в проходящие запросы и помогает обнаружить внешние взаимодействия |

Collaborator для точечных проверок встроен в Burp Pro; в Community остаётся [interactsh](https://github.com/projectdiscovery/interactsh) из консоли.

## Словари

| Словарь | Когда |
|---|---|
| [SecLists](https://github.com/danielmiessler/SecLists) `raft-small-words` | первый проход по каталогам |
| SecLists `raft-large-words` | более широкий перебор, если малого словаря недостаточно и есть время |
| Burp `burp-parameter-names` | перебор параметров там, где Param Miner молчит |
| `rockyou` | только лабы и CTF |

## CyberChef

Часто используемые рецепты:

- **Magic** — предлагает варианты декодирования неизвестной строки.
- **From Base64url → JSON Beautify** — разобрать JWT по частям: смотрим структуру, не подпись.
- **From Hex → XOR** — деобфускация строк в макросах (стадия 4 в [Squid Game](../WriteUps/THM/squid-game.md)).
- **From Base64 → Gunzip → From Base64** — последовательное декодирование и распаковка шеллкода из того же разбора.

## Утилиты вне Burp

- `feroxbuster` — перебор каталогов; обёртка — [ferox-wrap.py](./scripts/ferox-wrap.py).
- `ffuf` — фаззинг параметров и значений.
- `sqlmap` — извлечение данных через уже найденную инъекцию (см. [sqli.md](./sqli.md)).
- `interactsh-client` — OOB-коллбеки без Burp.

## Ссылки

- [GTFOBins](https://gtfobins.github.io) / [LOLBAS](https://lolbas-project.github.io) — справочники по использованию штатных программ, в том числе для повышения привилегий; дополняют [lin-quick.sh](./scripts/lin-quick.sh) и [win-quick.ps1](./scripts/win-quick.ps1).
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) — когда нужен нестандартный пейлоад под конкретный фильтр.
- [HackTricks](https://book.hacktricks.xyz) — справочник для поиска по конкретной задаче.
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) — материалы и лабораторные работы по веб-безопасности.
- [CyberChef](https://gchq.github.io/CyberChef/) — веб-версия; для CTF без доступа к сети пригодится локальная копия.
