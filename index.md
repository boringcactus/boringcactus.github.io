---
layout: default
title: boringcactus (Melody Horn)
description: immortal programming goddess
---

i am an immortal programming goddess and a trans woman.
i've been programming for over a decade, and in that time i've worked on [a wide variety of projects]({% link projects.md %}).

i exist in a lot of places:
- see me retweet nonsense you don't care about on [twitter](https://twitter.com/boring_cactus)
- give me money to continue to exist on [patreon](https://www.patreon.com/boringcactus)
- watch me occasionally stream things on [twitch](https://www.twitch.tv/boringcactus)
- watch various kinds of permanent video content on [youtube](https://www.youtube.com/channel/UCw0N-UmLylMSnCtHZ7vagBw)

every once in a very great while i write things here:

{% for post in site.posts %}
- [{{ post.title }} ({{ post.date | date_to_string }})]({{ post.url }})
{% endfor %}
