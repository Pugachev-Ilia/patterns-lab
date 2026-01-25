# Build stage: compile and produce runnable Spring Boot jar
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy only pom.xml first to maximize Docker layer cache for dependencies
COPY pom.xml .
RUN mvn -q -e -B -DskipTests dependency:go-offline

# Copy sources and build executable (repackaged) jar
COPY src ./src
RUN mvn -q -e -B -DskipTests package spring-boot:repackage

# Runtime stage: smaller image (JRE only), no build tools
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# curl is used by HEALTHCHECK; ca-certificates for outgoing HTTPS calls
# create a non-root user for safer runtime
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd -r app \
  && useradd -r -g app -d /app -s /usr/sbin/nologin app

# Copy the produced jar from build stage
COPY --from=build /workspace/target/demo-0.0.1.jar /app/app.jar

# Optional JVM tuning via env (ECS task definition can set it)
ENV JAVA_OPTS=""
EXPOSE 8080

# Container-level healthcheck (expects GET /health returns 200)
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=3 \
  CMD curl -fsS http://127.0.0.1:8080/health || exit 1

USER app
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]
