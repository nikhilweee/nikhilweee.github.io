+++
categories = ["Reinforcement Learning", "Long Posts"]
date = "2022-06-06"
title = "A Walkthrough of Isaac Gym"
subtitle = "NVIDIA's GPU based RL Framework"
slug = "isaac-gym-walkthrough"
+++
# Introduction

Training a policy using deep reinforcement learning consists of an agent interacting with the environment in a continuous loop. In practise, the agent is often modelled by deep networks that can take advantage of GPU parallelization, but the environment is still modelled by simulators that rely on the CPU. While the poor sample efficiency of RL algorithms remains a huge bottleneck, a significant amount of time is also spent on moving tensors from the CPU to the GPU, not to forget the additional delays caused by the lack of parallelism in CPU based simulation.

NVIDIA's Isaac Gym is a simulation framework designed to address these limitations. It runs entirely on the GPU, thus eliminating the CPU bottleneck. This post is a brief walkthrough of Isaac Gym. We shall install `isaacgym`, learn about its core principles, and train a policy for object manipulation using the [AllegroHand](http://wiki.ros.org/Robots/AllegroHand). To learn more about Isaac Gym, I highly recommend watching [these videos](https://www.youtube.com/playlist?list=PL-tHNF2x8sTZcoEGru_evvkQs6JxE99pE) from RSS 2021 and reading the [technical paper](https://arxiv.org/abs/2108.10470) available on arXiv.

# Getting Started

To download Isaac Gym, you need to head over to NVIDIA's [website](https://developer.nvidia.com/isaac-gym) and join the developer programme. At the time of this writing, the latest release is Isaac Gym Preview 3, which is what we'll be working with throughout this post. For ease of development, I recommend using a linux based machine with NVIDIA GPUs. Once you download and extract the archive, documentation is available at `docs/index.html`. To install, head over to the instructions at `docs/install.html`.

The first thing to check after installing Isaac Gym is to make sure that it runs fine. Head over to `python/examples` and run one of the example scripts, say `joint_monkey.py`. You should see the simulation window pop up where all the joints of the humanoid are being animated.

```console
$ cd python/examples
$ python joint_monkey.py
```

{{<rawhtml>}}
<figure>
<video src="https://i.imgur.com/oYO0WVa.mp4" controls autoplay loop></video>
<figcaption>Fig 1: Joint Monkey from <code>isaacgym3/python/examples/joint_monkey.py</code>.</figcaption>
</figure>
{{</rawhtml>}}

# IsaacGymEnvs

The `python/examples` directory only has a few scripts to test things out. NVIDIA has another repo of benchmarks trained using Isaac Gym, called [IsaacGymEnvs](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs) (IGE) available on GitHub.

Follow the instructions in the [README](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/main/README.md) to install IGE. To test things out, go to the `isaacgymenvs` directory and try running the training script. Once the window loads, you should notice that the cartpole starts balancing itself pretty quickly, in around 10 seconds or so.

```console
$ cd isaacgymenvs
$ python train.py task=Cartpole
```

{{<rawhtml>}}
<figure>
<video src="https://i.imgur.com/xXvl0bw.mp4" controls autoplay loop></video>
<figcaption>Fig 2: Cartpole training on IsaacGymEnvs.</figcaption>
</figure>
{{</rawhtml>}}

# AllegroHand

After cartpole, let's try out something that is a bit more involved. We shall focus on object manipulation using the Allegro Hand. IGE already has a script that we can use out of the box. To test it out, you can simply set `task=AllegroHand` while running the training script from the [previous section](#isaacgymenvs). By default, the script spawns 16,384 environments, and that can be really slow to visualize. We can change this to 16 instead. IGE extensively makes use of [Hydra](https://hydra.cc/) configs, so a lot of parameters are customizable directly through command line arguments. Try the following command. You should now see a window with 16 environments in parallel. 

```console
$ python train.py task=AllegroHand num_envs=16 train.params.config.minibatch_size=16
```

{{<rawhtml>}}
<figure id="fig-3">
<video src="https://i.imgur.com/wJ4OZzE.mp4" controls autoplay loop></video>
<figcaption>Fig 3: AllegroHand on <code>IsaacGymEnvs</code></figcaption>
</figure>
{{</rawhtml>}}

# Camera Movements

At first, the simulator window might not look like [Fig. 3](#fig-3) above. You may need to move the camera a bit. All camera movements[^camera] in Isaac Gym need to be performed while holding the right mouse button. To pan or tilt the camera, simply move the mouse while holding the right mouse button. To move forward and backward (dolly), use the `W` and `S` keys. To move left and right (truck), use `A` and `D`. To move up and down (pedestal), use the `E` and `Q` keys. The next two shortcuts are specific to IGE and don't need the right mouse button. To stop simulation and preempt training, press `ESC`. To pause simulation but continue training, press `V`. 

[^camera]: Read more about the different types of camera movements [here](https://blog.storyblocks.com/video-tutorials/7-basic-camera-movements/)

# Changing Assets

IGE uses a model of the Allegro Hand with BioTac sensors on its fingertips ([Fig. 4](#fig-4)). However, that's an additional accessory and might not be the desired setup for many. The default fingertips look like the ones in [Fig. 5](#fig-5), and the corresponding URDF file can be found in the official repo for the AllegroHand by Wonik Robotics ([github.com/simlabrobotics/allegro_hand_ros](https://github.com/simlabrobotics/allegro_hand_ros/blob/296ef6bae4b535ffb91420237cdc8a87f6e9f6df/allegro_hand_description/allegro_hand_description_right.urdf)).

{{<centerwrap>}}
<figure id="fig-4" style="display: inline-block; width: 49%">
<img src="https://i.imgur.com/GArxscp.png">
<figcaption>Fig. 4: AllegroHand with BioTac fingertips</figcaption>
</figure>
<figure id="fig-5" style="display: inline-block; width: 49%">
<img src="https://i.imgur.com/nMLoTll.png">
<figcaption>Fig. 5: AllegroHand with default fingertips</figcaption>
</figure>
{{</centerwrap>}}

After some inspection, it is easy to see that IGE also uses a URDF file to render its version of the AllegroHand, the path to which is defined in this [config file](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/cfg/task/AllegroHand.yaml#L56). I tried replacing this URDF file with the one from simlabrobotics, but unfortunately I ran into segmentation faults. 

Ultimately, I had to edit [`allegro.urdf`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/assets/urdf/kuka_allegro_description/allegro.urdf) manually and swap the BioTac fingertips with the original ones. If you plan to edit URDF files manually, you should definitely check out [gkjohnson's online URDF visualizer](https://gkjohnson.github.io/urdf-loaders/javascript/example/bundle/) that I found extremely helpful. To save yourself some time, you are free to use my implementation called [`allegro_ros.urdf`](https://github.com/nikhilweee/IsaacGymEnvs/blob/8de08db401b83bb887ca07dfa74a4da27190c303/assets/urdf/kuka_allegro_description/allegro_ros.urdf). You will also need a bunch of STL files for the default fingertips for this to work correctly. For reference, you can go through [my fork](https://github.com/nikhilweee/IsaacGymEnvs/tree/allegro-ros) of IGE.



# Walkthrough

Alright. So what's going on here? Behind the scenes, IGE relies on this package called [`rl_games`](https://github.com/Denys88/rl_games). I couldn't find much info about this package, except that it seems to implement a bunch of common RL algorithms particularly suited for Isaac Gym. At the time of this writing, IGE depends on `rl_games` version [1.1.4](https://github.com/Denys88/rl_games/tree/02c6a2127c76342e21d07f01a8793caba957394a). Note how IGE's [`train.py`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/train.py) essentially calls [`rl_games.torch_runner.Runner`](https://github.com/Denys88/rl_games/blob/02c6a2127c76342e21d07f01a8793caba957394a/rl_games/torch_runner.py#L20-L146).

Following common practices, `rl_games` loads algorithms dynamically according to a config object. When you run the training script with `task=AllegroHand`, hydra loads two configuration files.
```console
$ python train.py task=AllegroHand
```

The first is [`task/AllegroHand.yaml`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/cfg/task/AllegroHand.yaml) (env config), which contains parameters to setup the environment, and the other is [`train/AllegroHandPPO.yaml`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/cfg/train/AllegroHandPPO.yaml) (train config), which contains parameters to train the agent. The train config specifies `train.algo.name: a2c_continuous`. [`rl_games.torch_runner.Runner`](https://github.com/Denys88/rl_games/blob/02c6a2127c76342e21d07f01a8793caba957394a/rl_games/torch_runner.py#L20-L146) parses this config, creates an [`A2CAgent`](https://github.com/Denys88/rl_games/blob/02c6a2127c76342e21d07f01a8793caba957394a/rl_games/algos_torch/a2c_continuous.py#L16-L180) and calls [`agent.train()`](https://github.com/Denys88/rl_games/blob/02c6a2127c76342e21d07f01a8793caba957394a/rl_games/common/a2c_common.py#L1136).


{{<rawhtml>}}
<script src="https://emgithub.com/embed.js?target=https%3A%2F%2Fgithub.com%2FNVIDIA-Omniverse%2FIsaacGymEnvs%2Fblob%2F9656bac7e59b96382d2c5040b90d2ea5c227d56d%2Fisaacgymenvs%2Fcfg%2Ftrain%2FAllegroHandPPO.yaml%23L4-L5&style=github-gist&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on"></script>
<script src="https://emgithub.com/embed.js?target=https%3A%2F%2Fgithub.com%2FDenys88%2Frl_games%2Fblob%2F02c6a2127c76342e21d07f01a8793caba957394a%2Frl_games%2Ftorch_runner.py%23L23&style=github-gist&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on"></script>
<script src="https://emgithub.com/embed.js?target=https%3A%2F%2Fgithub.com%2FDenys88%2Frl_games%2Fblob%2F02c6a2127c76342e21d07f01a8793caba957394a%2Frl_games%2Ftorch_runner.py%23L122-L125&style=github-gist&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on"></script>
{{</rawhtml>}}

[Somewhere](https://github.com/Denys88/rl_games/blob/02c6a2127c76342e21d07f01a8793caba957394a/rl_games/common/a2c_common.py#L444) during training, `rl_games` calls the [`step()`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/tasks/base/vec_task.py#L292-L337) function (shown below) of the environment defined in the env config. Two important methods to pay attention to are `pre_physics_step()` and `post_physics_step()`, which contain all the environment specific code that should run just before and after stepping through the environment.

{{<rawhtml>}}
<script src="https://emgithub.com/embed.js?target=https%3A%2F%2Fgithub.com%2FNVIDIA-Omniverse%2FIsaacGymEnvs%2Fblob%2F9656bac7e59b96382d2c5040b90d2ea5c227d56d%2Fisaacgymenvs%2Ftasks%2Fbase%2Fvec_task.py%23L292-L337&style=github-gist&showBorder=on&showLineNumbers=on&showFileMeta=on&showCopy=on"></script>
{{</rawhtml>}}

For the AllegroHand, these methods are defined in [`allegro_hand.py`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/tasks/allegro_hand.py). If you're planning to make any changes in the existing environment, this is the file you should look at.
If you're curious, the interface between `rl_games` and `isaacgymenvs` is provided in [`rlgames_utils.RLGPUEnv`](https://github.com/NVIDIA-Omniverse/IsaacGymEnvs/blob/9656bac7e59b96382d2c5040b90d2ea5c227d56d/isaacgymenvs/utils/rlgames_utils.py#L157-L186).

>This post is a work in progress. More updates coming soon.

# Resources
* I highly recommend reading the technical paper about Isaac Gym available on [arXiv](https://arxiv.org/abs/2108.10470).
* Google Brax is another GPU based simulation platform to look at. More info on [GitHub](https://github.com/google/brax).
* There's also a GitHub repo of resources related to Isaac Gym available at [awesome-isaac-gym](https://github.com/wangcongrobot/awesome-isaac-gym).