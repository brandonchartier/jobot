(import sqlite3 :as sql)

(defn- exec
  [statement &opt ds]
  (default ds {})
  (let [db (sql/open "jobot.db")
        xs (sql/eval db statement ds)]
    (sql/close db)
    xs))

(defn- open-sql-file
  [filename]
  (string (slurp filename)))

(def- sql-create-table
  (open-sql-file "./sql/create-table.sql"))

(def- sql-insert-log
  (open-sql-file "./sql/insert-log.sql"))

(def- sql-select-random
  (open-sql-file "./sql/select-random.sql"))

(defn create-table
  []
  (exec sql-create-table))

(defn insert-log
  [by to message]
  (exec sql-insert-log
        {:to to
         :by by
         :message message}))

(defn select-random
  [query]
  (let [random (exec sql-select-random {:query query})]
    (get random 0)))
