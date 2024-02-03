+++
categories = ['References']
date = '2022-11-11'
slug = 'nyu-slurm-burst-guide'
subtitle = "Using burst nodes on NYU's HPC cluster"
title = 'Cloud Bursting with Slurm'
+++

Here's a guide on how to access NYU's burst cluster for graduate courses. I created this guide for
the Fall 2022 edition of the Computer Vision course, but a lot of this should still be applicable
for other courses. Please feel free to adapt this to your use case. Further readings can be found
towards the end of this post.

# Cluster Configuration

---

Different nodes in the NYU cluster are connected in the following manner. You will access everything
through SSH. This schematic should be helpful in understanding the rest of this guide.

The Greene login node will be your gateway to NYU's on-premise cluster. For this course, you will be
running jobs on one of the burst compute nodes, which you will access through the burst login node.

```console
                                            +--------------------+      +--------------------+
                                            |                    |      |                    |
                                            |                    |      |                    |
                                            |   Greene Compute   |      |   Burst Compute    |
                                            |                    |      |                    |
                                            |                    |      |                    |
                                            +----------|---------+      +----------|---------+
                                                       |                           |
                                                       |                           |
        +-----------------+                 +----------|---------+      +----------|---------+
        |                 |                 |                    |      |                    |
        |                 |                 |                    |      |                    |
        |      Local      <=== (NYU VPN) ===>    Greene Login    --------    Burst Login     |
        |                 |                 |                    |      |                    |
        |                 |                 |                    |      |                    |
        +-----------------+                 +--------------------+      +--------------------+
```

# Burst Setup

---

**1. Check Acess to Greene**: First off, you should check whether you have access to Greene, which
is NYU's compute cluster. If you're connecting from home, please make sure you're using NYU's VPN.

```console
$ # On your local machine
$ ssh <netid>@greene.hpc.nyu.edu
$ # You should be logged into a greene login node
```

The Greene cluster and its on-premise resources are primarily meant for researchers. For compute
requirements during courses like this one, NYU has a separate `burst` setup. This allows the cluster
to offload additional usage to a third party cloud provider. In our case, usage is handled by Google
Cloud.

**2. Login to Burst Node**: To use the burst setup, you should first login to the `burst` node from
`greene`.

```console
$ # On a greene login node
$ ssh burst
$ # You should be logged into a burst login node
```

**3. Check Bursting Setup**: Next, check whether you are associated with the burst account for this
class.

```console
$ # On a burst login node
$ sacctmgr show assoc user=$USER format=Account%30,GrpTRESMins%30
                       Account                    GrpTRESMins
------------------------------ ------------------------------
       csci_ga_2271_001-2022fa      cpu=120000,gres/gpu=12000
```

If you've been assigned an account for the CV class, you should see the row
`csci_ga_2271_001-2022fa`. The output suggests that you should have access to 2000 hours of CPU
usage and 200 hours of GPU usage.

**4. Check Resource Usage**: You should periodically keep track of your usage.

```console
$ # On a burst login node
$ sshare --user=$USER  --format=Account%30,GrpTRESRaw%90
                       Account                                                                                 GrpTRESRaw
------------------------------ ------------------------------------------------------------------------------------------
       csci_ga_2271_001-2022fa        cpu=112,mem=415950,energy=0,node=7,billing=112,fs/disk=0,vmem=0,pages=0,gres/gpu=14
```

This output represents 112 minutes of CPU usage (`cpu=112`) and 14 minutes of GPU usage
(`gres/gpu=14`). Be extra careful about GPU usage as it can add up quickly. Keep in mind that these
are cumulative quotas so running a job on 4 GPUs for 30 minutes will deplete your available GPU
quota by 120 minutes, not 30.

# Data Transfer

---

Something worth knowing is that the greene login node, the greene compute nodes, and the burst login
node share the same filesystem. However, you will run jobs on one of the burst compute nodes, which
have a separate filesystem. To transfer data from greene to one of the burst compute nodes, use
`rsync` to copy data from `greene-dtn`. This is a special node on the greene cluster optimized for
data transfer.

**5. Data Transfer**: Login to a burst compute node through an interactive job, then transfer data
using `rsync`.

```console
$ # On a burst login node
$ srun --account=csci_ga_2271_001-2022fa --partition=interactive --pty /bin/bash
$ # You should be logged into a burst compute node
$ rsync -aP <netid>@greene-dtn.hpc.nyu.edu:/source/file/path/on/greene /destination/file/path/on/burst
```

All burst compute nodes share the same filesystem, so you should only have to do this once.

# Partitions

---

As you might have noticed so far, while submitting a job, you also need to specify a partition. Each
partition gives you access to different kinds of resources. For the course, you have access to the
following partitions. The resources offered by each partition are also listed in the table.

```console
$ sinfo -O "Partition,CPUs,Memory,GRes"
PARTITION           CPUS                MEMORY (MB)         GPUS
interactive         2                   1500                (null)
c2s16p              16                  64000               (null)
n1s8-v100-1         8                   29000               gpu:v100:1
n1s16-v100-2        16                  59000               gpu:v100:2
n1c10m64-v100-1     10                  64000               gpu:v100:1
n1c16m96-v100-2     16                  96000               gpu:v100:2
```

Note that each V100 GPU has 16GB of memory. Partitions with `gpu:v100:1` have one V100 GPU available
for every job. Partitions with `gpu:v100:2` have two V100 GPUs available for each of your jobs, and
so on.

# Submitting Jobs

---

You have the option to either submit an interactive job, or submit a batch job. Jobs can take
anywhere from a few seconds to a few minutes of provisioning time to become fully available. Under
the hood, a new VM will be allocated for you on Google Cloud, so this takes some time. Please be
patient.

## Interactive Jobs

An interactive job is straightforward to run, but will terminate as soon as you lose network
connection or exit the terminal. You can launch an interactive job by using the `srun` command.

```console
$ # On a burst login node
$ srun --account=csci_ga_2271_001-2022fa --partition=n1s8-v100-1 --gres=gpu:1 --pty /bin/bash
$ # Wait for a few seconds to a few minutes
$ # You should be logged into a burst compute node
```

Note that there's an additional argument `--gres=gpu:1` passed because we're using a partition with
a single GPU. Once the job is allocated, you can run your training scripts as you would normally do.

## Batch Jobs

A batch job will not terminate before its time limit, unless explicitly killed. However, there are
some extra steps involved. You can launch a batch job using the `sbatch` command.

```console
$ # On a burst login node
$ sbatch --account=csci_ga_2271_001-2022fa --partition=n1s16-v100-2 --gres=gpu:2 --time=01:00:00 --wrap "sleep infinity"
$ # You should immediately get back the job ID
Submitted batch job 88344
$ # Note that you're still on the burst login node
```

Again, note that there's an additional argument `--gres=gpu:2` passed because we're using a
partition with two GPUs. To access the compute node, you need to find out the hostname of the node
being provisioned.

```console
$ # On a burst login node
$ squeue -u $USER -O "JobID:10,Partition:15,Nodelist:10,State:12,StartTime:21,TimeLeft:11,Account:25,Name:40"
JOBID     PARTITION      NODELIST  STATE       START_TIME           TIME_LEFT  ACCOUNT                  NAME
88345     n1s16-v100-2   b-6-1     RUNNING     2022-09-08T02:25:03  59:45      csci_ga_2271_001-2022fa  wrap
```

The hostname of the compute node is under the header `NODELIST`. In this case, it is `b-6-1`. You
can login to the compute node simply by using `ssh`. Please keep an eye on the `STATE` of the job.
You will only be able to ssh into compute nodes which are in the `RUNNING` state.

```console
$ # On a burst login node
$ ssh b-6-1
$ # You should be logged into a burst compute node
```

To cancel a job before it expires, use the `scancel` command. You will need to specify a JOBID.

```console
$ # On a burst node
$ scancel 88345
```

The running job should now be cancelled.

# Advanced Usage

---

If you don't wish to type out the long commands, you can use a bash script with SBATCH directives:

```bash
#!/bin/bash

#SBATCH --time=12:00:00
#SBATCH --gres=gpu:1
#SBATCH --output="%A_%x.txt"
#SBATCH --account=csci_ga_2271_001-2022fa
#SBATCH --partition=n1s8-v100-1
#SBATCH --job-name=train_both

singularity exec \
    --nv --overlay /scratch/abc1234/overlay-50G-10M.ext3:ro \
    /scratch/abc1234/cuda11.3.0-cudnn8-devel-ubuntu20.04.sif \
    /bin/bash -c "
    source /ext3/miniconda3/etc/profile.d/conda.sh;
    conda activate env;
    cd /home/abc1234/projects/cv;
    python -u train.py --batch_size 40 \
        --output_dir runs/${SLURM_JOB_NAME}_${SLURM_JOB_ID};
    "
```

This script also makes use of Singularity containers. More info can be found in the next section.

# Further Resources

---

For more information, feel free to check out the relevant documentation from NYU HPC.

- Submitting Jobs:
  https://sites.google.com/nyu.edu/nyu-hpc/training-support/general-hpc-topics/slurm-submitting-jobs
- Singluarity:
  https://sites.google.com/nyu.edu/nyu-hpc/training-support/general-hpc-topics/singularity-run-custom-applications-with-containers
- SLURM Commands:
  https://sites.google.com/nyu.edu/nyu-hpc/training-support/general-hpc-topics/slurm-main-commands
- Crowdsourced Cluster Support: https://github.com/nyu-dl/cluster-support
