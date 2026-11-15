#!/usr/bin/env python3
"""ferox-wrap.py — умный брутфорс директорий: сначала быстрый общий список, потом углубление
только в найденные подпути. Обёртка над feroxbuster, чтобы не рожать лишний трафик."""
import argparse, re, subprocess

def main():
    p = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('url', help='стартовая точка, со слэшем или без')
    p.add_argument('wordlist', help='словарь для feroxbuster')
    p.add_argument('depth', nargs='?', type=int, default=2,
                   help='на сколько уровней углубляться (по умолчанию 2)')
    args = p.parse_args()

    found = set()

    def scan(target, depth):
        if depth > args.depth: return
        print(f"\n[*] scan {target} (depth {depth})")
        out = subprocess.run(
            ["feroxbuster", "-u", target, "-w", args.wordlist, "-t", "50", "--silent",
             "-s", "200,301,302,403", "--depth", "1"],
            capture_output=True, text=True).stdout
        for line in out.splitlines():
            m = re.match(r"(https?://\S+)", line)
            if not m: continue
            url = m.group(1).rstrip("/")
            if url in found or url == target.rstrip("/"): continue
            found.add(url)
            status = re.search(r"\[(\d{3})\]", line)
            print(f"  [{status.group(1) if status else '???'}] {url}")
            scan(url + "/", depth + 1)

    scan(args.url.rstrip("/") + "/", 1)
    print(f"\n[+] найдено {len(found)} путей")

if __name__ == '__main__':
    main()
