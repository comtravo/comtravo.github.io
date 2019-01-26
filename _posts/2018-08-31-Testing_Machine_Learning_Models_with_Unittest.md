---
layout: article
title: Effective Mocking of Unit Tests for Machine Learning
date: 2019-01-26 05:31:00
published: false
categories: [testing]
comments: false
share: true
description: Writing unit tests for machine learning models can be challenging due to the complex structure of the models. In this post I'll show how the python unit test mocking framework can be used to write better unit tests for machine learning.
usemathjax: false
author: matti_lyra
---

# Rough Outline

- what are unit tests
- why writing tests for machine learning models is difficult
- what are unit test mocks
- what, specifically, is the `unittest.mock` library
- how to utilise `unittest.mock` to write better unit tests for ML

The data science backend at Comtravo is almost exclusively written in Python. We currently have about 15 different machine learning models performing various tasks. One does named entity recognition, another intent classification while yet a third does slot filling: recognising which semantic role a token or sequence of tokens has in a message, for instance `TXL` is the <a class="btn-info">origin</a>, `MUC` the <a class="btn-info">destination</a> and `tomorrow morning` is the <a class="btn-info">departure time</a> in the sentence "_Could you please book me a flight tomorrow morning from TXL to MUC_".

The models in the data science backend for performing these different tasks also have different architectures and use different libraries. Some are written with `tensorflow` or `pytorch` while others use `sklearn`. Each model requires different data preparation while all the models need to work on the same underlying data set. We've agreed upon an interface for all the models where each model is responsible for turning a general backend wide data representation into an internal representation that is useful for the model.

# Introduction

Writing automated unit tests for the machine learning in this environment can be cumbersome for a number of reasons:

- the data preparation methods of each can be computationally expensive
- the model training process is certainly computations expensive, especially in the context of unit tests

Ideally, each unit test should be narrowly focused on testing that a specific function called in a specific way has some, one, predictable outcome, for instance, an exception is raised. Each unit test should, therefore, also complete in a short period of time, say less than ½ a second. For a lot of the machine learning models some scaffolding needs to be built so that only the functionality that is under a specific unit tests scope is executed and other functionality is "_mocked_".

Let's look at a specific example. Below is a redacted piece of code from one of our models. There's two crucial bits of functionality in the code:

1. on line three a clone of the model is created and clone is returned not the original model
2. the for loop at the end trains a series of models, known as [bagging (PDF)](https://statistics.berkeley.edu/sites/default/files/tech-reports/421.pdf)

```python
def fit(self, y, msgs, ents, **fit_params):
    self._check_fit_input_args(y, msgs, ents)
    bag = self.clone()

    # lots of data transformations
    # ...
    # ...

    # train a bag of models
    for i in range(mdl.n_models):
        model = mdl._model()
        model.fit([X_train, X_ent, X_shape], y_train, **kwargs)
        bag.models.append(model)
    return bag
```

While the cloning is not optional the number of models to include in the bag is, it can be configured for each model separately. These two lead to two good, very focused unit test. Here's what a naïve unit test would look like.

```python
from unittest import TestCase

from ctlearn.estimators import BaggingModel  # this is the model we're testing

class TestBaggingModel(TestCase):
    def test_that_model_fit_returns_a_clone(self):  # I like to give my test functions descriptive names
        model = BaggingModel()
        model_ = model.fit(dummy_y, dummy_msgs, dummy_ents)
        assert type(model_) == type(model)  # must return the same type of object
        assert model_ is not model  # object identity MUST be different
```

While the test is short and to the point, the problem with the above test code is that calling `model.fit` not only exercises the functionality we want to test, it also exercises all the other, potentially very expensive to run, functionality. It is not the concern of this specific test to check if the model training works, this test is _only_ concerned with checking that the object returned from the function does not have the same object identity as the original one. This kind of unit testing increases the running time of the whole test suite for no good reason. We can do much better!

# Mocking with `unittest.mock`

The [unit testing library](https://docs.python.org/3/library/unittest.html) `unittest` gained a lot of really useful functionality in Python 3. One of those is the `mock` package that allows data and functions to be mocked for more effective testing.
