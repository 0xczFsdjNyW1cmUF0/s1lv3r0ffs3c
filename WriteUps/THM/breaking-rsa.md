# Breaking RSA: факторизация Ферма против кривой генерации ключей

**Машина:** [Breaking RSA](https://tryhackme.com/room/breakingrsa) (medium, crypto/Linux)
**Суть:** SSH-ключ сгенерирован библиотекой, которая выбирает p и q слишком близко друг к другу. Факторизация Ферма ломает modulus за секунды.

## Разведка

22 и 80. Гобустер находит `/development` с `id_rsa.pub` и `log.txt` — а в логе честно написано: библиотека генерирует простые числа p и q близкими, такие ключи ломаются методом Ферма, и root-логин по SSH включён. Это почти выданное решение, осталось кодить.

## Почему Ферма работает

RSA держится на сложности разложения n = p·q. Но если p и q близки, то n близко к квадрату:

```
a = isqrt(n)
ищем a, пока a² - n не станет квадратом b²
тогда p = a + b, q = a - b
```

Чем ближе p к q, тем меньше итераций — тут ключ ломается мгновенно.

## Скрипт

```python
from Crypto.PublicKey import RSA
from gmpy2 import isqrt, invert, lcm

pub = RSA.import_key(open('id_rsa.pub').read())
n, e = pub.n, 65537

a = isqrt(n)
while True:
    a += 1
    b2 = a*a - n
    b = isqrt(b2)
    if b*b == b2: break
p, q = a + b, a - b

d = invert(e, lcm(p-1, q-1))
priv = RSA.construct((n, e, int(d)))
open('id_rsa','wb').write(priv.export_key('PEM'))
```

```bash
chmod 400 id_rsa && ssh root@rsa.thm -i id_rsa
```

## Заметка

RSA не сломан — сломан конкретный генератор. Крипто в CTF почти всегда про это: не «взломать алгоритм», а найти, где его применили криво. Читать логи и думать над «почему авторы это оставили» — половина решения.
