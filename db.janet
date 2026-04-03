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
  [db-path statement &opt ds]
  (default ds {})
  (let [db (sql/open db-path)
        xs (sql/eval db statement ds)]
    (sql/close db)
    xs))

(defn create-table
  [db-path]
  (exec db-path sql-create-table))

(defn insert-log
  [db-path by to message]
  (exec db-path sql-insert-log
        {:to to
         :by by
         :message message}))

(defn select-random
  [db-path query sent]
  (let [random (exec db-path sql-select-random {:query query :sent sent})]
    (get random 0)))
