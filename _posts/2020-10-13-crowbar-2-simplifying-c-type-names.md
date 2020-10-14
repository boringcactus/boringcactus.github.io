---
title: "Crowbar: Simplifying C's type names"
---

(Previously in Crowbar: [Defining a good C replacement]({% link _posts/2020-09-28-crowbar-1-defining-a-c-replacement.md %}).)

I've been working intermittently on drawing up a specification for [Crowbar](https://sr.ht/~boringcactus/crowbar-lang/), a C replacement aiming to be both simpler and safer.
I'm still nowhere near done, but I'm proud of the concept I've reached for type names, and I want to explain it in depth here.

## The Problem

C declarations are known to be a nuisance in nontrivial cases.
There's a mid-90s ["clockwise/spiral rule"](http://c-faq.com/decl/spiral.anderson.html) that I've seen referenced a few times, but three steps are two too many for reading a declaration.
Function pointers in particular have a reputation for being legendarily impossible to visually parse.
I don't know what `void (*signal(int, void (*fp)(int)))(int);` is declaring, but it's the most complicated example listed on the spiral rule page, and I'm pretty sure just pasting it into this blog post has already summoned some eldritch abomination.

## A Solution

So we have this syntax which is well-established, and for simple cases well-understood, but in complex cases quickly becomes unmanageable.
Ideally, we can preserve the syntax as is for simple cases, while cutting down on that complexity in the more difficult cases.

As of right now, the Crowbar specification gives the syntax as a [parsing expression grammar](https://en.wikipedia.org/wiki/Parsing_expression_grammar), which I'll give an excerpt from here:

```
Type      ← 'const' BasicType /
            BasicType '*' /
            BasicType '[' Expression ']' /
            BasicType 'function' '(' (BasicType ',')* ')' /
            BasicType
BasicType ← 'void' /
            'int' /
            'float' /
            'bool' /
            '(' Type ')'
```

So essentially, basic types can be used as-is, and pointers-to or arrays-of those basic types require no additional syntax.
But if you want to do something nontrivial, you'll need to parenthesize the inner type.

I didn't think this would wind up being quite as elegant as it turned out to be, but it handles a lot of edge cases gracefully and intuitively.

## In Motion

I'll just lift some examples straight from the Spiral Rule page.

```c
char *str[10];
```

Evidently this means "str is an array 10 of pointers to char".
How would we express that in Crowbar (as it hypothetically exists so far)?

```
(char *)[10] str;
```

Now that's more like it.
We can look at it and tell right away that the array is the outermost piece and so `str` is an array.
In C, I'm not sure how we'd express a pointer-to-arrays-of-10-chars, but in Crowbar it's also straightforward:

```
(char[10])* str;
```

Now let's kick it up a notch, and look at those legendarily-awful aspects of C's syntax, function pointers.
The Spiral Rule offers up

```c
char *(*fp)( int, float *);
```

which supposedly means "fp is a pointer to a function passing an int and a pointer to float returning a pointer to a char".
That's not extremely dreadful, merely somewhat off-putting, but let's see how it looks in Crowbar.

```
((char *) function(int, (float *),)* fp;
```

I hate that way less.
It's less terse, certainly, but it's more explicit.
The variable name is where it belongs, instead of nestled three layers deep inside the declaration.
The fact that the `char *` and `float *` need to be parenthesized here is probably unnecessary, but you could imagine situations where those parentheses would be vital.
And introducing `function` as a keyword means you can look at it and know instantly that it's a pointer-to-a-function, instead of going "wait what's that syntax where there are more parentheses than you'd think you'd want? oh yeah it's function pointers."

So let's take a look at the worst thing C can offer.
The Spiral Rule calls it the "ultimate", and I don't think that's a misnomer:

```c
void (*signal(int, void (*fp)(int)))(int);
```

That fractal mess is "a function passing an int and a pointer to a function passing an int returning nothing (void) returning a pointer to a function passing an int returning nothing (void)".
My eyes glaze over reading that description even more than they do reading the original C.
Can we make this not look awful?

```
((void function(int,))*) signal(int, ((void function(int,))*),);
```

This is beautiful.
(Well, no it isn't, but it's way less ugly than the original.)
It's clear which things are functions and which things are not, the nesting is all transparent and visible, and *you can tell what the return type is without a PhD in Deciphering C Declarations*.
Plus, importantly, it's clear that this is a function prototype and not a function pointer declaration, which is a massive improvement over the original.

## Bonus Round

Just for kicks, another less-awful-but-still-not-great thing about C type syntax is the pointer-to-constant vs constant-pointer dichotomy.

```c
const int * points_to_const; // can never do *points_to_const = 8;
int * const const_pointer; // can never do const_pointer = &x;
```

You have to remember which is which.
And why memorize when you can read?

```
(const int)* points_to_const;
const (int *) const_pointer;
```

Much, much better.

## Looking Forwards

This syntax is simpler than C's without losing any expressive power.
That makes me very happy.

If you're curious what's coming next for Crowbar, watch this space for when I eventually write another Crowbar-related blog post, or [join the mailing list](https://sr.ht/~boringcactus/crowbar-lang/lists).
(But don't get your hopes up; Crowbar is a project I'm working on in my spare time on a when-I-feel-like-it basis.)
