---
layout: article
title: Pareto Selection for Search Ranking
date: 2021-07-14 12:00:00
published: true
categories: [search, ranking, algorithm, pareto, selection]
comments: false
share: true
description: Pareto optimization for ranking of search results
usemathjax: true
author: sandip_mukherjee
image:
  teaser: 2019_06_19/teaser.jpg
  feature: 2019_06_19/feature.jpg

---

At Comtravo, amongst others, we process incoming requests with travel itineraries. One way or the another, such requests are converted to a structured format and an automation module receives that request to spark automatic generation of offers. Such automatic offers are later reviewed by agents or - if they pass our QA scoring - directly send to customers.

This is an example of such a request and its structured representation

```text
Please book me a single room in Berlin at the Marriot Hotel from June 8th to June 10th 2021.
```

```json
{
    "item_type": "hotelRequest",
    "check_in": "2021-06-08",
    "check_out": "2021-06-10",
    "number_of_rooms": 1,
    "location": {
        "city": "Berlin",
        "country": "DE",
        "street_1": " ",
        "label": "Marriot Hotel",
        "longitude": 10.0379881,
        "latitude": 48.4061125
    },
    "room_type": "single",
    "poi": true
}
```

Based on such structured representation of a customer request, the automation module searches for supply, e.g. flights, trains, or hotels, in accordance with the request using third party APIs. Depending on the vertical and the request, anything between zero and a few thousands of search results can be returned from the supply side(s).

To generate an offer, the automation must now rank those search results and find the best possible options. The best matching options are then send to the customer:

<center>
<figure>
  <img style="width: 70%; height: 70%" src="/images/2021_07_15/automation_flow.png">
  <figcaption><b>Automation Flow</b> </figcaption>
</figure>
</center>

## Ranking of Search Results

The reminder of this article is about how we rank these search results. Ranking in this situation is a multi objective problem along with some constraints.

* *Objectives & Preferences*: We have multiple objectives. For example, we need to provide flight options which are cheap and fast at the same time. In this article we are optimising the price and duration of a flight. We call these **objectives** or - because that is what it usually looks like from a human perspective - **preferences**.
* *Constraints*: On the other hand, there are constraints. **Constraints** are hard, non-negotiable limits on the resource. In our context, constraints can be e.g. that a flight must be cancelable, or that a specific hotel is being requested. These constraints are mostly coming from the user request.

Without going into detail, lets assume that all objectives are something that we want to minimize (in practice there are clearly objectives we want to maximise - e.g. convenience - but they can all be reformulated to a minimization problem - e.g. inconvenience). Then what we need to achieve is to find options from the search results, that minimize our various objectives as well as possible, whilst fulfilling the constraints. It is important to notice that all objectives are independent, or at least that there is no easy way to combine them into a single objective. This is mainly because there is just no obvious way how to weight e.g. price vs. duration for a flight.

So we need a method to find good solutions to this kind of multi objective problems. And one of them is **Pareto Optimality**, named after the economist [Vilfredo Pareto](https://en.wikipedia.org/wiki/Vilfredo_Pareto).

## Pareto Optimization

The idea of Pareto optimization is to find solutions that help some objectives without hurting others. Let’s look at two examples to understand how it works.

### Example 1 - Multiple Pareto Optimal Points

Assuming a user requested a train from Berlin to Munich. We want to minimize time and duration here. For simplicity we are not considering any constraints.

We found 3 connections for this trip.

|Name | Price | Duration|
|--------|-------|---------|
| `Train 1` | 80 euros  | 1 hour|
| `Train 2`| 20 euros | 4 hours|
| `Train 3`| 100 euros | 10 hours|

Putting the options on a graph with axis *price* and *duration* we get:

<center>
<figure>
  <img style="width: 50%; height: 50%" src="/images/2021_07_15/graph_pareto_multiple_optimal.png">
  <figcaption><b>Multiple Pareto optimal solutions in criterion space</b> </figcaption>
</figure>
</center>

We see that `Train 1` in this criterion space has the lowest value of travel duration and `Train 2` has the lowest price. The edge between them is called Pareto front. This Pareto front has some interesting properties:

* Any point in the Pareto front is considered *Pareto Optimal*. By moving along the edge we can minimize price at expense of duration, or minimize duration at expense of price, but we cannot minimize both.
* In this case, both `Train 1` and `Train 2` will be Pareto optimal points. Hence they will rank higher than `Train 3`. Ranking between `Train 1` and `Train 2` - without any further conditions like in this example - is arbitrary.
* `Train 3` is called *Pareto Inefficient* as there exists at least one more point which is better than `Train 3` in all objectives.
* In our algorithm, we put Pareto optimal points first and then append Pareto inefficient points to the ranking. We do not exclude Pareto inefficient points - if there are very few (or no) Pareto optimal points we might still offer them.

### Example 2 - One Pareto Optimal Result

In this example we will minimize one objective **Price** and try to satisfy one constraint **FlexibleTicketConstraint**.
Constraints are binary criteria which are either met or not met. Constraints and objectives together create Pareto frontiers and Pareto optimal points.

|Name | Price | Flexible Ticket|
|--------|-------|---------|
| `Train 1`| 80 euros  | No|
| `Train 2`| 20 euros | Yes|
|`Train 3`| 100 euros | No|

Again, as a graph this looks like:

<center>
<figure>
  <img style="width: 50%; height: 50%" src="/images/2021_07_15/graph_pareto_one_optimal.png">
  <figcaption><b>One Pareto optimal solution in criterion space</b> </figcaption>
</figure>
</center>

In this case, there is one Pareto optimal point which is `Train 2` and all others are Pareto ineffienct. Hence `Train 2` will be ranked highest.

## Our Algorithm

The above two examples are simple examples where we have either two objectives or one objective with one constraint. In reality, we have more objectives and many constraints depending on the request. Let’s take the below train request as an example.

|Origin | Destination | Ticket type | Departure time | Stop overs |
|--------|-------|---------|--------|-------|
|Berlin| Munich  | Flexible| 07:00-09:00 | No

For above request we would minimise two objectives: **price and duration**

But now we will have three constraints:

| Constraint | Name |
|--------|-------|
| Ticket should be flexible | `FlexibleCostraint` |
| Departure between 7am and 9am | `DepartureTimeConstraint`|
| Direct connection | `NoStopOverCostraint`|

One train connection is better than another when it beats the other in, both objectives and constraints.
In the below table, `Train 1` is better than `Train 2` as it beats `Train 2` in two constraints while not stying below in the objectives (and the other constraint):

|Name | Price | Duration|Flexible|Time|Stops
|--------|-------|---------|---------|---------|---------|
| `Train 1`| 20 euros  | 1 hour|yes|08:00| 0
| `Train 2`| 20 euros | 1 hour|No|09:00| 1

In practice, for more search results, constraints and objective, the algorithm will iterate over all the results returned by the search.

For every search result:

* It compares the item with every other items in the result list
* If there is at least one other item which is better than the current item, it is marked as Pareto inefficient
* Otherwise the current item is marked as Pareto optimal

In the end each item will either be marked Pareto optimal or Pareto inefficient. The algorithm will rank the Pareto optimal points higher than others.

## Conclusion

Pareto selection works very well for this use case, especially when the request has many constraints since the algorithm is designed to handle multi-objective and multi constraints optimization problem.

Of course in practice we still need a way to rank amongst the Pareto optimal and Pareto inefficent points.
This we achieve by specifying a precedence between objectives and sorting among the Pareto optimal points accordingly. How we do this in detail is, however, material for another article.

Our special thanks to Gabriele Lanaro for contribution in ideation and implementation of the Pareto selection for ranking.
