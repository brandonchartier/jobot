(import ./config :as c)

(def crlf
  '(* "\r" "\n"))

(def message
  (peg/compile
    ~{:crlf ,crlf
      :tags (* (constant :tags)
               "@"
               (<- (some :S)))
      :prefix (* (constant :prefix)
                 (<- (some :S)))
      :from (* (constant :from)
               (<- (any (if-not "!" 1)))
               "!"
               :prefix)
      :source (* ":"
                 (+ :from :prefix))
      :command (* (constant :command)
                  (<- (some :w)))
      :trailing (* (constant :trailing)
                   ":"
                   (<- (any (if-not :crlf 1))))
      :to (* (constant :to)
             (<- (any :S))
             (any :s)
             :trailing)
      :params (+ :to :trailing)
      :middle (* (constant :middle)
                 (<- (some (+ :w " ")))
                 (constant :placeholder)
                 (<- (any (if-not :crlf 1))))
      :main (* (any (* :tags (some " ")))
               (any (* :source (some " ")))
               :command
               (any " ")
               (any (+ :params :middle))
               :crlf)}))

(def mention
  (peg/compile
    ~{:crlf ,crlf
      :rule (* (constant :rule)
               (<- (some :w)))
      :body (* :rule
               (any :s)
               (constant :body)
               (<- (any (if-not :crlf 1))))
      :main (* ,(c/config :nick)
               (any (set ": "))
               :body)}))
