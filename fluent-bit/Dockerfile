FROM fluent/fluent-bit:1.7.9 as fluent-bit
FROM hashicorp/envconsul:0.12.0 as envconsul

FROM gcr.io/distroless/cc-debian10

# Certificates
COPY --from=fluent-bit /usr/share/ca-certificates/ /usr/share/ca-certificates/
COPY --from=fluent-bit /etc/ssl/ /etc/ssl/

# SSL stuff
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/*sasl* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libcrypto.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libssl.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libz* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libz* /lib/x86_64-linux-gnu/

# For systemd
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libsystemd* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libselinux.so* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/liblzma.so* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/liblz4.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libgcrypt.so* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libpcre.so* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libgpg-error.so* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libpq.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libgssapi* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libldap* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libkrb* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libk5crypto* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/liblber* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libgnutls* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libp11-kit* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libidn2* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libunistring* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libtasn1* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libnettle* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libhogweed* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libgmp* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /usr/lib/x86_64-linux-gnu/libffi* /usr/lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libcom_err* /lib/x86_64-linux-gnu/
COPY --from=fluent-bit /lib/x86_64-linux-gnu/libkeyutils* /lib/x86_64-linux-gnu/

# Fluent Bit
COPY --from=fluent-bit /fluent-bit /fluent-bit

# envconsul
COPY --from=envconsul /bin/envconsul /usr/local/bin/envconsul

# Configuration files
COPY ./conf/ /fluent-bit/etc/

# Entry point
EXPOSE 2020
CMD [ \
        "envconsul", \
        "-config=/fluent-bit/etc/fluent-bit.hcl", \
        "/fluent-bit/bin/fluent-bit", \
        "-c", \
        "/fluent-bit/etc/fluent-bit.conf" \
    ]
