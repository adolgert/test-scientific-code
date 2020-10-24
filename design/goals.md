% Goal-level Specification for Testing Suite
% Andrew Dolgert
% 24 October 2020

# Introduction

I'm thinking about how to test scientific code and am using the Julia
language for examples. Julia has a half-dozen unit testing frameworks,
and they aren't very built-up with features. Since I come from unit
testing in C++, Java, .NET, and Python, I'm used to more mature frameworks
for unit testing. In this document, I'd like to consider what I'd like
to see in Julia's unit testing ecosystem.

My interest is driven by recent research into techniques for
testing scientific code. I've been teaching myself, and asking how
to teach others, how to test code that has lots of equations and
may not have expected answers. In the process, I've learned about
tools that are useful and not readily available in all frameworks.
Julia's ecosystem offers two advantages, that it isn't settled yet,
and that the language and runtime are designed to offer the kind
of introspection and metaprogramming that advanced unit testing
can take advantage of.

# High-level Goals

## Lists for context

### Qualities to test for

There are maybe eight of these. Some lists are longer.

* Functionality
* Speed
* Resource usage
* Security
* Architectural soundness

### Kinds of testing

There are fifty kinds of testing, according to Wikipedia.
Unit testing frameworks get used for all kinds of testing purposes.

* During development
* Unit testing
* Test-driven design
* Checkout testing
* Regression testing

### Testing environment

Literature on testability points out that there are many 
influences on whether code can be tested.

* Unit testing framework
* Language features
* ...there are six of these, in my notes.


# User-level features

* Select tests, in order to tailor unit tests to
  testing goals of current development stage.

  - by package, to focus on a scope during development,

  - by resource usage, to run on laptop, cluster, or cloud,

  - by runtime length, to distinguish unit tests from acceptance tests,

  - by system-under-test, such as those tests that exercise
    floating-point features, for testing GPU code compilation.

* Isolate tests from each other.

* Prioritize tests that fail more often or more recently.

* Find faults in tests that fail.

  - Debug code that runs in tests.

  - See segment, line of failure.

  - Document the purpose of a test. This documentation helps
    find the responsible fault.

* Generate test parameters according to a test design

  - Random testing

  - Fractional combinatorial designs, from BIBD to Orthogonal arrays.

  - Concrete-symbolic tests, that watch running code to determine
    how to generate parameters that give better coverage. (Intellitest)

* Report test results to user or automated (CI) systems.

* Modify runtime code in order to isolate system-under-test from
  dependencies on other code, other applications, or operating system
  resources.

  - Mock, stub, fake

  - Function rewriting is an research approach to this.

* Run tests from command-line, IDE, containerized application.

* Combine common work for multiple tests in order to isolate
  and identify tests that have a single purpose.

  - Setup and teardown, which pulls common work out into separate functions.

  - Decision tables for tests, which pulls unique work into
    a separate data structure.

* Evaluate test quality

  - Measure metrics during testing, such as code coverage,
    lines of testing code.

  - Match tests to the code that they test, so that you can
    as whether high-complexity code has more testing, whether
    you measure complexity by lines of code, Halstead metric,
    or number of calls into and out of a code segment.

  - Track test failures over time for what failed and how it failed.
