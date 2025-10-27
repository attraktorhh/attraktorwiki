# syntax=docker/dockerfile:1

ARG MEDIAWIKI_IMAGE_VERSION="1.43"
ARG MEDIAWIKI_RELEASE_BRANCH="REL1_43"

FROM mediawiki:${MEDIAWIKI_IMAGE_VERSION}

## Install additional packages, might be inefficient but makes debugging easier
RUN apt update && \
   apt install -y wget unzip iputils-ping nano mariadb-client

COPY --from=composer/composer:2.8-bin /composer /usr/bin/composer

USER www-data
ARG GERRIT_BASE_URL="https://gerrit.wikimedia.org/r/mediawiki/extensions"
ARG MEDIAWIKI_RELEASE_BRANCH

WORKDIR /var/www/html/extensions
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/CheckUser.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/intersection.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/Lockdown.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/MsUpload.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/NewUserNotif.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/PageForms.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/Renameuser.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/Variables.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/Widgets.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/PluggableAuth.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}/OpenIDConnect.git

WORKDIR /var/www/html
USER root

COPY ./configs/composer.local.json /var/www/html/composer.local.json
RUN chown www-data:www-data composer.local.json

ENV COMPOSER_HOME=/var/www/html/.composer
RUN composer update --no-dev --prefer-source

COPY ./skins/* /var/www/html/skins/
RUN chown -R www-data:www-data ./skins ./vendor

COPY ./scripts/* /usr/local/bin/
COPY ./configs/* /var/www/html/

RUN chown www-data:www-data /var/www/html/*
RUN chmod -R +x /usr/local/bin/*
