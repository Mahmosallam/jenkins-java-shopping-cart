#--------------build stage-----------------
FROM maven:3.6.3-jdk-8 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

#-----------------run stage-----------------
FROM openjdk:8-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8070
ENTRYPOINT ["java", "-jar", "app.jar"]
