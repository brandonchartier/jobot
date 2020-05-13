(import ./config :prefix "")
(import ./utility :prefix "")


(defn- write
  "Writes a message to a stream, with a newline suffix,
   and sleeps for :delay seconds to avoid flooding."
  [stream message]
  (let [line (string message "\r\n")]
    (debugging line)
    (net/write stream line)
    (os/sleep (in config :delay 0.5))))


(defn priv
  "Sends a message to a channel,
   responding to the user who sent the command.
   https://en.wikipedia.org/wiki/List_of_Internet_Relay_Chat_commands#PRIVMSG"
  [stream channel nickname message]
  (write stream (string/format "PRIVMSG %s :%s: %s"
                               channel
                               nickname
                               message)))

(defn user
  "Specifies the various names of the client.
   https://en.wikipedia.org/wiki/List_of_Internet_Relay_Chat_commands#USER"
  [stream username]
  (write stream (string/format "USER %s %s %s %s"
                               username
                               username
                               username
                               username)))

(defn nick
  "Changes the client's nickname.
   https://en.wikipedia.org/wiki/List_of_Internet_Relay_Chat_commands#NICK"
  [stream nickname]
  (write stream (string/format "NICK %s" nickname)))

(defn join
  "Joins an IRC channel.
   https://en.wikipedia.org/wiki/List_of_Internet_Relay_Chat_commands#JOIN"
  [stream channel]
  (write stream (string/format "JOIN %s" channel)))

(defn pong
  "Sends a PONG reply to the server to avoid disconnecting.
   https://en.wikipedia.org/wiki/List_of_Internet_Relay_Chat_commands#PONG"
  [stream message]
  (write stream (string/format "PONG %s" message)))
