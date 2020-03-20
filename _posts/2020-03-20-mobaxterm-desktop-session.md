---
layout: default
title: "Lifehack: Running An Entire Desktop Session Remotely With MobaXterm"
---
Since my university has gone as remote as possible due to coronavirus, I was looking at ways to run an entire desktop session remotely over SSH, using MobaXterm because it is very cool.
Here are the two steps to doing that.

1. Open your MobaXterm settings, go to the X11 tab, and make sure that the server display mode is set to windowed mode.
If you run individual programs over X11 forwarding, this is worse, but for an entire desktop session it is better.
2. Duplicate your regular command line session that already works, and under the "Advanced SSH settings" tab, set "Execute command" to `env GNOME_SHELL_SESSION_MODE=ubuntu gnome-session --session=ubuntu`.
(If you're not running the same setup I am, look around in `/usr/share/xsessions/`, pick something that looks reasonable, and use everything after `Exec=` on the line with that.)

At this point, you should be set.
You'll need to hit the "log out" button to smoothly exit the connection.
For me, this is extraordinarily slow, but that could easily be just because the machines I'm connecting to are being used a lot.
