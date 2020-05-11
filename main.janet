(import ./config :prefix "")
(import ./read)
(import ./write)


(defn main
  "Connects to a host and port, creating a duplex stream
   and begins the IRC connection process;
   passes the stream to a loop for further read processing."
  [&]
  (let [channel (config :channel)
        nick (config :nick)
        port (config :port)
        server (config :server)
        stream (net/connect server port)]
    (write/user stream nick)
    (write/nick stream nick)
    (write/join stream channel)
    (read/recur stream)))
