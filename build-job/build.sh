
# Fix problem with Docker
sudo usermod -aG docker ubuntu
sudo chmod 666 /var/run/docker.sock

# Build APP and create image
./mvnw clean package 
docker build -t petclinic-app:${BUILD_NUMBER} -f- .<<EOF
FROM openjdk:8-jdk-alpine
COPY target/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar /app.jar
CMD  [ "java", "-jar", "-Dspring.profiles.active=mysql", "/app.jar"]
EXPOSE 8080
EOF

