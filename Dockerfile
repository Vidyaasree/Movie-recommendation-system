FROM tomcat:9.0-jdk17

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy everything to ROOT
COPY . /usr/local/tomcat/webapps/ROOT/

# Debug: Check files
RUN echo "=== Files in ROOT ===" && \
    ls -la /usr/local/tomcat/webapps/ROOT/

EXPOSE 8080

CMD ["catalina.sh", "run"]