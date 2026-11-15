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

## Как поймать

- userenum: волна 4768 с одного source IP и статусом 0x6 (юзера нет). NTLM-перебор светится в 4771/4776, а Kerberos-энумерация по умолчанию часто не логируется вообще — потому её и любят. Аудит 4768 включать, считать по источнику.
- ASREPRoast: 4768 без pre-auth и с etype 0x17 (RC4) — аккаунт отдал ASREP, зашифрованный собственным хэшем, прямо в чужие руки.
- DCSync: 4662 на объекте домена с правами Replication Get Changes (GUID 1131f6aa / 1131f6ad) от аккаунта, который не контроллер. Репликация — работа DC, всё остальное — secretsdump.
- PtH: 4624 Logon Type 3 с NTLM от аккаунтов, которым положен Kerberos. От легитимного NTLM-логона почти не отличить — в этом и живучесть техники.

## Заметка

Классическая «дорожная карта AD» в миниатюре: enum юзеров → roast → DCSync. Одна ошибка конфигурации (pre-auth off) ведёт к полному домену, потому что дальше всё едет по инерции. Именно поэтому ASREPRoast — первое, что я проверяю на любом новом домене.
