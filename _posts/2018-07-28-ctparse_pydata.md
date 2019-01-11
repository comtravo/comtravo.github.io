---
layout: article
title: A Practical Parser for Time Expressions
date: 2018-07-28 11:25:00
categories: [time-parsing, ctparse, NLP, pydata]
comments: false
share: false
image:
  teaser: 2018_07_07/teaser.jpg
  feature: 2018_07_07/feature.jpg
description: ctparse is a pure python library (MIT-License) for parsing complex time expressions efficiently.
usemathjax: false
author: sebastian_mika
---

One of the main methods of communication for Comtravo customers is email. We get hundreds of travel booking request emails daily and all of them contain time expressions that we need to turn into a computer readable format. Humans naturally talk about "_tomorrow afternoon_" or "_early next Monday morning_". These expressions are both contextual and ambiguous; the exact date of "_next Monday_" and "_tomorrow_" of course depends on what day it is today. Furthermore, "_early morning_" means different things to different people, although some common overlap can probably be agreed upon. Computers on the other hand tend to prefer well defined and unambiguous times, for instance `1530961500` is the unix timestamp for the July 7th 2018, 11:05 (UTC). Note that the time zone, something that most of us don't usually actively think about, is also meaningful in this context.

Parsing time expression into structured, computer readable data is therefore challenging. Many solutions exist, but they are either too simplistic or problematic to use in a `python` setup. We therefore wrote a pure python library for time parsing. `ctparse` is a MIT-Licensed library built on straightforward concepts. It allows parsing complex expressions efficiently and can easily be adjusted for domain specific use cases [https://github.com/comtravo/ctparse](https://github.com/comtravo/ctparse).

In many ways `ctparse` is similar to `duckling`, albeit admittedly having a significantly smaller scope for the time being. `ctparse` implements a regular-expression and rule based system for parsing time and date expressions. There is also a statistical model to rank different parses and favour reasonable solkutions over others. Whilst still in an early stage, we currently outperform `duckling` in parsing date/time expressions from e-mail booking requests, both in terms of speed and accuracy.

For more details have a look at my talk about `ctparse` at the previous PyData Berlin conference. In the talk I lay out the basic concepts and ideas behind building the [PCFG](https://en.wikipedia.org/wiki/Probabilistic_context-free_grammar) (probabilistic context free grammar) inspired parser, discuss in detail some of the more challenging algorithmic building blocks and demonstrate how `python` is actually a very good choice to implement such a system.

Have look at `ctparse` on github and let us know what you think [https://github.com/comtravo/ctparse](https://github.com/comtravo/ctparse).

<iframe width="560" height="315" src="https://www.youtube.com/embed/1By9HIOfM-o" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
