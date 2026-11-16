# Management Wants a Word: от хэша пароля до флага

**Машина:** [Management Wants a Word](https://tryhackme.com/room/hh-managementwantsaword-6bf3cc41) (hard, Windows DFIR, Hacker Holidays 2026)
**Формат:** KAPE-триаж с ноутбука сотрудницы Веры, 461 файл. Живая машина отсутствует — только артефакты.

## Первый поиск

Поиск `rg -i 'thm{'` по всему триажу ничего не дал. По описанной ниже цепочке к флагу ведут хэш пароля, DPAPI, сохранённый пароль Chrome и контейнер VeraCrypt. Это зависимые этапы, а не четыре независимых слоя шифрования.

## Цепочка

**1. Хэш пароля Веры из SAM.** В наборе есть файлы реестра SAM и SYSTEM, поэтому извлекаем хэш офлайн и подбираем пароль:

```bash
impacket-secretsdump -sam SAM -system SYSTEM LOCAL
# vera:1000:...:1241186a4aac4f34f4bf7ace71b396a8:::
john --format=nt --wordlist=/usr/share/wordlists/rockyou.txt nt.john
# minivera
```

**2. Мастер-ключ DPAPI.** Файл ключа находится в `AppData/Roaming/Microsoft/Protect/<SID>/`:

```bash
impacket-dpapi masterkey -file <blob> -sid <SID> -password minivera
```

**3. Пароль из Chrome.** В этом образе ключ AES браузера хранится в `Local State` и защищён DPAPI. Полученный мастер-ключ позволяет расшифровать его, затем — записи в `Login Data`. Среди них есть сохранённый пароль для внутреннего хоста.

**4. VeraCrypt.** Пароль из Chrome подходит к контейнеру на диске. Внутри — PDF с флагом в виде изображения, поэтому `strings` его не находит.

## Заметка

Ключевой шаг — связать артефакты: подобранный пароль открывает мастер-ключ DPAPI, тот — сохранённые пароли Chrome, а один из них — контейнер VeraCrypt. Само шифрование здесь не взламывается.
