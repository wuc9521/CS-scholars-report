= Implementation

== System Architecture

II.1 Description of the system architecture

=== Frontend

We use `Next.js` and `React` as our frontend framework.
// TODO

=== Backend

We use `SpringMVC` as our backend framework.
// TODO

=== Database

We use `PostgreSQL` deployed on a Ubuntu server.
// TODO

== Dataset

II.2 Description of the dataset

- Snapshot of Academic Family Tree (academictree.org) taken on 2024-02-20
- locations.csv, people.csv, peopleGrant.csv, authorPub[05-35].csv
- Unique IDs, represents relations in organized way
- Each row one relation
- Many missing values, too many scholars, cleaned up with Python


// Originally our dataset comes from

== ER Diagram

A detailed explanation of the ER diagram is provided in #ref(<sec:relational-model>).
#figure(
  image(
    "../figures/er.png",
    width: 70%,
  ),
  caption: "ER Diagram",
)<fig:er>

== Relational Model<sec:relational-model>

II.4 Relational model (final version from the previous checkpoint copied here)


+ *`Person`*(#underline[`pid`], `name`, `major`, `hindex`)
  - `pid` is the primary key
+ *`Location`*(#underline[`locid`], `loc_name`, `city`, `state`, `country`)
  - locid is the primary key
+ *`Publication`*(#underline[`pubid`], `pmid`, `doi`)
  - `pubid` is the primary key
  - `pmid` and `doi` are also keys
+ *`Grant`*(#underline[`grantid`], `budget_start`)
  - `grantid` is the primary key
+ *`In`*(#underline[`pid`, `loc_id`])
  - `(pid, loc_id)` is a composite key
+ *`Publish`*(#underline[`pid`, `pubid`])
  - `(pid, pubid)` is a composite key
+ *`Obtain`*(#underline[`pid`, `grantid`])
  - `(pid, grantid)` is a composite key

== Prototype

II.5 Implementation: description of the prototype

== Evaluation

We mainly design our evaluation from three aspects:

+ *Data Accuracy Evaluation*: *CRUD* directly from backend and check.
+ *Data Consistency Evaluation*: end-to-end data consistency.
+ *Performance Evaluation*: regarding concurrency, indexing etc.


As required in the #underline[#link("https://canvas.wisc.edu/courses/402238/discussion_topics/1885324")[announcement]], we also include the feedback from Checkpoint 4.


#figure(
  image(
    "../figures/fb.png",
    width: 40%,
  ),
  caption: "Feedback of Checkpoint 4",
)<fig:fb>


=== Data Accuracy Evaluation

We designed 5 test cases for this evaluation.

- `addNewPerson()`: Insert a new record and verify successful insertion
- `getPersonProfile()`: Read an existing record and verify data correctness
- `updatePublicationAndVerifyChanges()`: Update a record and verify changes are saved
- `deletePublicationAndVerifyRemoval()`: Delete a record and verify it has been removed
- `updateNonExistentPublication()`: Updating non-existent records

#figure(
  image(
    "../figures/pplct.png",
    width: 100%,
  ),
  caption: `PeopleControllerTest.java`,
)<fig:pplct>

#figure(
  image(
    "../figures/pubct.png",
    width: 100%,
  ),
  caption: `PublicationsControllerTest.java`,
)<fig:pubct>

=== Data Consistency Evaluation

We designed 5 test cases for this evaluation.

- Perform a create operation on the frontend and verify the data is correctly stored in the backend
- Search for a scholar and verify the end-to-end data consistency
- Filter scholars with specific criteria and verify backend API call
- Test different sorting criteria for scholars and verify corresponding backend calls
- Simulate network interruptions during data transfer and test recovery mechanisms

#figure(
  image(
    "../figures/e2e.png",
    width: 70%,
  ),
  caption: `Scholars.test.js`,
)<fig:e2e>

=== Performance Evaluation

We designed 5 test cases for this evaluation.

- `testLargeDatasetQuery()`: Measure response time for querying a large dataset
- `testConcurrentConnections()`: Test the system's ability to handle multiple concurrent database connections
- `testComplexJoinOperation()`: Evaluate the performance of complex join operations or aggregations
- `testIndexImpact()`: Measure the impact of indexing on query performance
- `testSustainedLoad()`: Test the system's performance under sustained load over an extended period


#figure(
  image(
    "../figures/pfm.png",
    width: 100%,
  ),
  caption: `PerformanceTest.java`,
)<fig:pfm>

