FROM openjdk:8-jdk-alpine as builder

# Vars
ENV amqVersion 5.15.0
ENV amqURL https://archive.apache.org/dist/activemq/${amqVersion}/apache-activemq-${amqVersion}-bin.tar.gz
ENV amqLocation /sw_ux/activemq

# RUN mkdir /sw_ux

# Download, decompress, install and clean up
WORKDIR ${amqLocation}
RUN apk add --no-cache tar curl bash && \
    curl -L -s ${amqURL} | tar xzv -C . --strip-components 1 && \
    ln -s ${amqLocation}/bin/activemq /usr/local/bin

# Copy binary and configuration
COPY ./bin/ ${amqLocation}
COPY ./conf/ ${amqLocation}

# EXPOSE 3000
CMD ["activemq", "console"]