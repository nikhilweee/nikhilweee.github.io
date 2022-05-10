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
```console
$ ssh-copy-id abc1234@greene.hpc.nyu.edu
...
$ ssh-copy-id abc1234@access.cims.nyu.edu
...
```

## 2. Set up SSH aliases

Keying in `ssh abc1234@greene.hpc.nyu.edu` or `ssh abc1234@access.cims.nyu.edu` is so long and so old school when you can just get away with something like `ssh greene` or `ssh cims`. You should definitely set up an alias instead. Edit `~/.ssh/config` in your favourite text editor:

```bash {linenos=true}
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

```bash {linenos=true, hl_lines=[5]}
# ~/.ssh/config
# NYU CIMS
Host access1 access2 linserv1
    User abc1234
    ProxyJump cims

Host cims
    Hostname access.cims.nyu.edu
    User abc1234
```

Lines 7-9 describe the `login` node, and lines 3-5 describe the `compute` nodes. So now whenever you type `ssh linserv1`, you will first login to `cims` (`access.cims.nyu.edu`), and upon successful authentication, you will automatically SSH into `linserv1`. You can setup Greene in the same way.

```bash {linenos=true, hl_lines=[5]}
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

```bash {linenos=true, hl_lines=[5, 11]}
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

```console
$ # check if ssh-agent has keys loaded
$ ssh-add -l
The agent has no identities.

$ # add local keys to ssh-agent
$ ssh-add
Identity added: /Users/nikhil/.ssh/id_rsa (nikhil-macbook)

$ # verify that keys have been successfully added
$ ssh-add -l
3072 SHA256:abcdefghijklmnopqrstuvwxyz nikhil-macbook (RSA)
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
```console
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
These functions let you conveniently see the outputs for a given JOBID. For some reason they only work if the job is still running, so unfortunately you can't use them for completed jobs.
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

```console
$ # path to the log file for 14879246
$ slog 14879246
/home/abc1234/projects/sbatch/slurm-14879246.out

$ # contents of /home/abc1234/projects/sbatch/slurm-14879246.out
$ tailslog 14879278
archive  boot  etc   home  lib64  misc  net  proc  run   scratch  srv    sys  usr  vast
bin      dev   gpfs  lib   media  mnt   opt  root  sbin  share    state  tmp  var
```

# Slurm Gems
Here are some gems that I discovered during the course of my SLURM usage.

* `seff <jobid>`: Displays CPU and Memory usage stats for the job.
* `sattach <jobid.step>`: Attaches to the console of an existing job.  
  This can be used as an alternative to the [`tailslog()`](#3-view-output-from-your-job) function described above. If you don't know the `step` for a job, try using `0`. Please be aware that this doesn't always work.
* `sprio -u $USER`: Lists the scheduling priorities for pending jobs.

# Burst Instructions

For some courses, you might be alloted a specific number of GPU hours on GCP. To use these resources, you first need to login to the burst node from Greene. Next, you should check if you have access to a class account. If you do, you can specify that account to first submit a non-GPU job to setup your environment and code. When you're comfortable, you can submit a GPU job.

## 1. Housekeeping

```console
$ # Run these commands from greene
$ # SSH into the burst login node
$ ssh burst

$ # Check your associated accounts and resource quotas
$ sacctmgr show assoc user=$USER format=Account%25,GrpTRESMins%30
                  Account                    GrpTRESMins 
------------------------- ------------------------------ 
      csci-ga-2565-2022sp      cpu=120000,gres/gpu=12000 
                    users 

$ # Check your current usage
$ sshare --user=$USER  --format=Account,GrpTRESRaw%100
             Account                                                                                 GrpTRESRaw 
--------------------                                      ----------------------------------------------------- 
csci-ga-2565-2022sp         cpu=110,mem=116000,energy=0,node=50,billing=110,fs/disk=0,vmem=0,pages=0,gres/gpu=1 
users                          cpu=92,mem=69625,energy=0,node=46,billing=92,fs/disk=0,vmem=0,pages=0,gres/gpu=0 
```

## 2. Compute Nodes
```console
$ # Now, submit a job using one of these accounts
$ # This is not a GPU job and most likely should not count towards your quota
$ sbatch --account=csci-ga-2565-2022sp --partition=interactive --time=01:00:00 --wrap "sleep infinity"
Submitted batch job 74566

$ # Check the compute node where the job gets allocated
$ squeue -u $USER -O "JobID:10,Partition:15,Nodelist:10,State:15,StartTime,TimeUsed:10,TimeLeft:10,Account:25,Name"
JOBID     PARTITION      NODELIST  STATE          START_TIME          TIME      TIME_LEFT ACCOUNT                  NAME                
74566     interactive    b-9-90    RUNNING        2022-05-01T19:22:53 1:41      58:19     csci-ga-2565-2022sp      wrap

$ # SSH into the compute node
$ ssh b-9-90
```

```console
$ # Alternatively, you can also submit an interactive job instead of a batch job
$ # If you do not specify the time, the job will terminate after one hour
$ srun --account=csci-ga-2565-2022sp --partition=interactive --pty /bin/bash
```

## 3. Data Transfer
Once you have spun up a compute node, you might be looking to transfer data from Greene. Keep in mind that Greene and the Burst login node share data, however the Burst compute nodes have their own persistent storage. This means that you can access your files that are stored on Greene from the burst node, but the compute nodes cannot access that data.

```console
$ # Run these commands from a compute node on burst
$ # Copy whatever files you need
$ scp $USER@greene-dtn.hpc.nyu.edu:/source/path /dest/path
```

## 4. GPU Nodes
You can use GPU nodes in an interactive fashion just like you spawned a compute node.
```console
$ # Submit a GPU Job. Notice we changed the arguments --partition and --gres
$ sbatch --account=csci-ga-2565-2022sp --partition=n1s8-v100-1 --gres=gpu --time=01:00:00 --wrap "sleep infinity"
Submitted batch job 74601

$ # As before, see where this job gets allocated
$ squeue -u $USER -O "JobID:10,Partition:15,Nodelist:10,State:15,StartTime,TimeUsed:10,TimeLeft:10,Account:25,Name"
JOBID     PARTITION      NODELIST  STATE          START_TIME          TIME      TIME_LEFT ACCOUNT                  NAME                
74601     n1s8-v100-1    b-3-114   RUNNING        2022-05-01T19:54:23 1:01      58:59     csci-ga-2565-2022sp      wrap

$ # SSH into the compute node
$ ssh b-3-114

$ # Now run whatever job you wish to run
$ # Enjoy!
```

Alternatively, you can also use a script that you can submit using `sbatch`.
```bash
#!/bin/bash

#SBATCH --time=00-12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --gres=gpu:1
#SBATCH --output="sbatch_logs/%A_%x.txt"
#SBATCH --account=csci-ga-2565-2022sp
#SBATCH --partition=n1s8-v100-1
#SBATCH --job-name=pretrain_both


singularity exec \
    --nv --overlay /scratch/abc1234/overlay-50G-10M.ext3:ro \
    /scratch/abc1234/cuda11.3.0-cudnn8-devel-ubuntu20.04.sif \
    /bin/bash -c "
    source /ext3/miniconda3/etc/profile.d/conda.sh;
    conda activate env;
    cd /home/abc1234/projects/project;
    python -u train.py --batch_size 40 \
        --output_dir runs/${SLURM_JOB_NAME}_${SLURM_JOB_ID};
    "
```

## 5. Port Forwarding
If you're running training jobs on the burst cluster, there's a high chance you might want to use tensorboard as well. To access tensorboard on your local system, you need multiple levels of port forwarding. This is because the file system on the burst compute nodes is only accessible to the compute nodes, which in turn are accessible from the burst login node, which in turn is accessible from greene, which in turn is accessible from the NYU gateway. Yes, that's quite a lot of layers.

First, you need to spin up a compute node on the burst cluster and run tensorboard on the node.
```console
$ # Run this on a burst compute node
$ # Let's say the hostname is b-9-9
$ tensorboard --logdir runs
```

 Next, open up a local terminal and set up a series of port forwards. Note that in the following snippet I'm using the SSH alias for `greene` as described in [Section 1](#first-things-first) of this tutorial.

```console
$ ssh -t -L 6006:localhost:6006 greene \
$   ssh -t -L 6006:localhost:6006 burst \
$     ssh -t -L 6006:localhost:6006 b-9-9 
```

Without SSH aliases, the forwarding chain will look something like this.
```console
$ ssh -t -L 6006:localhost:6006 abc1234@greene.hpc.nyu.edu \
$   ssh -t -L 6006:localhost:6006 burst \
$     ssh -t -L 6006:localhost:6006 b-9-9
```

# Troubleshooting
## 1. Singularity can't open overlay for writing

If you were actively using a Singularity with an ext3 overlay, and for some reason you didn't exit cleanly (maybe slurm preempted your job), you may run into issues. The next time you try using Singularity, you might get this error complaining that your overlay file is still in use: 
```
FATAL:
while loading overlay images: failed to open overlay image /path/to/overlay.ext3: 
    while locking ext3 partition from /path/to/overlay.ext3: 
        can't open //path/to/overlay.ext3 for writing, currently in use by another process
```
If you're sure that your overlay file is clean to use, you can run `fsck` and clean the dirty bit. For more info see [this github issue](https://github.com/apptainer/singularity/issues/6196) on the singularity repo.
```
$ fsck.ext3 /path/to/overlay.ext3
```

## 2. Job killed because of Low GPU Usage

You should only request a GPU when you need it. However, if you need a dummy script to keep the GPU busy (which I highly recommend against), have a look at this [gist](https://gist.github.com/nikhilweee/b5a2a201f97c386f4701d48cbf7f5a04).

Hope this helps!
