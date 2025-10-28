# syntax=docker/dockerfile:1

ARG MARIADB_IMAGE_VERSION="11.8"

FROM mariadb:${MARIADB_IMAGE_VERSION}

# Probably overkill but coolify doesn't link file volumes properly.
COPY ./scripts/* /usr/local/bin/
RUN chmod -R +x /usr/local/bin/*
