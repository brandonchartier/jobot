(import sqlite3 :as sql)

(defn- read-file [filename]
  (string (slurp filename)))

(def- sql-create-table (read-file "./sql/create-table.sql"))
(def- sql-insert-log (read-file "./sql/insert-log.sql"))
(def- sql-select-random (read-file "./sql/select-random.sql"))
(def- sql-select-all (read-file "./sql/select-all.sql"))

(defn create-table [conn]
  (sql/eval conn sql-create-table))

(defn insert-log [conn by to message]
  (sql/eval conn sql-insert-log {:to to :by by :message message}))

(defn select-random [conn query sent]
  (get (sql/eval conn sql-select-random {:query query :sent sent}) 0))

(defn select-all [conn]
  (sql/eval conn sql-select-all))
