= Implementation

== System Architecture

II.1 Description of the system architecture

=== Frontend

We use `Next.js` and `React` as our frontend framework.

- Handles user interface and interactions, makes API calls to backend using HTTP
- Javascript, HTML, CSS, Bootstrap

// TODO

=== Backend

We use `SpringMVC` as our backend framework.

- Processes and responds to API requests, send SQL queries to database
- Java
// TODO

=== Database

Stores the data, processes SQL queries

We use `PostgreSQL` deployed on a Ubuntu server.

Implementation: Third Normal Form
Our database is in 3NF. The functional dependencies are as follows:
- *`Person`*:
  - `pid` $arrow$ `name`, `major`, `hindex`
- *`Location`*:
  - `locid` $arrow$ `loc_name`, `city`, `state`, `country`
- *`Publication`*:
  - `pubid` $arrow$ `pmid`, `doi`
  - `pmid` $arrow$ `pubid`, `doi`
  - `doi` $arrow$ `pubid`, `pmid`
- *`Grant`*: `grantid` $arrow$ `budget_start`
- *`In`*, *`Publish`*, *`Obtain`*: no non-trivial functional dependencies

For every non-trivial functional dependency, the left-hand side is a superkey, and the right-hand side is a prime attribute. The database is in 3NF.


== Dataset // Done

Our dataset is asnapshot of #link("https://academictree.org")[Academic Family Tree] taken on 2024-02-20. The data can be accessed from #link("https://zenodo.org/records/6349537")[this link] and explanations of columns are provided on #link("https://academictree.org/export.php")[the official website].

Originally, we downloaded these `csv` files:
- `locations.csv`,
- `people.csv`,
- `peopleGrant.csv`,
- `authorPub[05-35].csv`

These datasets seems to be exported from a relational database, as they have the following characteristics:
- Each table has a unique ID.
- Relations are represented in an organized way.

However here are some drawbacks of our downloaded dataset:
- There are many missing values in this dataset.
- Too many scholars for us to handle.

To solve these problems, we did the following:
- We filtered out the columns that are not useful for our project.
- We only considered CS-related scholars and their publications, grants, and locations respectively.
- We use python to clean the data.
- We use python to insert them into our database.

More details can be accessed from:

- Data Cleaning: https://github.com/ArdaGurcan/CS-Scholars/blob/main/cleaning.ipynb
- Data Insertion: https://github.com/wuc9521/CS-scholars-backend/tree/main/scripts

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

We designed 5 test cases for this evaluation. The testing source file(s) can be accessed from the #link("https://github.com/wuc9521/CS-scholars-backend/tree/main/src/test/java/site/wuct/scholars/controller")[this link].

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

For instance, in #ref(<code:updateNonExistentPublication>) we tested updating a non-existent publication to make sure our system handles it correctly without crashing. we use `MockMvc` in Spring framework. This lets us test our controllers without actually sending HTTP requests. This kind of edge case testing is very important. It helps us catch unexpected errors and makes our system more reliable.

#figure(
  ```java
      /**
       * Test for updating a non-existent publication
       *
       * @throws Exception if the request fails
       */
      @Test
      void updateNonExistentPublication() throws Exception {
          Long nonExistentId = 999L;

          when(publicationsService.findById(nonExistentId)).thenReturn(null);

          mockMvc.perform(put("/api/pub/{id}", nonExistentId)
                  .contentType(MediaType.APPLICATION_JSON)
                  .content("{\"doi\":\"10.1000/nonexistent\"}"))
                  .andExpect(status().isNotFound());

          verify(publicationsService, never()).save(any(Publication.class));
      }
  ```,
  caption: "update a non-existent publication",
)<code:updateNonExistentPublication>


=== Data Consistency Evaluation

We designed 5 test cases for this evaluation. The testing source file(s) can be accessed from the #link("https://github.com/ArdaGurcan/cs-scholars-frontend/tree/main/src/__tests__")[this link].

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

For example as shown in #ref(<code:networkError>), this end-to-end testing helps us catch issues that might only appear when the whole system is working together. Similarly, in this frontend test, we use the frontend testing framework Jest to mock axios API calls, we can test these edge cases without affecting real data in our database.

#figure(
  ```javascript
  test('5. Simulates network error and tests error handling', async () => {
    const mockOnSelectScholar = jest.fn()
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => { });
    axios.get.mockRejectedValueOnce(new Error('Network Error'))
    render(<Scholars onSelectScholar={mockOnSelectScholar} />)
    fireEvent.click(screen.getByText(/Search/i))
    await waitFor(() => {
      expect(consoleSpy).toHaveBeenCalledWith('Error fetching scholars:', expect.any(Error));
    });
    consoleSpy.mockRestore();
  });
  ```,
  caption: "Simulates network error and tests error handling",
)<code:networkError>

=== Performance Evaluation

We designed 5 test cases for this evaluation. The testing source file(s) can be accessed from the #link("https://github.com/wuc9521/CS-scholars-backend/tree/main/src/test/java/site/wuct/scholars/performance")[this link].

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

For example, as shown in #ref(<code:indexImpact>), we tested the impact of indexing on query performance. We used random data to minimize cache effects and get a fair comparison. Our tests showed that adding an index significantly improved query speed. This kind of testing helps us make sure our system stays fast even with lots of data.

#figure(
  ```java

    /**
     * Test the impact of indexing on query performance
     */
    @Test
    public void testIndexImpact() throws SQLException {
        jdbcTemplate.execute("DROP INDEX IF EXISTS idx_people_name"); // Ensure the index doesn't exist
        BiFunction<String, Integer, Long> runQueries = (indexStatus, iterations) -> { // Function to run test queries
            long totalTime = 0;
            for (int i = 0; i < iterations; i++) { // Generate a random string to search for
                String randomString = generateRandomString(3);
                String query = "SELECT * FROM people WHERE name LIKE '" + randomString + "%' LIMIT 100";
                // Flush cache by querying large amount of unrelated data
                jdbcTemplate.query("SELECT * FROM people ORDER BY RANDOM() LIMIT 10000", (rs, rowNum) -> null);
                long startTime = System.nanoTime();
                List<Map<String, Object>> results = jdbcTemplate.queryForList(query);
                totalTime += System.nanoTime() - startTime;
                System.out.println("Query for '" + randomString + "' returned " + results.size() + " results");
            }
            double avgTime = totalTime / iterations / 1_000_000.0;
            System.out.println("Average time " + indexStatus + " index: " + avgTime + " ms");
            return totalTime;
        };
        long timeWithoutIndex = runQueries.apply("without", 20); // Test without index
        jdbcTemplate.execute("CREATE INDEX IF NOT EXISTS idx_people_name ON people(name)"); // Create the index
        long timeWithIndex = runQueries.apply("with", 20); // Test with index
        jdbcTemplate.execute("DROP INDEX IF EXISTS idx_people_name"); // Clean up
        System.out.println("Time without index: " + (timeWithoutIndex / 20 / 1_000_000.0) + " ms");
        System.out.println("Time with index: " + (timeWithIndex / 20 / 1_000_000.0) + " ms");
        assertTrue(timeWithIndex < timeWithoutIndex,
                "Index did not improve performance. Without index: " + (timeWithoutIndex / 20 / 1_000_000.0) +
                        " ms, With index: " + (timeWithIndex / 20 / 1_000_000.0) + " ms");
    }
  ```,
  caption: "Test the impact of indexing on query performance",
)<code:indexImpact>
