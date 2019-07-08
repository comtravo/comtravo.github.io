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

## A Bayesian approach to modeling neural networks to estimate uncertainty in predicting personalised travel results for customers 

At Comtravo, we aim to simplify travel for our customers by handling requests with the aid of machine learning models. While natural language processing models infer the details required to query the Search engine, recommendation strategies are essential in selecting the most relevant results from those presented by the Search API. Rule based heuristics are currently employed to rank the search results, but given the tremendous success of deep learning in several fields, we are looking into employing neural networks as a component in our recommendation pipeline. 

Neural networks are extremely effective in learning complex patterns and capturing non-linearities. This would enable us to personalise search results using a learning framework that can infer travel preferences of our customers. However, traditional neural networks do not quantify the inherent uncertainity in the data or in the model predictions. This is something valuable while ranking and can be modeled by using a Bayesian approach.

### Learning to Rank Algorithm

A recommendation system in this application would solve the problem of ranking. From a list of travel options, the algorithm needs to sort it in the order of most to least relevant for the customer. For example, if a customer wishes to fly from Berlin to Frankfurt tomorrow, a search for this request would return numerous if not all possibilities of reaching Frankfurt from Berlin. But to simplify travel, we need to reduce this information overload by filtering the most relevant options. Some rule based logic can be useful for already narrowing the list of options. An algorithm to filter out options with the fastest travel time is an example. But ideally, these filters would be personalised according to each customer. Time preferences to travel (if not explicitly mentioned), frequently used airlines and preferred price ranges are some customer preferences which can be generalised by a deep learning framework which would rank the travel options. Moreover, a learning agent like neural networks would learn the importance each customer associates with the different travel related attributes such as time, airlines, cost, etc and applies weights for each influential attribute. This overcomes the problem we face while choosing individual strategies to rank the search results.

### Risk vs Uncertainty

Our dream recommender system would need to be able to reason like a human agent, if not better. Neural networks being good at abstracting patterns from data can do this if trained on the options selected by human agents for a travel request from the customer.  Typical ranking problems using neural networks use the softmax probability to rank. However, in the Bayesian world, the softmax probability is only the probability of a sample belonging to a certain class. This probability does not tell us anything about the quality of the prediction. However, there is uncertainty as well as risk which needs to be quantified by the model to make the selections. For example, a classifier which learns to distinguish between cats and dogs can give a erratic output for an unseen image such as a giraffe. In such cases, we cannot blindly trust the softmax probability but it would be helpful if the model also shows the confidence about its prediction. The model uncertainity should be high for classifying a giraffe as it's not trained on examples of giraffes. This type of uncertainity is also known as epistemic uncertainity, that is, the model could learn it if provided with infinte data. Since training data is usually limited, model uncertainity also arises in practice. In general, any model is trying to learn an abstract representation of the physical world. Since it is not able to explain all the observables of the underlying structure, we should quantify how well it has learnt the patterns.

Aleatoric uncertainty, on the other hand, arises from the risk or the inherent randomness, which is the nature of the world we operate in. This is reflected in the variability of the outcome given the same inputs. A user who usually flies with Lufthansa may choose to fly with Easyjet as an exception. This risk is more pronounced when the probability of that outcome is smaller. The risk in obtaining heads from a fair coin with a p = 0.5 is greater than a biased coin rigged to come heads up. Uncertainty, on the other hand, is introduced by the learning agent trying to learn this probability. As an analogy with human agents who generate offers for travel requests, an agent who knows the preferences of that particular customer through frequent interactions would choose options very differently than an agent who is reasoning without this additional knowledge. In a learning agent such as neural networks, uncertainity is introduced over the confusion of which model parameters apply. It is also introduced by the model learning from data which has uncertainity, reflecting errors and differences in human agent selections.

### Learning what the model does not know

A truly intelligent algorithm would reason about risk and uncertainty while making a decision, where intelligence can be defined as being aware of one's own limitations. In this context, the model is aware of the gaps in the knowledge that it has acquired from the real-world data. However, this is hard to learn as there is no labeled data available for learning uncertainty.

Looking at the different uncertainities individually, aleatoric uncertainity is much easier to work with. Monte Carlo methods can be employed to provide a random sample from the posterior distribution in Bayesian inference. But we will look at the concepts behind these big words soon. Monte Carlo methods repeatedly draw a random sample, based on which it allows us to estimate the "ground truth" probability distribution. 

Model uncertainty is more complex to evaluate. The primary reason for this being, there are an overwhelming number of models to consider. In terms of possible values of weights and biases alone, innumerable neural network models can be constructed for the same dataset. Machine learning models have a lot of hyper parameters, and small values changes yield very different model behavior. The second challenge is introduced by the number of covariates in any real-world problem, which greatly exceed the amount of data we collect. For example, travel choices can be affected by several characteristics such as weather, political climate, service quality of th operator, etc. While such explanatory covariates would greatly increase the model accuracy, the data collection of specialised data and covering all possible atrributes becomes an increasingly complex effort for possibly very marginal gains. Instead we want to know how much uncertainity the model has, so that we can improve the model if needed. 

#### Probabilistic Programming

#### Inference Techniques

#### Interpreting results
