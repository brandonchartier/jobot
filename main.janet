(import ./config :prefix "")
(import ./read)
(import ./write)


(defn main [&]
  (let [channel (config :channel)
        nick (config :nick)
        port (config :port)
        server (config :server)
        stream (net/connect server port)]
    (write/user stream nick)
    (write/nick stream nick)
    (write/join stream channel)
    (read/recur stream)))
