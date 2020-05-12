(import ./config :prefix "")
(import ./request)


(defn- debug
  "Prints error message if debugging is enabled,
   returns an optional value."
  [err &opt val]
  (when (config :debug)
    (pp err))
  val)

(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (let [rdm (os/cryptorand 10)
        len (length ind)
        idx (math/rng-int (math/rng rdm) len)]
    (in ind idx)))


(defn google-image
  "Provided a search term,
   pattern matches on the response from the request,
   and returns a link."
  [search-term]
  (match (request/google-image search-term)
    [:ok {"items" items}]
    (in (sample items) "link")
    [:error err]
    (debug err "not found")))


(defn ddate
  "Returns the current Discordian date."
  []
  (match (request/ddate)
    [:ok date]
    (string/trim date)
    [:error err]
    (debug err "today")))


(defn weather
  "Provided the name of a city and its lat,long string,
   pattern matches on the response from the request,
   and returns a description of the weather."
  [name lat-long]
  (match (request/weather lat-long)
    [:ok {"currently" current}]
    (string/format
      "%s: %d° %s"
      name
      (math/round (in current "temperature"))
      (in current "summary"))
    [:error err]
    (debug err "not found")))
