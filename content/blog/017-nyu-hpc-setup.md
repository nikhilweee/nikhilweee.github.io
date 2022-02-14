+++
categories = ["Tutorials"]
date = "2022-02-13"
draft = false
subtitle = "using SLURM on NYU's HPC cluster"
title = "Speed up your remote workflow"
slug = "speed-up-remote-workflow-slurm-nyu-hpc"

+++

Although NYU already a dedicated [website](https://sites.google.com/nyu.edu/nyu-hpc) with all the documentation to get started with the HPC cluster, here's a set of tricks that I use to ease up the workflow by a significant amount.

{{<toc>}}

# First things first
Here's something that I recommend doing for any remote server that you'll access frequently.

## 1. Passwordless SSH

If you haven't done so yet, you should definitely add your ssh keys to the cluster to avoid typing in your password whenever you want to login. Replace `abc1234` with your NetID.
```bash
$ ssh-copy-id abc1234@greene.hpc.nyu.edu
...
$ ssh-copy-id abc1234@access.cims.nyu.edu
...
```

## 2. Set up SSH aliases

Keying in `ssh abc1234@greene.hpc.nyu.edu` or `ssh abc1234@access.cims.nyu.edu` is so long and so old school when you can just get away with something like `ssh greene` or `ssh cims`. You should definitely set up an alias instead. Edit `~/.ssh/config` in your favourite text editor:

```bash
# ~/.ssh/config
# NYU Greene
Host greene
    Hostname greene.hpc.nyu.edu
    User abc1234

# NYU CIMS
Host cims
    Hostname access.cims.nyu.edu
    User abc1234
```

# A few simple tricks
These are a few hacks which should greatly simplify the overhead of using the cluster.

## 1. Login directly into compute nodes

Often times, you wish you could directly access the compute nodes (such as `linserv1`) without having to first SSH into `access.cims.nyu.edu`.
Here's how you can use the `ProxyJump` directive.

```bash {hl_lines=[5]}
# ~/.ssh/config
# NYU CIMS
Host access1 access2 linserv1
    User abc1234
    ProxyJump cims

Host cims
    Hostname access.cims.nyu.edu
    User abc1234
```

Lines 8-11 describe the `login` node, and lines 3-6 describe the `compute` nodes. So now whenever you type `ssh linserv1`, you will first login to `cims` (`access.cims.nyu.edu`), and upon successful authentication, you will automatically SSH into `linserv1`. You can setup Greene in the same way.

```bash {hl_lines=[5]}
# ~/.ssh/config
# NYU Greene
Host log-1 log-2 log-3 log-4 log-5
    User abc1234
    ProxyJump greene

Host greene
    Hostname greene.hpc.nyu.edu
    User abc1234
```

This setup is particularly helpful because whenever you SSH into `greene.hpc.nyu.edu`, you are randomly taken to one of the login nodes. Now let's say if you had `tmux` running on `log-3` and you lose connectivity. The next time you login, you might be taken into `log-4`. You type `tmux ls` and it complains about no open sessions. You're flabbergasted because you clearly remember running `tmux` a moment ago. Sadly, you didn't remember the hostname. 

With this setup, you can try making a habit of always logging in to one particular node, say `ssh log-3`, and now you don't have to worry about remembering hostnames anymore.

## 2. Use local SSH keys

Did you ever get annoyed when you tried to use `git clone` on one of the private repositories and you suddenly notice GitHub throwing an error? You may have added your local SSH keys to GitHub to for secure authentication but as you can imagine, GitHub does not recognise the keys from the cluster. The way around it is to use the `ForwardAgent` directive. 

```bash {hl_lines=[5, 11]}
# ~/.ssh/config
# NYU CIMS
Host access1 access2 linserv1
    User abc1234
    ForwardAgent yes
    ProxyJump cims

Host cims
    Hostname access.cims.nyu.edu
    User abc1234
    ForwardAgent yes
```

This way, you can _forward_ your local SSH keys to the cluster, and GitHub (or any other service) will receive your local keys so they'll stop complaining anymore. Just one more step before this works: make sure that your local keys are added to `ssh-agent`. Use the following commands:

```bash {linenos=false}
$ ssh-add -l
The agent has no identities.
# ssh-agent has no keys
$ ssh-add
Identity added: /Users/nikhil/.ssh/id_rsa (nikhil-macbook)
# add local keys to ssh-agent
$ ssh-add -l
3072 SHA256:abcdefghijklmnopqrstuvwxyz nikhil-macbook (RSA)
# verify that keys have been successfully added
```

# Some SLURM aliases

If you're using Greene on a regular basis, chances are that you will need to use a few of the SLURM commands to check and manage your jobs. Here's a few aliases that I created, they should be handy for you too. Once logged into the cluster, add the following lines to `~/.bash_aliases`. Make sure to `source ~/.bashrc` every time you make a change for the aliases to take effect.

## 1. Common aliases
I often run an interactive job while debugging code. Here are some shortcuts that I use.

```bash
# ~/.bash_aliases
# Slurm Job Aliases

# cpu job for 6 hours
alias srunc6h='srun --mem=64GB --time=6:00:00 --pty /bin/bash'

# gpu job for 1 hour
alias srung1h='srun --gres=gpu:1 --mem=16GB --time=1:00:00 --pty /bin/bash'
```

## 2. View your job queue
These aliases help you view your job queue, albeit in a slightly improved format.
```bash
# ~/.bash_aliases
# Slurm Control Aliases

# shows status of active jobs
alias sq='squeue -u abc1234 -o "%.15i %.9N %.9T %.9M %.12L %.20V %j" -S "V"'

# run the previous command in a loop, every 1 sec
alias watchsq='watch -n 1 \
    squeue -u abc1234 -o \"%.15i %.9N %.9T %.9M %.12L %.20V %j\" -S "V"'

# also shows completed jobs in the last 24 hours
alias shist='sacct -X -o "JobID%15,ExitCode,State,Reason,\
    Submit,Elapsed,MaxVMSize,NodeList,Priority,JobName%20"'
```
Here's an example. The best part about `sq` is that it shows the submit time, time elapsed, and time remaining so you can clearly identify your jobs. When you want to see completed jobs as well, use `shist`. Additional options can follow. For example, to filter jobs active between 1-10 February 2022, use `shist --starttime=2022-02-01 --endtime=2022-02-10`.
```bash {linenos=false}
$ sq
          JOBID  NODELIST     STATE      TIME    TIME_LEFT          SUBMIT_TIME NAME
       14878566     gv002   RUNNING     22:13        37:47  2022-02-13T03:34:31 bash

$ shist
          JobID ExitCode      State                 Reason              Submit    Elapsed  MaxVMSize        NodeList   Priority              JobName 
--------------- -------- ---------- ---------------------- ------------------- ---------- ---------- --------------- ---------- -------------------- 
       14878566      0:0    RUNNING                   None 2022-02-13T03:34:31   00:21:25                      gv002      18632                 bash 
       14879278      0:0  COMPLETED                   None 2022-02-13T03:50:16   00:00:00                      cs008      17618              test.sh
```

## 3. View output from your job
These functions let you conveniently see the outputs for a given JOBID.
```bash
# ~/.bash_aliases

# Slurm Log Aliases
# slog <JOBID> shows location of the log file for a given job
function slog() { scontrol show job "${1}" | grep StdOut | cut -d "=" -f 2 ; } 
# catslog <JOBID> is just `cat` on the file location returned by slog
function catslog() { cat $(slog "${1}") ; }
# catslog <JOBID> is just `tail -f` on the file location returned by slog
function tailslog() { tail -f -n +1 $(slog "${1}") ; }
```
Here are some examples. My general workflow is to use `sq` followed by `tailslog`.

```bash {linenos=false}
$ slog 14879246
# path to the log file for 14879246
/home/abc1234/projects/sbatch/slurm-14879246.out

$ tailslog 14879278
# contents of /home/abc1234/projects/sbatch/slurm-14879246.out
archive  boot  etc   home  lib64  misc  net  proc  run   scratch  srv    sys  usr  vast
bin      dev   gpfs  lib   media  mnt   opt  root  sbin  share    state  tmp  var
```

Hope this helps!