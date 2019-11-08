FROM  tomcat:9-jdk11-openjdk-slim
ARG WAR_FILE
RUN rm -rf /usr/local/tomcat/webapps/*
COPY vulnerapp_photos /root/vulnerapp_photos
COPY ${WAR_FILE} /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh","run"]
