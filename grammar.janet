(import ./config :as c)


(def- symbols
  "Symbols used for parsing URLs and user-provided data."
  '(set "`~!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?"))

(def message
  "Grammar for parsing IRC messages."
  (peg/compile
    ~{:symbols ,symbols
      :whitespace (some :s)
      :glyph (+ :w :symbols)
      :glyphs (some :glyph)
      :glyphs-or-spaces (some (+ :glyph " "))
      :nickname (some (+ :w (set "_{}[]^")))
      :mention (* ,(c/config :nick) (any ":"))
      :ping (* (constant :ping)
               "PING"
               :whitespace
               ":"
               (<- :glyphs :pong))
      :priv (* ":"
               (<- :nickname)
               "!"
               (<- :glyphs :hostname)
               :whitespace
               "PRIVMSG"
               :whitespace
               (<- :glyphs :channel)
               :whitespace
               ":"
               :mention
               :whitespace
               (<- :glyphs :command))
      :bare (* (constant :bare)
               :priv)
      :body (* (constant :body)
               :priv
               :whitespace
               (<- :glyphs-or-spaces :message))
      :main (+ :body :bare :ping)}))
