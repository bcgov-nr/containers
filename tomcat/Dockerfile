FROM registry.access.redhat.com/ubi8/ubi as builder

RUN dnf update -y

# Vars
ARG tomcatVersion=8.0.51
ENV TOMCAT_VERSION ${tomcatVersion}

WORKDIR /tmp/tomcat

# HACK: To extract the major version, to make the URL work
RUN export TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-"${TOMCAT_VERSION:0:1}"/v"${TOMCAT_VERSION}"/bin/apache-tomcat-"${TOMCAT_VERSION}".tar.gz && \
    curl -L -s $TOMCAT_URL | tar xzv -C . --strip-components 1 && \
    rm -rf /tmp/tomcat/webapps/*

# Deployment container
FROM registry.access.redhat.com/ubi8/ubi-micro

# Copy tomcat
COPY --from=builder /tmp/tomcat /usr/local/tomcat

# Create folder for JRE/JDK, to be provided via volume mount
RUN mkdir /usr/local/tomcat/jre

EXPOSE 8443

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]