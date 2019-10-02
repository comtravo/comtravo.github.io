---
layout: article
title: Uncertainty in Recommender Systems
date: 2019-10-01 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [Uncertainty, Bayesian statistics, Neural networks]
comments: true
share: true
published: true
image:
  teaser: 2018_10_01/teaser.jpg
  feature: 2018_10_01/feature.jpg
description: Bayesian neural networks to estimate uncertainty in recommendation
usemathjax: true  # if you need math symbols turn this one
author: bharathi_srini
---

## A Recommendation for Recommender Systems

At Comtravo, we aim to simplify travel for our customers and machine learning algorithms help us do this faster and better (most often). While natural language processing models infer the details required to query the Search engine, recommendation strategies are essential in selecting the most relevant results from those presented by the Search API. The Internet is a vast place and any good service would filter these results to reduce the information overload on the customer. A travel request from our customer can look like this:
"I want to fly from Berlin to Frankfurt tomorrow morning."
Search results for flights from Berlin to Frankfurt in the specified time range returns almost all possible travel options. However, we want to show a maximum of 3 results which are most relevant to the customer. Logical assumptions can be made about time each trip should take, reasonable price ranges, popular times to fly, etc and such heuristics can be used to select the Top 3 results. However, such a filtering model does not build a personalised set of results. By also applying rules individually, we do not consider how a combination of features influences a customer's choice. For example, I would choose to fly with the cheapest flight unless it has more than 2 stops. Besides, this does not learn from historic data.

If a customer requests a round trip on the same day without explicitly mentioning the desired time of travel, it is reasonable to propose travel options for the outbound trip for hours in the morning and return flights departing in the evening. While such cases are handled by rule based filtering, it quickly gets exhausting to cover all possible cases. Therefore, it is useful to have a learning agent which could infer such patterns and does the selection of 'best' travel options for each customer.
Step in, machine learning to save the day!

## But which machine learning algorithm to use?
![](/images/2019_10_01/machine_learning_2x.png)

[Source: xkcd](https://xkcd.com/)

Although several classification algorithms can be applied for this problem and typical recommendation systems are matrix factorization based, we will consider Bayesian neural networks which provides an uncertainty estimate. THe training data will be designed with booked flights as the positive class and the other options presented to the customer but not booked as the negative training samples. 

Neural networks are popular in the industry as they are extremely effective in learning complex patterns and capturing non-linearities. This would enable us to personalise search results using a learning framework that can infer travel preferences of our customers. There's also an added advantage of creating latenet representations for the user when Embeddings are used for denoting users. Embeddings are trained when the neural network is optimised and this also gives a vector representation of users which can be reused for other machine learning problems where we want to idenitfy similar users. However, traditional neural networks do not quantify the inherent uncertainty in the data or in the model predictions. This is something valuable while ranking and can be modeled by using a Bayesian approach.

While Bayesian methods is a vast topic by itself, it will not be covered in detail here but a brief overview is presented in the section below if the reader is not yet acquainted with Bayesian Neural Networks.

## A Quick Look at the Bayesian Neural Network

The Bayesian Neural Network is different from the 'frequentist' counterpart because it has probability distributions over the  weights and biases of the network. 

Each neuron of the neural network multiplies the data point with a weight matrix and some bias is added to it. To add non-linearity, we apply an activation function to this algebraic resultant. Typically, these weights and biases are determined using back propogation which results in point estimates as the solution.

Bayesian methods allow these weights and biases to be computed as distributions. We start with some inital distributions over the weights and biases. Let's call this distribution $$p(w)$$. This is useful for encoding our prior 'beliefs' about the underlying model which generated our data (either from historic data or subjective sources). The ambiguity of calling this initial distribution $$p(w)$$ as 'beliefs' is also why some Bayesians like to refer to this as prior information, but this is simply a quarrel over the semantics. Moreover, it is difficult to interpret the meaning of the parameters of the neural network and very often in practice, the prior is determined based on ease on computation (such as choosing Gaussians, or any distribution belonging to the exponential family since they have a beautiful property of having a conjugate pair). 

The next step is determining the likelihood function which is the probabilistic model by which the inputs $$X$$  map to the outputs $$Y$$, given some parameters $$w$$. In the case of a classification task in a neural network, the likelihood function would be softmax (and sigmoid in a binary classification) while it could be Euclidean loss in a regression setting.

One we have determined the prior distribution and the likelihood function, we can make magic happen by applying the Bayes rule. In all its simplicty, Bayes rules defines the posterior distribution to be the product of the prior and the likelihood. It is also normalised by the probability of the data. This transformation of the prior into posterior knowledge is what is known as Bayesian inference.

$$p(w | D) = \frac{p(D | w)p(w)} {p(D)}$$

The distribution above is the result of changing our initial beliefs about the weights from the prior $$p(w)$$ to the posterior $$p(w | D)$$ after seeing the data D. Since $$p(D)$$ is often intractable, Bayesian inference has some handy techniques such as Monte Carlo sampling techniques and variational inference. A recent development in approximation techniques is when Gal et al. shows that dropout in neural networks can be used for an approximation of the posterior. But these are topics for another day. The posterior distribution can now be applied to predict for new samples. The resulting distribution called the predictive posterior distribution is denoted as:

$$p(y^*,x^* | X,Y) = \int p(Y|X,w)p(w |X, Y)dw$$

To infer the prediction for the new data point $$x^*$$, we consider all the possible values of the parameters which maximise the posterior distribution, weighted by their probability. This provides a distribution as the prediction for each new data point.

To continue on our journey of uncertainty in recommender systems, let's just say we can use the predictive posterior distribution for this marvelous task of inferring uncertainty. It is as simple as the variance of the predictive posterior distribution.


## What does uncertainity tell us ?

The uncertainty in prediction can arise from two primary sources. There is randomness present in the data itself such as measurement errors involved in the data collection process. The real-world can also be considered as random to a certain extent and hence any data captured from real-life processes would have some randomness. This randomness reveals that we are uncertain about the prediction of the event rather than the event itself being uncertain. I say this, because with more information, we would make better predictions resulting in a lesser degree of randomness. But given our constraints in accurately capturing intrinsic preferences of customers, we will have to deal with the randomness introduced from our dataset. 

The second source of randomness arises from our model itself. The model is nothing but a set of rules to map the input data to the target prediction. And Machine Learning in particular relies on finding seemingly complex algorithms which learn curve fitting without too much human interference. Even when a human makes a probabilistic prediction, he/she is correct only to a certain degree, which is why we always regard a meteorologist's prediction with a grain of salt. Similarly, the variance of the predictive posterior distribution also quantifies the model uncertainty arising from variability in the model parameters. 

In an ideal world, we would have infinte data to eliminate this data (or aleatoric) uncertainty and the perfect model to eliminate model (or epistemic) uncertainty and machine learning engineers would be happy! But in the far from ideal world that we live in, the uncertainty measure gives us hints on how to improve our prediction. The aleatoric uncertainty can be reduced by improving our data quality and increasing data used for training the model, while epistemic uncertainty is an indication that the model needs to be refined further.

## Learning to recommend

In a typical recommendation system, a user is matched with an item that the algorithm determines to be most attractive for the user. In our setting, given a request for a flight/ hotel/ train/ rental car, we receive all possible search results and we want to filter the best 3 options for the customer.

If we employ a recommendation style, the underlying algorithm uses a ratings matrix composed of User Embeddings and Item Embeddings referred to as the latent features. The primary difficulty here is embedding an entire search result and making it as informative as possible. Moreover, you can travel with one search option only once and hence we are more interested in encoding the characteristics of the search result such as travel duration, flight carrier, type of train,etc. Then the rating matrix would contain information on how often the user traveled with a similar option. A Neural network approach here would embed the users and the features of the travel options independently and then concatenate the two layers to obtain the embedding matrix. This embedding would introduce the personalisation element in the predictions as it identifies certain features with a ID. So the predictions for this ID in the future will heavily rely on the historic data of this ID and similar IDs.

Once the features of the neural network are determined, packages like pyMC3 and edward allow probabilistic inference of the posterior. Another trick for inference is to repreatedly perform the neural network training with different dropout values and record the prediction value. This distribution has been shown to be an approximation of the posterior distribution. This method is very attractive as uncertainty can be derived from existing neural network frameworks without much modification. 

One of the ways this recommendation model can be designed is a classification problem where for each option, we determine if the user would book it. This is how we can determine the preference a particular user has for that option. So this can be modeled as a binary classification by choosing a binomial distribution as the likelihood. 

## How does this uncertainty look?

The dropout as an approximate Bayesian inference for example yields a Gaussian distribution (since the priors are multivariate Gaussians) and this makes it easy to interpret. The shape of the posterior from other methods such as sampling and variational inference depends on how we designed the priors for the model. Let's assume for the sake of simplicity, that we have a normal distribution. 

![](/images/2019_10_01/normal_distribution.png)

The prediction for data point $$x_1$$ denoted by the blue Gaussian has a higher mean probability of being selected by the customer. However, this prediction also has a large spread compared to the prediction of data point $$x_2$$ denoted by the orange bell curve. Then we can tell that on average this offer made to the customer is likely to be booked but not as much as the second offer which has a smaller variance and hence lesser uncertainty in the prediction.


## How can we use this uncertainty while recommending?

In this recommendation problem, we want to rank the predictions which are attractive to the customer, in other words, rank the search results based on which the model classifies as '1' most confidently. The softmax probability from the neural network denotes the strength of belonging to a class. Apart from this, we want another measure by which we can quantify how good the prediction is, or determine how confident the model is about the prediction. The uncertainty(variance of the posterior) can be used for this. One thing to keep in mind, is that this variance is underestimated when variational inference is employed as opposed to sampling based techniques. Hence this variance is more of a guideline rather than a hard realiable estimate of the actual undertainty. We could however, use the uncertainty including ranking measure by choosing the 20th percentile (or the lower quartile). The best percentile which can be used as a ranking measure can be determine by plotting it in a clibration plot. The measure which is closest to the diagonal is as close as we get to the "ground truth" probability. The idea behind choosing a lower percentile probability for ranking is that, the 20% percentile for example indicates that the predictions made by the model will be lower than this chosen value only 20% of the time. In other words, 80% of the time, we can be sure that the option is attractive to the user. This can be seen the two Gausssian distributions of the predictive posteriors in the figure above. When compaing the predicitve mean, the $$x_1$$ is chosen as a better option but the 20th percentile values would choose $$x_2$$ over $$x_1$$.

Another typical use of uncertainty in recommender systems is to tackle the exploration versus exploitation problem. There is a constant challenge in presenting a user with something they have shown preference towards while finding new options that are equally attractive. For example, maybe you always stay in the same 4-star hotel in Berlin Mitte when you visit the city and you rate it 8/10. But let's say there's a new hotel with similar chaarcteristics  but the recommender system is not sure what your preference towards this hotel can be - it ranges between 1 and 10. USing this confidence interval, if you wish to explore, you would choose to stay in the new hotel since it could 'the' one and you give it a 10. One advanced mthod from the family of algorithms dealing with multi armed bandit problems used in such an instance is Upper Confidence Bound (UCB). The confidence bound indicates our uncertainty of the user's perference towards and option and this technique uses the variance of the posterior for estimation.


We have now seen a couple of ideas of how useful uncertainty is, especially in the context of recommender systems. This is an exciting field where constant advantages are pushing forward the use of more Bayesian methods in large scale machine learning projects. We hope that these ideas would help help you as well if you are treading the gray areas of data and some uncertainity on available approaches to use while dealing with uncertainty.






