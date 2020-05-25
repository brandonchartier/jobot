(import ./config :as c)

(def mention
  "Grammar for parsing requests."
  (peg/compile
    ~{:crlf (* "\r" "\n")
      :rule (* (constant :rule)
               (<- (some :w)))
      :body (* :rule
               (any " ")
               (constant :body)
               (<- (any (if-not :crlf 1))))
      :main (* ,(c/config :nickname)
               (any (set ": "))
               :body)}))
