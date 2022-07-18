+++
date = '2022-04-01T00:00:00Z'
draft = true
title = 'Test Post'
subtitle = 'So everything works fine'
categories = ["Long Test Category"]
katex = true
citations = true
slug = "test"

+++

I shall use this post to test the layout of this website. 

First, make sure the subtitle, date and categories turns out to be fine.

# Headings
This is a level 1 header.

## Subheadings
This is a level 2 header. Make sure this renders correctly on the sidebar.

# Emojis
This blog has emoji support. :heart:

# KaTeX
Here's how to find $x$ using the standard quadratic equation. Make sure this doesn't scroll.

$$ x = -b \pm \frac{\sqrt{b^2 - 4ac}}{2a} $$

Make sure that the following equation does not overflow off the page width.

$$p(s_1, a_1, \dots, s_T, a_T) = p(s_1) \ p(a_1|s_1) \ p(s_2|s_1,a_1) \ p(a_2|s_1,a_1,s_2) \dots p(s_T|s_1, a_1, \dots, a_{T-1}) \ p(a_T|s_1, a_1, \dots, s_T)$$

Also make sure that line heights are preserved when using inline math. 

This is going to be a big paragraph which is not going to make any sense. This is because it is meant to test whether an expression disturbs the normal flow of a paragraph. This is an expression which can come up in sentences: $a^{x^2}$. This paragraph essentially uses $\KaTeX$ symbols as bullet points. When this happens, the line height of the adjacent lines gets affected in such a way that it breaks the flow of the page. I want to see consistent line heights, but when I fail to see one, this is a sign of trouble.

A **Markov chain** $\mathcal{M} = \\{\mathcal{S}, \mathcal{T}\\}$ can be defined by a set of states $\mathcal{S}$ and a transition function $\mathcal{T}$ which is used to compute the transition probabilities. Here, the next state only depends on the previous state $s_t$. A **Markov decision process** $\mathcal{M} = \\{\mathcal{S}, \mathcal{A}, \mathcal{T}, r\\}$ adds an action space $\mathcal{A}$, and a reward function $r(s_t, a_t)$ such that the next state $s_{t+1}$ is now also dependent on the current action $a_t$. A **partially observed Markov decision process** further adds an observation space, and an emission probability which defines the observation distribution. Instead of direct access to the complete state, we only have access to the observation, which derives from the state but may or may not fully describe the state. Here's a graphical picture.

# Citations

Prior work {{<cite "huang2017adversarial;kos2017delving" "paren" ";1-2">}},  has shown that deep RL policies are vulnerable to small adversarial perturbations to their observations, similar to adversarial examples {{<cite key="szegedy2013intriguing" type="paren">}} in image classifiers. Such adversarial models assume that the attacker can directly modify the victim’s observation. However, such attacks are not practical in the real world. 

{{<cite "bojarski2016end" "text">}} show that mounting side cameras collect extra observations.

# Contents Sidebar
The sidebar should not be too small compared to the main content. Take the next heading as an example. Note that the width of the sidebar is dependent on its content.

## This is an unnecessarily long heading

# Known Issues
There are several known issues on an android tablet. First, the font refuses to resize until a scroll action is performed. Second, the line height is not consistent while using KaTeX.

# Bibliography

{{<bibliography cited>}}

# Code
```python
# Here is some really long piece of code
def test_function(inputs):
    return "This is a very long piece of text which is designed to test the robustness of the layout of the blog."

```