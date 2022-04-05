+++
date = '2022-04-01T00:00:00Z'
draft = true
subtitle = 'So everything works fine'
title = 'Test Post'
categories = ["Test"]
mathjax = true
citations = true
slug = "test"
layout = "index"

+++

I shall use this post to test the layout of this website.

# Headings
This is a level 1 header.

## Subheadings
This is a level 2 header.

# Citations

Prior work {{<cite "huang2017adversarial;kos2017delving" "1-2;4-5">}},  has shown that deep RL policies are vulnerable to small adversarial perturbations to their observations, similar to adversarial examples {{<cite "szegedy2013intriguing">}} in image classifiers. Such adversarial models assume that the attacker can directly modify the victim’s observation. However, such attacks are not practical in the real world. In contrast, we look at attacks via adversarial policy designed specifically for the two-agent zero-sum environments. The goal of the attacker is to fail a well-trained agent in the game by manipulating the opponent’s behavior. Specifically, we explore the attacks using an adversarial policy in low-dimensional environments.

# Bibliography

{{<bibliography cited>}}

# Code
```python
# Here is some really long piece of code
def test_function(inputs):
    return "This is a very long piece of text which is designed to test the robustness of the layout of the blog."

```