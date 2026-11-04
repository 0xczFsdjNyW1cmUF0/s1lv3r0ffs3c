# Management Wants a Word: четыре слоя шифрования до флага

**Машина:** [Management Wants a Word](https://tryhackme.com/room/hh-managementwantsaword-6bf3cc41) (hard, Windows DFIR, Hacker Holidays 2026)
**Формат:** KAPE-триаж с ноутбука сотрудницы Веры, 461 файл. Живая машина отсутствует — только артефакты.

## Старт и облом

Первый инстинкт — `rg -i 'thm{'` по всему триажу. Ноль. Флаг не лежит в открытом виде нигде, потому что закопан под четыре независимых слоя защиты, и каждый артефакт в дампе — ступенька вниз. Это и есть вся мораль комнаты.

## Цепочка

**1. Креды Веры из SAM.** Hive'ы на месте, значит всё офлайн:

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
# vera:1000:...:1241186a4aac4f34f4bf7ace71b396a8:::
john --format=nt --wordlist=/usr/share/wordlists/rockyou.txt nt.john
# minivera
```

**2. DPAPI master key.** Блоб под `AppData/Roaming/Microsoft/Protect/<SID>/`:

```bash
impacket-dpapi masterkey -file <blob> -sid <SID> -password minivera
```

**3. Пароль из Chrome.** Ключ AES браузера в `Local State`, завёрнут в DPAPI — с мастер-ключом разворачивается. Дальше скриптом: тянем ключ, расшифровываем `Login Data` → сохранённый логин к внутреннему хосту. Именно то, о чём говорила подсказка: «браузер помнит то, что ты ему не говорил».

**4. VeraCrypt.** Контейнер на диске + пароль из Chrome. Флаг внутри, причём в PDF — растрирован, то есть даже после открытия контейнера `strings`-ом его не достать.

## Заметка

Красиво, что каждый слой защиты здесь легитимный и повседневный: NT-hash → DPAPI → Chrome AES → VeraCrypt. Все они по отдельности нормально стоят, и весь взлом — это не победа над криптой, а правильный порядок компоновки того, что утекло.
