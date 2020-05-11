(import ./api)
(import ./config :prefix "")
(import ./grammar)
(import ./write)


(defn- echo? [cmd]
  (= cmd "echo"))

(defn- image? [cmd]
  (or (= cmd "img") (= cmd "image")))

(defn- weather? [cmd]
  (= cmd "weather"))

(defn- date? [cmd]
  (or (= cmd "date") (= cmd "ddate")))


(defn- parse
  "Pattern matches on the result of the IRC message PEG,
   writes based on the command provided to the stream."
  [stream message]
  (match (peg/match grammar/message message)
    [:ping pong]
      (write/pong stream pong)
    [:body nick host chan cmd msg]
      (cond (echo? cmd)
              (write/priv stream chan nick msg)
            (image? cmd)
              (let [url (api/google-image msg)]
                (write/priv stream chan nick url)))
    [:bare nick host chan cmd]
      (cond (weather? cmd)
              (each city (config :cities)
                (do (os/sleep 0.5)
                    (let [temp (api/weather (city :name) (city :coords))]
                      (write/priv stream chan nick temp))))
            (date? cmd)
              (let [date (api/ddate)]
                (write/priv stream chan nick date)))))


(defn recur
  "Loop over the stream and parse the incoming messages,
   close the connection in case of a failure."
  [stream]
  (let [message (net/read stream 2048)]
    (if (nil? message)
        (net/close stream)
        (do (when (config :debug)
              (pp message)
              (print "--"))
            (parse stream message)
            (recur stream)))))
