(import ./config :prefix "")


(def ping
  (peg/compile
    '{:symbols (set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
      :message (+ :w+ :s+ :symbols)
      :main (* "PING" :s+ ":" (<- (any :message)))}))

(def message
  (peg/compile
    ~{:symbols (set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
      :whitespace (some :s)
      :words (+ :w+ :symbols)
      :whitespace-or-words (+ :whitespace :words)
      :me ,(string/format ":%s:" (config :nick))
      :main (* ":"
              (<- (some :w+) :nickname)
              (<- (some :words) :hostname)
              :whitespace
              "PRIVMSG"
              :whitespace
              (<- (some :words) :channel)
              :whitespace
              :me
              :whitespace
              (<- (some :words) :command)
              :whitespace
              (<- (some :whitespace-or-words) :message))}))

