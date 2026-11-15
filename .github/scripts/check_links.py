#!/usr/bin/env python3
"""check_links.py — битые относительные ссылки в .md. Внешние http(s) не проверяем:
CI не судья, жив ли чужой сайт, а вот ссылка на комнату или заметку внутри репо
должна работать всегда."""
import os, re, sys

LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)\)')

bad = 0
for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d != '.git']
    for name in files:
        if not name.endswith('.md'):
            continue
        path = os.path.join(root, name)
        # fenced-блоки выкидываем: ссылки в коде — не ссылки
        text = re.sub(r'```.*?```', '', open(path, encoding='utf-8').read(), flags=re.S)
        for m in LINK.finditer(text):
            target = m.group(1)
            if re.match(r'^[a-zA-Z][a-zA-Z0-9+.-]*:', target) or target.startswith('#'):
                continue  # внешние схемы и якоря — мимо
            target = target.split('#')[0]
            if not target:
                continue
            full = os.path.normpath(os.path.join(os.path.dirname(path), target))
            if not os.path.exists(full):
                bad += 1
                print(f'BROKEN: {path} -> {target}')

print('links ok' if bad == 0 else f'{bad} broken links')
sys.exit(1 if bad else 0)
