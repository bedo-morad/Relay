# Build stage: compile the jar with Maven + JDK
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Cache dependencies: pom first, source later — Docker reuses the layer
# unless pom.xml changes
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src
RUN mvn -q -B -DskipTests package

# Run stage: bare JRE, no Maven, no source code
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S relay && adduser -S relay -G relay
USER relay

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
