(import ./config :prefix "")
(import ./request)
(import uri)


(defn sample [xs]
  (get xs (math/rng-int (math/rng (os/time)) (length xs))))


(def google-image-url :private
  "https://www.googleapis.com/customsearch/v1?key=%s&cx=%s&q=%s&searchType=image")

(defn google-image-request :private [query]
  (let [url (string/format google-image-url 
                           (config :google-api-key) 
                           (config :google-cx)
                           (uri/escape (string/trim query)))]
    (print url)
    (request/get-request url)))

(defn google-image-search [query]
  (let [result (google-image-request query)]
    (match result
      [:ok {"items" items}] (get (sample items) "link")
      [error err] (do (print err) "not found"))))

