(import ./api)
(import ./config :prefix "")
(import ./pattern)
(import ./write)


(defn echo? :private [cmd]
  (= cmd "echo"))

(defn image? :private [cmd]
  (or (= cmd "img") (= cmd "image")))

(defn weather? :private [cmd]
  (= cmd "weather"))

(defn date? :private [cmd]
  (or (= cmd "date") (= cmd "ddate")))


(defn parse :private [stream message]
  (match (peg/match pattern/message message)
    [:ping pong]
      (write/pong stream pong)
    [:body nick host chan cmd msg]
      (cond (echo? cmd)
              (write/priv stream chan nick msg)
            (image? cmd)
              (let [url (api/google-image-search msg)]
                (write/priv stream chan nick url)))
    [:bare nick host chan cmd]
      (cond (weather? cmd)
              (each city (config :cities)
                (let [temp (api/weather-search (city :name) (city :coords))]
                  (write/priv stream chan nick temp)))
            (date? cmd)
              (let [date (api/ddate)]
                (write/priv stream chan nick date)))))


(defn recur [stream]
  (let [message (net/read stream 2048)]
    (if (nil? message)
        (net/close stream)
        (do (print message)
            (parse stream message)
            (recur stream)))))
