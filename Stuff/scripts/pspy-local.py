#!/usr/bin/env python3
"""pspy-local.py — детектор cron/запусков от рута без root-прав (аналог pspy, мини).
Сравнивает /etc/crontab и процессы, которые появляются, пока ты сидишь в шелле."""
import os, time, subprocess, sys

def snapshot():
    out = set()
    try:
        for pid in filter(str.isdigit, os.listdir('/proc')):
            with open(f'/proc/{pid}/cmdline','rb') as f:
                cmd = f.read().replace(b'\0',b' ').decode(errors='ignore').strip()
            if cmd: out.add(cmd)
    except PermissionError:
        pass
    return out

print("[*] базовый слепок…"); base = snapshot()
print(f"[*] {len(base)} процессов. Жду новые 60 сек (Ctrl+C стоп)…")
try:
    end = time.time() + 60
    seen = set()
    while time.time() < end:
        now = snapshot() - base
        new = now - seen
        for p in sorted(new):
            owner = 'root?' if '/root' in p else ''
            print(f"[+] {time.strftime('%H:%M:%S')} {owner} {p[:150]}")
        seen |= new
        time.sleep(1)
except KeyboardInterrupt:
    pass
print("\n[*] crontab на всякий случай:"); os.system('cat /etc/crontab 2>/dev/null | grep -v "^#"')
