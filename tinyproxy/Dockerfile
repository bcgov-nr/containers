# Builder
FROM registry.access.redhat.com/ubi8/ubi-minimal as builder

# Vars
ENV version 1.10.0
ENV url https://github.com/tinyproxy/tinyproxy/releases/download/${version}/tinyproxy-${version}.tar.gz

# Download, decompress, install and clean up
WORKDIR /tmp/tinyproxy
RUN microdnf install gcc make gzip tar && \
	curl -L -s ${url} | tar xzv -C . --strip-components 1 && \
	./configure && \
	make && \
	make install

# Deployment container
FROM registry.access.redhat.com/ubi8/ubi-micro

# Copy binary and configuration
COPY --from=builder /usr/local/bin/tinyproxy /usr/local/bin
COPY ./conf/ /usr/local/etc/tinyproxy/

# Startup, non-privileged user
EXPOSE 23128/tcp
USER 1001
CMD ["tinyproxy", "-d"]
