---
layout: article
title: Billing Engine on AWS Serverless
date: 2019-08-16 12:00:00
published: true
categories: [aws,serverless]
comments: false
share: true
description: Billing Engine on AWS Serverless
usemathjax: true
author: OhDavit
image:
  teaser: 2019_06_19/teaser.jpg
  feature: 2019_06_19/feature.jpg

---

At Comtravo we utilize AWS serverless infrustructure for many our business cases. Particularly Lambda functions and Step functions enable us to design and implement solutions for various complex business workflows in the same time allow us to extend those solutions in the future.
One vivid example is our Billing Engine.

# What is `Billing Engine`?

At Comtravo for each booking we charge our customers and for those charges we need to provide invocies and financial reports. Clients can choose their payment method and billing aggregation option. For example, `Collective Invoice` payment method indicates that customer wants to collect multiple charges into one invoice. And billing aggregation indicates intervals(TODO) of charges to collect. For example, `monthly` and `semi-monthly` indicate that customer wants to collect all charges with us and issue invoice once per month or twice per month correspondingly.
The solution which organizes these workflows we call `Billing Engine`. I want to hightlight that `Billing Engine` is much more than invoice issuer, it also generates report and sends to customer.

# Solution

 The `Billing Engine` itself runs purely on `Serverless` by utilizing AWS `Cloudwatch` to schedule events, `Lambda functions`, `Step functions` and `SQS`.


# Some References

- [Throttling pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/throttling)
- [Queue-Based Load Leveling](https://docs.microsoft.com/en-us/azure/architecture/patterns/queue-based-load-leveling)