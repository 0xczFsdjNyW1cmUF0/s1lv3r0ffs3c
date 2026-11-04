# THM WriteUps

Разборы машин с TryHackMe. Здесь только то, где был неочевидный ход или где сам застрял.

Список всех пройденных машин — в [`Certs/TryHackMe/rooms.md`](../../Certs/TryHackMe/rooms.md).

## Hard

- [Squid Game](./squid-game.md) — пять макродоков: oledump, vipermonkey, XOR, шеллкод
- [Management Wants a Word](./management-wants-a-word.md) — KAPE, NT-hash → DPAPI → Chrome → VeraCrypt, флаг в растрированном PDF
- [Python Playground](./python-playground.md) — `__import__`, shared mount `/mnt/log`, SUID
- [FAT32 Analysis](./fat32-analysis.md) — boot sector, E5-удаление, timestomping, slack space
- [HTTP/2 Request Smuggling](./http2-request-smuggling.md) — десинк на границе H2→H1, `Content-Length: 0`, h2c
- [macOS Forensics: Artefacts](./macos-forensics-artefacts.md) — APFS, zsh_history, knowledgeC.db, FSEvents

## Medium

- [Relevant](./relevant.md) — SMB-шара, которая оказалась веб-рутом; PrintSpoofer
- [Cactus](./cactus.md) — CVE-2022-46169: auth bypass + command injection в Cacti + детект в Kibana
- [0day](./0day.md) — Shellshock в CGI → kernel 3.13 (overlayfs)
- [ret2libc](./ret2libc.md) — первая ROP-цепочка: `pop rdi; ret`, system("/bin/sh")
- [Olympus](./olympus.md) — SQLi в старом CMS, SUID-бинарник, который сам приходит за пейлоадом
- [NoScope: Finding RCE](./noscope-rce.md) — обход песочницы Rhino через `returnClass`, эксфильтрация через лог расширения
