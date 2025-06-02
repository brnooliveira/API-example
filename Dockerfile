############################
# 1️⃣  Build stage
############################
FROM maven:3.9.7-eclipse-temurin-21 AS build
WORKDIR /app

# Copie apenas o pom.xml primeiro p/ aproveitar cache de dependências
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Agora o código-fonte
COPY src ./src
RUN mvn -B clean package -DskipTests   # gera target/app.jar

############################
# 2️⃣  Runtime stage
############################
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copia o jar gerado na fase anterior
COPY --from=build /app/target/*.jar app.jar

# Ajustes de runtime
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"
EXPOSE 8080
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar app.jar"]
