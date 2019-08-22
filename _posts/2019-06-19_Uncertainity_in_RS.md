---
layout: article
title: Uncertainty in Recommender Systems
date: 2019-06-19 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [uncertainity, Bayesian statistics, risk, model assessment]
comments: true
share: true
image:
  teaser: 2018_07_07/teaser.jpg
  feature: 2018_07_07/feature.jpg
description: Bayesian neural networks to estimate uncertainty in recommendation
usemathjax: true  # if you need math symbols turn this one
author: bharathi_srini
---

## A Recommendation for Recommender Systems

At Comtravo, we aim to simplify travel for our customers and machine learning algorithms help us do this faster and better (sometimes). While natural language processing models infer the details required to query the Search engine, recommendation strategies are essential in selecting the most relevant results from those presented by the Search API. The Internet is a vast place and any good service would filter these results to reduce the information overload on the customer. A travel request from our customer can look like this:
"I want to fly from Berlin to Frankfurt tomorrow morning."
Search results for flights from Berlin to Frankfurt in the specified time range returns almost all possible travel options. However, we want to show a maximum of 3 results which are most relevant to the customer. Logical assumptions about time of each trip, price ranges, popular times to fly, etc can be made and such heuristics can be used to select the Top 3 results. However, such a filtering model does not build a personalised set of results. Besides the fact that it contains no ML or the use of historic data.

If a customer requests a round trip on the same day without explicitly mentioning the desired time of travel, it is reasonable to propose travel options early in the morning and return trip options in the evening. While such cases are handled by rule based filtering, it quickly gets exhanusting to cover all possible cases. Therefore, it is useful to have a learning agent which could infer such patterns and does the selection of 'best' travel options for each customer.
Step in, machine learning to save the day!

## But which machine learning algorithm to use?

![XKCD Comic](/images/2019_07_25/machine_learning_2x.png)
Format: ![Alt Text](https://imgs.xkcd.com/comics/machine_learning.png)

Although several classification algorithms can be applied for this problem and typical recommendation systems are matrix factorization based, we will consider Bayesian neural networks which provides an uncertainty estimate. 

Neural networks are popular in the industry as they are extremely effective in learning complex patterns and capturing non-linearities. This would enable us to personalise search results using a learning framework that can infer travel preferences of our customers. However, traditional neural networks do not quantify the inherent uncertainity in the data or in the model predictions. This is something valuable while ranking and can be modeled by using a Bayesian approach. Later in this blog post, we will come back to this uncertainty estimate and examine how it is useful in recommendation vs ranking.

While Bayesian methods is a vast topic by itself, it will not be covered in detail here but a brief overview is presented in the section below if the reader is not yet acquainted with Bayesian Neural Networks.

## A Quick Look at the Bayesian Neural Network

The Bayesian Neural Network is different from the 'frequentist' counterpart because it has probability distributions over the  weights and biases of the network. 

On a more granular level, each neuron of the network multiplies the data point with a weight matrix which is learned from back propogation and some bias is added to it. To add non-linearity, we apply an activation function to this algebraic resultant. Typically, these weights and biases are initialised with point estimates, while in Bayesian Neural Networks, distributions are specified are the starting values. These are useful to encode our prior beliefs about the underlying model which generated our data. The ambiguity of calling this initial distribution $p(theta)$ as 'beliefs' is also why some Bayesians like to refer to this as prior information, but this is simply a quarrel over the semantics. 

## Ranking vs Recommending



## Estimating model uncertainty


## How does knowing the uncertainity help us make better choices?





### Learning to Rank vs Recommend

A recommendation system in this application would solve the problem of ranking. From a list of travel options, the algorithm needs to sort it in the order of most to least relevant for the customer. For example, if a customer wishes to fly from Berlin to Frankfurt tomorrow, a search for this request would return numerous if not all possibilities of reaching Frankfurt from Berlin. But to simplify travel, we need to reduce this information overload by filtering the most relevant options. Some rule based logic can be useful for narrowing the list of options. An algorithm to filter out options with the fastest travel time is an example. But ideally, these filters would be personalised according to each customer. Time preferences to travel (if not explicitly mentioned), frequently used airlines and preferred price ranges are some customer preferences which can be generalised by a deep learning framework which would rank the travel options. Moreover, a learning agent like neural networks would learn the importance each customer associates with the different travel related attributes such as time, airlines, cost, etc and applies weights for each influential attribute. This overcomes the problem we face while choosing individual strategies to rank the search results.




