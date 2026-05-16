FROM alpine:3.20

ARG SCCACHE_VERSION=0.15.0

LABEL org.opencontainers.image.title="sccache-dist" \
      org.opencontainers.image.description="sccache-dist runtime image for EEHUB scheduler and build-server" \
      org.opencontainers.image.source="https://github.com/zjm54321/sccache-dist"

RUN apk add --no-cache \
    bubblewrap \
    libcap \
    ca-certificates

COPY dist/sccache-dist /usr/local/bin/sccache-dist

RUN chmod 0755 /usr/local/bin/sccache-dist \
    && /usr/bin/bwrap --version \
    && /usr/local/bin/sccache-dist --help >/dev/null \
    && /usr/local/bin/sccache-dist scheduler --help >/dev/null \
    && /usr/local/bin/sccache-dist server --help >/dev/null

ENTRYPOINT ["/usr/local/bin/sccache-dist"]
CMD ["--help"]
