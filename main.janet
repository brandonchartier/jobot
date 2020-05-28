(import ./config :as c)
(import ./db)
(import ./request)
(import irc-client :as irc)

(defn- member [xs x]
  (some (partial = x) xs))

(defn- reply
  "Replies to messages based on type of command."
  [stream from to cmd msg]
  (cond
    (member ["echo"] cmd)
    (irc/write-priv stream to from msg)
    (member ["random"] cmd)
    (when-let [log (request/random-log)]
      (irc/write-msg stream to log))
    (member ["ddate" "date"] cmd)
    (when-let [date (request/ddate)]
      (irc/write-priv stream to from date))
    (member ["image" "img"] cmd)
    (when-let [url (request/google-image msg)]
      (irc/write-priv stream to from url))
    (member ["news"] cmd)
    (when-let [news (request/news)]
      (irc/write-priv stream to from news))
    (member ["weather"] cmd)
    (each city (c/config :cities)
      (when-let [temp (request/weather (city :name) (city :coords))]
        (irc/write-msg stream to temp)))))

(def- mention
  "Grammar for parsing requests,
   returns [:cmd c :msg m] on matches."
  (peg/compile
    ~{:crlf (* "\r" "\n")
      :cmd (* (constant :cmd)
              (<- (some :w)))
      :msg (* :cmd
              (any " ")
              (constant :msg)
              (<- (any (if-not :crlf 1))))
      :main (* ,(c/config :nickname)
               (any (set ": "))
               :msg)}))

(defn- read
  "Pattern matches on the result of the IRC message grammar,
   replies based on the command provided to the stream."
  [stream message]
  (match message
    [:ping pong]
    (irc/write-pong stream pong)
    [:priv _ from to trailing]
    (do
      (db/log-message from to trailing)
      (match (peg/match mention trailing)
        [:cmd cmd :msg msg]
        (reply stream from to cmd msg)))))

(defn main
  [&]
  (db/create-table)
  (irc/connect
    {:host (c/config :host)
     :port (c/config :port)
     :channels (c/config :channels)
     :nickname (c/config :nickname)
     :username (c/config :nickname)
     :realname (c/config :nickname)}
    read))
