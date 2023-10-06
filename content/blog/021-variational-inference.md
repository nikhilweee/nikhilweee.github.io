+++
categories = ['Explanations', 'Long Posts']
citations = true
date = '2022-04-18'
draft = true
katex = true
slug = 'variational-inference-basics'
subtitle = 'Recap of the basics'
title = 'Variational Inference'
+++

The standard recipe of Bayesian inference is to place some priors on the data, compute the likelihood given some observed data, and then update the posterior using the prior and the likelihood. The prior $p(\theta)$ represents our belief over the parameters $\theta$ of our model _before_ observing any data. The likelihood $p(y | \theta, x)$ represents the probability of observing data subject to our model, and the posterior $p(\theta | y, x)$ represents our belief over the parameters _after_ we observe the data.



{{<toc>}}

# References
{{<bibliography cited>}}