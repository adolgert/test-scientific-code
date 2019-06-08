The first job of a software developer is to estimate risk.<sup>1</sup>
We use risk to determine what to test and what not to test,
so that code can be safe without having brittle testing.

For most applications, assessment of risk is about what happens when
you hand an application to the user.
A unique feature of mathematical code is that the user is often
the developer, which shifts the highest risks to those that make
the answer wrong.

Jorgensen's *Software Testing: A Craftsman's Approach* distinguishes
faults from failures. A fault is the characters that were typed
incorrectly. A failure is observation that something went wrong.
The worst problem for mathematical code is when an
error in the code isn't visible.
The worst problem is faults that aren't failures.

This document covers two different kinds of failure-free faults.

 * Simple data manipulation that doesn't do what the user
   expected it to do.
   
 * Mathematical functions that return a result that looks
   reasonable but isn't correct.

While these faults are within the taxonomy of faults
in any book on testing, we can discuss some of the particular
challenges that complicated mathematical functions introduce.

Let's assume that we are testing an application that combines
multiple algorithms to produce a result. The *system under test*
could also be a single function that combines multiple algorithms.
Either way, define a single mathematical algorithm as a
function for which all data structures have been created before
the algorithm starts, and it writes a new data structure, or
updates an input data structure by the time the algorithm finishes.

Overall, we can model software, of a certain size, as a sequence
of data movement and application of mathematical algorithms.

1.  **Translate parameters** into an internal set of parameters.
2.  Read data.
3.  **Organize data** for the first mathematical algorithm.
4.  **Apply an algorithm** to input data structures.
5.  **Organize data** for the second mathematical algorithm.
6.  **Apply an algorithm** to the input data structures.
7.  **Organize data** for writing.
8.  Write data.

There can be math in the organization of data, and there
can be data organization during a mathematical algorithm,
which blurs distinction of the two, but 
this model of computation encapsulates two properties:

 * The mathematical algorithms determine order of computation,
   so they are focused and optimized. They carry risk in
   complexity of functional application.
   
 * During organization of data, none of the mathematical
   operations are particularly risky. They are transformations
   we might trust by eye. Most of the risk in these sections
   comes from selection of data and presentation to the
   more mathematical parts of the code.

Your code may not be organized in a way that follows this
model. There may be good reasons not to organize it this way,
or organizing the code into separate, testable regions of
data movement and mathematical computation might enable you
to separate concerns for risk, which separates concern
for testing. As a side effect, remembering to choose the
best data structure for an algorithm can make code faster.

<sup>1</sup> Personal communication with James Collins.
