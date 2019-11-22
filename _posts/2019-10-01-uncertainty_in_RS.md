---
layout: article
title: Uncertainty in Recommender Systems
date: 2019-11-25 11:25:00  # if the publication date is in the future the article will be published on that future date
categories: [Uncertainty, Bayesian statistics, Neural networks]
comments: true
share: true
published: true
image:
  teaser: 2019_10_01/teaser.png
  feature: 2019_10_01/feature.png
description: Bayesian neural networks to estimate uncertainty in recommendation
usemathjax: true  # if you need math symbols turn this one
author: bharathi_srini
---

Bayesian neural networks are gaining popularity in the industry. In this post, we break them down and talk about how they can be useful as a recommender system.

## A Recommendation for Recommender Systems

To establish the need for a recommender system, consider a typical travel request that we receive from a customer. 

> Dear Comtravo,

> I need to travel tomorrow from Berlin to Munich and also require a return trip on the following day.

> Kind regards,\\
> A very busy business traveler"

When we search for round trip travel options for BER - MUC, we get numerous different options. We could hypothesize that a two-day trip could mean a short business visit. To maximize the time spent in Munich, we would suggest onward flights to Munich in the morning and return flights to Berlin in the evening. If we knew that this customer also frequently traveled with Lufthansa, we could prioritize Lufthansa flights. In this way, the historical data of the traveler's past bookings can be extremely useful in finding the best possible travel options for the customer. 

A typical user makes a choice based on various factors. Price, convenience, preference for an airline, etc. play a role in how a customer chooses an option. Moreover, while one customer might be price sensitive and choose travel options flexibly, another customer might always prefer a specific carrier or a specific time of day. To learn the interplay between these attributes and to personalize the results to the users, we consider a deep neural network as our recommendation algorithm. The algorithm will likely find many options that it believes are good. Additionally the algorithm needs to use some criteria in ranking the positive predictions. From a Bayesian point of view, model uncertainty is an important criteria. We have to take into account how certain the model is about the prediction itself before we can be sure that it is a good prediction. First let's look at how and why uncertainty enters the picture.


## Where Does this Uncertainty Come from?

The uncertainty in predictions of a recommender system can arise from two primary sources. There is randomness present in the data itself, such as measurement errors involved in the data collection process. Moreover, the intrinsic preferences of customers are not always captured well by the data we are able to collect. Randomness or the inability to find a perfect pattern arises because of incomplete data. Let's say I prefer taking trains for traveling within Germany except if there is no ICE connection. If the model has seen a limited number of my past bookings and seen a mix of both flight and train bookings, it would be difficult to 'mine' this pattern. The choice of carrier may seem random at this point. One thing to keep in mind is that this randomness reveals that we are uncertain about the prediction of the event rather than the event itself being uncertain. I say this because with more information we would make better predictions resulting in a lower degree of uncertainty.

The second source of randomness arises from the model itself. The model learns a function to map the input data to the target prediction. The parameters of the function carry some amount error in the process of generalizing to the training data. Even when a human makes a probabilistic prediction, he/she is correct only to a certain degree, which is why we always regard a meteorologist's prediction with a grain of salt. Similarly, we need a measure which will hint at how much we can trust the model's prediction. 

In an ideal world, we would have infinite data to eliminate this data (or aleatoric) uncertainty and the perfect model to eliminate model (or epistemic) uncertainty(http://papers.nips.cc/paper/7141-what-uncertainties-do-we-need). This would, indeed, make for some very happy machine learning engineers! But in the far from ideal world that we live in, the uncertainty measure gives us hints on how to improve our prediction. If the aleatoric uncertainty is high, we need to work on improving our data quality and on increasing the data used for training the model. On the other hand, high epistemic uncertainty is an indication that the model needs to be refined further.


## How Can We Estimate Uncertainty of the Model?

Learning the uncertainty is an unsupervised technique, and techniques of Bayesian statistics are commonly employed to estimate this quantity. 
While Bayesian methods are a vast topic by itself, it will not be covered in detail here, but a brief overview is presented in the section below if the reader is not yet acquainted with Bayesian neural networks.

## A Quick Look at the Bayesian Neural Network

The Bayesian neural network is different from the 'frequentist' counterpart because it has probability distributions over the  weights and biases of the network. 

In the traditional neural network, each neuron of the neural network multiplies the data $$X$$ with a weight matrix $$W$$ and some bias $$b$$ is added to it. To add non-linearity, we apply an activation function to this algebraic resultant. Typically, these weights and biases are determined using back propagation, which results in point estimates as the solution.

<center>
<figure>
  <img style="width: 45%; height: 40%" src="/images/2019_10_01/bnn.png">
  <figcaption><b>Inner working of a Bayesian neural network
  (https://github.com/ericmjl/bayesian-deep-learning-demystified)</b> </figcaption>
</figure>
</center>


Bayesian methods replace these weights and biases with distributions, as seen in the figure above. We start with some initial distributions over the weights and biases. Let's call this distribution $$p(w)$$. This is useful for encoding our prior 'beliefs' about the underlying model which generated our data (either from historical data or subjective sources). The ambiguity of calling this initial distribution $$p(w)$$ 'beliefs' is also why some Bayesians like to refer to this as prior information, but this is simply a quarrel over the semantics. Moreover, it is difficult to interpret the meaning of the parameters of the neural network, and very often in practice, the prior is determined based on ease of computation (such as choosing a Gaussian or any distribution belonging to the exponential family since they have a beautiful property of having a conjugate pair. Choosing a prior which has a conjugate pair means that we already know which family of distributions the posterior belongs to and this aids in finding a stable optimum faster while using variational inference (https://arxiv.org/pdf/1711.05597.pdf)). 

The next step is determining the likelihood function, which is the probabilistic model by which the inputs $$X$$  map to the outputs $$Y$$, given some parameters $$w$$. In the case of a classification task in a neural network, the likelihood function would be softmax (and sigmoid in a binary classification,) while it could be Euclidean loss in a regression setting.

Once we have determined the prior distribution and the likelihood function, we can make magic happen by applying the Bayes rule. In all its simplicity, Bayes rule defines the posterior distribution to be the product of the prior and the likelihood. It is also normalized by the probability of the data. This transformation of the prior to posterior knowledge is what is known as Bayesian inference.

\begin{equation}
p(w | D) = \frac{p(D | w)p(w)} {p(D)}
\end{equation}

The distribution above is the result of changing our initial beliefs about the weights from the prior $$p(w)$$ to the posterior after seeing the data D. Since $$p(D)$$ is often intractable, Bayesian inference has some handy techniques such as Monte Carlo sampling techniques and variational inference. But these are topics for another day. The posterior distribution can now be applied to predict new samples. The resulting distribution called the predictive posterior distribution is denoted as:

\begin{equation}
p(y^{new}, x^{new}| X,Y) = \int {p(Y | X,w) p(w | X, Y) dw}
\end{equation}

To infer the prediction for the new data point $$x^{new}$$, we consider all the possible values of the parameters which maximize the posterior distribution, weighted by their probability. This provides a distribution as the prediction for each new data point.

We can use this predictive posterior distribution for the marvelous task of inferring uncertainty. It is as simple as the variance of the predictive posterior distribution. Variance gives the spread of the data and indicates how much the values deviate from the mean. If the distribution of predicted values is narrow and has a small variance, it has less model uncertainty as the predictions are consistently close to the true value. 


## Learning to Recommend

In the recommendation problem, we want to match a a user with an item that is most attractive for the user. In our setting, given a request for a flight/ hotel/ train/ rental car, we receive all possible search results, and we want to filter the best 3 options for the customer.

The most popular recommendation algorithm is matrix factorization which uses a ratings matrix composed of encodings for users and items with values indicating how attractive the item was for the user. The attractiveness can be quantified in terms of number of times that item was selected. The primary difficulty here is embedding an entire search result and making it as informative as possible. Moreover, you can travel with one search option only once, and hence we are more interested in encoding the characteristics of the search result such as travel duration, flight carrier, type of train, etc. Then the rating matrix would contain information on how often the user traveled with a particular option. A neural network approach here would embed the users and the features of the travel options independently and then concatenate the two layers to obtain the embedding matrix. This embedding would introduce the personalization element in the predictions as it identifies certain features with an ID. So the predictions for this ID in the future will heavily rely on the historical data of this ID and similar IDs.

Once the features of the neural network are determined, packages like [pyMC3](https://docs.pymc.io/), [Pyro](http://docs.pyro.ai/en/stable/) or [edward](http://edwardlib.org/) allow probabilistic inference of the posterior. Another trick for inference is to repeatedly perform the neural network training with different dropout values and record the prediction value. This distribution has been shown to be an approximation of the posterior distribution. ([Gal et al.](http://proceedings.mlr.press/v48/gal16.pdf)) This method is very attractive as uncertainty can be derived from existing neural network frameworks without much modification of the model itself.

One of the ways this recommendation model can be designed is a classification problem, where for each option, we predict if the user would book it as a high chance of booking implies that the options is attractive for the user. Hence we can model it as a binary classification by choosing a binomial distribution as the likelihood. 

Once we have the predictive posterior distributions from the model, we can analyze model uncertainty as follows in the next section.

## How Does this Uncertainty Look?

The dropout as an approximate Bayesian inference, for example, yields a Gaussian distribution (since the priors are multivariate Gaussians). This makes iterpretability of the posterior easier. The shape of the posterior from other methods such as sampling and variational inference depends on how we have designed the priors for the model. Let's work with a normal distribution here. 


<center>
<figure>
  <img style="width: 35%; height: 40%" src="/images/2019_10_01/normal_distribution.png">
  <figcaption><b>Predictive probability density for two data points</b> </figcaption>
</figure>
</center>

The prediction for data point $$x_1$$, denoted by the blue Gaussian, has a higher mean probability of being selected by the customer. However, this prediction also has a large variance compared to the prediction of data point $$x_2$$, denoted by the orange bell curve. Then we can say that on average, this offer made to the customer is likely to be booked but not as much as the second offer, which has a smaller variance, and hence lesser uncertainty in the prediction. ( The distributions have been plotted using the mean and variance of the predictions and hence we see the curve extending beyond the probability value of 1)


## How Can We Use this Uncertainty While Recommending?

In this recommendation problem, we want to rank the predictions which are attractive to the customer, in other words, rank the search results based on how how confidently the model believes that the option would be booked. While we would use the variance to rank the predictions to find the most confident predictions, this variance is underestimated when variational inference is employed as opposed to sampling-based techniques. And since variational inference is more optimal for large datasets,variance should be used more of a guideline rather than a hard reliable estimate of the actual uncertainty. We could, however, use another measure which includes the uncertainty value by choosing the 20th percentile (or the lower quartile). The idea behind choosing a lower percentile probability for ranking is that the 20% percentile, for example, indicates that the predictions made by the model will be lower than this chosen value only 20% of the time. In other words, 80% of the time, we can be sure that the option is attractive to the user. This is noticeable from the two predictive posterior distributions in the figure above. The best percentile, which can be used as a ranking measure, can be determined by plotting it in a calibration plot. The measure which is closest to the diagonal is as close as we get to the "ground truth" probability.  When comparing the predictive mean, the $$x_1$$ is chosen as a better option, but the 20th percentile values would choose $$x_2$$ over $$x_1$$.

Another typical use of uncertainty in recommender systems is to tackle the exploration versus exploitation problem. There is a constant challenge in presenting a user with something they have shown a preference towards while finding new options that are equally attractive. For example, maybe you always stay in the same 4-star hotel in Berlin Mitte when you visit the city, and you rate it 8/10. But let's say there's a new hotel with similar characteristics and the recommender system is not sure what your preference towards this hotel can be - it ranges between 1 and 10. Using this confidence interval, if you wish to explore, you would choose to stay in the new hotel since it could be better than your expectations, so you might rate it a 10. One advanced method from the family of algorithms dealing with such a multi-armed bandit problem is Upper Confidence Bound (UCB). The confidence bound indicates our uncertainty of the user's preference towards the new option, and this technique uses the variance of the posterior for estimation.


We have now seen a couple of ideas of how useful uncertainty is, especially in the context of recommender systems. This is an exciting field where constant advances are pushing forward the use of more Bayesian methods in large scale machine learning projects. We hope that these ideas would help you as well if you are treading the gray areas of data and dealing with uncertainty.






