+++
date = '2021-09-15T00:00:00Z'
draft = true
subtitle = 'From scratch. Yet again.'
title = 'Configuring a new environment'
+++

As a developer, everyone comes up with a unique set of customizatons over several years of using their machine. I have too. We spend years perfecting each and every setting for each and every app till we get everything right, and one fine day, we realise that our system is too old to function anymore. We get a new one. It has the latest and the greatest features of the present generation, but we realise that something is just not right. We're so used to our bag of tricks that we start tweaking everything to match the previous setup. And at that moment, we got no choice but to wonder, "If only I had documented them somewhere". I recently bought a new machine, and I'm in the same boat.

But this time, I'll learn from my mistakes, and I'll document all sorts of customizations that I'm going to follow to set up my new MacBook. Feel free to check them out. Oh, by the way, I'm aware that software changes rapidly and my favourites for today might not be the same as my favourites for tomorrow, but still, I also realise that a lot of them might still be the same. So, here are my set of customizations for September 2021.

## Browser
This is one of the most important pieces of software that we'll be interacting with on a daily basis. I've been a hardcore Chrome user since the time it was released, and I've stuck with it since then. But more recently, I've noticed how power hungry it is, and it's been bothering me for a while now. I got a new M1 MacBook Air, and I've been pleasantly surprised by the result of running optimized software for this chip. So I decided to give Safari a try. Moreover, you're going to have to interact with safar at least once (you'll need safari to download chrome, for instance :upside_down_face:), so why not give it a chance? Something to keep in mind, though. Safari does not display the full website address on the address bar. To change it, go to Preferences > Advanced and tick "Show full website address".

## Code Editor
I mostly use python on a daily basis, but I also work with other languages like Javascript and C++. So I strongly prefer a code editor over an IDE anyday. I've been using VSCode for quite some time. Thanks to @agrawalamey for persuading me to make the shift, and I'm proud to say that I haven't regretted that decision. I used to work on Sublime Text and Atom in the past, but VSCode is a refined product. Moreover, the set of plugins available let you work with almost language/framework. The major attraction for me is its remote editing capabilities, which I find lacking in most other code editors.

## Terminal
Until recently, Mac used bash as its default shell, but this was changed to ZSH in MacOS Catalina. To access the shell, I still use Mac's built in *Terminal* instead of third party apps (I've heard iTerm2 is pretty great, but I'm a man of habit, so I'll stick with Terminal for now). What I don't like about the terminal is its default theme. So first, click on preferences, and choose "Pro" as the default theme. I also changed the font to Monaco, 10pt and in the *Shell* tab, I check "Close if shell exited cleanly" because I usually exit shells by typing `exit`.

Anyone who's heard of Zsh must have also heard about Oh My Zsh, the plugin and theme system for Zsh. At one point I wanted to keep my system free from any bloatware as possible, but I finally gave in. Install ZSH from the official website.

