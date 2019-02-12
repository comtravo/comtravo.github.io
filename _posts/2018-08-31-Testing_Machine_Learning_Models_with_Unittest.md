---
layout: article
title: Effective Mocking of Unit Tests for Machine Learning
date: 2019-02-13 10:00:00
published: true
categories: [testing]
comments: false
share: true
description: Writing unit tests for machine learning models can be challenging due to the complex structure of the models. This post focuses on how the Python unit test mocking framework can be used to write better unit tests for machine learning.
image:
    feature: 2019_02_13/feature.jpg
    teaser: 2019_02_13/teaser.jpg
usemathjax: false
author: matti_lyra
---

The data science backend at Comtravo is almost exclusively written in Python (3). We currently have about 10 different machine learning models performing various tasks from named entity recognition to semantic role labelling; some of the models have dependencies where one model requires the output of another model. All of the models also have unit tests ensuring that they do what we intended them to do.

The issue we've had with writing unit tests is the tight integration between our code and the underlying library code we're calling into. In most cases, this affects models written using `tensorflow` or `sklearn`. Fundamentally, unit tests should not test or depend on the functionality of those third party libraries. In this post, I illustrate the problem in more detail and outline how the `unittest.mock` package in the Python standard library can be used to tease apart the two code bases.


# Why Write Unit Tests for Machine Learning Models?

Almost all of the models in our machine learning pipeline have different architectures and use different libraries. Some are written with `tensorflow` or `pytorch`, while others use `sklearn`. Having a unit test suite in place that checks the validity of model inputs and outputs against a shared data representation allows us to verify that changes to one model won't break the others. Furthermore, it gives reassurance that when we refactor code or experiment with new features, we're not unintentionally changing the functional contract of the models we currently have in our pipeline. In essence, a good set of unit tests allows us to separate one model from the rest and ensure that that one model works as expected in isolation.


# The Problem

Ideally, each unit test should be narrowly focused on testing that a specific function called in a specific way has a predictable outcome. For instance, an exception is raised or some specific value is returned. Therefore, each unit test should complete in a short period of time, say less than ½ a second. Writing automated unit tests for machine learning models in this environment can be cumbersome for a number of reasons:

- each model requires some data preparation, which can be computationally expensive
- the model training process is certainly expensive, especially in the context of unit tests

For a lot of the machine learning models some test scaffolding needs to be built, so that only the functionality that is under a specific unit test's scope is executed and other functionality is "_mocked_". Traditionally, this mocking would be done using [method stubs](https://en.wikipedia.org/wiki/Method_stub) that aim to replace existing real functionality with some alternative functionality. The alternative functionality should look close enough to the real one so as to not break the code, but be free from side effects or less expensive to run. In Python 3, these method stubs can be replaced with mock objects from the `unittest.mock` package.

Let's look at a specific example. Below is a redacted piece of code from one of our models. There's two crucial bits of functionality in the code:

1. on line three a clone of the model is created and the cloned object is returned, not the original
2. the for loop at the end trains a series of models, known as a [bag (PDF)](https://statistics.berkeley.edu/sites/default/files/tech-reports/421.pdf)

```python
class BaggingModel:
    def _model(self):
        """Return compiled tensorflow model."""
        # build Tensorflow model
        return tf_model

    def fit(self, y, msgs, ents, **fit_params):
        self._check_fit_input_args(y, msgs, ents)
        bag = self.clone()

        # lots of data transformations
        # ...
        # ...

        # train a bag of models
        for i in range(mdl.n_models):
            model = bag._model()
            model.fit([X_train, X_ent, X_shape], y_train, **kwargs)
            bag.models.append(model)
        return bag
```

Notice, that there is an internal `.fit` call inside the `BaggingModel.fit` which delegates the model fitting to a `tensorflow` model created using the `bag._model()` call. This is expensive and for almost all the unit tests completely unnecessary. The `bag._model` call gives us a good interception point later on, but let's first see what a unit test for this code would look like.

Here's what a naïve unit test without mocking looks like for checking that a clone is returned.

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

While the test is short and to the point, the problem is that calling `model.fit` not only exercises the functionality we want to test,i.e., the cloning, it also exercises all the other – potentially very expensive to run – functionalities. It is not the concern of this specific test to check if the model training works or if the data preparation works. This test is _only_ concerned with checking that the object returned from the function is not the same as the original one, i.e., the two do not share their object identity. Running all of the code in all of the unit tests increases the running time of the whole test suite for no good reason. We can do much better!

# Replacing Expensive Calls with `unittest.mock.patch`

The [`unittest` library](https://docs.python.org/3/library/unittest.html) gained a lot of really useful functionality in Python 3. One of those is the `unittest.mock` package that allows data and functions to be mocked, or patched, for more effective testing. Let's rewrite the test above to use this new functionality.

Specifically, let's rewrite the test so that the `.fit` method of the underlying bagged models is mocked. Recall that the final few lines of the `BaggingModel.fit` contains a for loop that creates a number of `tensorflow` models and calls `.fit` on those. We want to intercept this and instead have the internal `.fit` call go to a mocked object. This way we can isolate the test so that only checks if a cloned object is returned and not be concerned with actually training a machine learning model.

Here's what the changed test case looks like
```python
from unittest import TestCase, mock

from ctlearn.estimators import BaggingModel  # this is the model we're testing

class TestBaggingModel(TestCase):
    def test_that_model_fit_returns_a_clone(self):  # I like to give my test functions descriptive names
        with mock.patch('ctlearn.estimators.BaggingModel._model'):
            model = BaggingModel()
            model_ = model.fit(dummy_y, dummy_msgs, dummy_ents)
            assert type(model_) == type(model)   # must return the same type of object
            assert model_ is not model           # object identity MUST be different
```

That doesn't look like a big change, it's a just a single [context manager](https://docs.python.org/3/library/stdtypes.html#typecontextmanager), but there's quite a bit packed into that one context manager.

Let's first delve into what the `patch` actually does. For the scope of the context manager it replaces the patched object, in this case the `._model` method, with a `MagicMock`. The `MagicMock` and its parent class `Mock` are special objects in the `unittest.mock` package specifically designed to act as stubs, a kind of no-op object that can be called but does not do anything and typically has no side effects. Any call or attribute access just returns a new [`MagicMock` object] (https://docs.python.org/3/library/unittest.mock.html#magicmock-and-magic-method-support).

Notice, that the patched method `._model` is never called in the test code itself, it is called internally in `BaggingModel.fit`. Once it gets called it'll return another `MagicMock`. The for loop that finally creates the bag of models, which we're not interested in for the purposes of this test, will therefore call the `.fit` method on the created mock objects, not on the real `tensorflow` models.

This usage of `mock.patch` allows us to replace expensive calls, or calls that are outside the scope of a unit test, with no-op calls that have no side effects. Another useful aspect is the ability to make assertions directly on the mock objects.


# Making assertions about mocked objects

Above we wrote a test to check that `BaggingModel.fit` returns a cloned object. The other bit of functionality we wanted to test was to ensure that the correct number of models is included in the bag. For this we'll utilise the ability to make assertions on the mock objects themselves. Let's start with a test case.

```python
class TestBaggingModel(TestCase):
    def test_that_model_fit_returns_the_correct_sized_bag(self):
        with mock.patch('ctlearn.estimators.BaggingModel._model') as mock_mdl:
            model = BaggingModel(n_models=5)
            model_ = model.fit(dummy_y, dummy_msgs, dummy_ents)
            assert len(model_.models) == 5
            assert mock_mdl().fit.call_count == 5
```

Again, this doesn't look like much, but don't be fooled by the simplicity. Let's focus on the last two lines of the test. We've set the number of models in the bag to 5, so logically the size of the bag in the returned object should be five, that's what the first assertion is about. However, having a bag of five models is not useful. Those five objects need to be fitted and for the model to be a real bag, the models need to be fitted on random samples drawn with replacement from the original data set.

The second assertion is saying that the `.fit` method on the created `MagicMock` object is called five times, once for each model in the bag. This works because the mocked function returns the _same_ mock object each time it is called. We also retain a reference to that mock object inside the context manager, the `mock_mdl` variable, which allows us to make the assertions in the first place. Notice, that the we don't ever need to instantiate or declare that a `.fit` method exists on the `MagicMock` object; this is what the mock objects do. They record any attribute access and allow us to introspect what was done the mock objects later on.

Notice that we're not interested in what `tensorflow` does once the `.fit` method is called, just that _it is_ called. The test could be made even more specific by asserting that the `.fit` method is called with specific splits of the data. This can be done using the [`.assert_has_calls`](https://docs.python.org/3/library/unittest.mock.html#unittest.mock.Mock.assert_has_calls), which allows us to specify exact call parameters for each of the five calls. I'll leave it as an exercise for the reader to piece that final detail together.


# Conclusion

The example I showed was not the most complex, but at the same time fairly realistic. One thing that took me quite a while to wrap my head around was exactly how the patching works and where to do it. The `mock.patch` function can be used as a function or class decorator, a context manager, as in this article, or simply as a normal function in the unit test set up phase. Deciding on which option is the most appropriate can take a little getting used to, luckily the Python docs have a [section dedicated to this point](https://docs.python.org/3/library/unittest.mock.html#where-to-patch).

This article talked about how to use the `unittest` mocking library to create function stubs that make it very easy to replace expensive calls to third party libraries with no-op mock objects. Some time ago I rewrote the entire test suite for the data science backend to use exactly these kinds of mocks and shaved off approximately a third of the runtime from the entire test suite. I hope I've managed to convince you how easy and powerful the mocking library is to use. I encourage everyone to have a look at it.

