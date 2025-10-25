# Upgrading

## Upgrade path

- 1.23
- 1.27
- 1.31
- 1.34
- 1.35
- 1.39
- 1.42
- 1.43
- future LTS versions...

## Common Commands

- bring down and up the containers

  ```bash
  docker compose down && docker compose up -d
  ```

- bring down and up the wiki

  ```bash
  docker compose down mediawiki && docker compose up mediawiki -d    
  ```

- run the MediaWiki database update script

  ```bash
  docker compose exec -u www-data mediawiki php maintenance/update.php --quick
  ```

- run the MediaWiki database update script (1.40 and later)

  ```bash
  docker compose exec -u www-data mediawiki php maintenance/run.php update --quick
  ```

- Backup all the files (just to be sure)

  ```bash
  docker compose exec mediawiki tar czf attraktorwiki.REL1_27.fs.tar.gz /var/www/html && docker compose cp mediawiki:/var/www/html/attraktorwiki.REL1_27.fs.tar.gz ./backups/ && docker compose exec mediawiki rm /var/www/html/attraktorwiki.REL1_27.fs.tar.gz
  ```

- Backup the database

  ```bash
  docker compose exec mediawikidb mysqldump -u attraktorwiki -p4fnk455s --default-character-set=binary --single-transaction attraktorwiki | gzip > ./backups/attraktorwiki.REL1_27.sql.gz
  ```

- setup database

  ```bash
  docker compose exec mediawikidb sh -lc 'mysqladmin -u root -prootsecret drop attraktorwiki'

  docker compose exec mediawikidb sh -lc 'mysqladmin -u attraktorwiki -p${SERVICE_PASSWORD_DBUSERPW} create attraktorwiki --default-character-set=binary'
  ```

- restore database backup

  ```bash
  source '.env' && gunzip < ./backups/attraktorwiki.REL1_27.sql.gz | docker compose exec -T mediawikidb mysql -u attraktorwiki -p${SERVICE_PASSWORD_DBUSERPW} attraktorwiki
  ```

## Upgrade steps

- Backup the database (IMPORTANT)
- Create new branch for desired MediaWiki version (ideally LTS version e.g. `REL1_43`).
- Update `MEDIAWIKI_RELEASE_BRANCH` in `Dockerfile` to desired version (e.g. `REL1_43`).
- Update `MEDIAWIKI_IMAGE_VERSION` in `Dockerfile` to desired version (e.g. `1.43`).
- rebuild with `docker compose down && docker compose build && docker compose up -d`
- verify all extensions were properly cloned during build
- run updater script to update the database schema
- test the wiki functionality
- Backup the database (IMPORTANT)
- next version!
