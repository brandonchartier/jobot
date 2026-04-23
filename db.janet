(import sqlite3 :as sql)

(defn create-table [conn]
  (sql/eval conn
            ``CREATE TABLE IF NOT EXISTS log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sent_to VARCHAR(128),
        sent_by VARCHAR(128),
        message VARCHAR(1024),
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )``))

(defn insert-log [conn by to message]
  (sql/eval conn
            ``INSERT INTO log (sent_to, sent_by, message)
      VALUES (:to, :by, :message)``
            {:to to :by by :message message}))

(defn select-random [conn query sent]
  (get (sql/eval conn
                 ``SELECT * FROM log
           WHERE sent_to = :sent
           AND message LIKE :query
           ORDER BY RANDOM()
           LIMIT 1``
                 {:query (string "%" query "%") :sent sent})
       0))

(defn select-batch [conn offset limit]
  (sql/eval conn
            ``SELECT message FROM log LIMIT :limit OFFSET :offset``
            {:limit limit :offset offset}))
