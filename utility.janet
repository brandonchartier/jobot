(import ./config :prefix "")

(defn debugging
  "Prints error message if debugging is enabled,
   returns an optional value."
  [message &opt value]
  (when (config :debug)
    (pp message))
  value)

(defn sample
  "Returns a random item from an indexed data structure."
  [ind]
  (let [rdm (os/cryptorand 10)
        len (length ind)
        idx (math/rng-int (math/rng rdm) len)]
    (in ind idx)))

(def not-empty?
  (comp not empty?))
