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

At Comtravo for each booking we charge our customers and for those charges we need to provide invoices and financial reports. Clients can choose their payment method and billing aggregation option. For example, `Collective Invoice` payment method indicates that customer wants to collect multiple charges into one invoice. And billing aggregation indicates intervals(TODO) of charges to collect. For example, `monthly` and `semi-monthly` indicate that customer wants to collect all charges with us and issue invoice once per month or twice per month correspondingly.
The solution which organizes these workflows we call `Billing Engine`. I want to hightlight that `Billing Engine` is much more than invoice issuer, it also generates report and sends to customer.

# Solution

 The `Billing Engine` itself runs purely on `Serverless` by utilizing AWS infrustructure and consuming our internal APIs. It get's triggered by AWS cloudwatch, which provides for each business case specific input.  
 
 ![Cloudwatch triggers Lambda function](/images/2019_08_16/cloudwatch_triggers_lambda.png)

 You can easily configure clowdwatch event with `Terraform` as following:

 ``` 
 resource "aws_cloudwatch_event_target" "ci_monthly" {
  rule = "${aws_cloudwatch_event_rule.ci_monthly.name}"
  arn  = "${module.lambda-finance-report-preprocessor.lambda_arn}"

  input = <<INPUT
{
    "billing_aggregation": "monthly",
    "period_of_execution":  "beginning-of-the-month"
}
INPUT
}
 ```

The first Lambda function which get's triggered we call pre-processor. Based on input from cloudwatch event the pre-processor(feeder) Lambda function loads the bookings happened during specified period of time from our (micro)service and figures out which companies are affected. Each event is processed by `Step function` which consists of multiple lambda functions. It is responsible for generating invoices and reports, and sending those reports to our customers via `SES`. 

Usually platform providers Control the consumption of resources used by an instance of an application, an individual tenant, or an entire service. This can allow the system to continue to function and meet service level agreements, even when an increase in demand places an extreme load on resources.

In order to meet `SLA` and allow the system to function in case of extreme load on resources cloud providers are adopting `Throttling pattern` to control the consumption of resources used by an instance of an application, an individual tenant, or an entire service. 
So in our case if we start processing events for all companies at once, i.e. stating as many step functions as we have events, we would get rate limit exception: ThrottlingException.(TODO: Elaborate more https://aws.amazon.com/blogs/messaging-and-targeting/how-to-handle-a-throttling-maximum-sending-rate-exceeded-error/). You can increase limits by communicating with AWS but this is not really scalable solution, as probably you will not know in advance how much parallel events you will have.

In order to avoid this issue we implemented pattern called `Queue-Based Load Leveling`.
 
![Queue and Lambda function control the rate](/images/2019_08_16/queue-based-load-leveling-pattern.png)


So instead of directly triggering AWS Step function, Pre-processor Lambda feeds `SQS`. On the other side of the queue Lambda function is responsible for triggering `Step Function` by controling it's number of parallel executions. It checks whether there is a capacity for new `Step functions` to run, and if so fetchs events with pre-defined limits from the queue and triggers `Step functions`. 

This approach doesn't solve all kind of problems, as still you have to think about individual `Lambda function's` behaviour in case of it's failure, but it's makes engine scalable and allows us to decouple events from `Step Functions`.
