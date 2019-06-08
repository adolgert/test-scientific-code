# Testing Data Movement

If the central work for the system under test is a
long-running mathematical algorithm, there is usually some work
to put the data into the best data structure for that algorithm
to be efficient.

For instance, global health code works on
hierarchies of locations, where the world is the root of the
tree, and districts within countries are the leaves. If an algorithm
will act on all children of a particular node in the tree,
then it can help to sort data so that all child nodes follow
their parents. Then data for children of a node is continuous
in memory, increasing locality.

From a testing standpoint, the work done during data movement
falls into the create-read-update-delete (CRUD) categories.
For the scientist using the code, they might understand
descriptions such as

* **Read** - If the user specifies `get_csmr`, then get cause-specific
  mortality from the database and add it to the data.
* **Create** - If the input data doesn't have excess mortality,
  then derive it from cause-specific mortality and prevalence.
* **Update** - Use the average of incidence data at all child
  locations because it tends to be sparse.
* **Delete** - All-cause mortality isn't included in this step.
  
These are requirements. Failure to meet one of these requirements
often won't make the code stop running. It will harm confidence
in the code.

*Testing data movement is about assurance that the
function under test meets requirements.*

These tests are therefore classic boundary-value tests, where
we try parameters at the lower boundary, upper boundary,
and middle of the range. Combinatorial testing can be appropriate
across all parameters. What isn't mentioned in Jorgensen, for instance,
is that input datasets are parameters. They are high-dimensional
parameters which can make combinatorial testing quite large.
You are asking not only whether the dataset is nonzero in length,
as a boundary value, but whether each kind of data record is at
any boundary value that it can take on. For all cases, the goal
is to assert that requirements, as stated above in CRUD categories,
are true for all parameter values.
