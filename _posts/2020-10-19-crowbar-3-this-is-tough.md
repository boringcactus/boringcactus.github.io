---
title: "Crowbar: Turns out, language development is hard"
---

(Previously in Crowbar: [Defining a good C replacement]({% link _posts/2020-09-28-crowbar-1-defining-a-c-replacement.md %}), [Simplifying C's type names]({% link _posts/2020-10-13-crowbar-2-simplifying-c-type-names.md %}))

Originally, I hadn't decided whether Crowbar should be designed with an eye towards compiling to C or with an eye towards compiling directly.
Compiling to C massively cuts down the scope of Crowbar as a project, but compiling directly gives me more comprehensive control over what all happens.

I figured I wouldn't need comprehensive control over everything, so I chose compiling to C, and then almost immediately ran into a pile of issues that compiling to C brings with it.

## libc is part of the problem

One of the goals I had for Crowbar was memory safety - most of the footguns in C are of the dubious-memory-operations variety - but it turns out you can't just duct tape memory safety to an existing language and call it a day.
Among the most easily-exploited class of dubious memory operations is the buffer overflow, and the most straightforward fix is bounds checking.

However, most of the C standard library doesn't perform bounds checking, because the C standard library was designed in the 1600s when every CPU cycle took six months and compiler optimizations hadn't been invented yet.

The C11 specification actually defines bounds-checking-performing alternatives to some of the standard library APIs, but it's optional (filed away in Annex K) and fuckin nobody can be bothered to implement it.
Some of the spec authors [wrote a whole investigation](http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1969.htm) of why nobody uses Annex K, and it all boils down to "error handling in C is broken-by-default" - which is the other big issue Crowbar will have to solve, and I haven't even begun to think about how to do that.

But.
We live in a world where C already exists in all its mixed glory, and in that world, nothing supports Annex K.
There exist some tacked-on implementations, but the [most complete-looking one](https://github.com/sbaresearch/slibc) is licensed under the regular GPL, not even the LGPL, which would be a problem for a lot of software.
So if I want Crowbar to be designed to compile into C, I need to either reimplement Annex K my damn self or design some equivalent APIs and implement those.

In either case, now Crowbar has a runtime library on top of libc, and nobody's going to already have it so it'll have to figure out how to ensure that its runtime library is available wherever needed.
And that's a pain in the ass.

## you can't win

Okay, so if compiling to C would still require a runtime library, and ensuring that the runtime library still worked in mixed-Crowbar-and-C and fully-Crowbar projects without requiring system-wide installation or anything would be a nuisance, why not just simplify some things and skip over C?

Well, for an ordinary language, that'd work rather well, which is why fucking nothing uses C as a compile target.
But one of the nonnegotiable goals of Crowbar is to have low- or no-effort C interoperability.
As such, you need to be able to include regular C headers.
But loading and parsing regular C headers means the Crowbar compiler needs to be able to understand all of C, and either implement or shell out to a C preprocessor that can use conventional command line arguments to define include directories.
And if the compiler has to encompass all of the complexity of C, then Crowbar just went from a subset of C to a superset of C.
I do not want to write a C compiler.
If Crowbar is supposed to be simpler than C, then writing a Crowbar compiler should be simpler than writing a C compiler, not more complicated.

So compiling to C creates problems, and compiling not-to-C creates problems.
This sucks.
Send help.

No, seriously, if you have advice, even if it's just "well I'd probably do this because it seems more intuitive to me", [send it in](mailto:~boringcactus/crowbar-lang-devel@lists.sr.ht).
