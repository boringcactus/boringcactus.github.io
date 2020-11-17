---
title: A Survey of Rust Embeddable Scripting Languages
---

Rust is a nice programming language.
But it's only ever compiled, so if you want behavior that can be edited at runtime, you have to either anticipate and implement every single knob you think might need adjusting or let users write code in some other language that you then call from Rust.
Lua is (to my knowledge) the most common language for this use case in general, but I don't really like using Lua all that much, so let's take a more comprehensive look at some of our options.

We'll need a use case in mind before we can really get going here, so here's our motivating example.
We've got an event enum that our host can send to our script:
```rust
pub enum Event {
    Number(i64),
    Word(String),
}
```

And we've got some operation that makes sense in the context of our host, which the script can call:
```rust
pub fn print_fancy(text: &str) {
    println!("✨{}✨", text);
}
```

It'd be nice to reuse most of this structure, so let's define a consistent interface:
```rust
pub trait ScriptHost {
    type ScriptContext;
    type Error;

    fn new_context() -> Result<Self::ScriptContext, Self::Error>;
    
    fn handle_event(context: &mut Self::ScriptContext, event: Event) -> Result<(), Self::Error>;
}
```

And it'd be nice if almost all the logic was generic over `ScriptHost` so our individual examples could just call it as is:
```rust
pub fn run_main<SH: ScriptHost>() -> Result<(), SH::Error> {
    let stdin = stdin();

    let mut context = SH::new_context()?;

    loop {
        println!("Type a number or some text to fire an event, or nothing to exit.");
        let mut input = String::new();
        stdin.read_line(&mut input).unwrap();
        let input = input.trim();

        if input.is_empty() {
            break;
        }
        let event = match input.parse() {
            Ok(i) => Event::Number(i),
            Err(_) => Event::Text(input.to_string())
        };

        SH::handle_event(&mut context, event)?;
    }

    Ok(())
}
```

And specifically, where possible, we'd like to have the script simply export a function we can call and pass in an event.
That way, the script can maintain its own long-running state if it wants to.

So that's the context in which we are working.
If your context is not like this, then some libraries that don't work here might work for you.
(If you're curious, you can check out the full source code for these examples [here](https://git.sr.ht/~boringcactus/rust-scripting-languages).)

Our contenders will be pulled from the top crates.io results for the tags "script", "scripting", and "lua", sorted by Recent Downloads as of when I'm starting this blog post and with a cutoff of whenever I feel like stopping.
Specifically (these are links to the sections where I discuss them, if you've got one in mind you're curious about) we have
- [mlua](#mlua-and-rlua) (31,454 recent downloads)
- [rlua](#mlua-and-rlua) (30,877 recent downloads)
- [duckscript](#duckscript) (24,901 recent downloads)
- [rhai](#rhai) (5,884 recent downloads)
- [dyon](#dyon) (1,539 recent downloads)
- [gluon](#gluon) (946 recent downloads)
- [ketos](#ketos) (497 recent downloads)
- [rune](#rune) (495 recent downloads)
- [ruwren](#ruwren) (451 recent downloads)

That seems like a lot.
Let's hope I don't regret this.

## mlua and rlua

[mlua](https://crates.io/crates/mlua) and [rlua](https://crates.io/crates/rlua) are both Lua bindings - mlua is apparently a fork of rlua - so we'll look at them together.

Reading through the mlua README, we see something unfortunate:
> On Windows `vendored` mode is not supported since you need to link to a Lua dll.
> Easiest way is to use either MinGW64 (as part of MSYS2 package) with `pkg-config` or MSVC with `LUA_INC` / `LUA_LIB` / `LUA_LIB_NAME` environment variables.

I would really rather not have to go to all that work and expect any potential contributors to do the same.
So there goes that one.

Since mlua is an rlua fork, I was guessing "not a pain in the ass on Windows" isn't a feature rlua has either, but apparently rlua works just fine on Windows with zero extra pain.
So that's interesting.

Oh hey, less than a hundred lines of glue and we're fuckin set!
The rlua crate has its own script host, so our choice of ScriptContext is really simple:
```rust
struct LuaScriptHost;

impl ScriptHost for LuaScriptHost {
    type ScriptContext = Lua;
    type Error = Error;
```

When we make a new context, we want to create a binding to our `print_fancy` method.
Aside from having to use a `String` instead of `&str` it's pretty straightforward:
```rust
    fn new_context() -> Result<Lua, Error> {
        let lua = Lua::new();
        lua.context::<_, Result<(), Error>>(|lua_ctx| {
            let print_fancy = lua_ctx.create_function(|_, text: String| {
                print_fancy(&text);
                Ok(())
            })?;

            lua_ctx.globals()
                .set("print_fancy", print_fancy)?;

            lua_ctx
                .load(&(read_to_string("scripts/rlua-sample.lua").unwrap()))
                .set_name("rlua-sample.lua")?
                .exec()?;

            Ok(())
        })?;
        Ok(lua)
    }
```

(We're hard coding the path to the script here, because autodiscovering those is beyond the scope of this blog post, but you could totally iterate a directory and either run all those scripts in the same context or give them each their own context.)
We're going to need a little more glue on the `Event` enum, though since Lua doesn't exactly have anything like enums natively.
(And that glue is more complicated if we're using Cargo examples, because they aren't technically the same crate, so Rust's orphan rules kick in.)
The easiest way to do that, I think, is to just add `get_number` and `get_text` methods that will return `nil` if the `Event` wasn't of that type:

```rust
struct EventForLua(Event);

impl UserData for EventForLua {
    fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_method("get_number", |ctx, this, _: ()| {
            match this.0 {
                Event::Number(number) => Ok(number.to_lua(ctx)?),
                _ => Ok(Nil)
            }
        });

        methods.add_method("get_text", |ctx, this, _: ()| {
            match &this.0 {
                Event::Text(text) => Ok(text.clone().to_lua(ctx)?),
                _ => Ok(Nil)
            }
        });
    }
}
```

Armed with all these tools, we can now actually write our Lua script:
```lua
function handle_event(event)
    local number = event:get_number()
    if number ~= nil then
        print("number!", number)
    end
    local text = event:get_text()
    if text ~= nil then
        print("text!", text)
    end
    print_fancy("got an event!")
end
```

And now that we have our function, since we already ran this script, to handle an event all we need to do is call that function:
```rust
    fn handle_event(context: &mut Lua, event: Event) -> Result<(), Error> {
        context.context::<_, Result<(), Error>>(|lua_ctx| {
            let handle_event: Function = lua_ctx.globals().get("handle_event")?;
            handle_event.call::<_, ()>(EventForLua(event))?;

            Ok(())
        })?;

        Ok(())
    }
}
```

And that's all there is to it!
That was surprisingly painless, all things considered.
The only part that hurt a bit was the glue from `Event` into Lua, which wasn't even that bad for my case, but depending on what you're doing it might be.

## duckscript

So Lua is a language I know I don't like all that much, and the gnarliest part of using it here was getting Rust types into it.
Let's see if [Duckscript](https://crates.io/crates/duckscript), a "simple, extendable and embeddable scripting language", will be even simpler.

Well, this is a minor nitpick, but if I want to write a custom command (which, I think, is the right way to get `print_fancy` available to our script) the trait for that requires that I manually write
```rust
fn clone_and_box(&self) -> Box<dyn Command> {
    Box::new(self.clone())
}
```

even though *anything that is `Clone` can already be cloned into a box*.
So that's a (very) minor nuisance.

The less-minor nuisance, it turns out, is that I can't figure out how to actually run a function defined in a script.
So I guess in Duckscript you can't do that, and we'll have to just rerun the whole script when the event gets fired.

But once we've discovered and adapted to those issues, there's not much actual code that needs writing.
Conveniently, since we can't have any persistent state anyway, there's no script context to store:
```rust
struct DuckscriptHost;

impl ScriptHost for DuckscriptHost {
    type ScriptContext = ();
    type Error = ScriptError;

    fn new_context() -> Result<Self::ScriptContext, ScriptError> {
        Ok(())
    }
```

The glue to expose our `print_fancy` is pretty terse as well:
```rust
#[derive(Clone)]
struct FancyPrintCommand;

impl Command for FancyPrintCommand {
    fn name(&self) -> String {
        "fancy_print".to_string()
    }

    fn clone_and_box(&self) -> Box<dyn Command> {
        Box::new(self.clone())
    }

    fn run(&self, arguments: Vec<String>) -> CommandResult {
        print_fancy(&arguments.join(" "));
        CommandResult::Continue(None)
    }
}
```

Once we've got this, we can handle events by setting up everything from scratch:
```rust
    fn handle_event(_context: &mut Self::ScriptContext, event: Event) -> Result<(), ScriptError> {
        // Make a context
        let mut context = Context::new();
        // Add the standard library
        duckscriptsdk::load(&mut context.commands)?;
        // Add our print_fancy command
        context.commands.set(Box::new(PrintFancyCommand))?;
        // Pick some strings to put in the context to represent our event
        let (event_type, event_value) = match event {
            Event::Number(value) => ("number", format!("{}", value)),
            Event::Text(value) => ("text", value)
        };
        context.variables.insert("event.type".to_string(), event_type.to_string());
        context.variables.insert("event.value".to_string(), event_value);
        // Run the script
        run_script_file("scripts/duckscript-sample.ds", context)?;
        Ok(())
    }
}
```

That's a lot of steps there.
As you may notice, we have to put the number into a string before we can add it to the context.
This is because all values in Duckscript are strings.

Well, now that we've got all the code to pass in variables and run it, let's write our event handler script:
```duckscript
if eq ${event.type} "number"
    echo "number!" ${event.value}
else
    echo "text!" ${event.value}
end
print_fancy "Got an event"
```

Technically, this all works.
But I don't like it.
It might be enough for your use case, though, and if it is, it'll work.

## rhai

We're still in search of a Rust-centric scripting language that's good for our use case, so let's see if [Rhai](https://crates.io/crates/rhai), "an embedded scripting language and evaluation engine for Rust that gives a safe and easy way to add scripting to any application", will be that.
It's got [an entire documentation book](https://schungx.github.io/rhai/), which is always nice to see, and WebAssembly support.
So hopefully this one is as cool as it looks.

Page four of said documentation book gives some really helpful clarity:
> Rhai’s purpose is to provide a dynamic layer over Rust code, in the same spirit of zero cost abstractions. It doesn’t attempt to be a new language.

That also sounds like exactly what we need.

Just take a minute and *look at how fucking gorgeous this code is*:
```rust
struct RhaiScriptHost;

impl ScriptHost for RhaiScriptHost {
    type ScriptContext = (Engine, Scope<'static>, AST);
    type Error = Box<EvalAltResult>;

    fn new_context() -> Result<Self::ScriptContext, Self::Error> {
        let mut engine = Engine::new();
        engine.register_fn("print_fancy", print_fancy);
        let mut scope = Scope::new();

        let ast = engine.compile_file_with_scope(&mut scope, PathBuf::from("scripts/rhai-sample.rhai"))?;
        // if there's some global state or on-boot handling, make sure it runs
        engine.consume_ast_with_scope(&mut scope, &ast)?;
        Ok((engine, scope, ast))
    }

    fn handle_event((engine, scope, ast): &mut Self::ScriptContext, event: Event) -> Result<(), Self::Error> {
        let argument = match event {
            Event::Number(number) => Dynamic::from(number),
            Event::Text(text) => Dynamic::from(text),
        };
        engine.call_fn(scope, ast, "handle_event", (argument,))?;
        Ok(())
    }
}
```

That's all of it.
That's the whole damn thing.
Our script is pretty darn straightforward, too, unsurprisingly:
```rhai
fn handle_event(data) {
    if type_of(data) == "i64" {
       print("number! " + data);
    } else {
       print("text! " + data);
    }
    print_fancy("got an event!");
}
```

Rhai doesn't have pattern matching, so we can't use our `Event` enum directly, but it does have runtime type introspection, so we can simply pass in either a number or a string and let the script sort it out.
(If this is possible in Lua, too, then we could've made our Lua implementation a little simpler, but I'm not as familiar with Lua.)

There's so much to love here, but my favorite part is that we don't need any extra glue at all around `print_fancy` to be able to expose it to our Rhai script.
This is *excellent*.
Well done to Stephen Chung, Jonathan Turner, and [the rest of the contributors](https://github.com/jonathandturner/rhai/graphs/contributors).
This is gonna be tough to beat.

## dyon

Ooh, [dyon](https://crates.io/crates/dyon) was built by one of the two big Rust game engine projects.
(In fairness, though, rlua was built by the other one.)

On the upside, this is almost as straightforward as Rhai was:
```rust
struct DyonScriptHost;

impl ScriptHost for DyonScriptHost {
    type ScriptContext = Arc<Module>;
    type Error = Error;

    fn new_context() -> Result<Self::ScriptContext, Error> {
        let mut module = Module::new();

        dyon_fn!{fn dyon_print_fancy(x: String) {
            print_fancy(&x);
        }}
        module.add_str("print_fancy", dyon_print_fancy, Dfn::nl(vec![Type::Str], Type::Void));

        load("scripts/dyon-sample.dyon", &mut module)?;

        Ok(Arc::new(module))
    }

    fn handle_event(context: &mut Self::ScriptContext, event: Event) -> Result<(), Error> {
        let call = Call::new("handle_event");
        let call = match event {
            Event::Number(value) => call.arg(value as f64),
            Event::Text(value) => call.arg(value),
        };

        call.run(&mut Runtime::new(), context)?;

        Ok(())
    }
}
```

Our script is likewise pretty straightforward:
```dyon
fn handle_event(data) {
    if typeof(data) == "number" {
       println("number! " + str(data))
    } else {
       println("text! " + data)
    }
    print_fancy("got an event!")
}
```

But the API took a really long time for me to actually figure out, and there are a few language features that I extremely don't get.
Like, they've got [secrets](http://www.piston.rs/dyon-tutorial/secrets.html) that can be attached to a bool or number, so you can ask for a retroactive explanation for why a function returned the value it did, or where a value came from.
And that's neat and all, but like. why.
Honestly I'm just not as impressed by this as I am by Rhai.
Maybe you are, though, in which case this might work well for you.

## gluon

[gluon](https://crates.io/crates/gluon), unlike our previous contestants, is a statically typed functional language.
Static types, for this context, are nice to have.
Functional programming... may or may not be, depending on how it's implemented.

Oh hey, at time of writing their website is down.
That's always a good sign.

An even better sign, of course, is the fact that trying to declare our Event type in Gluon causes a stack overflow.
In theory, since it's got algebraic data types, we could just declare it as is and bring it right on in, but unfortunately the code to do that 100% automatically appears to not compile, and the code to do that only almost automatically still requires us to write the type definition on the Gluon side manually:
```rust
vm.load_script("rust-scripting-languages.event", "type Event = Number Int | Text String")?;
```

I'm not sure why this causes a stack overflow either.
But it does.
As such, I have no clue how good this actually would be to use.

## ketos

[ketos](https://crates.io/crates/ketos) describes itself as "a Lisp dialect functional programming language".
So that ought to be interesting.

The Rust function glue all assumes your functions return a `Result` and that's a minor nuisance, but that's not insurmountable.
Overall, this is pretty terse:
```rust
struct KetosScriptHost;

impl ScriptHost for KetosScriptHost {
    type ScriptContext = Interpreter;
    type Error = Error;

    fn new_context() -> Result<Self::ScriptContext, Error> {
        let interp = Interpreter::new();

        let scope = interp.scope();

        fn print_fancy_fallible(text: &str) -> Result<(), Error> {
            print_fancy(text);
            Ok(())
        }

        ketos_fn! { scope => "print-fancy" => fn print_fancy_fallible(text: &str) -> () }

        interp.run_file(&PathBuf::from("scripts/ketos-sample.ket"))?;

        Ok(interp)
    }

    fn handle_event(context: &mut Self::ScriptContext, event: Event) -> Result<(), Error> {
        let value = match event {
            Event::Number(n) => Value::from(n),
            Event::Text(t) => Value::from(t),
        };
        context.call("handle-event", vec![value])?;

        Ok(())
    }
}
```

Our script itself is... definitely Lisp-y.
```ketos
(define (handle-event event)
    (do
        (println "~a ~a" (type-of event) event)
        (print-fancy "got an event!")))
```

This all works, and if you love Lisp and want your users to write a bunch of Lisp then this'll work perfectly for you.
But it's not really to my tastes.

## rune

[rune](https://crates.io/crates/rune) lists pattern matching in their README as a feature, so that's a good sign.
And they've got a Book that starts by giving a shout out to Rhai as a major inspiration, which is also neat.

Turns out the pattern matching doesn't let you match on enum variants even though Rune *has enums*.
So we've gotta do the same dynamic typing stuff we've been doing before.
But this is pretty clean:
```rust
struct RuneScriptHost;

impl ScriptHost for RuneScriptHost {
    type ScriptContext = Vm;
    type Error = Box<dyn Error + 'static>;

    fn new_context() -> Result<Vm, Self::Error> {
        let mut context = rune::default_context()?;

        let mut module = runestick::Module::default();
        module.function(&["print_fancy"], print_fancy)?;

        context.install(&module)?;

        let script = read_to_string("scripts/rune-sample.rn")?;

        let mut warnings = rune::Warnings::new();
        let unit = rune::load_source(&context, &Default::default(), Source::new("scripts/rune-sample.rn", &script), &mut warnings)?;

        let vm = Vm::new(Arc::new(context), Arc::new(unit));

        Ok(vm)
    }

    fn handle_event(vm: &mut Vm, event: Event) -> Result<(), Self::Error> {
        let arg = match event {
            Event::Number(n) => Value::from(n),
            Event::Text(t) => Value::from(t)
        };
        vm.clone().call(&["handle_event"], (arg,))?.complete()?;

        Ok(())
    }
}
```

Again, we have zero glue required for our `print_fancy` function, which is nice.
Our script looks pretty decent too:
```rune
fn handle_event(event) {
    match event {
        n if n is int => println(`Number! {n}`),
        t => println(`Text! {t}`),
    }
    print_fancy("got an event!")
}
```

The one issue I notice is that `Vm::call` takes `self` by value, which means we're forced to `clone()` our VM every time we want to handle a new event instead of handling them all in the same VM.
This probably means a more complicated script with some global state to maintain wouldn't be able to do that.
So if that's something you know you'll want to support, Rune might not be for you, unless there's a different way to do this that I didn't find in the docs.
But if you know you don't need that, Rune might work well for you.

## ruwren

[ruwren](https://crates.io/crates/ruwren) provides bindings to the [Wren](https://wren.io/) embeddable scripting language, which looks kinda neat:
> Think Smalltalk in a Lua-sized package with a dash of Erlang and wrapped up in a familiar, modern syntax.

I think the example presented in the README at time of writing is incomplete and buggy, but I figured out how to fix it and sent in a pull request.

We do have to write some glue for our `print_fancy` method; since Wren is inspired by Smalltalk, everything is objects, so we need a class within which `print_fancy` can be a static method:
```rust
struct Demo;

impl Class for Demo {
    fn initialize(_: &VM) -> Self {
        Demo
    }
}

impl Demo {
    fn print_fancy(vm: &VM) {
        let text = get_slot_checked!(vm => string 1);
        print_fancy(&text);
    }
}

create_module! {
    class("Demo") crate::Demo => foo {
        static(fn "print_fancy", 1) print_fancy
    }

    module => demo
}
```

Armed with this, the actual integration is pretty straightforward:
```rust
struct RuwrenScriptHost;

impl ScriptHost for RuwrenScriptHost {
    type ScriptContext = VMWrapper;
    type Error = Box<dyn Error + 'static>;

    fn new_context() -> Result<Self::ScriptContext, Self::Error> {
        let mut modules = ModuleLibrary::new();
        demo::publish_module(&mut modules);

        let vm = VMConfig::new()
            .library(&modules)
            .build();

        vm.interpret("demo", r##"
        foreign class Demo {
            foreign static print_fancy(string)
        }
        "##)?;

        let script = read_to_string("scripts/ruwren-sample.wren")?;
        vm.interpret("main", &script)?;

        Ok(vm)
    }

    fn handle_event(vm: &mut VMWrapper, event: Event) -> Result<(), Self::Error> {
        vm.execute(|vm| {
            vm.ensure_slots(2);
            vm.get_variable("main", "EventHandler", 0);
            match &event {
                Event::Number(n) => vm.set_slot_double(1, *n as f64),
                Event::Text(t) => vm.set_slot_string(1, t),
            }
        });
        vm.call(FunctionSignature::new_function("handleEvent", 1))?;

        Ok(())
    }
}
```

And our test script in Wren looks nice:
```wren
import "demo" for Demo
class EventHandler {
    static handleEvent(data) {
        if (data is Num) {
            System.print("Number! %(data)")
        } else {
            System.print("Text! %(data)")
        }
        Demo.print_fancy("got an event")
    }
}
```

Overall, I think this is pretty good.
This specific use case isn't particularly well suited to Smalltalk-style object orientation, but if yours is then this will work well for you.
Plus, since Wren isn't Rust-specific, it might be slightly more portable, if that's a concern for you.

## summary

So those are our options.
A convenient bullet points tl;dr for you:
- Use [rlua](https://crates.io/crates/rlua) if you specifically want a scripting language that some of your users might already know.
- Use [ruwren](https://crates.io/crates/ruwren) if you specifically want a Smalltalk-like (object-oriented) scripting language.
- Use [ketos](https://crates.io/crates/ketos) if you specifically want a LISP-like (parentheses-oriented) scripting language.
- Use [rhai](https://crates.io/crates/rhai) if you just want a good scripting language.
