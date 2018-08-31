---
layout: default
title: "Windows, Vim, and Python: An Unholy Trinity of Pain"
---

Last summer I figured I'd learn Vim. That did not go well.

I started by stealing somebody's `.vimrc`, as is natural.
In this case the person from whomst I lifted my `.vimrc` was a Python dev, and I was working in Python at the time, so that was a reasonable choice.
But once I opened an actual Python file I got an error message that Vim couldn't find Python.

I did some research and it turned out that even though I'd grabbed the latest version of Vim, it was looking for Python 3.5 and I had Python 3.6, which had been out for a while by then.
So I uninstalled Python 3.6 and installed Python 3.5 and started getting a different error message.

A bit more research revealed that my Python was 64-bit but my Vim was 32-bit.
Apparently Vim didn't provide official 64-bit Windows builds at that time, so for 64-bit Vim on Windows they just linked to a handful of third party distributions.
I went ahead and uninstalled my 32-bit Vim so I could install 64-bit Vim, and then everything worked fine.
(Except for all the minor Vim papercuts that eventually led me to write [my own Nano clone](https://github.com/mathphreak/mfte) instead.)

To get Vim and Python to play nice with each other, I had to reinstall both of them.

And that's basically what developing on Windows is like in a nutshell.

But it doesn't have to be this way.
If more people treated Windows as a first class platform, the tools to develop on Windows wouldn't be so frustrating to use, and then more people would treat Windows as a first class platform.
