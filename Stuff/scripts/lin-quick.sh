#!/usr/bin/env bash
# lin-quick.sh — быстрая разведка Linux после шелла. Запускать bash lin-quick.sh | tee enum.txt
# Ищет самое сочное: sudo, SUID, креды в конфигах, world-writable, cron, capabilities.
set -u

H(){ echo; echo "===== $* ====="; }

H "KERNEL / OS"; uname -a; cat /etc/os-release 2>/dev/null | head -3
H "USER / GROUPS"; id; echo "sudo -l:"; sudo -ln 2>&1 | head -20

H "SUID / SGID (не стандартные)"
find / -perm -4000 -type f 2>/dev/null | grep -vE '^/(usr/)?s?bin|/proc' | head -30

H "SUDO-обходники из GTFOBins (частые)"
for b in find vim nano less awk nmap perl python python3 tar git env man rsync cpulimit; do
  command -v $b >/dev/null && sudo -ln 2>/dev/null | grep -q "(root) NOPASSWD: .*$b" && echo "!! sudo NOPASSWD: $b"
done

H "CAPABILITIES"
command -v getcap >/dev/null && getcap -r / 2>/dev/null | grep -vE 'none' | head -20

H "КРЕДЫ В ФАЙЛАХ"
grep -rliE 'pass(word)?|secret|token' /etc /opt /home /var/www 2>/dev/null | head -20
ls -la ~ 2>/dev/null | grep -E 'history|ssh|aws|kube'

H "CRON"
cat /etc/crontab 2>/dev/null; ls -la /etc/cron* 2>/dev/null

H "WORLD-WRITABLE В PATH И НЕ ТОЛЬКО"
find / -writable -type f 2>/dev/null | grep -vE '^/(proc|sys|dev)' | head -20

H "СЕТЬ / ПРОЦЕССЫ"
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null | head -20
ps aux --sort=-%cpu 2>/dev/null | head -10

H "DOCKER / LXD"
id | grep -q docker && echo "!! в группе docker"; id | grep -q lxd && echo "!! в группе lxd"
[ -S /var/run/docker.sock ] && echo "!! docker.sock доступен"

H "МОНТЫ / NFS"
cat /etc/exports 2>/dev/null; mount | grep -E 'nfs|cifs' 
