# Outline

1. Introduction

  a. This code matters.

  b. We don't have guidance on writing it.

  c. Will describe both structure of such a program for testing
     and what you do. Show movement-algorithm-movement.

  d. Apply these to reduce risk.
     The value of unit testing is that it makes you write units.


1. Faults in Mathematical Code

  * Feature-fault-failure

  * Classes of errors.
     * off-by-one index
     * equation wrong in functional form
     * NaN, Inf mishandling
     * for-loop limit problem
     * if-then conditional test wrong

  * computational complexity versus arithmetic complexity


2. Testing parameter logic

  a. Logic-intensive is a traditional problem that complicates
     this other problem.

  b. Apply traditional methods, but separately.

  c. The chart. Test this logic once, never again. Separate it.

  d. Think of parameter-handling as translation from an external
     language to some kind of parameterization that's more
     consistent, concise for internal processing.


3. Testing data movement

  a. Integration tests are important for scientific too.

  b. Integration tests look more like moving data structures, so
     the problem is anything in one data structure and anything in another.

  c. Generate data, including at bounds. Verify data, including at bounds.

  d. Trusting movement lets you reuse code.


3. Testing Numbers

  * When does a == b for IEEE?
    * What's small enough for a single or double?
    * It depends on the number of calculations for drift.

  * Vectors are lots of numbers.
    * A bunch of parameters. A large space.
    * Nondecreasing, one-hump, categorical measures.

  * Stratify tests for run time

    * cheap, fast on box.
    * long on push to repo.


3. Compare with limiting theory

   * Large-N limit
     * How you calculate what a sequence of values approaches.

   * Limiting parameter value (infinity or zero)

     * Taylor series
     * Limits at infinity and zero

   * Simpler simulations (random walker). testing a metric on a value.

   * Categorical behavior

      * Moves in the right direction when perturbed.
      * Rock in the pond to test axis usage.
      * one-hump or two.

3. Parallel Implementation

  * Brute force numerical algorithms for comparison

    a. Not having an oracle for most of the solutions is a problem.

    b. Can we find a limiting answer or something related?

    c. Calculus techniques are powerful here.

       1. limits

       2. numerical integration
       
       3. numerical derivatives
    
    d. There are a lot of techniques that would be slow but are useful.

  * Micro-macro and macro-micro

  * Think of invariants, not algorithms. Relate x+1 to x.

  * Another language or library

  * A figure in a paper

  * Compare with your former answer, for refactoring


5. Common Statistical Tests

  a. Statistical work may not have an exact answer, but it has wrong ones.

  b. Use statistics in your tests.

  c. Find bounds and measure them statistically.

    * Fix seeds.

    * Look for determinism, eg. ordering from hash in a dictionary.

    * Empirical distributions.

  d. It's not foolproof to run 20 tests, but no test is foolproof.


6. Using symmetry to test a function

  a. Sometimes we can't know what a function will make.

  b. You have equations, though, and you can use what you do know.

  c. Metamorphic testing can catch a lot.
     * p goes to 1-p.
     * reverse of elements
     * linear in input is linear in output

  d. Knowing symmetries will also help optimization.

6. Random changes to the code.
   * Tests unit tests.

7. Outside the code

  a. Your mistakes can be that you fooled yourself.

  b. How do you set yourself up for external help?

  c. Other code, expert opinion on results from multiple disciplines.

  d. The world will test your code, if all goes well.
