---
layout: default
title: boringcactus (Melody Horn)
description: immortal programming goddess
---

i am an immortal programming goddess and a trans woman.
i've been programming for over a decade, and in that time i've worked on [a wide variety of projects]({% link projects.md %}).

i mostly exist on [twitter](https://twitter.com/boring_cactus).
if you like the fact that i exist, you can pay me to keep doing that on [patreon](https://www.patreon.com/boringcactus).
every once in a very great while i write things here:

{% for post in site.posts %}
- [{{ post.title }} ({{ post.date | date_to_string }})]({{ post.url }})
{% endfor %}
