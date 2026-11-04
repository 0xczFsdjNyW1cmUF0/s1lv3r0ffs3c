# macOS Forensics: Artefacts — что macOS помнит о тебе

**Машина:** [macOS Forensics: Artefacts](https://tryhackme.com/room/macosforensicsartefacts) (hard, DFIR)
**Формат:** macOS-образ (`mac-disk.img`) анализируется с линуксовой VM. Монтирование APFS:

```bash
apfs-fuse -v 4 mac-disk.img ~/mac   # -v 4 — именно Data-том
```

## Артефакты по полочкам

- **Plist.** XML читается `cat`-ом, бинарные (BLOB) — только `plutil -p` на маке или `plistutil -p` на лине.
- **SQLite.** История чатов, браузера, usage приложений — всё в базах. DB Browser для ручного разбора, APOLLO — для таймлайна.
- **Терминал.** `~/.zsh_history` — до 1000 команд по порядку исполнения. Золото.
- **ASL-логи** в `/private/var/log/asl/` — логины, utmp/wtmp. В лине парсится через mac_apt (отдаёт CSV/JSON).
- **Использование приложений** — `knowledgeC.db` (пользовательский: `~/Library/Application Support/Knowledge/`, системный: `/private/var/db/CoreDuet/`): старт/стоп приложений, активность.
- **Файловая активность** — FSEvents: создание, удаление, rename, монтирование томов.
- **USB и монтированные образы** — `com.apple.finder.plist`, ключ `FXDesktopVolumesPositions`: флешки и DMG, которые видел Finder.
- **Bluetooth-аудио** — тоже из knowledgeC.db, удобно через модуль APOLLO `knowledge_audio_bluetooth_connected`.

## Заметка

Приятно было узнать, что на моём же маке всё это лежит открытым текстом и бинарниками — история команд, подключённые девайсы, что запускал и когда. Для форензика это сокровищница, для параноика — повод задуматься.
