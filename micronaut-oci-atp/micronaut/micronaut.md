# Build a Micronaut Application

## Introduction
In this lab you will build a Micronaut application locally that connects to Oracle Autonomous Database.

If at any point you run into trouble completing the steps, the full source code for the application can be cloned from Github using the following command to checkout the code:

    <copy>
    git clone -b lab3 https://github.com/graemerocher/micronaut-hol-example.git
    </copy>

If you were unable to setup the Autonomous Database and necessary cloud resources you can also checkout a version of the code that uses an in-memory database:

    <copy>
    git clone -b lab3-h2 https://github.com/graemerocher/micronaut-hol-example.git
    </copy>

Estimated Lab Time: 30 minutes

### Objectives

In this lab you will:

* Create Micronaut Data entities that map Oracle Database tables
* Define Micronaut Data repositories to implement queries
* Expose Micronaut Controllers as REST endpoints
* Populate Data on Application Startup
* Write tests for the Micronaut application
* Run the Micronaut application locally

### Prerequisites
- An Oracle Cloud account, Free Trial, LiveLabs or a Paid account

## Task 1: Create Micronaut Data entities that map Oracle Database tables

In the previous lab Flyway was used to setup the following schema:

    CREATE TABLE "PET" ("ID" VARCHAR(36),"OWNER_ID" NUMBER(19) NOT NULL,"NAME" VARCHAR(255) NOT NULL,"TYPE" VARCHAR(255) NOT NULL);
    CREATE TABLE "OWNER" ("ID" NUMBER GENERATED ALWAYS AS IDENTITY,"AGE" NUMBER(10) NOT NULL,"NAME" VARCHAR(255) NOT NULL);

As you can see a table called `OWNER` and a table called `PET` were created.

1. The first step is to define entity records that can be used to read data from the database tables.

    Using your favorite IDE create a `Owner.java` file under `src/main/java/example/atp/domain` which will represent the `Owner` class and looks like the following:

    ```java
    <copy>
    package example.atp.domain;

    import io.micronaut.core.annotation.Nullable;
    import io.micronaut.data.annotation.GeneratedValue;
    import io.micronaut.data.annotation.GeneratedValue.Type;
    import io.micronaut.data.annotation.Id;
    import io.micronaut.data.annotation.MappedEntity;

    @MappedEntity
    public record Owner(
        // The ID of the class uses a generated sequence value
        @Id @GeneratedValue(Type.IDENTITY) @Nullable Long id, 
        // Each component of the record maps to a database column
        String name, 
        int age) {
        // A secondary constructor makes it easier to instantiate 
        // new instances without an ID
        public Owner(String name, int age) {
            this(null, name, age);
        }
    }
    </copy>
    ```

    The `@MappedEntity` annotation indicates that the entity is mapped to a database table. By default, this will be a table using the same name as the class (in this case `owner`).

    The columns of the table are represented by each Java record component. In the above case an `id` column will be used to represent the primary key and by using `@GeneratedValue` this sets up the mapping to assume the use of an `identity` column in Autonomous Database.

    A seconary constructor is also defined to make it easier to construct instances of `Owner` without an `id` assigned (which will be assigned later by the database).

2.  Now define a `Pet.java` file that will represent the `Pet` entity to model a `pet` table under `src/main/java/example/atp/domain`:

    ```java
    <copy>
    package example.atp.domain;

    import java.util.UUID;

    import io.micronaut.core.annotation.Nullable;
    import io.micronaut.data.annotation.AutoPopulated;
    import io.micronaut.data.annotation.Id;
    import io.micronaut.data.annotation.MappedEntity;
    import io.micronaut.data.annotation.Relation;

    @MappedEntity
    public record Pet(
        // This class uses an auto populated UUID for the primary key
        @Id @AutoPopulated @Nullable UUID id, 
        String name, 
        // A relation is defined between Pet and Owner
        @Relation(Relation.Kind.MANY_TO_ONE)
        Owner owner, 
        // Optional columns can be defined by specifying Nullable
        @Nullable
        PetType type) {
            
        // Default values can be set with the Record initializer
        public Pet {
            if (type == null) {
                type = PetType.DOG;
            }
        }

        // Secondary record constructors make it easier to construct instances
        public Pet(String name, Owner owner) {
            this(null, name, owner, null);
        }

        public Pet(String name, Owner owner, PetType type) {
            this(null, name, owner, type);
        }

        public enum PetType {
            DOG,
            CAT
        }
    }

    </copy>
    ```

Note that the `Pet` class uses an automatically populated `UUID` as the primary key to demonstrate differing approaches to ID generation.

A relationship between the `Pet` class and the `Owner` class is also defined using the `@Relation(Relation.Kind.MANY_TO_ONE)` annotation, indicating this is a many-to-one relationship.

With that done it is time to move onto defining repository interfaces to implement queries.

## Task 2: Define Micronaut Data repositories to implement queries

Micronaut Data supports the notion of defining interfaces that automatically implement SQL queries for you at compilation time using the data repository pattern.

To take advantage of this feature of Micronaut Data define a new repository interface that extends from `CrudRepository` and is annotated with `@JdbcRepository` using the `ORACLE` dialect in a file called `OwnerRepository.java` under `src/main/java/example/atp/repositories`:

```java
<copy>
package example.atp.repositories;

import example.atp.domain.Owner;
import io.micronaut.data.jdbc.annotation.JdbcRepository;
import io.micronaut.data.model.query.builder.sql.Dialect;
import io.micronaut.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

// The @JdbcRepository annotation indicates the database dialect
@JdbcRepository(dialect = Dialect.ORACLE)
public interface OwnerRepository extends CrudRepository<Owner, Long> {

    @Override
    List<Owner> findAll();

    // This method will compute at compilation time a query such as
    // SELECT ID, NAME, AGE FROM OWNER WHERE NAME = ?
    Optional<Owner> findByName(String name);
}
</copy>
```

Note that if you were unable to setup Autonomous database and are using the H2 in-memory database you should use the `H2` dialect instead.

The `CrudRepository` interface takes 2 generic argument types. The first is the type of the entity (in this case `Owner`) and the second is the type of the ID (in this case `Long`).

The `CrudRepository` interface defines methods that allow you to create, read, update and delete (CRUD) entities from the database with the appropriate SQL inserts, selects, updates and deletes computed for you at compilation time. For more information see the Javadoc for [CrudRepository](https://micronaut-projects.github.io/micronaut-data/latest/api/io/micronaut/data/repository/CrudRepository.html).

You can define methods within the interface that perform JDBC queries and automatically handle all the intricate details for you such as defining correct transaction semantics (read-only transactions for queries), executing the query and mapping the result set to the `Owner` entity class you defined earlier.

The `findByName` method defined above will produce a query such as `SELECT ID, NAME, AGE FROM OWNER WHERE NAME = ?` automatically at compilation time.

For more information on query methods and the types of queries you can define see the [documentation for query methods](https://micronaut-projects.github.io/micronaut-data/latest/guide/index.html#querying) in the Micronaut Data documentation.

With the `OwnerRepository` in place let's create another repository and this time using a data transfer object (DTO) to perform an optimized query.

First create the DTO record in a file called `NameDTO.java` under `src/main/java/example/atp/domain`:

```java
<copy>
package example.atp.domain;

import io.micronaut.core.annotation.Introspected;

@Introspected
public record NameDTO(String name) {
}
</copy>
```

A DTO is a simple record that allows you to select only the columns a particular query needs, thus producing a more optimized query. Define another repository called `PetRepository` in a file called `PetRepository.java` for the `Pet` entity that uses the DTO under `src/main/java/example/atp/repositories`:

```java
<copy>
package example.atp.repositories;

import example.atp.domain.NameDTO;
import example.atp.domain.Pet;
import io.micronaut.data.annotation.Join;
import io.micronaut.data.jdbc.annotation.JdbcRepository;
import io.micronaut.data.model.query.builder.sql.Dialect;
import io.micronaut.data.repository.PageableRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@JdbcRepository(dialect = Dialect.ORACLE)
public interface PetRepository extends PageableRepository<Pet, UUID> {

    List<NameDTO> list();

    @Join("owner")
    Optional<Pet> findByName(String name);
}
</copy>
```

Take note of the `list` method that returns the DTO. This method will again be implemented for you at compilation time, but this time instead of retrieving all the columns of the `Pet` column it will only retrieve the `name` column and any other columns you may define.

The `findByName` method is also interesting as it uses another important feature of Micronaut Data which is the `@Join` annotation which allows you to [specify join paths](https://micronaut-projects.github.io/micronaut-data/latest/guide/#joinQueries) so that you retrieve exactly the data you need via database joins resulting in much more efficient queries.

With the data repositories in place let's move on to exposing REST endpoints.

## Task 3: Expose Micronaut Controllers as REST endpoints

REST endpoints in Micronaut are easy to write and are defined as [controllers (as per the MVC pattern)](https://docs.micronaut.io/latest/guide/index.html#httpServer).

Define a new `OwnerController` class in a file called `OwnerController.java` in `src/main/java/example/atp/controllers` like the following:

```java
<copy>
package example.atp.controllers;

import example.atp.domain.Owner;
import example.atp.repositories.OwnerRepository;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.scheduling.TaskExecutors;
import io.micronaut.scheduling.annotation.ExecuteOn;

import javax.validation.constraints.NotBlank;
import java.util.List;
import java.util.Optional;

@Controller("/owners")
@ExecuteOn(TaskExecutors.IO)
final class OwnerController {

    private final OwnerRepository ownerRepository;

    OwnerController(OwnerRepository ownerRepository) {
        this.ownerRepository = ownerRepository;
    }

    @Get("/")
    List<Owner> all() {
        return ownerRepository.findAll();
    }

    @Get("/{name}")
    Optional<Owner> byName(@NotBlank String name) {
        return ownerRepository.findByName(name);
    }
}
</copy>
```

A controller class is defined with the `@Controller` annotation which you can use to define the root URI that the controller maps to (in this case `/owners`).

Notice too the `@ExecuteOn` annotation which is used to tell Micronaut that the controller performs I/O communication with a database and therefore operations should [run on the I/O thread pool](https://docs.micronaut.io/latest/guide/index.html#reactiveServer).

The `OwnerController` class uses [Micronaut dependency injection](https://docs.micronaut.io/latest/guide/index.html#ioc) to obtain a reference to the `OwnerRepository` repository interface you defined earlier and is used to implement two endpoints:

* `/` - The root endpoint lists all the owners
* `/{name}` - The second endpoint uses a [URI template](https://docs.micronaut.io/latest/guide/index.html#routing) to allow looking up an owner by name. The value of the URI variable `{name}` is provided as a parameter to the `byName` method.

Next define another REST endpoint called `PetController` in a file called `PetController.java` under `src/main/java/example/atp/controllers`:

```java
<copy>
package example.atp.controllers;

import example.atp.domain.NameDTO;
import example.atp.domain.Pet;
import example.atp.repositories.PetRepository;
import io.micronaut.http.annotation.Controller;
import io.micronaut.http.annotation.Get;
import io.micronaut.scheduling.TaskExecutors;
import io.micronaut.scheduling.annotation.ExecuteOn;

import java.util.List;
import java.util.Optional;

@ExecuteOn(TaskExecutors.IO)
@Controller("/pets")
final class PetController {

    private final PetRepository petRepository;

    PetController(PetRepository petRepository) {
        this.petRepository = petRepository;
    }

    @Get("/")
    List<NameDTO> all() {
        return petRepository.list();
    }

    @Get("/{name}")
    Optional<Pet> byName(String name) {
        return petRepository.findByName(name);
    }
}
</copy>
```

This time the `PetRepository` is injected to expose a list of pets and pets by name.

## Task 4: Populate Data on Application Startup

The next step is to populate some application data on startup. To do this you can use [Micronaut application events](https://docs.micronaut.io/latest/guide/index.html#contextEvents).

Modify your `src/main/java/example/atp/Application.java` class to look like the following:

```java
<copy>
package example.atp;

import example.atp.domain.Owner;
import example.atp.domain.Pet;
import example.atp.repositories.OwnerRepository;
import example.atp.repositories.PetRepository;
import io.micronaut.context.event.StartupEvent;
import io.micronaut.runtime.Micronaut;
import io.micronaut.runtime.event.annotation.EventListener;
import jakarta.inject.Singleton;

import javax.transaction.Transactional;
import java.util.Arrays;

@Singleton
public class Application {
    private final OwnerRepository ownerRepository;
    private final PetRepository petRepository;

    Application(OwnerRepository ownerRepository, PetRepository petRepository) {
        this.ownerRepository = ownerRepository;
        this.petRepository = petRepository;
    }

    public static void main(String[] args) {
        Micronaut.run(Application.class);
    }

    @EventListener
    @Transactional
    void init(StartupEvent event) {
        // clear out any existing data
        petRepository.deleteAll();
        ownerRepository.deleteAll();
        
        // create the data
        Iterable<Owner> owners = ownerRepository.saveAll(List.of(
                new Owner("Fred", 45),  new Owner("Barney", 40)
        ));
        List<Pet> pets = new ArrayList<>();
        for(Owner person : owners) {
            // Use Java 17 switch expressions to simplify logic
            switch(person.name()) {
                case "Fred" -> {
                    var dino = new Pet("Dino", person);
                    var bp = new Pet("Baby Puss", person, PetType.CAT);
                    pets.addAll(List.of(dino, bp));
                }
                case "Barney" -> 
                    pets.add(new Pet("Hoppy", person));
            }
        }

        petRepository.saveAll(pets);
    }
}
</copy>
```

Note that the constructor is modified to dependency inject the repository definitions so data can be persisted.

Finally the `init` method is annotated with `@EventListener` with an argument to receive a `StartupEvent`. This event is called
once the application is up and running and can be used to persist data when your application is ready to do so.

The rest of the example demonstrates saving a few entities using the [saveAll](https://micronaut-projects.github.io/micronaut-data/latest/api/io/micronaut/data/repository/CrudRepository.html#saveAll-java.lang.Iterable-) method of the [CrudRepository](https://micronaut-projects.github.io/micronaut-data/latest/api/io/micronaut/data/repository/CrudRepository.html) interface.

Notice that `javax.transaction.Transactional` is declared on the method which ensures that Micronaut Data wraps the execution of the `init` method in a JDBC transaction that is rolled back if an exception occurs during the execution of the method.

If you wish to monitor the SQL queries that Micronaut Data performs you can open up `src/main/resources/logback.xml` and add the following line to enable SQL logging:

```xml
<copy>
<logger name="io.micronaut.data.query" level="debug" />
</copy>
```

## Task 5: Run Integration Tests for the Micronaut Application

The application will already have been setup with a single test that tests the application can startup successfully (and hence will test the logic of the `init` method defined in the previous section).

To execute your tests, if you are using Gradle use the `test` task to execute your tests:

```bash
<copy>
./gradlew test
</copy>
```

If you're using Maven use the `test` goal:

```bash
<copy>
./mvnw test
</copy>
```

When running tests a Docker container will automatically be started to run [Oracle XE container images](https://hub.docker.com/r/gvenzl/oracle-xe) for the application using the [Micronaut Test Resources](https://micronaut-projects.github.io/micronaut-test-resources/latest/guide/) for [Testcontainers](https://www.testcontainers.org/).

Note that to improve productivity when running tests you can start a shared test resources server by running the Gradle `startTestResourcesService` command which can later by stopped with `stopTestResourcesService`:

```bash
<copy>
./gradlew startTestResourcesService
</copy>
```

If you are using Maven you can use `mvn mn:start-test-resources-service`:


```bash
<copy>
./mvnw mn:start-test-resources-service
</copy>
```

## Task 6: Run the Micronaut application locally

To run the application locally if you are using Gradle use the `run` task to start the application:

```bash
<copy>
./gradlew run -t
</copy>
 ```

 Note that the `-t` flag activates continuous build mode for Gradle which will automatically restart the server whne you make changes to the application source code.

Alternatively if you are using Maven use the `mn:run` goal:

```bash
<copy>
./mvnw mn:run
</copy>
 ```

In both cases like with testing a Docker container will automatically be started to run [Oracle XE container images](https://hub.docker.com/r/gvenzl/oracle-xe) for the application using the [Micronaut Test Resources](https://micronaut-projects.github.io/micronaut-test-resources/latest/guide/) for [Testcontainers](https://www.testcontainers.org/). 

You can now access [http://localhost:8080/pets](http://localhost:8080/pets) for the `/pet` endpoint and [http://localhost:8080/owners](http://localhost:8080/owners) for the `/owners` endpoint. For example:

```bash
curl -i http://localhost:8080/pets
HTTP/1.1 200 OK
Date: Thu, 20 Aug 2020 15:12:47 GMT
Content-Type: application/json
content-length: 55
connection: keep-alive

[{"name":"Dino"},{"name":"Baby Puss"},{"name":"Hoppy"}]
```

## Task 6: Run the Micronaut application with Autonomous Database

To run the application and connect to the previously configured Autonomous Database instance you need to active the `oraclecloud` environment locally first by setting the `MICRONAUT_ENVIRONMENTS` environment variable, for example:

```bash
<copy>
MICRONAUT_ENVIRONMENTS=oracecloud ./gradlew run -t
</copy>
 ```

 Or for Maven:

 ```bash
<copy>
MICRONAUT_ENVIRONMENTS=oracecloud ./mvnw mn:run
</copy>
 ```

 This will result in the configuration defined in `src/main/resources/application-oraclecloud.yml` loading and the application connecting to the instance of Autonomous Database instead of a locally running Docker container.

## Learn More
* [Micronaut Documentation](https://micronaut.io/documentation.html)
* [Micronaut Data Documentation](https://micronaut-projects.github.io/micronaut-data/latest/guide/index.html)

You may now *proceed to the next lab*.

## Acknowledgements
- **Owners** - Graeme Rocher, Architect, Oracle Labs - Databases and Optimization
- **Contributors** - Chris Bensen, Todd Sharp, Eric Sedlar
- **Last Updated By** - Kay Malcolm, DB Product Management, August 2020
