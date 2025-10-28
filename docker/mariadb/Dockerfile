# syntax=docker/dockerfile:1

ARG MARIADB_IMAGE_VERSION="11.8"

FROM mariadb:${MARIADB_IMAGE_VERSION}

# Probably overkill to use Dockerfile for this but coolify doesn't link file volumes properly.
# so this is needed to copy the backup scripts into the container.
COPY ./scripts/* /usr/local/bin/
RUN chmod -R +x /usr/local/bin/*
