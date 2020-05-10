(import ./config :prefix "")


(def ping-pattern :private
  (peg/compile
    '{:symbols (set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?")
      :message (+ :w+ :s+ :symbols)
      :main (* "PING" :s+ ":" (<- (any :message)))}))

(def no-body-pattern :private
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
              (<- (some :words) :command))}))

(def body-pattern :private
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


(defn parse [message]
  (when-let [[pong] (peg/match ping-pattern message)]
    (break [:ping pong]))
  (when-let [[nick host chan cmd msg] (peg/match body-pattern message)]
    (break [:body nick host chan cmd msg]))
  (when-let [[nick host chan cmd] (peg/match no-body-pattern message)]
    (break [:bare nick host chan cmd])))
