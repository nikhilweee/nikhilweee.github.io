+++
categories = ['Tutorials']
date = '2016-01-28T00:00:00Z'
subtitle = 'Set up IRC on a blocked connection'
tags = ['irc', 'web']
title = 'Shout IRC!'
+++

If you're reading this, there are high chances that you are under internet surveillance and your IT
admin has blocked access to IRC. God! Why do they do this? IRC isn't bad at all, you may argue. But
unfortunately there's no one to listen. Hush. You'll have to find a way out, and here's exactly how
you can do it!

I'll be using one of the many benefits of
[having your own server](https://www.digitalocean.com/?refcode=ad1b7e083b2e) in the cloud. Sure it
costs you, but $5 a month won't hurt your pockets! Added to this, the open source community is just
awesome! It has tools for almost all your needs. Yes, it can help you get over IRC, and this blog is
one of their many freebies. Thank you Open Source!

So let's talk business. There's this tool called [**Shout IRC**](http://shout-irc.com/) which has
all what you need to get over your IRC block. And using it is as simple as logging in to your
account! Exactly what you needed? Perfect!

Although you can find instructions on how to use on their [website](http://shout-irc.com/), I'll cut
it short. All you have to do is install a `node` module, and edit some configuration files. Simple.

### 1. Installing

After you've logged in to your server,

```console
$ npm install -g shout
```

is what you do to install shout. That's it. However, if you don't have `node` or `npm` installed on
your Ubuntu based server, just run this

```
$ sudo apt-get install nodejs npm
$ sudo npm install -g npm
$ sudo ln -s "$(which nodejs)" /usr/bin/node
```

### 2. Configuring Shout

Doing it the easy way, just open up the configuration file. All you have to do is

```console
$ shout config
```

- The `public` setting gives you the option of allowing public access or restricted access using a
  username and password. Set it to `false` if you want user based access.
- Next, the `host` and `port` settings are pretty much self explanatory. I'll be using shout behind
  an nginx proxy, so set the host to `127.0.0.1` and the port to whatever you like, say `7468`.

You may change additional settings, but that is not required for now.

#### Adding users

If you've set `public` to `false`, you are required to add users to shout. To create a user named
'Nikhil', just run

```console
$ shout add nikhil password
```

With of course, your desired password, and the user with username `nikhil` is created.

### 3. Configuring Nginx

It's pretty likely that you also have other sites hosted on your server and so I'll be using nginx
which is pretty robust for this task. If you're familiar with this, you know what to do. Create a
new configuration for your site.

```console
$ sudo nano /etc/nginx/sites-available/irc
```

And run Shout IRC behind a proxy

```
server {
    listen 80;
    server_name <YOUR SITE ADDRESS>;
    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:7468;
    }
}
```

Replace `YOUR SITE ADDRESS` with the url you intend to use. Then, enable the site by creating a
symlink

```console
$ sudo ln -s /etc/nginx/sites-available/irc /etc/nginx/sites-enabled/irc
```

Now, just restart your server

```console
$ sudo service nginx restart
```

No. Shout isn't live yet, in case you were exited.

### 4. Withstanding restarts

It may happen that for some reason your shout service gets stopped, such as in a server restart.
That's bad. So, I'll use `supervisor` to manage Shout on my server. It'll start shout automatically
in case it gets shut down on the server. That way it'll even withstand server restarts. If you have
more than one service set up on your server, such as another blog or website, supervisor makes
managing all of them pretty easy.

First, install supervisor in case you haven't.

```console
$ sudo apt-get install supervisor
```

Next, create a config file for shout, just as you did for nginx

```console
$ sudo nano /etc/supervisor/conf.d/ghost.conf
```

Now edit the file to create an autostart process so that your blog remains stable. `user` should be
an existing user on the system. Better to use a dedicated user with restricted access as a safety
measure

```
[program:shout]
command = shout start
user = server
autostart = true
autorestart = true
stdout_logfile = /var/log/supervisor/shout.log
stderr_logfile = /var/log/supervisor/shout_err.log
```

Save it, and you're just a restart away!

```
$ sudo supervisorctl reread
$ sudo supervisorctl update
$ sudo supervisorctl restart shout
```

And you should have your own personal web IRC client ready! No more restrictions! Yay!

Queries? Suggestions? Feedback? Feel free to comment below!
