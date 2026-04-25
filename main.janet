(import sqlite3 :as sql)
(import ./db)
(import ./request)
(import irc-client :as irc)

(defn- make-mention-grammar
  [nickname]
  (peg/compile
    ~{:crlf (* "\r" "\n")
      :cmd (* (constant :cmd)
              (<- (some :w)))
      :msg (* :cmd
              (any " ")
              (constant :msg)
              (<- (any (if-not :crlf 1))))
      :main (* ,nickname
               (any (set ": "))
               :msg)}))

(defn- member [xs x]
  (some (partial = x) xs))

(defn- reply
  "Replies to messages based on type of command."
  [config chain writer from to cmd msg]
  (cond
    (member ["echo"] cmd)
    (irc/write-priv writer to from msg)
    (member ["image" "img"] cmd)
    (when-let [url (request/google-image (config :google-key) (config :google-cx) msg)]
      (irc/write-priv writer to from url))
    (member ["news"] cmd)
    (when-let [news (request/news (config :news-key) (config :news-sources))]
      (irc/write-priv writer to from news))
    (member ["random"] cmd)
    (when-let [log (request/select-random (chain :conn) msg to)]
      (irc/write-msg writer to log))
    (member ["weather"] cmd)
    (each city (config :cities)
      (when-let [temp (request/weather (city :name) (city :coords))]
        (irc/write-msg writer to temp)))
    (irc/write-msg writer to (request/markov-reply chain (string cmd " " msg)))))

(defn- observe [chain from to text]
  (db/insert-log (chain :conn) from to text)
  (request/train-message chain text))

(defn- dispatch
  [config chain mention writer message]
  (match message
    [:priv _ from to trailing]
    (match (peg/match mention trailing)
      [:cmd cmd :msg msg]
      (ev/go (fn []
               (try (reply config chain writer from to cmd msg)
                 ([err] (eprintf "error in reply: %s" err)))))
      _ (observe chain from to trailing))
    [:action _ from to text]
    (observe chain from to text)))

(defn- read
  [config chain mention writer message]
  (when (config :debug) (pp message))
  (try (dispatch config chain mention writer message)
    ([err] (eprintf "error handling message: %s" err))))

(defn main
  [&]
  (def config (parse (slurp (or (os/getenv "JOBOT_CONFIG") "config.jdn"))))
  (def mention (make-mention-grammar (config :nickname)))
  (def conn (sql/open (config :db-path)))
  (db/create-table conn)
  (def chain (request/train-chain conn))
  (irc/connect
    {:host (config :host)
     :port (config :port)
     :channels (config :channels)
     :nickname (config :nickname)
     :username (config :nickname)
     :realname (config :nickname)}
    (partial read config chain mention)))
