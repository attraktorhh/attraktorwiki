# syntax=docker/dockerfile:1

ARG MEDIAWIKI_IMAGE_VERSION="1.43"
ARG MEDIAWIKI_RELEASE_BRANCH="REL1_43"

FROM mediawiki:${MEDIAWIKI_IMAGE_VERSION}

RUN apt update && \
   apt install -y wget unzip iputils-ping nano

COPY --from=composer/composer:2.8-bin /composer /usr/bin/composer

ARG MEDIAWIKI_RELEASE_BRANCH

ENV COMPOSER_HOME=/var/www/html/.composer

COPY ./configs/composer.local.json /var/www/html/composer.local.json
RUN chown root:www-data /var/www/html/composer.local.json && chmod 640 /var/www/html/composer.local.json

COPY ./configs/LocalSettings.php /var/www/html/LocalSettings.php
RUN chown root:www-data /var/www/html/LocalSettings.php && chmod 640 /var/www/html/LocalSettings.php

COPY ./configs/.htaccess /var/www/html/.htaccess
RUN chown root:www-data /var/www/html/.htaccess && chmod 640 /var/www/html/.htaccess

COPY ./skins /var/www/html/skins
RUN chown -R www-data:www-data /var/www/html/skins/*

RUN chown -R www-data:www-data /var/www/html/vendor

USER www-data

WORKDIR /var/www/html/extensions
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/CheckUser.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/intersection.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/Lockdown.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/MsUpload.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/NewUserNotif.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/PageForms.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/Renameuser.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/Variables.git
RUN git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/Widgets.git

WORKDIR /var/www/html/extensions/Widgets
RUN composer update --no-dev

WORKDIR /var/www/html

RUN composer update --no-dev --prefer-source

USER root
