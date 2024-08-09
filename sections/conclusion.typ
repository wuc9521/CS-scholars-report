= Conclusion

== Course Learnt from this Project

This project has been an invaluable learning experience:

1. *Flexibility in Query Design*: We discovered that hard-coding queries in the backend, while initially seeming straightforward, significantly limits the flexibility of our application. This realization underscores the importance of designing more dynamic and adaptable query systems.

2. *Data Cleaning with Purpose*: The process of cleaning our dataset from Academic Family Tree highlighted the critical importance of keeping our end-use cases in mind. We learned to balance between removing unnecessary data and preserving valuable information, even when incomplete (such as retaining scholars with missing h-index values).

3. *Backend Necessity*: This project reinforced the crucial role of a robust backend in managing complex data operations and ensuring data integrity. Our use of Spring Boot for the backend proved essential in handling the intricate relationships within our CS-scholars database.

4. *`MVC` Design Pattern Benefits*: Implementing the Model-View-Controller (`MVC`) design pattern in our project structure greatly enhanced our code organization and maintainability. It allowed for a clear separation of concerns between data management, business logic, and user interface components.

5. *Security Considerations*: As we developed our application, we became increasingly aware of the importance of security in database management. This includes considerations for data privacy, secure API endpoints, and protection against potential SQL injection attacks.

== Relevant Database Knowledge

The database knowledge acquired during this course proved immensely helpful throughout the project:

1. *Normalization*: Applying the principles of database normalization, particularly achieving Third Normal Form (3NF), was crucial in designing our efficient and consistent database schema.

2. *SQL and Query Optimization*: Our coursework on SQL querying and optimization techniques was directly applicable when writing complex queries, especially for retrieving scholar profiles and aggregating publication data.

3. *Indexing*: The performance evaluation tests, particularly the one measuring the impact of indexing on query performance, directly applied the indexing concepts learned in class. This practical application demonstrated the significant performance improvements that proper indexing can achieve.

4. *Transaction Management*: While implementing CRUD operations and ensuring data consistency, the concepts of transaction management and the use of the `@Transactional` annotation in our service layer directly reflected our course learnings.

5. *Relational Model and ER Diagrams*: The process of creating our ER diagram and translating it into a relational model was a practical application of the theoretical concepts covered in the course.

Throughout the project, we encountered and addressed several database-related issues discussed in the course, such as:

- Handling large datasets efficiently
- Ensuring data integrity across multiple related tables
- Optimizing query performance for complex joins and aggregations
- Balancing between normalization and query complexity

This project has not only reinforced our theoretical understanding of database systems but has also provided us with valuable hands-on experience in applying these concepts to a real-world application. The challenges we faced and overcame have significantly deepened our appreciation for the complexities and importance of effective database design and management in software development.