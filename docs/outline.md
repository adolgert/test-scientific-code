# Outline

1. Introduction

  a. This code matters.

  b. We don't have guidance on writing it.

  c. Will describe both structure of such a program for testing
     and what you do. Show movement-algorithm-movement.

  d. Apply these to reduce risk.


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


4. Brute force numerical algorithms for comparison

  a. Not having an oracle for most of the solutions is a problem.

  b. Can we find a limiting answer or something related?

  c. Calculus techniques are powerful here.

     1. limits

     2. numerical integration
     
     3. numerical derivatives
  
  d. There are a lot of techniques that would be slow but are useful.


5. Common Statistical Tests

  a. Statistical work may not have an exact answer, but it has wrong ones.

  b. Use statistics in your tests.

  c. Find bounds and measure them statistically. Fix seeds.

  d. It's not foolproof to run 20 tests, but no test is foolproof.


6. Using symmetry to test a function

  a. Sometimes we can't know what a function will make.

  b. You have equations, though, and you can use what you do know.

  c. Metamorphic testing can catch a lot.

  d. Knowing symmetries will also help optimization.


7. Outside the code

  a. Your mistakes can be that you fooled yourself.

  b. How do you set yourself up for external help?

  c. Other code, expert opinion on results from multiple disciplines.

  d. The world will test your code, if all goes well.
