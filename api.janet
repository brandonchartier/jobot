(import ./config :prefix "")
(import ./request)
(import ./uri)


(defn sample :private [xs]
  (get xs
    (math/rng-int (math/rng (os/time))
                  (length xs))))


(defn google-image-request :private [query]
  (let [qs {:key (config :google-api-key)
            :cx (config :google-cx)
            :q query
            :searchType "image"}
        url (uri/create :scheme "https"
                        :host "www.googleapis.com"
                        :path "/customsearch/v1"
                        :query qs)]
    (request/get-request url)))

(defn google-image-search [query]
  (let [result (google-image-request query)]
    (match result
      [:ok {"items" items}]
        (get (sample items) "link")
      [:error err]
        (do (print err) "not found"))))


(defn ddate []
  (let [result (request/ddate-request)]
    (match result
      [:ok date]
        (string/trim date)
      [:error err]
        (do (print err) "today"))))


(defn weather-request [lat-long]
  (let [url (uri/create
              :scheme "https"
              :host "api.darksky.net"
              :path (string/format
                      "/forecast/%s/%s"
                      (config :darksky-key)
                      lat-long)
               :query {})]
    (request/get-request url)))

(defn weather-search [name lat-long]
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

