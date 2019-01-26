---
layout: article
title: Effective Mocking of Unit Tests for Machine Learning
date: 2019-01-26 05:31:00
published: false
categories: [testing]
comments: false
share: true
image:
  teaser: 2018_07_07/teaser.jpg
  feature: 2018_07_07/feature.jpg
description: Writing unit tests for machine learning models can be challenging due to the complex structure of the models. In this post I'll show how the python unit test mocking framework can be used to write better unit tests for machine learning.
usemathjax: false
author: matti_lyra
---

The data science backend at Comtravo is almost exclusively written in Python. We currently have about 15 different machine learning models performing various tasks. One does named entity recognition, another intent classification while yet a third does slot filling: recognising which semantic role a token or sequence of tokens has in a message, for instance `TXL` is <a class="btn-info">origin</a>, `MUC` the <a class="btn-info">destination</a> and `tomorrow morning` is the <a class="btn-info">departure time</a> in the sentence "_Could you please book me a flight tomorrow morning from TXL to MUC_".


- what are unit tests
- why writing tests for machine learning models is difficult
- what are unit test mocks
- what, specifically, is the `unittest.mock` library
- how to utilise `unittest.mock` to write better unit tests for ML

# Testing Machine Learning Models with `unittest`

how to use mocks effectively


and some toher things.
