
from std/strutils import parseInt
from std/os import getEnv, createDir

when defined(DB_SQLITE):
  import
    waterpark/sqlite
  export
    sqlite

  createDir("db")
  let
    pgWorkers = getEnv("PG_WORKERS", "1").parseInt()
    pg* = newSqlitePool(pgWorkers, "db/nimletter.db")

else:
  import
    waterpark/postgres
  export
    postgres

  echo "PostgreSQL: connecting ..."
  let
    pgHost      = getEnv("PG_HOST", "localhost")
    pgUser*     = getEnv("PG_USER", "postgres")
    pgPassword* = getEnv("PG_PASSWORD", "postgres")
    pgDatabase* = getEnv("PG_DATABASE", "nimletter_db")
    pgWorkers   = getEnv("PG_WORKERS", "3").parseInt()
    pg* = newPostgresPool(pgWorkers, pgHost, pgUser, pgPassword, pgDatabase)
  echo "PostgreSQL: connected"