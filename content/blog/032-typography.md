+++
title = "Typography"
categories = ['Blogging']
date = '2024-02-01'
slug = 'typography'
draft = false
+++

This blog uses the [hugo-whiteglass](https://github.com/nikhilweee/hugo-whiteglass) theme. This page
showcases commonly used elements.

# Headings

---

Headings have been scaled to preserve their order. The first three levels -- `H1`, `H2` and `H3` are
scaled to `1.5rem`, `1.25rem` and `1.17rem` respectively. All other headings -- `H4`, `H5` and `H6`
are scaled to `1rem`. Here is what they look like.

# Heading 1

## Heading 2

### Heading 3

#### Heading 4

##### Heading 5

###### Heading 6

# Styling

---

**Here is some text that is bold. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut mattis
fringilla ex eu blandit. Suspendisse potenti. Fusce porttitor egestas posuere. Donec molestie odio
ullamcorper mauris consectetur, nec porttitor lectus congue.**

_Here is some text that is italic. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut
mattis fringilla ex eu blandit. Suspendisse potenti. Fusce porttitor egestas posuere. Donec molestie
odio ullamcorper mauris consectetur, nec porttitor lectus congue._

> This is some quote by a very famous person. Lorem ipsum dolor sit amet, consectetur adipiscing
> elit. Ut mattis fringilla ex eu blandit. Suspendisse potenti. Donec molestie odio ullamcorper
> mauris consectetur, nec porttitor lectus congue.

# Lists

---

This is a bulleted list. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

- Ut mattis fringilla ex eu blandit.
- Suspendisse potenti.
  - Aenean in elit at elit commodo feugiat.
  - Sed cursus risus sed feugiat placerat.
- Fusce porttitor egestas posuere.
- Quisque eu tortor ac leo dictum egestas.

This is a numbered list. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

1. Ut mattis fringilla ex eu blandit.
1. Suspendisse potenti.
   1. Aenean in elit at elit commodo feugiat.
   1. Sed cursus risus sed feugiat placerat.
1. Fusce porttitor egestas posuere.
1. Quisque eu tortor ac leo dictum egestas.

# Links

---

There are a couple different ways to use links.

- You can use a regular markdown-style link, so `[Google](https://google.com)` appears as
  [Google](https://google.com).

- You can use raw links in angled brackets, so `<https://google.com>` appears as
  <https://google.com>.

- Finally, you can also use reference style links, so `[this link][google]` would appear as [this
  link][google]. Note that for reference style links to work, you need to actually define the
  reference somewhere within the source code.

  ```text
  [google]: https://google.com
  ```

- You can also add footnotes [^footnote]. Define the reference like this.

  ```text
  [^footnote]: This is a footnote.
  ```

[google]: https://google.com

[^footnote]: This is a footnote.

# Code Blocks

---

This is what `inline code` looks like. A code block looks like the following. Remember to always
include a language when using code blocks. For plaintext, set the language as `text`.

```py
def fibonacci(n):
    """
    Calculate the nth Fibonacci number using recursion.
    :param n: The position of the Fibonacci number to be calculated.
    :return: The nth Fibonacci number.
    """
    if n <= 1:
        return n
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)
```

# Tables

---

This is what a table looks like.

| Header 1 | Header 2 | Header 3 |
| :------- | :------: | -------: |
| Cell 1   |  Cell 2  |   Cell 3 |
| Cell 4   |  Cell 5  |   Cell 6 |
| Cell 7   |  Cell 8  |   Cell 9 |
