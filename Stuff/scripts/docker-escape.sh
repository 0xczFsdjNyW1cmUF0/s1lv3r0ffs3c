#!/usr/bin/env bash
# docker-escape.sh — разведка контейнера после шелла: контейнер ли это вообще
# и какие двери наружу не закрыты. В lxc и подах k8s то же самое.
# Запускать: bash docker-escape.sh | tee enum.txt
set -u

H(){ echo; echo "===== $* ====="; }

H "КОНТЕЙНЕР ЛИ ЭТО"
[ -f /.dockerenv ] && echo "!! /.dockerenv на месте"
grep -E 'docker|kubepods|containerd|lxc' /proc/1/cgroup 2>/dev/null | head -2
# pid 1 — приложение, а не systemd? значит, изоляция есть, но она тонкая

H "CAPABILITIES"
if command -v capsh >/dev/null 2>&1; then
  capsh --print 2>/dev/null | grep -E 'Current:|Bounding'
else
  grep -E 'CapEff|CapBnd' /proc/self/status
fi
# privileged = 000001ffffffffff. Одиночные, за которые дают побег:
# cap_sys_admin (mount/release_agent/cgroup), cap_sys_ptrace, cap_dac_read_search, cap_net_admin

H "DOCKER.SOCK"
[ -S /var/run/docker.sock ] && echo "!! sock живой: curl --unix-socket /var/run/docker.sock http://localhost/info"
# дальше — свой контейнер с / хоста в /host и chroot

H "ЧУЖИЕ ПРОЦЕССЫ (pid namespace)"
ps aux 2>/dev/null | head -8
# видны процессы хоста или соседних контейнеров = namespace не изолирован

H "МОНТЫ ХОСТА"
grep -vE 'proc|sysfs|tmpfs|cgroup|devpts|mqueue|shm|overlay' /proc/mounts 2>/dev/null | head -12
# смонтированный / или /etc с хоста — конец игры

H "DEV / SYS"
# нужен список с правами, find тут не то
# shellcheck disable=SC2010
ls -la /dev 2>/dev/null | grep -vE 'null|zero|full|tty|pts|shm|random|urandom|fd' | head -10
fdisk -l 2>/dev/null | grep '^Disk /' | head -5
[ -w /sys/fs/cgroup/release_agent ] && echo "!! release_agent доступен на запись (cgroup v1 + cap_sys_admin)"

H "K8S SERVICEACCOUNT"
SA=/var/run/secrets/kubernetes.io/serviceaccount
[ -d "$SA" ] && echo "!! токен на месте: namespace $(cat "$SA/namespace" 2>/dev/null) — дальше kubectl с этим токеном"

H "ENV"
env 2>/dev/null | grep -iE 'docker|kube|token|secret|pass|key' | head -10
