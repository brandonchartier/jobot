(import ./api)
(import ./config :prefix "")
(import ./grammar)
(import ./queue)
(import ./utility :prefix "")
(import ./write)


(defn- date? [cmd]
  (or (= cmd "date") (= cmd "ddate")))

(defn- echo? [cmd]
  (= cmd "echo"))

(defn- image? [cmd]
  (or (= cmd "img") (= cmd "image")))

(defn- weather? [cmd]
  (= cmd "weather"))


(defn- bare-handler
  "Handles condition with no trailing content,
   dispatches on the type of command and sends a reply."
  [stream nick chan cmd]
  (cond
    (date? cmd)
    (let [date (api/ddate)]
      (write/priv stream chan nick date))
    (weather? cmd)
    (each city (config :cities)
      (let [temp (api/weather (city :name) (city :coords))]
        (write/priv stream chan nick temp)))))

(defn- body-handler
  "Handles condition with trailing content,
   dispatches on the type of command and sends a reply."
  [stream nick chan cmd msg]
  (cond
    (echo? cmd)
    (write/priv stream chan nick msg)
    (image? cmd)
    (let [url (api/google-image msg)]
      (write/priv stream chan nick url))))


(defn- process
  "Pattern matches on the result of the IRC message grammar,
   replies based on the command provided to the stream."
  [stream message]
  (debugging message)
  (match (peg/match grammar/message message)
    [:ping pong]
    (write/pong stream pong)
    [:bare nick _ chan cmd]
    (bare-handler stream nick chan cmd)
    [:body nick _ chan cmd msg]
    (body-handler stream nick chan cmd msg)))


(defn recur
  "Loop over the stream and parse the incoming messages,
   close the connection in case of a failure."
  [stream]
  (let [message (net/read stream 2048)]
    (if (nil? message)
      (net/close stream)
      (let [message-queue (queue/new)]
        (queue/split-and-add message-queue message)
        (queue/read-until-end message-queue (partial process stream))
        (recur stream)))))
