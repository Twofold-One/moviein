# PostgreSQL Notes

## General

Connect to psql:

`psql -U <postgres_username> -d <dbname>`

## General psql

To list all users:

`\du`

To list all db's:

`\l`

To list all tables in the current db:

`\dt`

Run .sql file:

`\i <file_path>`

To connet to database:

`\c <database_name>`

To see the full list of available meta commands:

`\?`

### Create DB

`CREATE DATABASE <dbname> OWNER <postgres_username>`

### Connect to DB with specific credentials

`$ psql --host=<host_name> --dbname=<db_name> --username=<username>`

## Good info for PostgreSQL DB tuning

https://www.enterprisedb.com/postgres-tutorials/how-tune-postgresql-memory
