(import sqlite3 :as sql)

(defn- open-db
  []
  (sql/open "jobot.db"))

(defn- open-sql-file
  [filename]
  (string (slurp filename)))

(def- sql-create-logs
  (open-sql-file "./sql/create-table.sql"))

(def- sql-log-message
  (open-sql-file "./sql/log-message.sql"))

(def- sql-random-log
  (open-sql-file "./sql/random-log.sql"))

(defn create-table
  []
  (let [db (open-db)]
    (sql/eval db sql-create-logs)
    (sql/close db)))

(defn log-message
  [by to message]
  (let [db (open-db)
        msg {:to to
             :by by
             :message message}]
    (sql/eval db sql-log-message msg)
    (sql/close db)))

(defn random-log
  []
  (let [db (open-db)
        random (sql/eval db sql-random-log)]
    (sql/close db)
    random))
