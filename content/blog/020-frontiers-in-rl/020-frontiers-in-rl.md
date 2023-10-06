+++
categories = ['RL Series', 'Long Posts']
citations = true
date = '2022-04-07'
draft = true
katex = true
slug = 'rl-refresher'
subtitle = ''
title = 'Reinforcement Learning Refresher'
toc = false
+++
<!-- This post has been heavily inspired by Prof. [Lerrel Pinto](https://www.lerrelpinto.com/)'s Deep Reinforcement Learning [course](https://nyu-robot-learning.github.io/deep-rl-class/) at NYU, and it also borrows from Prof. [Sergey Levine](https://people.eecs.berkeley.edu/~svlevine/)'s Deep RL [course](https://rail.eecs.berkeley.edu/deeprlcourse/) at UC Berkeley. -->

RL as a field has evolved a lot over the years. When I first got started, I was pretty overwhelmed with the abundance of terminology specific to the field. This post is intended to summarize common ideas that appear frequently in the literature. To follow the rest of the post, I shall assume familiarity with standard definitions and notations of the environment, states $s_t$, actions $a_t$, observations $o_t$, rewards $r_t$ and policy $\pi_\theta$. We shall first revisit the formalism common in RL literature, followed by a basic taxonomy and finally a summary of a few important algorithms and techniques that have shaped the field. 

 <!-- A few remarks though. Recall that the observation is derived from the state, however, it might not be sufficient to deduce the state completely. In contrast, we assume that the current state is sufficient to determine the next state. This is called the Markovian property, and it allows us to formulate optimal policies solely based on the current state, disregarding all previous states of the system. Typically, observations do not follow the Markov property. -->

{{<toc>}}

# Formalism
___
<!-- ## Markov Everything
The **markov property** is one of the many fundamental assumptions behind much of the RL literature. Simply put, it states that the next state $s_t$ is only dependent on the previous state $s_{t-1}$, and is independent of any other state $s_t \ne s_{t-1}$. Mathematically, we get the following independence relation:
$$p(s_t | s_{t-1}, s_{t-2}, \dots, s_0) = p(s_t | s_{t-1})  $$

Based on this assumption, we can define a few formalisms.  A **markov decision process** $\mathcal{M} = \\{\mathcal{S}, \mathcal{A}, \mathcal{T}, r\\}$ is a sequence of decisions (or actions) $a \in \mathcal{A}$ taken at every state $s \in \mathcal{S}$. Here the state $s$ follows the markov property and the next state is obtained through the transition probability $\mathcal{T}$. $r(s, a)$ is the reward obtained as a result of performing action $a$ in state $s$. The MDP below is $\mathcal{M} = \\{s_1, a_1, s_2, a_2, \dots\\}$.

{{<figure src="https://i.imgur.com/9U98QUW.png" caption="Fig. 1: A graphical representation of a markov decision process (MDP)." width="75%">}}

A **partially observed markov decision process** $\mathcal{M} = \\{\mathcal{S}, \mathcal{A}, \mathcal{O}, \mathcal{T}, \mathcal{E}, r\\}$ further adds an observation $o \in \mathcal{O}$, obtained through an emission function $\mathcal{E}$. Instead of direct access to the complete state $s$, we only have access to the observation $o$. The observation derives from $s$ but may or may not fully describe $s$.

{{<figure src="https://i.imgur.com/uNmlXKV.png" caption="Fig. 2: A partially observed markov decision process (POMDP)." width="75%">}} -->

This section revisits value functions and policies, which are instrumental in building up the rest of the post.

A **policy** $\pi$ in the simplest terms is a function that returns action probabilities given a state. Often times, the policy is explicitly modelled (such as a neural network), and its parameters $\theta$ are included in the notation $\pi_\theta$. Other times, the policy is implicitly modelled through a value function. In this case, the policy can be greedily represented as $\pi(s) = \argmax_{a} Q(s, a)$ where the best action is the one which maximizes $Q(s, a)$.

The value function itself has two different flavours. The first one is the action value function, also called as the Q function $Q(s, a)$, and the second one is the state value function, also denoted by $V(s)$.

The **action value function** $Q(s, a)$ is the expected cumulative reward on taking an action $a$ in state $s$. Simply put, this is the implicit _value_ of choosing action $a$ in state $s$. The expectation is over the complete set of possible states distributed according to the transition probability $p(s'|s,a)$, and the complete set of actions distributed according to the policy $\pi(a'|s')$. Note the explicit dependence on the policy $\pi$.
$$ Q^{\pi}(s, a) = r(s, a) + \gamma \mathbb{E}\_{s' \sim p(s'|s, a)} \big[\mathbb{E}\_{a' \sim \pi(a' | s')}[Q(s', a')]\big] $$

{{<rawhtml>}}
<details>
<summary><strong>Here's a graphical visualization of the Q function</strong></summary>
{{<figure src="https://i.imgur.com/TXEPzvN.png" caption="Fig. 1: A graphical vizualization of the Q function. $Q(s, a)$ is the expected reward considering all possible state and action combinations. In this figure, there are four possible states and each state has three possible actions. Therefore, $Q(s, a)$ is an expectation over all 12 rewards added to $Q(s', a')$, the Q value at the next step.">}}
</details>
{{</rawhtml>}}

The **state value function** $V(s)$ represents the implicit _value_ of being in the state $s$. A state is only as good as the actions that you can take from that state, and the rewards that you can expect from those actions. Quite simply, $V(s)$ is the average of $Q(s, a)$ over all possible actions distributed according to $\pi(a|s)$.
$$ V(s) = \mathbb{E}_{a \sim \pi(a|s)}[Q(s, a)] $$

Based on these two definitions, we often come across the **advantage function** $A(s, a)$. It is a measure of the added advantage of choosing an action $a$ over other possible actions. Mathematically, this is the difference between $Q(s, a)$, the expected reward of choosing $a$, and the expected reward over all possible actions $V(s)$.
$$A(s, a) = Q(s, a) - V(s)$$

<!-- **Total Rewards**: $G_t$ is the discounted sum of rewards starting from timestep $t$.
$$ G_t = R_{t+1} + \gamma R_{t + 2} + \dots + \gamma^{T-1}R_T $$ -->

The goal of reinforcement learning is quite simple. Find a policy $\pi^*_\theta$ that maximizes the expected return.

$$ \pi^*\_\theta = \argmax\_{\pi_\theta} \mathbb{E}\_{\tau \sim p\_{\pi_\theta} (\tau)} \left[\sum_t r(s_t, a_t)\right] $$

As you can imagine, finding the optimal policy is difficult enough that there is an entire field of RL dedicated to it.

# Taxonomy
---
RL algorithms are commonly categorized based on the use of transition probabilities. However, each algorithm can differ on various parameters so there are often other categorizations as well. Some of them are listed below.

**Model Free vs Model Based**: RL algorithms can be broadly classified based on whether $p(s'|s, a)$ is known. If the dynamics of the environment is known and the algorithm makes use of these transition probabilities, the algorithm is a model-based algorithm. If the algorithm does not use $p(s'|s, a)$, it's a model-free algorithm.

{{<figure src="https://i.imgur.com/VVJ6V1e.png" caption="Fig. 3: Taxonomy of RL Algorithms" width="75%">}}

**Policy Based, Value Based or Actor Critic**: Model-free algorithms can further be classified into policy based, value based or actor critic algorithms based on what is being parameterized. If the policy $\pi_\theta$ is explicitly being modelled by a set of parameters $\theta$, the algorithm is a policy based algorithm. If an algorithm does not explicitly model the policy and makes use of the value function instead, it's a value based algorithm. If the algorithm takes a hybrid approach and parameterizes both, the policy and the value function, it's an actor-critic algorithm.

**Online vs Offline RL**: Many algorithms interact with the environment during the learning process. Such algorithms are called online RL algorithms. On the other hand, if the algorithm does not have the ability to interact with the environment and is constrained to learn from a fixed dataset, it's an offline RL algorithm.

**On-policy vs Off-policy**: Some algorithms require that the trajectories used during an update step be collected from the same policy which is being optimized. These algorithms are on-policy algorithms. If the algorithm does not impose restrictions on the policy used to collect the observations that it learns from, it's an off-policy algorithm.


# Imitation Learning
---
## Behaviour Cloning

This approach is very similar to supervised learning. The basic idea here is to learn to imitate the actions of an expert, hence the name _behaviour cloning_. In the simplest setting, a dataset $\mathcal{D}$ of expert labelled observations is collected, which is then used to train a policy $\pi_\theta$ with the objective of imitating the actions of the expert.

## Distributional Mismatch
A system trained through behaviour cloning will work fine as long as the distribution of observations from the trained policy $p_{\pi_\theta}$ closely follows the distribution of observations from the behaviour policy (the policy used to collect the training data) $p_\text{data}$. But this is rarely the case. Consider the example of learning to drive a car. As soon as a learnt policy makes a mistake, the new set of observations (car running off the road) will be significantly different from the training set (car centred in a lane). This is further exacerbated by the problem of compounding errors in sequential decision making. A wrong action will lead to an unseen observation which further leads to another wrong action and this negative feedback loop continues.

To overcome this issue, {{<cite "bojarski2016end" "text">}} collect extra observations from cameras mounted to either side of the car. These side cameras store observations with a corrective action in the opposite direction to steer the car towards the center of the road. A similar approach is also followed by {{<cite "giusti2015machine" "text">}} to train drones.


{{<rawhtml>}}
<figure>
<img src="https://i.imgur.com/FGwcvdD.png" controls></img>
<figcaption>Fig. 3: The observations collected from the side cameras have a corrective action. Image from {{<cite "bojarski2016end" "text">}}.</figcaption>
</figure>
{{</rawhtml>}}


## DAgger

One way to solve the distributional mismatch is to keep on collecting failed observations and later ask an expert to relabel them correctly. Repeating this cycle many times will eventually lead to a dataset of diverse observations, which might finally train our agent. This approach, first described in {{<cite "ross2011reduction" "text">}}, is called **DAgger** (short for Dataset Aggregation). Here's the recipe:

1. Train $\pi_\theta(a_t|o_t)$ on expert data $\mathcal{D} = \\{o_1, a_1, \dots, o_N, a_N\\}$.
2. Run $\pi_\theta(a_t|o_t)$ to get $\mathcal{D_\pi} = \\{o_1, \dots, o_M\\}$.
3. **Ask expert to annotate $\mathcal{D_\pi}$ with actions $a_t$.**
4. Aggregate $\mathcal{D} \leftarrow \mathcal{D} \cup \mathcal{D_\pi}$.
5. Repeat from step 1 until convergence.

The major challenge here is that one needs access to an expert (step 3). This might work in cases where a finite amount of data is sufficient, but typically modern deep neural nets require much more data which is difficult to be collected by an expert.

# Todo
* Value Iteration
* TD Learning
* Double DQN

# Policy Gradients
---
The objective, in its simplest form, is to maximize the expected rewards over the trajectory $\tau$ when following a policy $\pi_\theta$. For a given trajectory, $r_\tau$ is the sum of discounted rewards with a discount factor of $\gamma$ over the horizon $T$. We can optimize this using score function gradients.

Keep in mind that randomness comes from the following sources:
* The actions sampled from the policy $\pi_\theta(a_t|s_t)$
* The state transition probabilities $p(s_{t+1}|s_t, a_t)$
* The rewards $r(s_t, a_t)$

$$
\mathcal{L}(\theta) = \mathbb{E}\_{\tau \sim \pi_\theta}[r_\tau]
,\quad
r_\tau = \sum_{t=1}^{T} \gamma_t r_t
$$

# References
{{<bibliography cited>}}