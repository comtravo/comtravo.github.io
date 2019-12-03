---
layout: article
title: Bayesian neural networks: Under the hood
date: 2019-11-25 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [Uncertainty, Bayesian statistics, Neural networks]
comments: true
share: true
published: true
image:
  teaser: 2019_10_01/teaser.png
  feature: 2019_10_01/feature.png
description: The inner working and math which runs the Bayesian neural network engine
usemathjax: true  # if you need math symbols turn this one
author: bharathi_srini
---

In the previous blog post, we introduced the idea of Bayesian neural networks and looked at one application of where it can be successful. This raises questions like what kind of data is idea for these algorithm and where they should be used. To answer which problems can be solved well by utilizing Bayesian neural networks, it is essential to look under the hood. In this post, we will look at the inner workings of the engine that runs Bayesian neural networks.