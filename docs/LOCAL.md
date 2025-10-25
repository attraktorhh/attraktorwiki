# Local Development with Docker Compose

- Prerequisites
  - Docker and Docker Compose installed
  - Database dump in `./backup/` compatible with MediaWiki 1.43 (e.g. `attraktorwiki.REL1_43.sql.gz`)
  - Backup of `images/` in `./backup/` (or directly in `./images/` from previous installation)

1. Copy `.env.dist` to `.env` and adjust environment variables as needed.

   ```shell
   cp .env.dist .env
   ```

2. Build and start the containers:

   ```shell
   docker compose up -d --build
   ```

3. import database dump from backup file in `./backup/` folder:

   ```shell
   source '.env' && gunzip < ./backup/attraktorwiki.REL1_43.sql.gz | docker compose exec -T mariadb mariadb -u attraktorwiki -p${SERVICE_PASSWORD_DBUSERPW} attraktorwiki
   ```

4. Import images from backup files in `./backup/` folder and set proper permissions:

   - If images are in `./backup/images/`:

     ```shell
     docker compose cp ./backup/images/. mediawiki:/var/www/html/images/
     ```

   - in any case, set proper ownership:

      ```shell
      docker compose exec mediawiki chown -R www-data:www-data /var/www/html/images
      ```

5. Run MediaWiki update script:

   ```shell
   docker compose exec mediawiki php maintenance/run.php update --quick
   ```

6. Run pending Jobs:

   ```shell
   docker compose exec mediawiki php maintenance/run.php runJobs
   ```

7. Access the wiki at <http://localhost:8080>
