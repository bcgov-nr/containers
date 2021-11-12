FROM hashicorp/envconsul:0.12.0 as envconsul
FROM fluent/fluent-bit:1.7.9

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
