# Building Native Executables with Micronaut & GraalVM

## Introduction
In this lab you will learn how to turn your application into a native executable with GraalVM Native Image.

Estimated Lab Time: 20 minutes

Watch the video below for a quick walk-through of the lab.
[Build a GraalVM Native Image](videohub:1_xp83wilj)

### Objectives

In this lab you will:
* Understand the benefits and tradeoffs with AOT compilation
* Build a native executable from your Micronaut application
* Run the executable on a VM or with Docker

### Prerequisites
- Access to your project instance

## Overview of Native Image

[GraalVM Native Image](https://www.graalvm.org/reference-manual/native-image/) is a technology that allows performing a closed world static analysis of a Java application and turning the Java application into a native executable designed to execute on a specific target environment.

Whilst building a native executable can take some time, the benefits include a dramatic reduction in startup time and reduced overall memory consumption, both of which can significantly reduce the cost of running Cloud applications over time.

## Building a Native Executable with Gradle

If you are using Gradle and the GraalVM SDK with Native Image installed (Native Image is an optional component installable via `gu install native-image`), then building a native executable is trivial.

Open up the Terminal pane and run the following command:

    <copy>
    ./gradlew nativeCompile
    </copy>

After some time the native executable will be built to `build/native-image/application`.

You can now run the native executable from Terminal:

    <copy>
    MICRONAUT_ENVIRONMENTS=oraclecloud ./build/native/nativeCompile/example-atp
    </copy>

## Building a Native Executable with Maven

If you are using Maven and the GraalVM SDK with Native Image installed (Native Image is an optional component installable via `gu install native-image`), then building a native executable is trivial.

Open up the Terminal pane and run the following command:

    <copy>
    ./mvnw clean package -Dpackaging=native-image
    </copy>

After some time the native executable with be built into the `target/native-image` directory.

You can now run the native executable from Terminal:

    <copy>
    MICRONAUT_ENVIRONMENTS=oraclecloud ./target/example
    </copy>

You may now *proceed to the next lab*.

### Acknowledgements
- **Owners** - Graeme Rocher, Architect, Oracle Labs - Databases and Optimization
- **Contributors** - Palo Gressa, Todd Sharp, Eric Sedlar
