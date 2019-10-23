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

At Comtravo we utilize AWS serverless infrustructure for many our business cases. Particularly Lambda functions and Step functions enable us to design and implement solutions for various complex business workflows in the same time allow us to extend those solutions in the future.
One vivid example is our Billing Engine.

# What is `Billing Engine`?

At Comtravo for each booking we charge our customers and for those charges we need to provide invoices and financial reports. Clients can choose their payment method and billing aggregation option. For example, `Collective Invoice` payment method indicates that customer wants to collect multiple charges into one invoice. And billing aggregation indicates intervals of charges to collect. For example, `monthly` and `semi-monthly` indicate that customer wants to collect all charges with us and issue invoice once per month or twice per month correspondingly.
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

The first Lambda function which get's triggered we call Pre-rocessor. Based on input from cloudwatch event the Pre-processor Lambda function loads the bookings happened during specified period of time from our (micro)service and figures out for which companies reports must be generated. Number of events are at variable rate and in practice there can be more than 10K events. Each of these events is processed by `Step function` which consists of multiple `Lambda functions`. It generats invoices and reports, and sends them to our customers via `Simple Email Service`.

In order to meet `service-level agreement` and allow the system to function in case of extreme load on resources cloud providers are adopting `Throttling pattern` to control the consumption of resources used by an instance of an application, an individual tenant, or an entire service.
So in our case if we start processing events for all companies at once, i.e. start as many `Step functions` as we have events, we would get rate limit exception: ThrottlingException. There are several approaches for coping with this issue, one of them for example is [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff) algorithm which uses progressively longer waits between retries for consecutive error responses.
Unfortunatelly it can perform quite poorly when a lot of clients trigger requests at the same time and processing requests is not a matter of couple of milliseconds. Google [recommends](https://landing.google.com/sre/sre-book/chapters/handling-overload/) for example to implement client-side throttling to prevent overloading backend with just rejecting requests.

In order to solve this issue we implemented pattern called `Queue-Based Load Leveling`.
![Queue and Lambda function control the rate](/images/2019_08_16/queue-based-load-leveling-pattern.png)


So instead of directly triggering AWS Step function, Pre-processor Lambda feeds `SQS`. `SQS` provides nearly unlimited throughput in case of standard queues enabling and scales dynamically based on demand of the application.
On the other side of the queue is Gatekeeper `Lambda function` is responsible for triggering `Step Function` by controling it's number of parallel executions. Here is some code snippet on how to check number of running `Step functions` in TypeScript.

```

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

At first it fetches running `Step functions` and checks whether there is a capacity to trigger new `Step functions`, and if so fetchs events with pre-defined limits from the queue and runs new `Step functions`.


# Summary
Decouplling events from `Step function` makes this approach extensible: in case of new type of payment method or billing aggregation we have to just add new `Cloudwatch trigger` by slightly adjusting Pre-processor `Lambda function`. It's also quite scalable as in case of new customers, i.e. more events, we don't have to deal with infrustructure limitations.