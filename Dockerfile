FROM eclipse-temurin:17-jre-jammy

# Set application directory
WORKDIR /deployments

# Copy the precompiled Quarkus files and dependencies
COPY quarkus-run.jar /deployments/
COPY app/ /deployments/app/
COPY lib/ /deployments/lib/
COPY quarkus/ /deployments/quarkus/
COPY config/ /deployments/config/

# Expose the default port
EXPOSE 8180

# Run Quarkus app, dynamically binding to the port Render expects (or defaulting to 8180)
CMD java -Dquarkus.http.host=0.0.0.0 -Dquarkus.http.port=${PORT:-8180} -jar quarkus-run.jar
