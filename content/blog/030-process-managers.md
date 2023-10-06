+++
categories = ['Experiences']
date = '2023-08-22'
slug = 'linux-process-managers'
subtitle = 'or how PM2 works surprisingly well for Python'
title = 'Linux Process Managers'
draft = true
toc = false
+++

When starting a hobby project (and this is even more true in the case of a work
project) a lot of time on the internet is spent searching for _the best tool for
\<insert task here>_. More recently, I was on the lookout for a process manager
that would primarily manage a `gunicorn` based Django app amongst other scripts
running on a Linux machine.

There are plenty of options to consider, but I narrowed down my choices to three
popular alternatives: `supervisord`, `systemd` and `pm2`. I'm considering
systemd because it's already installed on many linux systems, supervisord
because it's python based and has also been around for the longest time, and
even though pm2 is typically used to manage node.js applications, I'm
considering it for its relative ease of use. And with that, I should emphasize
that although there's no single answer here, this article is particularly biased
by my own choices, and you should keep that in mind while reading the rest of
this piece.

# Systemd

---

Let's start with the one that's already available on most linux systems. Systemd
is a popular choice, and is already trusted with managing many critical services
like `sshd` and `cron`. New services can be added through a _service unit_ file
that contains details about the process, working directory, environment
variables, and the likes. Once these files are in order, you can use the
familiar `systemctl` frontend to interact with systemd processes.

```console
$ # <command> can be start, stop, enable,
$ # disable, reload, restart, status, etc
$ sudo systemctl <command> <service>
```

If you're looking for a reliable process manager and don't want to spend time
setting things up, systemd could probably be your first choice. That being said,
I personally do not prefer systemd because I don't want to accidentally mess
with a system service. Imagine being locked out of your machine if you
accidentally stop the ssh service. Or worse, imagine if you mess up networking
and there's no easy way for your cloud provider to help you out. Now you might
say "but hey, systemd requires sudo!" and you'd be right, but I would rather be
happy wandering in safe waters than being careful in dangerous territory.

# Supervisord

---

With its initial release in 2004, `supervisord` is the oldest process manager
out of the three. And although it doesn't come preinstalled on any system, the
fact that it's been around for about two decades definitely gives it a lot of
credibility. By the way, if you don't have supervisor, it's just a `pip install`
away! Just like `systemd`, the way to manage a process using supervisor is to
create an INI-style configuration file. `supervisord` also provides a frontend
called `supervisorctl` to manage processes.

```console
$ # <command> can be start, stop, status, restart, etc
$ supervisorctl <command> <process>
```

Well, that's precisely why its not my first choice. I'm not very comfortable
editing `ini` files in a directory that also stores the configuration for other
critical services. I would much rather prefer managing my processes separately,
and if possible, without having to edit configuration files at all.

I did not consider it simply because of ease of use.

Although `supervisord` is not very different when it comes to ease of use, it's
worth spending some time Both `supervisord` and `systemd` use `ini` files for
process configuration. may be considered the default choice since it's written
in Python and has been around for about two decades now, it is also old quite
old. Don't get me wrong, old means that it's battle tested and has survived the
test of time, but it also means that when it comes to decision making, there are
better design choices available right now compared to its first release in 2004.

The biggest reason to favour `pm2` is the relative ease of use. I don't have to
type `sudo systemctl` before practically doing anything. Same with
`supervisorctl`. Although that's less of a mess because I can type `sup` `<tab>`
`c` `<tab>` to autocomplete `supervisorctl`.

`pm2` is short and sweet.
