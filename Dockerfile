# Use a base image with JDK
FROM eclipse-temurin:23-jdk-alpine as builder

# Set the working directory in the container
WORKDIR /app

# Copy the build.gradle and gradle wrapper files
COPY build.gradle .
COPY settings.gradle .
COPY gradlew gradlew
COPY gradle/ gradle/

RUN chmod +x gradlew
# Download dependencies using Gradle
RUN ./gradlew build --no-daemon


# Copy the source code
COPY src ./src

# Build the application (this will compile the code and package it)
RUN ./gradlew bootJar --no-daemon --stacktrace

# Use a minimal JRE base image to run the app
FROM eclipse-temurin:23-jdk-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the built JAR file from the builder
COPY --from=builder /app/build/libs/helloworld-0.0.1-SNAPSHOT.jar app.jar

# Expose the port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
