(defn- write [stream message]
  (net/write stream
    (string message "\n")))

(defn priv [stream channel nickname message]
  (write stream
    (string/format "PRIVMSG %s :%s: %s"
                   channel
                   nickname
                   message)))

(defn user [stream username]
  (write stream
    (string/format "USER %s %s %s %s"
                   username
                   username
                   username
                   username)))

(defn nick [stream nickname]
  (write stream
    (string/format "NICK %s" nickname)))

(defn join [stream channel]
  (write stream
    (string/format "JOIN %s" channel)))

(defn pong [stream message]
  (write stream
    (string/format "PONG %s" message)))
