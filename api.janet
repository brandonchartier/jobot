(import ./config :prefix "")
(import ./request)
(import ./uri)


(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (ind (math/rng-int (math/rng (os/cryptorand 10))
                     (length ind))))


(defn google-image-request
  "Provided a search term,
   returns the JSON result of a Google image search."
  [search-term]
  (let [qs {:key (config :google-api-key)
            :cx (config :google-cx)
            :q search-term
            :searchType "image"}
        url (uri/unparse
              :scheme "https"
              :host "www.googleapis.com"
              :path "/customsearch/v1"
              :query qs)]
    (request/get-request url)))

(defn google-image-search
  "Provided a search term,
   pattern matches on the response from the request,
   and returns a link."
  [search-term]
  (let [result (google-image-request search-term)]
    (match result
      [:ok {"items" items}]
        (get (sample items) "link")
      [:error err]
        (do (print err) "not found"))))


(defn ddate
  "Returns the current Discordian date."
  []
  (let [result (request/ddate-request)]
    (match result
      [:ok date]
        (string/trim date)
      [:error err]
        (do (print err) "today"))))


(defn- weather-request
  "Provided a lat,long string,
   returns the current temperature of location,
   as a JSON result from a Dark Sky lookup."
  [lat-long]
  (let [url (uri/unparse
              :scheme "https"
              :host "api.darksky.net"
              :path (string/format
                      "/forecast/%s/%s"
                      (config :darksky-key)
                      lat-long))]
    (request/get-request url)))

(defn weather-search
  "Provided the name of a city and its lat,long string,
   pattern matches on the response from the request,
   and returns a description of the weather."
  [name lat-long]
  (let [result (weather-request lat-long)]
    (match result
      [:ok {"currently" currently}]
        (string name
                ": "
                (math/round (get currently "temperature"))
                "° "
                (get currently "summary"))
      [:error err]
        (do (print err) "no data"))))
