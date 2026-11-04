#!/usr/bin/env python3
"""ferox-wrap.py — умный брутфорс директорий: сначала быстрый общий список, потом углубление
только в найденные подпути. Обёртка над feroxbuster, чтобы не рожать лишний трафик."""
import subprocess, sys, re

if len(sys.argv) < 3:
    print("usage: ferox-wrap.py URL wordlist [depth=2]")
    sys.exit(1)

URL, WORDLIST = sys.argv[1], sys.argv[2]
DEPTH = int(sys.argv[3]) if len(sys.argv) > 3 else 2

found = set()

def scan(target, depth):
    if depth > DEPTH: return
    print(f"\n[*] scan {target} (depth {depth})")
    out = subprocess.run(
        ["feroxbuster", "-u", target, "-w", WORDLIST, "-t", "50", "--silent",
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

scan(URL.rstrip("/") + "/", 1)
print(f"\n[+] найдено {len(found)} путей")
