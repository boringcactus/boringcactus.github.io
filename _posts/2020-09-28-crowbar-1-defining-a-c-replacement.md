---
title: "Crowbar: Defining a good C replacement"
---

I like Rust a lot.
That said, the always-opinionated, often-correct Drew DeVault raises some good points in his blog post [Rust is not a good C replacement](https://drewdevault.com/2019/03/25/Rust-is-not-a-good-C-replacement.html).
He names some attributes that C has and Rust lacks which he thinks are required in a good C replacement.
So what can we say are some features of a hypothetical good C replacement?

## Portability

Per Drew, "C is the most portable programming language."
Rust, via LLVM, supports a lot of target architectures, but C remains ubiquitous.
Anything less portable than LLVM is, therefore, incapable of being a good C replacement, and to be a truly great C replacement a language should be as portable as C.

The lifehack that makes sense here to me, difficult as it might be to implement, is to have the compiler for your C replacement be able to emit C as a compile target.
It might not be the same C that a competent C programmer would write by hand, the result might not initially be as fast as the compiler would be if it were running the full toolchain directly, but in principle a self-hosting compiler that could also emit C would be extremely easy to bootstrap on any new architecture.

## Specification

The C specification, while large and unwieldy and expensive, does at least exist.
This creates a clear definition for how a compiler *should* work, whereas the behavior of Rust-the-language is defined to be whatever rustc-the-compiler does.
Rust's lack of a specification allows it to move fast and not break things, which is cool for Rust (shout out to async/await), but there's virtue in moving slow, too.
I don't think Rust itself necessarily needs a specification, but I do think that a good C replacement should be formally specified, and move at the speed of bureaucracy to ensure only the best changes get actually made.

The C99 specification is 538 pages and costs more money than I'd want to spend to get a legitimate copy of.
A good C replacement should probably have a specification that fits in half the size - hell, call it 200 pages for a nice round number - and that specification should be released free of charge and under a permissive license.

## Diverse Implementations

I think this is a result of having a specification more than a cause of its own, but Drew points out that the various C compilers keep each other and the spec honest and well-tested.
I think in principle a good C replacement could start out with only one compiler, but it would need to be fairly straightforward to write a new compiler for - which is certainly not the case for C.
It might be helpful to have several different reference compilers, themselves written in different languages and for different contexts.
(It would be a fun party trick to have a WebAssembly-based compiler that people could poke around at in their browsers.)

## Zero-Effort FFI

Drew calls this point "a consistent and stable ABI," but I think the context in which that matters is being able to use other libraries from your code, and being able to compile your code as a library that other people can use in turn, without needing to jump through extra hoops like writing glue layers manually or recompiling everything from source.
The easy ("easy") solution is to just build libraries that C code can just use directly, and use the same ABI that C libraries in turn would export, so that there's no such thing as FFI because no functions exist which are foreign.

## Composable Build Tools

I don't give a shit about this one, but in fairness to Drew I could understand why he would.
If I have a project that starts out being entirely C, and I'm like "oh lemme try out Rust for some of this", I don't want to start by swapping out my build system and everything, I want to keep my Makefiles and make like one change to them and call it a day.
(Makefiles also suck, but they don't dual-wielding-footguns suck, so it doesn't matter.)
But cargo is very decidedly not built to be used that way, and rustc is very decidedly not built to be called from things that aren't cargo.
So a good C replacement should have a compiler that works the way C compilers tend to, i.e. you pass in a file or several and a bunch of arguments and it builds the file you need it to build.

## *fart noises*

> Concurrency is generally a bad thing.

## Safety Is Just Another Feature

In light of all the problems he has with Rust, Drew declares

> Yes, Rust is more safe. I don’t really care. In light of all of these problems, I’ll take my segfaults and buffer overflows.

And like.
On one hand, those are all extremely avoidable problems, and the way to avoid them is to start using a memory safe language.
And they do cause *rather more substantial problems* than not having a specification.

But also.
On the other hand, I don't eat my vegetables, I only comment my code half the time, I use Windows and I don't hate it.
We're all of us creatures of habit, we do what's familiar, and we'll keep doing things in dangerous ways if switching to safe ways would have too high a learning curve.
So as much of a bruh moment as this is in the abstract, I've been there, I'll likely be there again, and I can't really judge all that harshly.

## Crowbar

The conclusion to Drew's blog post opens like this:

> C is far from the perfect language - it has many flaws.
> However, its replacement will be simpler - not more complex.

And those sentences have been rattling around in my brain for a while now.
Because he's right about that much.
If we want C programmers to stop using C, we have to give them something that's only as different from C as it actually needs to be.
We need C: The Good Parts Plus Barely Enough To Add Memory Safety And Good Error Handling.

And as someone with extraordinarily poor time management skills, I think I kinda want to work on building that.

Naming things is widely known to be the hardest problem in computer science, but since the goal is to pry C diehards away from C, I think a good name for this project would be

[Crowbar: the good parts of C, with a little bit extra](https://sr.ht/~boringcactus/crowbar-lang/).

I don't know if this will get any of my time and attention.
It really shouldn't - I've got so much other shit I should be doing instead - but also this is fun so who knows.
Join the mailing lists if you're interested in participating.
