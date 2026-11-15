# CTF

Участие в соревнованиях Capture The Flag. Основная площадка — [ACLabs.pro](https://aclabs.pro): сезонные CTF с динамическими флагами (флаг уникален для каждого запуска машины, копировать чужие бессмысленно), индивидуальные машины на каждого участника и убывающая стоимость флага со временем.

**Содержание:** [сезоны](#aclabs-топ-10-сезонов) · [разборы](#разборы) · [прочее](#прочее)

## ACLabs: топ-10 сезонов

| Сезон | Даты | Место | Очки |
|---|---|---|---|
| [S3](https://aclabs.pro/seasons/S3-2025) | 17–26.10.2025 | **1** 🥇 | 12 336.86 |
| [S4](https://aclabs.pro/seasons/S4-2025) | 12–24.12.2025 | 5 | 10 312.72 |
| [S7](https://aclabs.pro/seasons/S7-2026) | 12–19.06.2026 | 8 | 6 877.76 |

Профиль на платформе: [s1lv3r](https://aclabs.pro/profile). Всего участий — 6 сезонов подряд, в трёх из них топ-10.

S3 запомнился тем, что выиграл всухую, S7 был самым жёстким по составу заданий — AD, Windows, tunneling, без лёгких OSINT/GEOINT.

## Разборы

Таски, где был неочевидный ход. Формат тот же, что в THM: суть → вектор → заметка, флагов нет. Цепочки взяты из публичных разборов — источники и авторы в [readings.md](./readings.md).

- **S7** — [GhostBusters](./tasks/ghostbusters.md) — Ghost CMS: SQLi → RCE через тему → kernel exploit → бинарник-мониторинг, отдающий флаги за поведение
- **S6** — [SaveWalterWhite](./tasks/savewalterwhite.md) — LFI → RFI/RCE → sudo-скрипты → Borg с пассфразой в MySQL → privileged-контейнер
- [Bank](./tasks/bank.md) — сезон не помечен в разборе: Windows DC → Server Operators → HMAC-пин → ProFTPD → docker.sock
- **S5** — [PigeonsRevenge](./tasks/pigeons-revenge.md) — port knocking из exiftool → бэкдор Webmin → ligolo → SETENV-инъекция через таб

## Прочее

- [CyberYozh Advanced Cyber Labs CTF](../Certs/CyberYozh/) — октябрь 2025, диплом в сертификатах.
