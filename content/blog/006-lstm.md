+++
categories = ['Explanations']
date = '2016-11-09T00:00:00Z'
draft = true
katex = true
subtitle = 'the name says it all!'
title = 'LSTMs'
+++

>This post explains LSTMs used as a part of [assignment 3](http://cs231n.github.io/assignment3/) of Andrej Karpathy's CS231N course at Stanford. I would highly recommend reading Chris Olah's [blog post](http://colah.github.io/posts/2015-08-Understanding-LSTMs/) about LSTMs before continuing.

Traditional Neural Networks have successfully been used for various purposes that I do not need to reiterate upon. But in applications involving sequential data such as natural language processing, it so happens that the current output (say, the next word in a predicted sentence) very much depends on several previous outputs (the sequence of words predicted so far). In such cases, the network needs to somehow keep a _memory_ so that it could use them for prediction at each step.

RNNs help solve this problem. These are just like the regular neuron, except that it has loops, which allows it to have memory. Now RNNs are good when it comes to storing information in the short term, but due to something called the [vanishing gradient problem](http://www.jmlr.org/proceedings/papers/v28/pascanu13.pdf), they cannot store information for long (like learning relation between words that are a several steps apart).

### Enter LSTMs
This is where LSTMs come into the picture. Short for _Long Short-Term Memory_, these cells have memory along with mechanisms to control information flow so that relevant information is persisted for long.

The core idea behind LSTMs is something called a memory cell, $c_t$ which can maintain its state over time.

Here's a simple overview of the LSTM Cell with some of the important parameters.

![intro](/img/lstm/intro.svg)

The LSTM Cell accepts the input vector, $x_t$, the previous hidden state, $h_{t-1}$, and the previous cell state, $c_{t-1}$ shown in green, such that the input vector, $x_t \in \mathbb{R}^D$, hidden vector, $h_{t-1} \in \mathbb{R}^H$ cell state vector, $c_{t-1} \in \mathbb{R}^H$.

It also maintains the matrices $W_x$, $W_b$ and the bias vector $b$ internally. Input to hidden matrix, $W_x \in \mathbb{R}^{4H \times D}$. Hidden to hidden matrix, $W_h \in \mathbb{R}^{4H \times H}$ and bias vector, $b \in \mathbb{R}^{4H}$.

At each timestep, we first calculate something called the activation vector, $a$, which is simply:

$$a = W_x x_t + W_h h_{t-1} + b$$

Going by the rules of matrix multiplication, $a \in \mathbb{R}^{4H}$. We then essentially split this activation vector equally in to 4 vectors, which we name $a_i, a_f, a_o$ and $a_g$.

$$
\begin{bmatrix} a_i \\\ a_f \\\ a_o \\\ a_g \end{bmatrix} = \begin{bmatrix}
    a_{1:N} \\\ a_{N:2N} \\\ a_{2N:3N} \\\ a_{3N:4N}
\end{bmatrix}
$$

These vectors are then passed through $\mathrm{sigmoid}$ and $\tanh$ functions, to finally get the well known $i, f, o$ and $g$ gates.

$$
\begin{bmatrix} i \\\ f \\\ o \\\ g \end{bmatrix} =
\begin{bmatrix} \sigma(a_i) \\\ \sigma(a_f) \\\ \sigma(a_o) \\\ \tanh(a_g) \end{bmatrix}
$$

To summarize until now, here is a computational graph.
![gates](/img/lstm/gates.svg)

Once we get the gate vectors, the cell state, $c_t$ and the next cell state, $h_t$ is given by

$$ c_t = f \odot c_{t-1} + i \odot g $$

$$ h_t = o \odot \tanh(c_t) $$

where $\odot$ stands for elementwise multiplication.
This can also be visualised by the following graph.
![output](/img/lstm/output.svg)

This is how both of them fit together.
![merged](/img/lstm/merged.svg)

Stay tuned for part 2 where I explain the backward pass of the cell.
