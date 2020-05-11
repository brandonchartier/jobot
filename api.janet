(import ./config :prefix "")
(import ./request)


(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (ind (math/rng-int (math/rng (os/cryptorand 10))
                     (length ind))))


(defn google-image
  "Provided a search term,
   pattern matches on the response from the request,
   and returns a link."
  [search-term]
  (let [result (request/google-image search-term)]
    (match result
      [:ok {"items" items}]
        (get (sample items) "link")
      [:error err]
        (do (when (config :debug) (pp err)) "not found"))))


(defn ddate
  "Returns the current Discordian date."
  []
  (let [result (request/ddate)]
    (match result
      [:ok date]
        (string/trim date)
      [:error err]
        (do (when (config :debug) (pp err)) "today"))))


(defn weather
  "Provided the name of a city and its lat,long string,
   pattern matches on the response from the request,
   and returns a description of the weather."
  [name lat-long]
  (let [result (request/weather lat-long)]
    (match result
      [:ok {"currently" currently}]
        (string name
                ": "
                (math/round (get currently "temperature"))
                "° "
                (get currently "summary"))
      [:error err]
        (do (when (config :debug) (pp err)) "no data"))))
