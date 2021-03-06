---
layout: default
title: "Post-Open Source"
description: "FOSS is dead. what now?"
---

i'm writing this like a day after [big mozilla layoffs](https://www.fastcompany.com/90539632/mozilla-vows-mdn-isnt-going-anywhere-as-layoffs-cause-panic-among-developers) that included a lot of people working on cool and important shit.
the consensus i'm seeing is that it reflects mozilla's search for profit over impact, mismanagement, and disproportionate executive compensation.
this is taking place in a larger trend of corporatization of open source over the past several years, an ongoing open source sustainability crisis, and of course COVID-19, the all-consuming crisis that makes all our other crises worse.
all of this was summed up most concisely by [Kat Marchán](https://twitter.com/zkat__/status/1293626135142477825):

> Imo, open source as a community endeavor is falling apart right before our eyes, and being replaced by open source as Big Corp entrenchment strategy.
>
> I mean it's been happening for a while, but seeing Mozilla sinking like this is just driving the point home for me.
>
> FOSS is dead

how did we get here?
where even are we?
what happens next?

i am incredibly unqualified to answer any of this - i didn't show up until right around the peak of SourceForge, i wasn't there for most of this - but i'm not gonna let that stop me.

## names

to start this funeral service for FOSS, we have to unpack the term itself.
"free and open source software" as a term already contains multitudes.
on one hand, "free software", an explicitly political movement with a decidedly anti-charismatic leader.
on the other hand, "open source software", defanged and corporate-friendly by design.
the free software people (correctly) criticize "open source" as milquetoast centrism.
the open source people (correctly) criticize "free software" as stubborn idealism fighting tooth and nail to reject the real world as it actually exists.
they have as much in common as leftists and liberals (but they're more prepared to work together), and although their short-term goals were similar enough that it made sense to lump them together (hence the cooperation), now that the movement is dead i think there's more to gain from considering them separately.
most software licenses that i'm going to bring up technically qualify as both, but they're popular with one or the other, so i'll refer to "free software licenses" and "open source licenses" as licenses that are more directly tied to those movements, even though any given license likely meets both definitions.

i'd say free software died a while ago, and open source went horribly right.

## freedom

the free software movement, for all its faults, has always known [what it's about](https://www.gnu.org/philosophy/free-sw.html.en):

> 0. The freedom to run the program for any purpose.
> 1. The freedom to study how the program works, and change it to make it do what you wish.
> 2. The freedom to redistribute and make copies so you can help your neighbour.
> 3. The freedom to improve the program, and release your improvements (and modified versions in general) to the public, so that the whole community benefits.

it's concise, it's understandable, and it's… kinda useless.
this point was [raised better by actual lawyer Luis Villa](https://lu.is/blog/2016/03/23/free-as-in-my-libreplanet-2016-talk/) (Karl Marx slander notwithstanding), but those freedoms don't actually mean shit to the average end user.
only programmers care if they have access to the source code, and most people aren't programmers.
and i *am* a programmer, and i don't give a shit.
the freedom to not think about my operating system and just get work done overrules all of those for me, so i use windows.
like, yeah, those things are all in principle nice to have, and between two otherwise equally good programs i'd take the free one.
but they're really fuckin specific things, and even if i have the freedom to do them i'm not likely to have the ability or desire to do them, so there's no good reason for me as a user to use software that's worse in other ways because it gives me freedoms i don't need.

the free software movement is explicitly political, but its politics suck.
it's a movement by and for ideological diehards but the ideology is extremely esoteric.
theirs was a losing battle from day one.
so what was it that actually killed them?
i think in a very real way it was the GPLv3.

## losing

the flagship projects of the free software movement are probably Linux and the GNU pile of tools.
the Linux kernel being released under a free software license doesn't directly create more free software, though, since even things that tie closely to the kernel aren't obligated to also be free software, and of course user-level applications can have whatever license they want.
and also most of the people using Linux right now are using it by accident, distributed as ChromeOS or Android, neither of which is free software.
so Linux is a win for the free software movement but a useless one.

the GNU userland tools are, for the most part, even more underwhelming.
it may be technically more accurate to call it GNU/Linux, but the only time i remember my linux userland tools are GNU or free software at all is when there's [some weird inconsistency between a GNU tool and its BSD equivalent](https://twitter.com/boring_cactus/status/1166408436386430976), and that's not exactly ideal.
gcc had, as far as i can tell, been basically *the* C compiler for a while, if you weren't stuck with MSVC or something worse.
the free software movement were stubborn ideologues with weird priorities, but they still had one big technical advantage.
then the GPLv3 happened.

the GPLv2 was pretty popular at the time, but there were a couple notable loopholes some big corporations had been taking advantage of, which the free software people wanted to close.
a whole bunch of people thought the GPLv2 was fine the way it was, though - closing the loopholes as aggressively as the GPLv3 did cut off some justifiable security measures, and some people said that it could do more harm than good.
the linux kernel, along with a lot more stuff, declared it was sticking with the GPLv2 and not moving to the GPLv3.
when your movement says "here is the new version of The Right Way To Do Things" and several of your largest adherents say "nah fuck you we're going with the old version" that is not a good sign.
around the same time, free software organizations were starting to successfully sue companies who were using free software but not complying with the license.
so big companies, like Apple, saw new restrictions coming in at the same time as more aggressive enforcement, and said "well shit, we want to base our software on these handy convenient tools like GCC but we can't use GPLv3 software while keeping our hardware and software as locked together as we'd like."
so they started pouring money into a new C compiler, LLVM, that was instead open source.

and LLVM became at least as good as GCC, and a less risky decision for big companies, and easier to use to build new languages.
so the free software movement's last technical advantage was gone.
its social advantages also kinda went up in flames with the GPLv3, too: the software that was the foundation for the GPL enforcement lawsuits stuck with the GPLv2.
the discourse over that decision was so nasty that the lead maintainer (Rob Landley; he'll come up later) started an identical project which he wound up relicensing under an open source license because the lawsuits had completely backfired: instead of complying with the terms of the GPL, companies were just avoiding GPL software.

the free software movement, in the end, burned itself out, by fighting for a tiny crumb of success and then turning around and lighting that success on fire.
the death of free software tells us that we can't use a license to trick corporations into sharing our values: they want to profit, and if good software has a license that puts a limit on how much they can do that, they'll put more resources into writing their own alternative than they would spend complying with the license in the first place.

## openness

the open source movement manages to share the same short term goals as the free software movement but be bad in almost entirely disjoint ways.
the [mission of the Open Source Initiative](https://opensource.org/about) says

> Open source enables a development method for software that harnesses the power of distributed peer review and transparency of process.
> The promise of open source is higher quality, better reliability, greater flexibility, lower cost, and an end to predatory vendor lock-in.

this is so profoundly different from the free software definition that it's almost comical.
where free software says "we value freedom, which we define in these ways," open source says "your code will get better."
the free software movement was prepared to start fights with corporations that used their work but didn't play by their rules.
the open source movement was invented to be a friendly, apolitical, pro-corporate alternative to the free software movement.

the contrast between "use free software because it preserves your freedom" and "use open source software because it's better" is profound and honestly a little disappointing to revisit this explicitly.
free software preserves freedoms i don't need or care about as a user, but it does at least do that.
open source software is frequently not in fact better than closed source alternatives, and "use open source software because on rare occasions it manages to be almost as good" is an even more underwhelming sales pitch than anything free software can give.

where free software is misguided and quixotic, open source is spineless and centrist.
and as tends to happen with spineless centrism, it has eaten the world.

## winning

if there's anything corporations love more than rewriting software so it lets them make all the money they can dream of, it's letting other people do that work for them.
it took a while to take off, because the conservative approach of "keep things closed source" was pretty solidly entrenched in a lot of places, but now even the once conservative holdouts have accepted the gospel of centrism.
corporations have little to nothing to lose by publishing existing source code, and can gain all sorts of unpaid volunteer labor.
if they start a new internal project, important enough that they're prepared to put effort into it but not so important that someone could run off with it and compete with them, then now they'll likely open source it.
worst case scenario, they do all the work they were already prepared to do.
best case scenario, their library turns into the single most popular library of its type, with thousands of unpaid volunteers donating their time to you.
more labor for free, community goodwill for having started the project everybody uses, the benefits if it goes well are countless.
free software is not in principle anti-corporate, but corporations are very cautious getting caught up in the free software movement, because that actually creates obligations for them.
open source gives corporations a shot at improving their code for free, so as long as they don't share so much someone could start a competitor, so there's zero reason for a corporation to not get into open source.

the best part for corporations is they don't even have to be the ones to start a project.
if you're just some random small time developer, they can just show up.
you made a cool database server that's under an open source license?
amazon's selling it as a service now, and they're not paying you a fuckin dime.
you want to change your license to stop them from doing that?
now the open source people are yelling at you, because when they say they're apolitical they mean they support the status quo.
and the free software people are also yelling at you, because you didn't do it their way with their license, you did it a different way with a different license, and that goes against amazon's freedom to screw you over.

github itself is arguably the epitome of the open source movement.
the platform itself is closed source, because they don't want people to compete with them running their code, and also they sell the very expensive self-hosted version to corporations.
opening up the source for github itself would take a chunk out of github's profits.
can't have that.
but they don't even need to start or adopt an open source component to profit off other people's labor: *literally every project on github* makes github more valuable.
popular projects get people in, network effects bring their colleagues in, and then when it's time for something that you'd rather have closed source you and everyone else are already on github so you might as well spring for the paid tier.
if they believed open source was in principle better, they'd be open source themselves.
they believe open source is profitable for them, and corporate profit is by definition value generated by labor but not paid to the laborer.

what's good for corporations is, of course, bad for people.
random individual contributors almost never get paid for their work, even when a corporation or several will profit substantially from those changes.
maintainers of vital infrastructure libraries generally only get paid if they wrote the library for or under the control of the company they worked for anyway.
professional, corporate maintainers can offer more to the community since they're getting paid for it, which heightens expectations on independent maintainers and leads to maintainer burnout.
and if a company runs off with some existing open source software, they can build their secret competitive advantage around it without giving any of that work back to the original authors.

all of these individual crises are by design: this was always the endgame of the open source movement.
the free software movement was transparent with its greatest value: "we believe users should have the freedom to mess with and contribute to the source code of the programs they use."
the open source movement had a far subtler value: "we believe corporations should have the freedom to exploit the labor of developers."
the fact that individual developers were ever on board with the open source movement speaks to the pernicious branding it employs.
but people are starting to notice that this isn't actually good at all.

the free software movement was on occasion writing actually good software; corporations saw that and wanted to get in on it without having to actually have principles.
so they embraced the nominal goals of the free software movement and extended it into a more corporate-friendly movement with a larger pile of software to draw from.
the conventional step after embrace and extend is, [naturally](https://en.wikipedia.org/wiki/Embrace,_extend,_and_extinguish), extinguish.
the free software movement died long ago, in no small part due to its own mistakes, so there's not much left to extinguish.
that which is being extinguished, that which died with mozilla, is the idea that the open source movement could have any other principles than corporate exploitation.

i wouldn't say that the open source movement died per se.
it was undead from the moment it began; it won, and with its victory it has stopped pretending to be anything other than a lich.
the only meaningful lesson to learn from the open source movement is that letting corporations do whatever the hell they want ends poorly, which is not exactly news.

## not learning

open source won, and nothing got better.
in an effort to fix this feature of the open source movement, some people have chosen to repeat the mistakes of the free software movement.
as [some smart german dude](https://en.wikipedia.org/wiki/Karl_Marx) once said, everything in history happens twice, first as tragedy, then as farce.

the free software movement declared that the user's freedom to tinker with and contribute to the software they use is supreme, and they wrote a license specifically built to preserve that in software applied to it, and to spread that freedom to software based on it.
an uninspiring but at least well-defined goal, pursued somewhat decently, with at least some lasting success.

the "ethical source" movement declares that the UN's Universal Declaration of Human Rights is supreme, with relevant laws in whatever jurisdiction is relevant a close second, and the Hippocratic License says "if the software author says you're violating human rights you have to go through public arbitration or the license is void."
the goal is at least in principle better, so that's something, at least.
although i will say, if someone releases a data visualization library under the Hippocratic License and someone else uses that library to display leaked personal information of police officers who got away with murder, there are several articles of the Universal Declaration of Human Rights that'd arguably be violated, so the library author would likely have grounds to make a nuisance of themself.
and that sucks shit.
the fact that the website for the Hippocratic License is `firstdonoharm.dev` kinda gives the whole thing away, because sometimes a little harm in one way prevents a much greater harm in some other way.
there's a reason doctors don't use the hippocratic oath anymore.

even setting that aside, there's a far greater issue with the Hippocratic License.
show me a corporate lawyer who'll look at a license that says "i can drag you into arbitration proceedings that have to be public whenever i want and there's no consequences for me doing that in bad faith" and say "yeah that looks good, we can use this library" and i'll show you a corporate lawyer who's gonna get fired tomorrow.
the free software movement tried and failed to use a license to trick corporations into sharing their values.
the ethical source movement appears to be trying to use a worse license to trick corporations into sharing less concretely defined values.

until all the talented people in that community start doing more useful things with their time, we can at least learn a few things from this preemptive failure.
one, trying to bake the complexity of an ethical system into your license is a fool's errand that will not go well.
two, if you're writing a license to coerce companies into behaving differently, don't scare them off right out of the gate with a poorly considered enforcement system.

## options

the term "post-open source" apparently was used by a couple people in like 2012 to refer to just not giving your code a license.
it's got a [wikipedia page](https://en.wikipedia.org/w/index.php?title=Post_open_source&oldid=890953566) that's had the "this might not be notable enough for wikipedia" box applied to it since 2013.
i am declaring that Basically Dead and so i'm using that term in a broader way now.

so what do we do after open source has eaten the world?
the retro option, apparently, is to skip the license entirely.
it'll scare off the corporations, since they technically can't safely use your work if you maintain full copyright.
and as actual lawyer Luis Villa [pointed out at the time](https://lu.is/blog/2013/01/27/taking-post-open-source-seriously-as-a-statement-about-copyright-law/), the idea that you need to give other people permission to do things like modify your code for themselves is something we shouldn't automatically take for granted.
(although i must say, for someone who claims to hate "permission culture" so much, Nina Paley sure does seem concerned with giving people permission to count as women.
TERFs fuck off, now and forever.)
not using a license at all can be interpreted as a conscious rejection not just of copyright but also of the endeavor to wield copyright as a tool for justice at all.

however, not using a license at all also makes it complicated for actual human beings who want to use your software.
Villa points to a favorite of mine, the [Do What The Fuck You Want To Public License](http://www.wtfpl.net/), as a way to make the implicit permissiveness of rejecting licensing altogether explicit while preserving the anti-serious aspect.
however, once the corporations realize that they're allowed to use software that says fuck, they can and will exploit the shit out of WTFPL software, so this does not provide a long term solution for the problems with open source.
(it is, however, really good, so i will count it as post-open source at heart even though it is essentially just open source).
its nominally equivalent but more serious cousin, [zero-clause BSD](http://landley.net/toybox/license.html), was written by the same Rob Landley whose experience navigating GPLv2 vs GPLv3 was so unpleasant back in the day; it's no fun, and i wouldn't call it a post-open source license, but it is in a very real way a post-free software license, and the exact opposite of the GPL.
and in fairness i'd be trying to write the opposite of the GPL after that mess too.

the ethical source people are trying to use the hippocratic license to make it illegal to use certain software if you're doing bad things.
the issues with that were the broad definition of "bad things" and the weird enforcement provisions.
you can take both of those to the other extreme and get the [JSON License](https://www.json.org/license.html).
it's just a regular MIT/BSD/X11/whatever permissive license but with an extra caveat:

> The Software shall be used for Good, not Evil.

now, this is basically decorative (although evidently IBM paid the author for permission to do evil with that software, which is *fucking beautiful*), but it does also scare off corporations while letting normal people do whatever.
i actually had a [brief twitter exchange](https://twitter.com/boring_cactus/status/1090803883230679040) with the unparalleled jenn schiffer about the effectiveness of the json license a while back, but she understandably doesn't let ancient tweets linger forever, so whatever actual points were made there are lost to time.
it does at least manage to solve the problems with the hippocratic license, though: the definition of evil is left completely implicit anyway, and the mechanism for enforcement is just copyright law like with any old license.
now, since the vagueness is left implicit, there's room to argue that the clause is unenforceable.
nobody has tested it, but that's a loophole waiting to be exploited, and also it's not as fun as the WTFPL.
as such, right before i started writing this blog post i wrote the [fuck around and find out license v0.1](https://git.sr.ht/~boringcactus/fafol/tree/master/LICENSE-v0.1.md) (or FAFOL for short), which replaces the json license's ethics disclaimer with something more clear:

> the software shall be used for Good, not Evil. the original author of the software retains the sole and exclusive right to determine which uses are Good and which uses are Evil.

now it is unambiguous in its intent, and also, it says fuck in the title.
as such, it is the only good software license.

*update 2020-08-17*: i have set up [broader infrastructure around the Fuck Around and Find Out License](https://git.sr.ht/~boringcactus/fafol/tree/master/README.md), if you're interested.

on a more sincere note, some licenses are trying to solve the problem of corporate exploitation by bringing back into fashion the idea of public-private licenses, where the default license is principled and corporations can simply pay for an exception and be covered by a different license instead.
the most interesting of these projects, at least as of August 2020, is [license zero](https://licensezero.com/), run by actual lawyer Kyle E. Mitchell, which offers two different public licenses, one standard private license template, and infrastructure for automatically selling exceptions.
their Parity license is a share-alike license that allows any use that is also published under an open license.
their Prosperity license allows any use as long as it is not commercial in nature; as such, it technically doesn't satisfy the Open Source Definition and is thus in a very concrete sense a post-open source license.
their Patreon license, which isn't linked on their homepage at all, grants an automatic license exception for certain financial supporters.
Kat Marchán, whose tweet i opened this blog post with, has a [blog post of their own](https://dev.to/zkat/a-system-for-sustainable-foss-11k9) explaining one approach to using license zero's tools as a solution to the open source sustainability crisis.
license zero the project appears to be currently working through some branding issues, and might have a different name and structure by the time you're reading this.
but as it stands it's at least relevant.

an additional concept comes once more from actual lawyer Luis Villa, who was [talking about data and not code](https://lu.is/blog/2016/09/26/public-licenses-and-data-so-what-to-do-instead/) when he said all this, but i think it can be applied to code too.
i'll let him summarize his post himself:

> tl;dr: say no to licenses, say yes to norms.

a license is a tool of the law, but the law is not actually very good at delineating the exact boundaries of ethical behavior (in either direction).
as such, the approach Villa describes is to tell the law to mind its own damn business and use a maximally permissive license, and then use social norms to delineate what behavior you do and do not find acceptable.
norms are tough to start from scratch, but sociologically they can fill a similar role in principle to laws while maintaining flexibility.
i'm not quite sure what a normative approach to post-open source software would look like - i'm not aware of anyone attempting to implement it, and i'm not sure i'm ready to be the first - but most likely it'd combine the WTFPL (or, more plausibly, zero-clause BSD) with an ecosystem of standard sets of norms similar to the current varieties in codes of conduct.

*update 2020-08-15*: actual lawyer Kyle E. Mitchell proposed an implementation of this approach in early 2019 and i think everyone should go read [that proposal](https://writing.kemitchell.com/2019/03/15/Ethical-Subcommons.html) right now and then come back to this blog post.

and since i've been quoting him the whole time, i should probably also give a shout out to actual lawyer Luis Villa's current project, [Tidelift](https://tidelift.com/), which is trying to address open source funding at both ends.
for corporate clients, (it looks like) tidelift is selling known-good, actively maintained, secure dependency subscriptions, and for open source maintainers, they're (i think) offering not just a proportional cut of the subscription revenue but also resources for keeping projects good, maintained, and secure.
i haven't used it on either end, i'm just paraphrasing their marketing copy, but they do exist.

## evaluation

so those are some options for what we do next.
which ones are good?
here we venture even deeper into my arbitrary, poorly informed, untrustworthy opinion than we already were.

rejecting licenses altogether is fun but feels kinda halfhearted.
like, if you think licenses are a waste of time, you can just use the WTFPL and get in principle the same effect but with more gratuitous profanity.
also, you can't refer to software that doesn't have a license as "unlicensed" because some chucklefucks decided to make a license called The Unlicense and so it's ambiguous now.
"license-free" just doesn't have the same ring to it.
and more concretely, if you have a real organization that wants to do actual good with your work, they probably still have a lawyer telling them copyright exists, and it'd be good to give them explicit permission to be doing good things.

the zero-clause BSD license is the most open of open source licenses, and as such it inherits all the issues of the open source movement it is attached to.
it's essentially the same as releasing your software to the public domain, skipping copyright entirely and giving basically unlimited permissions, and therefore providing no protection from exploitation.
the WTFPL is in practice probably equivalent, but in theory scares off lawyers by being impossible to take seriously.
however, i remember when i got into dogecoin back when dogecoin was a Thing i thought it was impossible to take seriously and therefore immune from the cryptocurrency true believers, and that wound up pretty decidedly not happening.
so a surface-level anti-serious tone is not foolproof protection against bad things.
i've released software under the WTFPL, and i'd likely do it again for code i have no interest in maintaining for other people's benefit, but i would never use it as a license for a library i wanted other people to use.

if i recall correctly, the JSON license was explicitly intended as a jab at corporate lawyers, and so it is close in spirit to the WTFPL.
and my FAFOL makes that harmony even greater.
but as we (or at least some of us) learned from the free software movement, using a license as a tool of enacting corporate ethics by proxy is essentially impossible; corporations interpret ethics as damage and route around them.
so as funny as it is, it's not actually useful.

license zero's work has a chance to succeed at creating funding opportunities for software maintainers.
if you're going to want to cut into a corporation's profits, the best way that can go for you is if they can budget in the cost of your exception.
i'm not aware of instances of that actually working super well for anybody, but maybe it's happened and i haven't heard, or maybe it'll happen as time goes on.
same goes for tidelift, honestly.
trying to solve specifically the maintainer-side economic issues is an approach i'm not qualified to evaluate, but it definitely feels more like a medium-term patch to the open source movement than a long-term fix.

i think the normative approach is at least in principle worth exploring, and maybe the next project i release will be stapled to an experiment with that.
it definitely feels like it has potential, and could actually supplant the open source model if it works well.
plus the idea of replacing laws with explicit but informal expectations and letting the community self-regulate warms my anarchist heart.

## conclusion

FOSS is dead.
free software died long ago, and open source software was a lich the whole time, only now claiming victory and beginning to pull up the ladder behind it.
what will come next?

i can't predict every aspect of the post-open source movement, but i can tell you one thing it'll absolutely require if it's going to be meaningful.

what really killed mozilla?
what really killed free software?
what really gave us the already-dead open source movement?

optimizing for profit at the expense of any other consideration.
chasing short-term gains and ignoring long-term sustainability or justice.
squeezing every drop of surplus value out of every person within reach and putting it in the hands of a dozen investors and overpaid executives.

in a word, capitalism.

if post-open source wants to not die the same death, it will need to explicitly and aggressively fight its greatest existential threat.
