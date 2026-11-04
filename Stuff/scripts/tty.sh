#!/usr/bin/env bash
# tty.sh — апгрейд кривого шелла в полноценный. Выполнять НА жертве.
# свалится после Ctrl+C в старом шелле — пережить можно, сразу экспортировать TERM.
cat <<'EOF'
# --- в шелле жертвы ---
python3 -c 'import pty;pty.spawn("/bin/bash")'
# или: script -qc /bin/bash /dev/null
# --- на своей стороне (Ctrl+Z вернёт в свой терминал) ---
stty raw -echo; fg
# --- вернулся в шелл жертвы: ---
export TERM=xterm
stty rows $(tput lines) cols $(tput cols)
EOF
