---
layout: article
title: Pareto Selection for search ranking
date: 2021-07-15 12:00:00
published: true
categories: [search-ranking, ranking-algorithm, pareto-selection]
comments: false
share: true
description: Pareto optimization for ranking of search results
usemathjax: true
author: sandip_mukherjee
image:
  teaser: 2019_06_19/teaser.jpg
  feature: 2019_06_19/feature.jpg

---

In comtravo, We have email requests coming from the user for a travel itinerary. The NLP engine converts that email to a structured request and our automation module receives the request for further offer generation. An example of a structured hotel request is below.

**Please book me a room in Berlin Marriot hotel from 8 June to 10 June 2021**
<center>
<figure>
  <img style="width: 30%; height: 30%" src="/images/2021_07_15/structured_request.png">
  <figcaption><b>Structured request</b> </figcaption>
</figure>
</center>

Our automation module then searches for flight/train/hotel in accordance with the request using third party apis and gathers search results. It can be 50-1000 search results based on how many searches the system did.
Then it ranks those search results to find the best possible results so that it can send top n results to the customer.

<center>
<figure>
  <img style="width: 70%; height: 70%" src="/images/2021_07_15/automation_flow.png">
  <figcaption><b>Automation flow</b> </figcaption>
</figure>
</center>

## Ranking of search Results

This ranking is a multi objective problem along with some constraints.

### Objectives/preferences
We have multiple objectives here. For example, we want to provide flight options which are cheap and fast at the same time. Here we are optimising the price and duration of flight. We call these objectives/preferences.
### Constraints
The constraints are hard, non-negotiable limits on the resource. In our context, constraints can be a cancelable flight, a flexible train ticket, a specific hotel (not just a city) or a specific room type in a hotel (e.g twin bed). These constraints are coming from user requests.

We want to minimize our objectives/preferences fulfilling the constraints.

One way to find good solutions to this kind of multiobjective problems is with **Pareto optimality**, named after economist Vilfredo Pareto.

## Pareto optimization
The idea is to find solutions that help some objectives without hurting others.
Let’s look at two examples to understand how it works.
 
### Example 1 - Multiple pareto optimal points

Let’s say a user requested a train from Berlin to Munich. We want to minimize time and duration here. For simplicity we are not considering any constraints here.

We found 3 connections for this trip.

|Name | Price | Duration|
|--------|-------|---------|
| Train_1| 80 euros  | 1 hour|
| Train_2| 20 euros | 4 hours|
|Train_3| 100 euros | 10 hours|

<center>
<figure>
  <img style="width: 50%; height: 50%" src="/images/2021_07_15/graph_pareto_multiple_optimal.png">
  <figcaption><b>Multiple pareto optimal in criterion space</b> </figcaption>
</figure>
</center>

Note that Train_1 in this criterion space has the lowest value of Travel Duration and Train_2 has the lowest price. The edge between them is the pareto front.

-   Any point in the pareto front is considered “Pareto Optimal”. By moving along the curve you could minimize price at expense of Duration, or minimize Duration at expense of price, but you cannot minimize both.
    
-   In this case, both Train_1 and Train_2 will be pareto optimal points hence they will be ranked higher than Train_3. Ranking between Train_1 and Train_2 is arbitrary.
    
-   Train_3 is called pareto_inefficient as there exists at least one more point which is better than Train_3 in all objectives.
    
-   In our algorithm, we put pareto optimal points first and then pareto inefficient points. We put pareto inefficient points in the bottom to provide more options to users in case there are very few pareto optimal points available.

### Example 2 - One Pareto optimal
This time we found 4 connections for this trip.

|Name | Price | Duration|
|--------|-------|---------|
| Train_1| 80 euros  | 1 hour|
| Train_2| 20 euros | 4 hours|
|Train_3| 100 euros | 10 hours|
|Train_4| 10 euros | 0.5 hours|

<center>
<figure>
  <img style="width: 50%; height: 50%" src="/images/2021_07_15/graph_pareto_one_optimal.png">
  <figcaption><b>One pareto optimal in criterion space</b> </figcaption>
</figure>
</center>

In this case, there is one pareto optimal point which is Train_4 and all others are pareto_ineffienct hence Train_4 will be ranked highest. Clearly, there are no other points which can beat Train_4 in Price or Duration.

## Our algorithm
The above two examples are simple examples where we are trying to minimize two objectives without any constraints.

In reality, we have more objectives and many constraints depending on the request.

Let’s take the below train equest for example.


|Origin | Destination | Ticket type | Departure time |Stop overs 
--------|-------|---------|--------|-------|
|Berlin| Munich  | Flexible| 07:00-09:00 | No

For above request we would minimise two objectives
**Price and Duration**

And We will have three constraints
**FlexibleCostraint, DepartureTimeConstraint, NoStopOverCostraint**

One train connection is better than another when it beats the other in objectives and constraints both.
In the below table, Train_1 is better than Train_2 as it beats Train_2 in two constraints while not loosing in objectives and other constraints.

|Name | Price | Duration|Flexible|Time|Stops
|--------|-------|---------|---------|---------|---------|
| Train_1| 20 euros  | 1 hour|yes|08:00|0
| Train_2| 20 euros | 1 hour|No|09:00|1

The algorithm will iterate over all the train connections returned by the search.

For every item in the search responses list
 - It will compare the item with every other items in the list.
 - If there is at least one other item which is better than the current item, remove the current item from the list and move it to the pareto_inefficient points.
 - Otherwise copy it to pareto_optimal points.

Continue above steps these until the list is empty.

In the end there will be a list of pareto_optimal points and a list of pareto_inefficients points. The algorithm will rank the pareto_optimal points higher than others.

##  Conclusion ##

Pareto selection works well for us especially when the request has many constraints since the algorithm is designed to handle multi-objective and multi constraints optimization problem.
It can even be further improved by specifying which objective has higher precedence to sort among the pareto optimal points especially when there are multiple optimal points. That's work for the future.
