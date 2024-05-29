FROM bellsoft/liberica-openjdk-alpine:17

ARG JAR_FILE=be/issue_tracker/build/libs/*.jar

COPY ${JAR_FILE} app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app.jar"]