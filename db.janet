(import sqlite3 :as sql)

(defn- read-file
  [filename]
  (string (slurp filename)))

(def- sql-create-table
  (read-file "./sql/create-table.sql"))

(def- sql-insert-log
  (read-file "./sql/insert-log.sql"))

(def- sql-select-random
  (read-file "./sql/select-random.sql"))

(defn- exec
  [statement &opt ds]
  (default ds {})
  (let [db (sql/open "jobot.db")
        xs (sql/eval db statement ds)]
    (sql/close db)
    xs))

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
  [query sent]
  (let [random (exec sql-select-random {:query query :sent sent})]
    (get random 0)))
