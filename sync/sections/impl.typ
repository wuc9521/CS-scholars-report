= Implementation

== System Architecture

II.1 Description of the system architecture

=== Frontend

Our frontend is built using `React`. This allows us to display the dynamically changing results of queries and keep our application responsive.

We've structured the application around four main components, allowing users to easily navigate between them and access their desired information:

- The *Scholars* component displays a searchable and sortable list of academic professionals. Users can filter scholars by location or major, sort them by publication count or h-index, and even isolate those with publications but no grants.
- The *Locations* component offers similar functionality for research locations. Users can filter locations by major, and sort them by number of scholars with major, total grants, or maximum h-index.
- When a user selects a specific *Scholar* or *Location*, they can access the respective detailed information from *Profile* or *LocationProfile* components.
  - The *Profile* component displays in depth data about a scholar such as major, h-index, location, publications, and grants. It also includes forms for adding new publications, grants, and updating existing information.
  - The *LocationProfile* component displays in depth data about a location such as the country, scholars, total grants, and publications.

All of these components use `React` hooks for state management and `axios` for API communication with the backend to ensure efficient data handling and responsive interactions. Additionally, we used `React Bootstrap` to keep the design neat, consistent and responsive across all devices.

=== Backend

We used `Java` and and the `Spring Boot` framework for our backend. Using `Spring MVC` we built a `REST` API which our frontend uses to interact with the system's data and functions. We planned to handle data storage and management with `JPA` and `Hibernate` which makes it easy to work with our data models. However we've needed to mostly use native `SQL` queries inside `JPA`'s `@Query` annotations.

We've defined repositories, including PeopleRepository, LocationsRepository, PublicationsRepository, and GrantsRepository, to extend JpaRepository to provide basic CRUD operations and sometimes implement more complex queries. For example in PeopleRepository:
```java
@Query(nativeQuery = true, value = "SELECT p.pid, p.name, p.major, p.hindex, " +
        "l.loc_name AS location, l.locid as location_id, " +
        "(SELECT COUNT(*) FROM Publish pub WHERE pub.pid = p.pid) AS publication_count, " +
        "(SELECT COUNT(*) FROM Has o WHERE o.pid = p.pid) AS grant_count " +
        "FROM People p " +
        "JOIN \"in\" i ON p.pid = i.pid " +
        "JOIN Locations l ON i.locid = l.locid " +
        "WHERE p.pid = :personId")
Map<String, Object> getPersonProfile(@Param("personId") Long personId);
```
This query fetches a detailed profile for a person including their publication and grant counts.

We've implemented four main controllers: PeopleController, LocationsController, PublicationsController, and GrantsController. Here's a comprehensive list of the endpoints provided:
*PeopleController* endpoints:
- GET `/api/scholar/publication-count`: Retrieve scholars sorted by publication count
- GET `/api/scholar/hindex`: Retrieve scholars sorted by h-index
- GET `/api/scholar/publications-no-grants`: Get scholars with publications but no grants
- GET `/api/scholar/{personId}/profile`: Get a detailed profile for a specific scholar
- POST `/api/scholar/add`: Add a new scholar
- PUT `/api/scholar/update-hindex`: Update a scholar's h-index
- POST `/api/scholar/add-publication`: Add a new publication for a scholar
- POST `/api/scholar/assign-grant`: Assign a grant to a scholar
- PUT `/api/scholar/change-location`: Change a scholar's location

*LocationsController* endpoints:
- GET `/api/locations`: Get all locations
- GET `/api/locations/{id}`: Get a specific location by ID
- GET `/api/locations/person/{personId}`: Get locations for a specific person
- GET `/api/locations/by-people-count`: Get locations sorted by number of scholars
- GET `/api/locations/by-grant-count`: Get locations sorted by number of grants
- GET `/api/locations/by-max-hindex`: Get locations sorted by maximum h-index
- GET `/api/locations/{id}/profile`: Get a detailed profile for a specific location
- POST `/api/locations`: Add a new location
- DELETE `/api/locations/{id}`: Delete a location

*PublicationsController* endpoints:
- GET `/api/pub`: Get all publications
- GET `/api/pub/{id}`: Get a specific publication by ID
- GET `/api/pub/scholar/{pid}`: Get all publications for a specific scholar
- POST `/api/pub`: Create a new publication
- PUT `/api/pub/{id}`: Update a publication
- DELETE `/api/pub/{id}`: Delete a publication

*GrantsController* endpoints:
- GET `/api/grants`: Get all grants
- GET `/api/grants/{id}`: Get a specific grant by ID
- GET `/api/grants/scholar/{pid}`: Get all grants for a specific scholar
- POST `/api/grants`: Create a new grant

We used a service layer to include any necessary logic between controllers and repositories. For data consistency in complex operations, we've used the `@Transactional` annotation in our service layer.

=== Database

We use `PostgreSQL` deployed on a Ubuntu server. Our database combined with our Postgres DBMS stores the data and out stored procedures, processes SQL queries.

We used stored procedures for functionalities that have many parameters and require detailed checks and multiple inserts. For example this is the stored procedure used to insert a new scholar:
```sql
CREATE OR REPLACE FUNCTION AddNewPerson(
 p_name VARCHAR(100),
 p_major VARCHAR(50),
 p_hindex INT,
 p_location VARCHAR(100)
) RETURNS void AS $$
DECLARE
 new_pid INT;
 loc_id INT;
BEGIN
 SELECT MAX(pid) + 1 INTO new_pid FROM people;
  INSERT INTO people (pid, name, major, hindex)
 VALUES (new_pid, p_name, p_major, p_hindex);


 SELECT locid INTO loc_id FROM locations WHERE loc_name = p_location;
 IF NOT FOUND THEN
   SELECT MAX(locid) + 1 INTO loc_id FROM locations;
  
   INSERT INTO locations (locid, loc_name)
   VALUES (loc_id, p_location);
 END IF;


 INSERT INTO "in" (pid, locid) VALUES (new_pid, loc_id);
END;
$$ LANGUAGE plpgsql;
```


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

For every non-trivial functional dependency, the left-hand side is a superkey, or the right-hand side is a prime attribute. The database is in 3NF.


== Dataset // Done

Our dataset is a snapshot of #link("https://academictree.org")[Academic Family Tree] taken on 2024-02-20. The data can be accessed from #link("https://zenodo.org/records/6349537")[this link] and explanations of columns are provided on #link("https://academictree.org/export.php")[the official website].

Originally, we downloaded these `csv` files:
- `locations.csv` (10 columns, 46,826 rows),
- `people.csv` (17 columns, 859,814 rows),
- `peopleGrant.csv` (13 columns, 6,123,642 rows),
- `authorPub[05-35].csv` (9 columns, 75,423,143 rows)

These datasets seemed to be exported from a relational database, as each entity has a unique id (pid, locid, grantid, pubid) and relations are represented by attributes with other entities' ids. However there were two main issues:

Some values weren't in the format we wanted and there were a lot of missing values. We imported these into Python using `pandas` and formatted the columns correctly and decided not to use the columns with too many empty values. We also decided to remove people whose name or major was empty as having these people in our database would not give the user any useful information. Initially we also removed people whose h-index was empty. However this removed too much valuable information that might be useful to our users, so we decided against it.

The second issue was that a total of 82,453,425 rows was too many for us too handle. For this we only limited our scope to people whose majors included computer science, and removed locations, grants, and publications not in a relationship with these people. After this we ended up with a total of 1,966,747 rows.

Finally we used Python scripts to combine the data into relationship and entity sets and automatically insert it into our database. We first tried to insert the data remotely which took a very long time. After this realization we switched to inserting the data locally on the server.

More details about our specific implementation for this process can be accessed from:
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
// I don't know what else to put here
We managed to implement all the frontend and backend functionality specified in this report for the prototype. We used our own laptops to locally run the frontend using `Node.js` and the backend using `Apache Maven`. We hosted the `PostgreSQL` database on a remote `Ubuntu` VPS Server for persistency.

A detailed demo of our application prototype can be accessed from #link(
  "https://www.youtube.com/watch?v=ILDfNDC0rio"
)[this link].

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
