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
author: davit_ohanyan
image:
  teaser: 2019_08_16/teaser.jpg
  feature: 2019_08_16/feature.jpg

---

At Comtravo we utilize AWS serverless infrustructure for many of our business cases. Lambda functions and Step functions, in particular, enable us to design and implement solutions for various complex business workflows. They also allow us to flexibly extend those solutions in the future. One example is our Billing Engine.

In this post I'll discuss how we enabled the billing engine to avoid service level throttling even at times of high load.

# What is `Billing Engine`?

At Comtravo we charge our customers per booking. For those charges we need to provide invoices and financial reports. Our customers can choose their payment method and billing aggregation option. For example, `Collective Invoice` payment method indicates that a customer wants to collect multiple charges into one invoice. Billing aggregations indicate intervals of charges to collect. For example, `monthly` and `semi-monthly` indicate that a customer wants to collect charges into a monthly invoice or bi-weekly invoice respectively. We call the solution that organizes these workflows the `Billing Engine`. I want to hightlight that the `Billing Engine` is much more than an invoice issuer, it also generates reports and handles sendingd those reports to our customers.

# Solution

The `Billing Engine` itself runs purely on [`Serverless` infrastucture on AWS](https://tech.comtravo.com/aws/cloud/serverless/project_a_marko/) and consumes our internal APIs. It is triggered by AWS cloudwatch, which provides sprecific input for each business case.

 ![Cloudwatch triggers Lambda function](/images/2019_08_16/cloudwatch_triggers_lambda.png)

We've configured clowdwatch events with `Terraform`. It's rather simple to do, for instance like the following:

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

The first Lambda function that is triggered is the Pre-processor. Based on cloudwatch input the Pre-processor loads bookings that happened during a specified period of time. The Pre-processor then figures out which companies are due reports. The number of booking events varies; in practice there can are often more than 20K events for each run of the lambda function. Each of these events is processed by a `Step function` that itself consists of multiple `Lambda functions`. Together they generate invoices and reports, and handle sending those to our customers via the `Simple Email Service`.

# The Challenge of Throttling

In order to maintain a high level of quality of service, cloud providers can throttle services during peak times. This allows the cloud provides to ensure their overall system is stable. The resource throttling can be limited to individual instances of an application or be more general and throttle entire services. This has a major impact on serive design. 

In our use case if we started processing events for all companies at once, for instance by starting as many `Step functions` as we have events, the lambda and step functions would get rate limited. There are several approaches to resolve this issue. For example the [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff) algorithm uses progressively longer waits between retries for consecutive rate limit responses. Exponential backoff, however, can perform quite poorly in practice when a lot of clients issue long running requests at the same time. The cloud provider can be become overloaded simply from having to reject a large number of requests. A better approach would be to implement client-side throttling, which allows the application developer to account for application specific behaviours. Google [recommends](https://landing.google.com/sre/sre-book/chapters/handling-overload/) client-side throttling to prevent overloading backend with just rejecting requests.

In order to solve the throttling issue we implemented `Queue-Based Load Leveling`.
![Queue and Lambda function control the rate](/images/2019_08_16/queue-based-load-leveling-pattern.png)


Instead of directly triggering an AWS Step function, the Pre-processor Lambda feeds a work queue based on [`SQS`](https://aws.amazon.com/sqs/). `SQS` provides nearly unlimited throughput and scales dynamically based on demand of the application. On the other side of the queue, a Gatekeeper `Lambda function` actively controls to number of parallel `Step Function`s. Here is a code snippet on how to check the number of running `Step functions` in TypeScript.

First we fetch the currently running `Step functions` and check whether there is enough capacity to trigger a new `Step functions`. If some available capacity exists, we fetch events with pre-defined limits from the work queue and run new `Step functions`. Below is a rough implementation in TypeScript.

```TypeScript

const stepFunctions = new AWS.StepFunctions();

const params = {
  maxResults: 100,
  stateMachineArn: this.stateMachineArn,
  statusFilter: 'RUNNING'
};

const data: AWS.StepFunctions.ListExecutionsOutput = await stepFunctions
  .listExecutions(params)
  .promise();

const numberOfExecutions: number = data.executions.length;

const numberOfStepFunctions = MAX_PARALLEL_STEP_FUNCTIONS - numberOfExecutions;
const tasksToBeExecuted = [];
for (let i = 0; i < numberOfStepFunctions; ++i) {
  tasksToBeExecuted.push(this.processMessage()); // processMessage method fetches message from queue and triggers Step Function
}

await Promise.all(tasksToBeExecuted);

```



# Summary

Decouplling events from the `Step function` that handles the event, makes our approach both scalable and extensible. If there is a new type of payment method or billing aggregation all we need to do is add a new `Cloudwatch trigger` and slightly adjusting Pre-processor `Lambda function`. The approach is also scalable and allows us to handle peak times easily. A sudden increase in the number of billing events does not cause a service disruption due to infrustructure limitations.
