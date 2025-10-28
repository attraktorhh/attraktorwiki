# syntax=docker/dockerfile:1

ARG MEDIAWIKI_IMAGE_VERSION="1.43"
ARG MEDIAWIKI_RELEASE_BRANCH="REL1_43"

FROM mediawiki:${MEDIAWIKI_IMAGE_VERSION}

## Install additional packages, might be inefficient but makes debugging easier
RUN apt update && apt install -y iputils-ping nano zip unzip

# Install Composer to manage SemanticMediaWiki extensions
COPY --from=composer/composer:2.8-bin /composer /usr/bin/composer

# Install MediaWiki Extensions from Git repositories which are not on packagist
USER www-data
ARG MEDIAWIKI_RELEASE_BRANCH
ARG GERRIT_BASE_URL="https://gerrit.wikimedia.org/r/mediawiki/extensions"
ARG GIT_CLONE="git clone --recurse-submodules -b ${MEDIAWIKI_RELEASE_BRANCH} ${GERRIT_BASE_URL}"

WORKDIR /var/www/html/extensions
RUN ${GIT_CLONE}/CheckUser.git
RUN ${GIT_CLONE}/intersection.git
RUN ${GIT_CLONE}/Lockdown.git
RUN ${GIT_CLONE}/MsUpload.git
RUN ${GIT_CLONE}/NewUserNotif.git
RUN ${GIT_CLONE}/PageForms.git
RUN ${GIT_CLONE}/Renameuser.git
RUN ${GIT_CLONE}/Variables.git
RUN ${GIT_CLONE}/Widgets.git
RUN ${GIT_CLONE}/PluggableAuth.git
RUN ${GIT_CLONE}/OpenIDConnect.git

WORKDIR /var/www/html
USER root

COPY ./configs/composer.local.json /var/www/html/composer.local.json
RUN chown www-data:www-data composer.local.json

# Install composer dependencies for MediaWiki and extensions
ENV COMPOSER_HOME=/var/www/html/.composer
RUN composer update --no-dev --prefer-source

COPY ./skins/* /var/www/html/skins/
RUN chown -R www-data:www-data ./skins ./vendor

COPY ./scripts/* /usr/local/bin/
COPY ./configs/* /var/www/html/

RUN chown www-data:www-data /var/www/html/*
RUN chmod -R +x /usr/local/bin/*
