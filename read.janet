(import ./pattern)
(import ./write)


(defn recur [stream]
  (let [message (net/read stream 2048)]
  (if (nil? message)
      (net/close stream)
      (do (print message)
          (when-let [[pong] (peg/match pattern/ping message)]
            (write/pong stream pong))
          (when-let [[nick host chan cmd msg] (peg/match pattern/message message)]
            (case cmd
              "echo" (write/privmsg stream chan nick msg)))
          (recur stream)))))
