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

Neural networks are extremely effective in learning complex patterns and capturing non-linearities. This would enable us to personalise search results using neural networks which infer travel preferences of our customers. However, traditional neural networks use point estimates which results in point predictions. Moreover, they tend to have overconfident predictions from being poorly calibrated in modern applications. These are compelling reasons to use a Bayesian approach to modelling a neural network.

A recommendation system in this application would solve the problem of ranking. From a list of travel options, the algorithm needs to sort it in the order of most to least relevant for the customer. For example, if a customer wishes to fly from Berlin to Frankfurt tomorrow, a search for this request would return numerous if not all possibilities of reaching Frankfurt from Berlin. But to simplify travel, we need to reduce this information overload by filtering the most relevant options. Some rule based logic can be useful for already narrowing the list of options. An algorithm to filter out options with the fastest travel time is an example. But ideally, these filters would be personalised according to each customer. Time preferences to travel (if not explicitly mentioned), frequestly used airlines and preferred price ranges are some customer preferences which can be generalised by a deep learning framework which would rank the travel options. 

Our dream recommender system would need to be able to reason like a human agent, if not better. Neural networks being good at abstracting patterns from data can do this if trained on the options selected by human agents from the search responses for a travel request from the customer. However, there is uncertainty as well as risk which needs to be quantified by the model to make the selections. Risk is the inherent randomness which is a nature of the world we operate in. This is reflected in the variability of the outcome given the same inputs. A user who usually flies with Lufthansa may choose to fly with Easyjet as an exception. This risk is more pronounced when the probability of that outcome is smaller. The risk in obtaining heads from a fair coin with a p = 0.5 is greater than a biased coin rigged to come heads up. Uncertainty, on the other hand, is introduced by the learning agent trying to learn this probability. As an analogy with human agents who generate offers for travel requests, an agent who knows the preferences of that particular customer through frequent interactions would choose options very differrently than an agent who is reasoning without this additional knowledge. In a learning agent such as neural networks, uncertainity is introduced over the confusion of which model parameters apply. It is also introduced by model learning from data which has uncertainity, reflecting errors and differences in human agent selections.
