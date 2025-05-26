# ---- Stage 1: Build the application ----
FROM gradle:8.13-jdk17 AS builder

WORKDIR /app

# Copy only necessary files
COPY build.gradle settings.gradle ./
COPY gradle gradle
COPY src src

# Pre-fetch dependencies and build using system Gradle
RUN gradle dependencies --no-daemon
RUN gradle bootJar --no-daemon

# ---- Stage 2: Run the application ----
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
