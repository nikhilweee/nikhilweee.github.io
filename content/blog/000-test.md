+++
date = '2022-04-01T00:00:00Z'
draft = true
subtitle = 'So everything works fine'
title = 'Test Post'
categories = ["Test"]
tex = true
citations = true
slug = "test"
layout = "index"

+++

I shall use this post to test the layout of this website.

# Headings
This is a level 1 header.

## Subheadings
This is a level 2 header.

# KaTeX
Here's how to find $x$ using the standard quadratic equation.

$$ x = -b \pm \frac{\sqrt{b^2 - 4ac}}{2a} $$

Make sure that the following equation does not overflow.

$$p(s_1, a_1, \dots, s_T, a_T) = p(s_1) \ p(a_1|s_1) \ p(s_2|s_1,a_1) \ p(a_2|s_1,a_1,s_2) \dots p(s_T|s_1, a_1, \dots, a_{T-1}) \ p(a_T|s_1, a_1, \dots, s_T)$$

# Citations

Prior work {{<cite "huang2017adversarial;kos2017delving" "paren" ";1-2">}},  has shown that deep RL policies are vulnerable to small adversarial perturbations to their observations, similar to adversarial examples {{<cite key="szegedy2013intriguing" type="paren">}} in image classifiers. Such adversarial models assume that the attacker can directly modify the victim’s observation. However, such attacks are not practical in the real world. 

{{<cite "bojarski2016end" "text">}} show that mounting side cameras collect extra observations.

# Bibliography

{{<bibliography cited>}}

# Code
```python
# Here is some really long piece of code
def test_function(inputs):
    return "This is a very long piece of text which is designed to test the robustness of the layout of the blog."

```