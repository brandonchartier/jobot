(import ./request)
(import ./utility :as u)


(defn google-image
  "Provided a search term,
   pattern matches on the response from the request,
   and returns a link."
  [search-term]
  (match (request/google-image search-term)
    [:ok {"items" items}]
    (in (u/sample items) "link")
    [:error err]
    (u/debugging err "not found")))


(defn ddate
  "Returns the current Discordian date."
  []
  (match (request/ddate)
    [:ok date]
    (string/trim date)
    [:error err]
    (u/debugging err "today")))


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
    (u/debugging err "not found")))
