+++
title = "Zotfetch: Fetch and Relocate PDFs in Zotero 7"
categories = ['Tools']
date = '2024-02-29'
slug = 'introducing-zotfetch'
draft = false
+++

In a [previous post]({{< ref "033-zotero-file-sync.md" >}}), I explained that if your Zotero
workflow mainly involves syncing PDF annotations, you can use Zotero on multiple devices without the
need for its file sync feature. To make this work, you could use Zotero's `Run Javascript` feature
and paste a code snippet. If you find yourself doing this frequently, like myself, you might feel
the need for a straightforward solution that does this for you at the click of a button. I certainly
did, so I took it upon myself to create an addon that lets me fetch and relocate missing PDFs. Allow
me to introduce [Zotfetch](https://github.com/nikhilweee/zotfetch)!

# What is ZotFetch?

If you install Zotero on a new device and you don't have file sync turned on, Zotero will sync all
database entries in your library but the actual attachments will still be missing. In which case,
when you try to open an entry from your libary, you will be greeted with an error like this.

{{<figure src="https://i.imgur.com/BdSmWMt.jpg" caption="Zotero throws an error when file sync is disabled.">}}

Zotfetch is a simple extension that tries to remedy this situation by downloading the missing PDF
from the internet. To use Zotfetch, select one or more entries in your database by holding `CTRL` /
`CMD`, right click, then click on the context menu entry called `Zotfetch: Relocate`.

{{<figure src="https://i.imgur.com/jHAKFtB.jpg" caption="Zotfetch can be activated from the context menu.">}}
{{<figure src="https://i.imgur.com/jZnoc9G.jpg" caption="Zotfetch will automatically fetch PDFs from the internet.">}}

Zotfetch will show you a popup with details about its progress. If you selected multiple items,
Zotfetch will download PDFs in parallel. This is an easy way to recreate your entire library without
having to use Zotero's file sync feature especially if you just signed in to a new device.

# Installation

Installing Zotfetch is easy. Just head over to Zotfetch's
[releases](https://github.com/nikhilweee/zotfetch/releases) page on GitHub and download
[`zotfetch.xpi`](https://github.com/nikhilweee/zotfetch/releases/latest/download/zotfetch.xpi) from
the latest release. Next, open Zotero, then click `Tools` > `Add-ons`. On the Add-ons Manager window
that appears, click the cog icon, then click `Install Add-on from File...` and locate `zotfetch.xpi`
that you just downloaded. If everything goes smoothly, you should see `Zotfetch: Relocate` in the
context menu when you right click on any item.

# How does it work?

Behind the scenes, Zotfetch uses Zotero's in-built _Find Available PDFs_ feature. That's strange,
you may think. If such a function already exists, what's the need for a new extension? Turns out the
_Find Available PDFs_ menu only appears for items which don't have an attachment associated with
them already. If the attachment goes missing, the menu item does not appear.

{{<figure src="https://i.imgur.com/KoRpob0.jpg" caption="Zotero only shows _Find Available PDFs_ selectively.">}}

Not only does Zotfetch expose hidden functionality, it also makes sure that you don't lose any
annotations because of missing attachments. Zotfetch merely tries to download the missing attachment
without altering the database entry. This is different from _Find Available PDFs_ which will create
a new database entry for the attachment. Since Zotero saves PDF annotations with the database entry
for the attachment, your annotations are safe with Zotfetch.

# Caveats

Make no mistake. This is an extension that I came up with in my free time. I am no expert in writing
extensions for Zotero, and moreover doing so is no easy feat given the lack of documentation about
Zotero. All this to say that Zotfetch us certainly not perfect. Here are some things you should keep
in mind before trying it out:

1. This extension only supports Zotero 7, which is still in beta at the time of this writing.
2. If there are multiple PDFs available, there is no option to choose between them.
3. This extension only works on the desktop version for now.

Disclaimers aside, the extension is [open source](https://github.com/nikhilweee/zotfetch). If you
have ideas for improvement, feel free to contribute. I even came up with a small
[guide](https://github.com/nikhilweee/zotfetch/blob/main/GUIDE.md) that might help you if you are
new to writing extensions for Zotero. I hope that saves you some trouble.
