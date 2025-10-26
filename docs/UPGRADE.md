# Upgrading

## Upgrade path

- 1.23.9 (initial attraktorwiki version)
- 1.27.4
- 1.31.0
- 1.34.0
- 1.35.0
- 1.39.0
- 1.42.0
- 1.43.1
- 1.43.0
- future LTS versions...

## Common Commands

- bring down and up the wiki

  ```bash
  docker compose down mediawiki && docker compose up mediawiki -d    
  ```

- run the MediaWiki database update script

  ```bash
  docker compose exec mediawiki php maintenance/update.php --quick
  ```

- run the MediaWiki database update script (1.40 and later)

  ```bash
  docker compose exec -u www-data mediawiki php maintenance/run.php update --quick
  ```

- Backup images

  ```shell
  docker compose exec mediawiki tar -cz -f /mnt/backups/REL1_27.images.tar.gz -C /var/www/html images
  ```

- Backup database

  ```bash
  docker compose exec mariadb bash -lc 'mariadb-dump -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --default-character-set=binary --single-transaction ${MYSQL_DATABASE}' | gzip > ./backups/attraktorwiki/REL1_27.db.sql.gz
  ```

- restore database

  ```bash
  gunzip < ./backups/attraktorwiki/REL1_23.db.sql.gz | docker compose exec -T mariadb bash -lc 'mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE}'
  ```

- Restore images

  ```shell
  docker compose exec mediawiki tar -xz -f /mnt/backups/REL1_23.images.tar.gz -C /var/www/html/
  ```

- setup database
  - older versions of mariadb/mysql

    ```bash
    docker compose exec mariadb sh -lc 'mysqladmin -u root -p${SERVICE_PASSWORD_DBROOTPW} drop attraktorwiki'

    docker compose exec mariadb sh -lc 'mysqladmin -u attraktorwiki -p${SERVICE_PASSWORD_DBUSERPW} create attraktorwiki --default-character-set=binary'
    ```

  - newer versions of mariadb/mysql

    ```bash
    docker compose exec mariadb sh -lc 'mariadb-admin -u root -p${MYSQL_PASSWORD} drop ${MYSQL_DATABASE}'

    docker compose exec mariadb sh -lc 'mariadb-admin -u ${MYSQL_USER} -p${SERVICE_PASSWORD_DBUSERPW} create ${MYSQL_DATABASE} --default-character-set=binary'
    ```

## Upgrade steps

- Backup the database (IMPORTANT)
- Create new branch for desired MediaWiki version (ideally LTS version e.g. `REL1_43`).
- Update `MEDIAWIKI_RELEASE_BRANCH` in `Dockerfile` to desired version (e.g. `REL1_43`).
- Update `MEDIAWIKI_IMAGE_VERSION` in `Dockerfile` to desired version (e.g. `1.43`).
- rebuild with `docker compose down && docker compose build && docker compose up -d`
- verify all extensions were properly cloned during build
- run updater script to update the database schema
- run `php extensions/SemanticMediaWiki/maintenance/rebuildData.php -v`
- test the wiki functionality
- Backup the database (IMPORTANT)
- next version!
