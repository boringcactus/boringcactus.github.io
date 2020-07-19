---
layout: default
title: "Monads, Explained Without Bullshit"
---

there's a CS theory term, "monad," that has a reputation among extremely online programmers as being a really difficult to understand concept that nobody knows how to actually explain.
for a while, i thought that reputation was accurate; i tried like six times to understand what a monad is, and couldn't get anywhere.
but then a friend sent me [Philip Wadler's 1992 paper "Monads for functional programming"](https://homepages.inf.ed.ac.uk/wadler/papers/marktoberdorf/baastad.pdf) which turns out to be a really good explanation of what a monad is (in addition to a bunch of other stuff i don't care about).
so i'm gonna be repackaging the parts i like of that explanation here.

math jargon is pretty information-dense for me, though, and my eyes tend to glaze over pretty quickly, so i'll be using [Rust](https://www.rust-lang.org) (or an idealized version thereof) throughout this post instead of math.

so, a monad is a specific kind of type, so we can think of it like a `trait`:

```rust
trait Monad {
    // TODO
}
```

Rust has two types that will be helpful here, because (spoilers) it turns out they're both monads: `Vec` and `Option`.
now, if you've worked with Rust before, you might be thinking "wait, don't you mean `Vec<T>` and `Option<T>`?" and that's a reasonable question to ask, since Rust doesn't really let you just say `Vec` or `Option` by themselves.
but as it happens, the monad-ness applies not to a specific `Vec<T>` but to `Vec` itself, and the same goes for `Option`.
which means what we'd like to do is say

```rust
impl Monad for Vec {}
impl Monad for Option {}
```

but Rust won't let us do that because we can't talk about `Vec`, only `Vec<T>`.
this is (part of) why Rust doesn't have monads.
so let's just kinda pretend that's legal Rust and move on.
what operations make a monad a monad?

## new

Wadler calls this operation `unit`, and Haskell calls it `return`, but i think it is easier to think of it as `new`.

```rust
trait Monad {
    fn new<T>(item: T) -> Self<T>;
}
```

`new` takes a `T` and returns an instance of whatever monad that contains that `T`.
it's pretty straightforward to implement for both `Option` and `Vec`:

```rust
impl Monad for Option {
    fn new<T>(item: T) -> Self<T> { Some(item) }
}

impl Monad for Vec {
    fn new<T>(item: T) -> Self<T> { vec![item] }
}
```

we started out with a stuff, and we made an instance of whatever monad that contains that stuff.

## flat_map

Wadler calls it `*`, Haskell calls it "bind" and spells it `>>=`, but i think `flat_map` is the best name for it.

```rust
trait Monad {
    fn flat_map<T, U, F: Fn(T) -> Self<U>>(data: Self<T>, operation: F) -> Self<U>;
}
```

we have an instance of our monad containing data of some type `T`, and we have an operation that takes in a `T` and returns the same kind of monad containing a different type `U`.
we get back our monad containing a `U`.

as you may have guessed by how i named it, `flat_map` is basically just `Iterator::flat_map`, so implementing it for `Vec` is fairly straightforward.
for `Option` it's literally just `and_then`.

```rust
impl Monad for Option {
    fn flat_map<T, U, F: Fn(T) -> Self<U>>(data: Self<T>, operation: F) -> Self<U> {
        data.and_then(operation)
    }
}

impl Monad for Vec {
    fn flat_map<T, U, F: Fn(T) -> Self<U>>(data: Self<T>, operation: F) -> Self<U> {
        data.into_iter().flat_map(operation).collect()
    }
}
```

so in theory, we're done.
we've shown the operations that make a monad a monad, and we've given their implementations for a couple of trivial monads.
but not every type implementing this trait is really a monad: there are some guarantees we need to make about the behavior of these operations.

## monad laws

(written with reference to [the relevant Haskell wiki page](https://wiki.haskell.org/Monad_laws))

like how there's nothing in Rust itself to ensure that your implementation of `Add` doesn't instead multiply, print a dozen lines of nonsense, or delete System32, the type system is not enough to guarantee that any given implementation of `Monad` is well-behaved.
we need to define what a well-behaved implementation of `Monad` does, and we'll do that by writing functions that assert our `Monad` implementation is reasonable.
we're going to have to also cheat a bit here and deviate from actual Rust by using `assert_eq!` to mean "assert equivalent" and not "assert equal"; that is, the two expressions should be interchangeable in every context.

first off, we have the "left identity," which says that passing a value into a function through `new` and `flat_map` should be the same as passing that value in directly:

```rust
fn assert_left_identity_holds<M: Monad>() {
    let x = 7u8; // this should hold for any value
    let f = |n: u8| M::new((n as i16) + 3); // this should hold for any function
    assert_eq!(M::flat_map(M::new(x), f), f(x));
}
```

next, we have the "right identity," which says that "and then make a new monad instance" should do nothing to a monad instance:

```rust
fn assert_right_identity_holds<M: Monad>() {
    let m = M::new('z'); // this should hold for any instance of M
    assert_eq!(M::flat_map(m, M::new), m);
}
```

and last but by no means least we have associativity, which says it shouldn't matter the sequence in which we apply `flat_map` as long as the arguments stay in the same order:

```rust
fn assert_associativity_holds<M: Monad>() {
    let m = M::new(false); // this should hold for any instance of M
    let f = |data: bool| if data { M::new(3usize) } else { M::new(7usize) }; // this should hold for any function
    let g = |data: usize| M::new(vec!["hello"; data]); // this should hold for any function
    assert_eq!(
        M::flat_map(M::flat_map(m, |x: bool| f(x)), g),
        M::flat_map(m, |x: bool| M::flat_map(f(x), g))
    );
}
```

so now we can glue all those together and write a single function that ensures any given monad actually behaves as it should:

```rust
fn assert_well_behaved_monad<M: Monad>() {
    assert_left_identity_holds::<M>();
    assert_right_identity_holds::<M>();
    assert_associativity_holds::<M>();
}
```

## but. why

well.
monads exist in functional programming to encapsulate state in a way that doesn't explode functional programming (among other things, please do not @ me).
Rust isn't a functional programming language, so we have things like `mut` to handle state.

there's a bit of discussion in Rust abt how monads would be actually implemented - the hypothetical extended Rust that i use here is not actually what anyone advocates for, you can look around for yourself if you care - but even the people in that discussion seem to not really explain why Rust needs monads.
so all of this doesn't really build up to anything.
but hey, now (with luck) you understand what monads are!
i hope you find that rewarding for its own sake.
i hope i do, too.
