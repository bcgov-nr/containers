FROM registry.access.redhat.com/ubi8/ubi as builder

RUN dnf update -y

# Vars
ARG tomcatVersion=8.0.51
ENV TOMCAT_VERSION ${tomcatVersion}

ARG jreVersion=8u192
ENV JRE_VERSION ${jreVersion}

WORKDIR /tmp/jre

# HACK: Cuz Oracle requires login to get JRE(s)
COPY ./files/JRE/jre-"${JRE_VERSION}"-linux-x64.tar.gz .
RUN tar xzvf jre-"${JRE_VERSION}"-linux-x64.tar.gz -C . --strip-components 1 && \
    rm jre-"${JRE_VERSION}"-linux-x64.tar.gz && \ 
    rm -rf man

WORKDIR /tmp/tomcat

# HACK: To extract the major version, to make the URL work
RUN export TOMCAT_URL=https://archive.apache.org/dist/tomcat/tomcat-"${TOMCAT_VERSION:0:1}"/v"${TOMCAT_VERSION}"/bin/apache-tomcat-"${TOMCAT_VERSION}".tar.gz && \
    curl -L -s $TOMCAT_URL | tar xzv -C . --strip-components 1 
    # && \
    #  rm -rf /tmp/tomcat/webapps/*

# Deployment container
FROM registry.access.redhat.com/ubi8/ubi-micro

# Copy binary and configuration
COPY --from=builder /tmp/tomcat /usr/local/tomcat
COPY --from=builder /tmp/jre /usr/local/tomcat/jre
COPY files/scripts/setenv.sh /usr/local/tomcat/bin

EXPOSE 8443

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]