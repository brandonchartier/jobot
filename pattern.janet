(import ./config :prefix "")

(def symbols :private
  '(set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?"))

(def message
  (peg/compile
    ~{:symbols ,symbols
      :whitespace (some :s)
      :words (+ :w+ :symbols)
      :rest (any 1)
      :me ,(string/format ":%s:" (config :nick))
      :ping (* (constant :ping)
               "PING"
               :s+
               ":"
               (<- :rest :pong))
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
               :priv
               :rest)
      :body (* (constant :body)
               :priv
               :whitespace
               (<- :rest :message))
      :main (+ :body :bare :ping)}))

