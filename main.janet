(import ./config :as c)
(import ./grammar)
(import ./request)
(import irc-client :as irc)

(defn member [xs x]
  (some (partial = x) xs))

(defn- priv-handler
  "Replies to messages based on type of rule."
  [stream from to rule body]
  (cond
    (member ["echo"] rule)
    (irc/write-priv stream to from body)
    (member ["ddate" "date"] rule)
    (let [date (request/ddate)]
      (irc/write-priv stream to from date))
    (member ["image" "img"] rule)
    (let [url (request/google-image body)]
      (irc/write-priv stream to from url))
    (member ["news"] rule)
    (let [news (request/news)]
      (irc/write-priv stream to from news))
    (member ["weather"] rule)
    (each city (c/config :cities)
      (let [temp (request/weather (city :name) (city :coords))]
        (irc/write-msg stream to temp)))))

(defn- read
  "Pattern matches on the result of the IRC message grammar,
   replies based on the command provided to the stream."
  [stream message]
  (match message
    [:ping pong]
    (irc/write-pong stream pong)
    [:priv _ from to trailing]
    (match (peg/match grammar/mention trailing)
      [:rule rule :body body]
      (priv-handler stream from to rule body))))

(defn main
  [&]
  (irc/connect
    {:host (c/config :host)
     :port (c/config :port)
     :channels (c/config :channels)
     :nickname (c/config :nickname)
     :username (c/config :nickname)
     :realname (c/config :nickname)}
    read))
