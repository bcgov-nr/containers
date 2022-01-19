FROM registry.access.redhat.com/ubi8/ubi as builder

RUN dnf update -y
RUN dnf install java-1.8.0-openjdk --nodocs -y

# Vars
# ARG tomcatVersion=8.0.17
# ENV TOMCAT_VERSION ${tomcatVersion}
# ENV TOMCAT_MAJOR_VERSION="${TOMCAT_VERSION:0:1}"
# ENV TOMCAT_URL https://archive.apache.org/dist/tomcat/tomcat-"${TOMCAT_MAJOR_VERSION}"/v"${TOMCAT_VERSION}"/bin/"${TOMCAT_VERSION}".tar.gz

WORKDIR /usr/share
# RUN curl -L -s ${TOMCAT_URL} | tar xzv -C . --strip-components 1 