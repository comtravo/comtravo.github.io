---
layout: article
title: Uncertainty in Recommender Systems
date: 2019-06-19 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [uncertainity, Bayesian statistics, risk, model assessment]
comments: false
share: true
image:
  teaser: 2018_07_07/teaser.jpg
  feature: 2018_07_07/feature.jpg
description: Bayesian neural networks to estimate uncertainity in recommendation
usemathjax: true  # if you need math symbols turn this one
author: bharathi_srini
---

A Bayesian approach to modeling neural networks to estimate uncertainty in predicting personalised travel results for customers 

At Comtravo, we aim to simplify travel for our customers by handling requests using machine learning models. While natural language processing models infer the details required to query the Search engine, recommendation strategies are essential in selecting the most relevant results from those presented by the Search API. While rule based heuristics are currently employed to rank the search results, given the tremendous success of deep learning in several fields, we are looking into employing neural networks as a component in our recommendation pipeline. 

Neural networks are extremely effective in learning complex patterns and capturing non-linearities. This would enable us to personalise search results using neural networks which learn travel preferences of our customers. However, traditional neural networks use point estimates which results in point predictions. Moreover, tend to have overconfident predictions from being poorly calibrated in mod- ern applications. These are compelling reasons to use a Bayesian approach to modelling a neural network.
