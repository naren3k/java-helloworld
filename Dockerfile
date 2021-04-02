#
# Build stage
#
FROM maven:3.6.0-jdk-11-slim AS build
#USER root
#COPY ZScalarCARoot.cer $JAVA_HOME/jre/lib/security
#RUN  cd $JAVA_HOME/jre/lib/security  && keytool -keystore cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias ZScalarCARoot -file ZScalarCARoot.cer
#COPY ZScalarCARoot.cer /usr/local/share/ca-certificates
#RUN update-ca-certificates

COPY src /home/app/src
COPY pom.xml /home/app
#COPY web.xml /home/app
#COPY settings.xml /tmp/settings.xml
WORKDIR /home/app/
RUN mvn clean install -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true  -f /home/app/pom.xml
#RUN mvn liberty:dev -Dmaven.wagon.http.ssl.insecure=true -Dmaven.wagon.http.ssl.allowall=true -Dmaven.wagon.http.ssl.ignore.validity.dates=true 

#
# Package stage
#
#FROM tomcat:8.0-alpine
#FROM tomcat:10.0-jdk11-openjdk
#LABEL maintainer=”naren.karanam@tcs.com”
#COPY --from=build /home/app/target/webapp-0.0.1-SNAPSHOT.war $CATALINA_HOME/webapps/webapp.war
#####ADD target/webapp-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/
#EXPOSE 8080
#CMD ["catalina.sh", "run"]

FROM websphere-liberty:kernel
USER root
COPY --chown=1001:0  --from=build /home/app/target/*.war  /config/dropins/
COPY --chown=1001:0  server.xml /config/
#RUN installUtility install --acceptLicense defaultServer
RUN configure.sh