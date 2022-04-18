+++
categories = ['Explanations']
date = '2017-04-12T00:00:00Z'
draft = true
subtitle = "Visualizing algorithms for the rubik's cube"
tags = ['cube', 'algorithms']
title = 'Visual Cube'

+++
> This page is best viewed on Safari. Functionality is known to be broken on Chrome.

The rubik's cube needs no introduction. I've personally seen these since my childhood but I was never quite interested in solving the cube. As a kid, I used to play around, knowing that this is impossible for me to solve. I gave up easily. This was nothing more than a fidgeting toy.

Only recently has this toy caught my interest, and it was a bit too late when I tried to learn how to actually solve a cube. Most of the tutorials on the web throw out algorithms at you, but without an intuitive understanding of how they actually work, simply memorizing them does no good.

Here's an attempt to simplify all those `FR'UDD'R`s. Feel free to play around.

>The animation is based on [RubiCSS cube](https://codepen.io/pixelass/pen/CsItl) by [Gregor Adams](https://codepen.io/pixelass).  
>For more details on the algorithms, visit  [how-to-solve-a-rubix-cube.com](https://how-to-solve-a-rubix-cube.com/)

# Correcting the edges

`F R D' R F F`

This might be the first "difficult" step for many newbies. Pay attention to the highlighted edge. Notice how this algorithm cleverly corrects the orientation of the red-green edge.

{{<rawhtml>}}
    <object type="text/html" style="width: 100%; height: 500px" data="frdrff.html"></object>
{{</rawhtml>}}

# The Top Cross

`F R U R' U' F`

Once you've made the second layer, these algorithms start to get a bit longer. And why not? These algorithms also have the additional responsibility to maintain the bottom two layers. Here's the popular `fruruf`.

There are a few interesting observations about this algorithm.  
Notice the "L" and "Rod" shapes on the top edge that are commonly talked about. Also notice how there's a counterclockwise follow up to every move. There's an `R'` for an `R`, an `F'` for an `F`, and a `U'` for a `U`. These are certainly necessary to maintain the bottom two layers. Also notice that the reverse order is  not `U'R'F'` for obvious reasons.
Notice how six iterations of the same algorithm bring you back to where you started. Also notice the "L" and "Rod" shapes formed on the top face of the cube.

{{<rawhtml>}}
    <object type="text/html" style="width: 100%; height: 500px" data="fruruf.html"></object>
{{</rawhtml>}}

# The Last Layer Edges

`R U R' U R U U R' U`

Swapping the edges on the last layer can be tricky to understand. Take a look below.
Notice how the consecutive `UU`s are important to bring the top edges back to position.

{{<rawhtml>}}
    <object type="text/html" style="width: 100%; height: 500px" data="rururuuru.html"></object>
{{</rawhtml>}}

# Position the Last Layer Corners

`U R U' L' U R' U' L`

Swapping the edges on the last layer can be tricky to understand. Take a look below.
Corner 1 always stays in the same place, and in the same orientation. Notice how the bottom layers and the top corners are gracefully in place.
Also note the positions of the four corners at the end of every iteration. The algorithm repeats itself after three iterations. The highlighted corners can only be in one of the three possibilities.

{{<rawhtml>}}
    <object type="text/html" style="width: 100%; height: 500px" data="urulurul.html"></object>
{{</rawhtml>}}

# Orient the Last Layer Corners

`R' D' R D`

Swapping the edges on the last layer can be tricky to understand. Take a look below.
Notice how the orienttion of the four corners is changed after an even iteration.

{{<rawhtml>}}
    <object type="text/html" style="width: 100%; height: 500px" data="rdrd.html"></object>
{{</rawhtml>}}

I hope this visual tour helps improve your understanding of the cube. I'm sure there might be better interpretations. Please feel free to comment!
