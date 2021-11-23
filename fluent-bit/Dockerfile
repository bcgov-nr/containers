FROM hashicorp/envconsul:0.12.0 as envconsul

# Builder
FROM registry.access.redhat.com/ubi8/ubi as builder

# Vars
ENV fbVersion 1.8.7
ENV fbURL https://github.com/fluent/fluent-bit/archive/refs/tags/v${fbVersion}.tar.gz

ENV flexVersion 2.6.4
ENV flexURL https://github.com/westes/flex/releases/download/v${flexVersion}/flex-${flexVersion}.tar.gz

ENV bisonVersion 3.8.2
ENV bisonURL http://ftp.gnu.org/gnu/bison/bison-${bisonVersion}.tar.gz

# RUN microdnf install cmake tar gzip gcc-c++ make m4 diffutils ca-certificates openssl openssl-devel
RUN dnf install cmake tar gzip gcc-c++ make m4 diffutils ca-certificates openssl openssl-devel -y

# Install flex (not available publicly, as of RHEL8)
WORKDIR /tmp/flex
RUN curl -L -s ${flexURL} | tar xzv -C . --strip-components 1 && \
	./configure --prefix=/usr/local/flex && \
	make && \
	make install && \
	ln -s /usr/local/flex/bin/flex /usr/bin

# Install bison (not available publicly, as of RHEL8)
WORKDIR /tmp/bison
RUN curl -L -s ${bisonURL} | tar xzv -C . --strip-components 1 && \
	./configure --prefix=/usr/local/bison --with-libiconv-prefix=/usr/local/libiconv/ && \
	make && \
	make install && \
	ln -s /usr/local/bison/bin/bison /usr/bin

# Download, decompress, install and clean up
WORKDIR /tmp/fluentbit
RUN curl -L -s ${fbURL} | tar xzv -C . --strip-components 1 && \
	cd build/ && \
	cmake ../ -DFLB_STREAM_PROCESSOR=Off && \
	make && \
	make install

# Deployment container
# FROM registry.access.redhat.com/ubi8/ubi-micro

# Copy binary and configuration
# COPY --from=builder /usr/lib64/libgcc_s.so.1 /usr/lib64
# COPY --from=builder /usr/local/bin/fluent-bit /usr/local/bin

# COPY --from=builder /etc/ssl/certs /etc/ssl/certs
# COPY --from=builder /usr/lib64/libssl.so.1.1 /usr/lib64
# COPY --from=builder /usr/lib64/libcrypto.so.1.1 /usr/lib64
# COPY --from=builder /usr/lib64/libz.so.1 /usr/lib64
# COPY --from=builder /usr/bin/openssl /usr/bin

# envconsul
COPY --from=envconsul /bin/envconsul /bin/envconsul

WORKDIR /usr/local/etc/fluent-bit/conf
COPY ./conf/ .

EXPOSE 2020/tcp

CMD [ \
        "envconsul", \
        "-config=/usr/local/etc/fluent-bit/conf/fluent-bit.hcl", \
        "fluent-bit", \
        "-c", \
        "/usr/local/etc/fluent-bit/conf/fluent-bit.conf" \
    ]