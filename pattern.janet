(import ./config :prefix "")

(def symbols :private
  '(set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?"))

(def message
  (peg/compile
    ~{:symbols ,symbols
      :whitespace (some :s)
      :words (+ :w+ :symbols)
      :whitespace-or-words (+ :whitespace :words)
      :me ,(string/format ":%s:" (config :nick))
      :ping (* (constant :ping)
               "PING"
               :s+
               ":"
               (<- (any :whitespace-or-words)))
      :priv (* ":"
               (<- (some :w+) :nickname)
               "!"
               (<- (some :words) :hostname)
               :whitespace
               "PRIVMSG"
               :whitespace
               (<- (some :words) :channel)
               :whitespace
               :me
               :whitespace
               (<- (some :words) :command))
      :bare (* (constant :bare)
               :priv)
      :body (* (constant :body)
               :priv
               :whitespace
               (<- (some :whitespace-or-words) :message))
      :main (+ :body :bare :ping)}))

