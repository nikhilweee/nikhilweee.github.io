+++
categories = ['Work', 'Long Posts']
citations = true
date = '2022-05-13'
draft = true
katex = true
slug = 'contrastive-mae'
subtitle = 'Masked Autoencoding vs Contrastive Learning'
title = 'Contrastive MAE'
+++

> This post a write up for the final project as part of NYU's graduate course on Machine Learning.

# Abstract

---

Many of the recent self-supervised learning methods {{<cite "he2020momentum;chen2020simple">}} rely on contrastive learning for network pretraining. However, recent research {{<cite "he2021masked">}} has shown that masked autoencoders (MAEs) can outperform contrastive learning approaches. This post is an attempt to combine the best of both worlds by adding a contrastive loss on MAEs. It compares the performance of vanilla MAEs with contrastive MAEs, and experiments suggest that a contrastive loss is detrimental to performance. The code for this post is publicly available on [GitHub](https://github.com/nikhilweee/contrastive-mae).

# Background

---

## Pretraining and Finetuning

The idea of self-supervised learning has recently been popularised with the advent of large language models like BERT {{<cite "devlin-etal-2019-bert">}} and GPT-3 {{<cite "brown-etal-2020-language">}}. These models follow the two step pretraining - finetuning paradigm, where the model is pretrained on a large amount of unsupervised data before finetuning on downstream tasks. The task used for pretraining is not of primary concern. It merely exists so that the model can learn meaningful representations of the input data, which can be further exploited in downstream tasks.

This design can lead to two distinct advantages. One, it enables the use of a large amount of training data in an unsupervised manner. Two, it encourages diverse representations that can be used for more than one tasks. Compare this with supervised learning, where the training data is much more limited due to the requirement of supervised labels. Here the model is often trained on the same task that it is tested on, so there is no direct incentive to learn diverse representations.

## Classification Tasks

There have been many different kinds of pretraining tasks used in the literature. BERT was pretrained using a masked language modelling task, whereas GPT-3 was trained using the next token prediction task. In the vision domain, pretraining tasks range from predicting the rotation of an augmented image, predicting relative positions of image patches, and even solving jigsaw puzzles. More recently, quite a few approaches have used instance discrimination as the pretraining task. Given an image (instance) and a set of candidate patches, the aim of the model is to choose the patch that belongs to the same instance under consideration.

{{<rawcaption src="https://i.imgur.com/KNIxVB3.png">}}
A description of the instance discrimination task {{<cite "zhao2021self">}}
{{</rawcaption>}}

## Generation Tasks

All the pretraining tasks describe above can be modelled as a multiclass classification problem. However, there can be another class of pretext tasks based on generation.

I will refer you to Lilian Weng's [blog post](https://lilianweng.github.io/posts/2021-05-31-contrastive/) on Contrastive Learning.

# Acknowledgements

---

The code for this project is based on the [official implementation](https://github.com/facebookresearch/mae) by Facebook Research. I would also like to thank our course instructor, [Prof. Rajesh Ranganath](https://cims.nyu.edu/~rajeshr/), and [Mark Goldstein](https://marikgoldstein.github.io/), our course TA for their helpful insights on this project. This project was the result of a collaboration with my classmates [Emily Hao](https://www.linkedin.com/in/emilyhao/) and [Mugdha Thigle](https://www.linkedin.com/in/mugdha-thigle/).

# References

---

{{<bibliography cited>}}
