#!/usr/bin/env python3
"""pspy-local.py — детектор cron/запусков от рута без root-прав (аналог pspy, мини).
Сравнивает /etc/crontab и процессы, которые появляются, пока ты сидишь в шелле."""
import argparse, os, time

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

def main():
    p = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('-s', '--seconds', type=int, default=60,
                   help='сколько секунд ловить новые процессы (по умолчанию 60)')
    args = p.parse_args()

    print("[*] базовый слепок…"); base = snapshot()
    print(f"[*] {len(base)} процессов. Жду новые {args.seconds} сек (Ctrl+C стоп)…")
    try:
        end = time.time() + args.seconds
        seen = set()
        while time.time() < end:
            now = snapshot() - base
            new = now - seen
            for proc in sorted(new):
                owner = 'root?' if '/root' in proc else ''
                print(f"[+] {time.strftime('%H:%M:%S')} {owner} {proc[:150]}")
            seen |= new
            time.sleep(1)
    except KeyboardInterrupt:
        pass
    print("\n[*] crontab на всякий случай:"); os.system('cat /etc/crontab 2>/dev/null | grep -v "^#"')

if __name__ == '__main__':
    main()
