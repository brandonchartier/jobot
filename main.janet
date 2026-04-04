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
  [config stream from to cmd msg]
  (cond
    (member ["echo"] cmd)
    (irc/write-priv stream to from msg)
    (member ["image" "img"] cmd)
    (when-let [url (request/google-image (config :google-key) (config :google-cx) msg)]
      (irc/write-priv stream to from url))
    (member ["news"] cmd)
    (when-let [news (request/news (config :news-key) (config :news-sources))]
      (irc/write-priv stream to from news))
    (member ["random"] cmd)
    (when-let [log (request/select-random (config :db-path) msg to)]
      (irc/write-msg stream to log))
    (member ["weather"] cmd)
    (each city (config :cities)
      (when-let [temp (request/weather (city :name) (city :coords))]
        (irc/write-msg stream to temp)))))

(defn- read
  "Pattern matches on the result of the IRC message grammar,
   replies based on the command provided to the stream."
  [config mention stream message]
  (pp message)
  (match message
    [:priv _ from to trailing]
    (match (peg/match mention trailing)
      [:cmd cmd :msg msg]
      (reply config stream from to cmd msg)
      _ (db/insert-log (config :db-path) from to trailing))))

(defn main
  [&]
  (def config (parse (slurp (or (os/getenv "JOBOT_CONFIG") "config.jdn"))))
  (def mention (make-mention-grammar (config :nickname)))
  (db/create-table (config :db-path))
  (irc/connect
    {:host (config :host)
     :port (config :port)
     :channels (config :channels)
     :nickname (config :nickname)
     :username (config :nickname)
     :realname (config :nickname)}
    (partial read config mention)))
