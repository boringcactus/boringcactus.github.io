---
layout: default
title: A Survey of Rust GUI Libraries
---

a popular trend in the Rust community is to ask "Are We X Yet" for various things that it would be nice to be able to develop easily in Rust - [game](https://arewegameyet.rs/) and [web](https://www.arewewebyet.org/) are the most prominent ones as far as i can tell - and one such question is [Are We GUI Yet](https://areweguiyet.com/).
that's a good question; *are* we GUI yet?
Are We GUI Yet has a list of libraries for building GUIs: let's go through them in alphabetical order and see if we can build a simple to-do list with them without too much struggle.

some notes before we get started.
1. this is all extremely subjective.
2. the only ui toolkits i have used and not hated are Swing (i know), Electron (*i know*), and wxWidgets, which doesn't have Rust bindings because Rust bindings to C++ libraries are generously described as a nuisance to create (i've tried, and i'm writing this post instead of trying harder).
as such, i might be using some of these wrong, who knows.
3. i use windows, and so anything that's a nuisance to set up on windows is not going to fare well regardless of how cool it is once you get it working.
it could be the best thing since sliced bread or Meteor on release and i wouldn't care.
do not @ me.
4. the people who wrote these libraries have done more than i have to make the rust gui ecosystem not suck, and i don't want any of this to come across as suggesting that they suck and their work is bad.
the strongest thing i want to say is that a library is not designed in a way that i would want it to be designed, or that it doesn't work for me.
doing this shit at all is really goddamn difficult, and i don't want to minimize that by being unhappy with the results.
5. i started drafting this post in early July 2020, and finished it in late August 2020.
some things may have changed in the meantime while i wasn't paying attention.

## azul

first on our list is [azul](https://azul.rs/):
> A free, functional, immediate-mode GUI framework for rapid development of desktop applications written in Rust, supported by the Mozilla WebRender rendering engine.

the wiki says we need cmake installed, which is never a good sign, but conveniently, i've already got that set up on my computer, for reasons i forget but probably didn't enjoy.
the runtime dependencies on linux are a mile long, but fortunately i don't have to care.
azul isn't currently available on crates.io for reasons that presumably exist but are difficult to explain, so we have to add it directly as a git dependency.

once we've got it added as a dependency, we can attempt to run our test crate, just to make sure everything's not on fire. unfortunately:
```text
error: failed to run custom build command for `servo-freetype-sys v4.0.5`

Caused by:
  process didn't exit successfully: `D:\Melody\Projects\we-are-not-gui-yet\target\debug\build\servo-freetype-sys-1fae054761ff82c5\build-script-build` (exit code: 101)
--- stdout
running: "cmake" <snip>

--- stderr
CMake Error: Could not create named generator Visual Studio 16 2019
```

this is an inauspicious beginning.
one version history crawl later and it looks like my cmake is from April 2019, which is not all that old but maybe they hadn't caught up on the latest visual studio yet, who knows.
this is already more work than i was prepared to do, but i've come this far, so it's time to update my cmake.

okay one installer later and it's time to try again.
armed with a cmake from May 2020, let's give this another shot:
```text
error[E0433]: failed to resolve: could not find `IoReader` in `bincode`
   --> C:\Users\Melody\.cargo\registry\src\github.com-1ecc6299db9ec823\webrender_api-0.60.0\src\display_list.rs:270:35
    |
270 |             let reader = bincode::IoReader::new(UnsafeReader::new(&mut self.data));
    |                                   ^^^^^^^^ could not find `IoReader` in `bincode`
```
welp.
the cmake update fixed things, i guess, but now we've got a whole other pile of mess.
this might be fixable, it may have been fixed by the time you read this.
regardless, this library does not work for me.

## conrod

next up is [conrod](https://github.com/pistondevelopers/conrod):
> An easy-to-use, 2D GUI library written entirely in Rust.

i've actually used this one before in a couple of projects, but it's been a minute, so i forget the details.

they do not have a real tutorial, which is unfortunate, but they do have some examples.
unfortunately, step one is to pick which of the half dozen backends i want.
do i want glium or vulkano or rendy or piston?
do i look like i know what a vulkano is?
i just want a picture of a [god dang hot dog](https://youtu.be/EvKTOHVGNbg).
okay that's not quite fair, i recognize three of those and can infer from context what the fourth one is, but that's only because i've been down this road before, and i still have no clue which one is the right one to pick.
all the examples live under glium, though, so let's go with that.

wait actually i'm staring at these examples and there's an entire ass event loop in the support code for the examples.
something in here mentions a `GliumDisplayWinitWrapper` and i'm scared.
i have literally used this library before - on two different projects - and i'm at a loss.
i don't want to just copy and paste the examples without actually understanding what's going on, i can't understand what's going on in the examples, and there's nowhere else to get started.
so there goes that i guess.

## core-foundation

> Bindings to Core Foundation for macOS.

oh hey, it's an OS i don't have access to at all.
next.

## druid

our next contender is [druid](https://linebender.org/druid/):
> Druid is a framework for building simple graphical applications.

apparently this sprung out of that vi-like text editor a couple googlers were working on, so apparently it's at least possible to use it for real software.
there's a tutorial, they're on crates.io, they're describing it as "conceptually simple and largely non-magical" which i am always a fan of, i am cautiously optimistic.
if we throw it in our dependencies and just see if anything breaks, we find the surprising result that everything just works.

oh hey the first real chapter in the tutorial starts with
> this is outdated, and should be replaced with a walkthrough of getting a simple app built and running.

you love to see it.
fortunately, we can just ignore that and skip to the hello world example, reproduced here in its entirety:
```rust
use druid::{AppLauncher, WindowDesc, Widget, PlatformError};
use druid::widget::Label;

fn build_ui() -> impl Widget<()> {
    Label::new("Hello world")
}

fn main() -> Result<(), PlatformError> {
    AppLauncher::with_window(WindowDesc::new(build_ui)).launch(())?;
    Ok(())
}
```
and somehow, this actually works.

the tutorial ends here, which is unfortunate, but there's more documentation, including explanations of core concepts with examples that are... todo lists!
with even more features than what i was planning to include here!
so that's convenient.
the UI hierarchy is based on CSS Flexbox, which i also appreciate.
this is what peak UI layout API looks like:
```rust
fn build_new_todo() -> impl Widget<TodoState> {
    let textbox = TextBox::new()
        .with_placeholder("New todo")
        .lens(TodoState::next_todo);
    let button = Button::new("Add")
        .on_click(|_, data: &mut TodoState, _| data.create_todo());

    Flex::row()
        .with_flex_child(textbox.expand_width(), 1.0)
        .with_child(button)
}
```

1 hour and 80 lines of code later, we've got ourselves a perfectly valid and working todo list!

![our sample druid application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-1.png)

i'm not quite happy with this, though: we can type text and hit the button and it adds the todo, but pressing enter in the text field doesn't do anything.
there's no way out-of-the-box to make that happen; let's see if we can build that ourselves.

~30 lines of code later, we've got it!
the `Controller` trait is designed for exactly this sort of thing, when you need to wrap the behavior of an existing component and intercept some events to inject your own logic.

if you're curious, you can take a look at [the source for our druid example](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/druid-test).

so apparently druid is actually pretty darn usable.
i only have a couple tiny issues with it:
1. it doesn't use platform native UI widgets, so it doesn't look quite like a windows app should, and it won't look quite like a mac or linux app should either if i test it there.
this one is a feature as far as some people are concerned, but i am not on that list.
2. accessibility features like being able to tab between UI widgets are missing, so you'd have to roll those yourself in a real application.
maybe they'll add that by default in future versions, maybe not, but it would be neat if it existed.
3. high-level documentation is incomplete.
the individual struct/function docs are really good, but at a high level you don't really have a convenient place to jump in.

i was about to add "no support for web" to that list, but even though the high-level docs don't mention it, the crate root docs and the examples do.
on the plus side, it just works, and i didn't have to make any changes to my code because i use [this patch to wasm-pack that lets you just use binary crates in wasm-pack](https://github.com/rustwasm/wasm-pack/pull/736) even though it hasn't been merged yet upstream.
on the minus side, it points everything at a `<canvas>` tag, which means you get none of the accessibility features of actually using the DOM.
so that one's a mixed bag.

but yeah, overall druid is perfectly usable for gui development.
i was originally calling this post "we are not gui yet" but i guess we are at least a little bit gui already.
pleasant surprises are the best kind.

## fltk

following up that success is [fltk](https://github.com/MoAlyousef/fltk-rs):
> The FLTK crate is a crossplatform lightweight gui library which can be statically linked to produce small, self-contained and fast gui applications.

cross-platform and statically linked are both good things.
the upstream FLTK website makes my eyes bleed, which is never a good sign for a UI library, but that doesn't mean much one way or the other.
the simple hello world example is once again a mere handful of lines:
```rust
use fltk::{app::*, window::*};

fn main() {
    let app = App::default();
    let mut wind = Window::new(100, 100, 400, 300, "Hello from rust");
    wind.end();
    wind.show();
    app.run().unwrap();
}
```
a downside i'm noticing already, at least compared to druid, is that everything has to be positioned manually, and we don't get any layout stuff calculated for free.

a lot of wrestling later, we have a technically working implementation ([source code](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/fltk-test)).

![our sample fltk application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-2.png)

it's half as much code as the druid implementation, but part of that's because the druid implementation also preserves state information, so we could easily have added persistence without all that much work, but our fltk version does not do that and is just a pile of ui widgets.
some of that code, i will say, fails to spark joy:
```rust
add_todo.set_callback(Box::new(move || {
    let text = next_todo.value();
    next_todo.set_value("");
    let done = CheckButton::new(0, top, 400, 30, &text);
    wind.add(&done);
    wind.redraw();
    top += 30;
}));
```
we have to drag that position and size around manually.
i don't like that.

overall, this technically works i guess, but i think the code is ugly and the style of the resulting application is also ugly.
we do get tab and space and everything working out of the box on buttons, which is always appreciated, though.
not broken or anything, not something i'd be likely to choose to use though either.

## gtk

next on our list is another pile of bindings to an existing ui library, [gtk](https://gtk-rs.org/):
> Rust bindings and wrappers for GLib, GDK 3, GTK+ 3 and Cairo.

however.
the second meaningful sentence in the README says
> gtk expects GTK+, GLib and Cairo development files to be installed on your system.

and i have been down that road before and mother of god once is enough.
maybe on things-that-are-not-windows this isn't a nightmare, but i do not use things that are not windows.
the windows instructions are a nightmare even in the happy path that their instructions explain, which last time around i failed to hit, making the whole process even more nightmarish.
so i think i will pass.

## iced

our next contestant is [iced](https://github.com/hecrj/iced):
> A cross-platform GUI library for Rust focused on simplicity and type-safety. Inspired by Elm.

cross-platform and simple are good.
inspired by elm is a tentative "nice" - my experiment with elm way back in the day had mixed results, but it's not clear how much of that was my fault.

iced compiles just fine, and it looks like we've got a vaguely MVC-ish architecture here.
it looks like you write your logic in a highly portable way and then glue it together in ways that vary based on whether you're building for native or for Web.

conveniently, there's a todo list example!
but we don't even need it; the example given in the README, with some of the details elided there, is enough context to have an entire todo list application in [100 lines of Rust](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/iced-test).

![our sample iced application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-3.png)

notably, our checkboxes aren't aligned to the right of the window.
i couldn't figure out how to make that happen.
however, we do have built-in support for "do a thing when the user presses enter in the text area," which we had to write ourself in other frameworks.
so that one is nice.

compared to druid, i'd say the logic is a little more intuitive, the layout controls are less intuitive, and the web support is way better.
the native build once again doesn't use native widgets and so once again doesn't get tab-between-fields or other accessibility features, but the web build uses actual HTML elements and so gets tab-between-fields for free.
high-level documentation is a little more robust here, plus the concepts are less complicated in the first place.

so it's a little easier to get off the ground than with druid, and the results on the web are way better, but it's more difficult to make it look decent.
maybe that's just a documentation issue, but it's not ideal.
regardless, yet again we have a perfectly usable library.

## imgui

up next, another binding to an existing library, [imgui](https://github.com/Gekkio/imgui-rs):
> Rust bindings for Dear ImGui

further down the readme, we see
> Almost every application that uses imgui-rs needs two additional components in addition to the main imgui crate: a backend platform, and a renderer.

and immediately i no longer give a shit.
i'm pretty sure imgui is designed for, like, diy game engines etc where you already have a backend and a renderer set up, which is a really specific use case that i don't currently meet.
goodbye.

## kas

this one is not a binding to something else, it's new from scratch, it's [kas](https://github.com/kas-gui/kas):
> KAS, the toolKit Abstraction System, is a general-purpose GUI toolkit.

the readme has a lot of screenshots, which is always nice to see.
no tutorial, apparently, but several examples.

the guts of kas are mostly macro-based, which doesn't combine well with the lack of high-level documentation, but the examples are enough to let me bullshit my way towards something almost usable.

![our sample kas application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-4.png)

why almost?
because clicking in the text entry field to give it focus causes an explosion:

```text
thread 'main' panicked at 'called `Option::unwrap()` on a `None` value', C:\Users\Melody\.cargo\registry\src\github.com-1ecc6299db9ec823\kas-text-0.1.3\src\prepared.rs:465:9
```

that's bad.
and i don't feel like chasing down why that happens, especially because my gut says [my code](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/kas-test) isn't the problem.
shame, though, the widgets sure look pretty.

## neutrino

next up we have [neutrino](https://github.com/alexislozano/neutrino):
> Neutrino is a MVC GUI framework written in Rust.

ah, [ol' reliable](https://knowyourmeme.com/memes/ol-reliable), MVC.
the wiki has an actual tutorial, too, which you love to see.

most of the other libraries have not made me throw around `Rc<RefCell<T>>` everywhere myself, though.
but neutrino has that just all over the place.
and it gets worse than you'd think.
building the same example to-do list required a `Rc<RefCell<Vec<Rc<RefCell<TodoItem>>>>>` and i feel like that's bad.
it definitely makes [my code](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/neutrino-test) look terrible.

excitingly, we now have a demo that looks bad and also doesn't work:

![our sample neutrino application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-5.png)

excitingly, when we type some text and hit the "add" button, the text gets lost in the created todo, and i have no goddamn clue where it's going or what to do to fix it.

the approach is interesting, though.
as i'm writing this neutrino is unmaintained and seeking a new maintainer, so hopefully somebody has the time and energy to steer it forwards.

## orbtk

our next contestant is [OrbTK](https://github.com/redox-os/orbtk):
> The Orbital Widget Toolkit is a cross-platform (G)UI toolkit for building scalable user interfaces with the programming language Rust.

apparently this is attached to Redox, the OS written in Rust.
so that's neat.

again, no tutorial, some examples that are far from self-explanatory.

it does let us build a working todo list, and one that looks pretty nice:

![our sample orbtk application, showing a todo list](/assets/2020-08-21-survey-of-rust-gui-libraries-6.png)

i can't for the life of me figure out how to make the text field take up the entire width available to it.
but everything works, and we get built-in support for adding the todo on Enter in the text field, which is nice.

in theory, there's web support, but when i tried it it very loudly didn't work:

```text
error[E0405]: cannot find trait `StdError` in module `serde::de`
   --> C:\Users\Melody\.cargo\registry\src\github.com-1ecc6299db9ec823\serde_json-1.0.46\src\error.rs:317:17
    |
317 | impl serde::de::StdError for Error {
    |                 ^^^^^^^^ not found in `serde::de`
```

so yeah, we've got some nice-looking widgets, with unintuitive layout settings, broken web support, and a *lot* of glue i had to write by hand that makes [the source code](https://git.sr.ht/~boringcactus/survey-of-rust-gui-libraries/tree/main/orbtk-test) cluttered and messy.
don't think i'd use it for anything more serious, at least as it exists right now.

## qmetaobject

> The qmetaobject crate is a crate which is used to expose rust object to Qt and QML.

i don't want to install Qt.
that sounds like a nuisance, and more importantly, if i want Travis or whatever to give me automated CI builds, i don't think it's easy to make sure Qt exists on all platforms on Travis.

## qt_widgets

oh hey, more Qt API bindings!
i still don't want to install Qt.

## relm

> Asynchronous, GTK+-based, GUI library, inspired by Elm, written in Rust.

as established, GTK+ setup on Windows is a scary nightmare hellscape.

## rust-qt-binding-generator

i am so tired.

## sciter-rs

i think sciter is a thing actual programs use, which is nice.
however, we need not only the sciter sdk installed and available, but also GTK+, and god damn i do not want to do that.

## WebRender

last, but hopefully not least, we have [webrender](https://github.com/servo/webrender):

> WebRender is a GPU-based 2D rendering engine written in Rust.
> Firefox, the research web browser Servo, and other GUI frameworks draw with it.

pour one out for Servo, btw.

unfortunately, the ["basic" example](https://github.com/servo/webrender/blob/master/examples/basic.rs) is still 300+ lines of code.
so i doubt that's gonna be useful.

## so *are* we GUI yet?

well, kinda.
druid works well if you want a straightforward layout experience.
iced works well if you want a straightforward render-update architecture, or actual HTML elements on Web.
everything else is, as of today, broken and/or more complex than i want.
and if you want native ui widgets to match your platform's look and feel, that's gonna be like a year away at least.
