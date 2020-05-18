(import ./config :as c)
(import ./grammar)
(import ./helper :as h)
(import ./queue)
(import ./request)
(import ./write)

(defn- handler
  "Replies to messages based on type of rule."
  [stream from to rule body]
  (cond
    (h/contains ["echo"] rule)
    (write/priv stream to from body)
    (h/contains ["ddate" "date"] rule)
    (let [date (request/ddate)]
      (write/priv stream to from date))
    (h/contains ["image" "img"] rule)
    (let [url (request/google-image body)]
      (write/priv stream to from url))
    (h/contains ["news"] rule)
    (let [news (request/news)]
      (write/priv stream to from news))
    (h/contains ["weather"] rule)
    (each city (c/config :cities)
      (let [temp (request/weather (city :name) (city :coords))]
        (write/priv stream to from temp)))))

(defn- process
  "Pattern matches on the result of the IRC message grammar,
   replies based on the command provided to the stream."
  [stream message]
  (h/log message)
  (match (peg/match grammar/message message)
    [:command "PING" :trailing trailing]
    (write/pong stream trailing)
    [:from from :prefix _ :command "PRIVMSG" :to to :trailing trailing]
    (match (peg/match grammar/mention trailing)
      [:rule rule :body body]
      (handler stream from to rule body))))

(defn recur
  "Loop over the stream and parse the incoming messages,
   close the connection in case of a failure."
  [stream &opt acc]
  (let [message (net/read stream 1024)]
    (if (nil? message)
      (net/close stream)
      (let [message-queue (queue/new)
            chunk (queue/split-and-add message-queue message acc)]
        (queue/read-until-end message-queue (partial process stream))
        (recur stream chunk)))))
