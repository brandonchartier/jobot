(import ./config :as c)
(import ./db)
(import http)
(import json)
(import url)

(def- not-empty?
  (comp not empty?))

(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (let [rdm (os/cryptorand 10)
        len (length ind)
        idx (math/rng-int (math/rng rdm) len)]
    (in ind idx)))

(defn- request
  "Helper function for making HTTP requests."
  [url]
  (let [response (http/get url)]
    (match (response :status)
      200 (json/decode (response :body))
      _ "not found")))

(defn- image-url
  [query]
  (url/format
    :scheme "https"
    :host "www.googleapis.com"
    :path "/customsearch/v1"
    :query {:key (c/config :google-key)
            :cx (c/config :google-cx)
            :q query
            :searchType "image"}))

(defn google-image
  "Provided a search term,
   makes a request to Google APIS and returns a link."
  [query]
  (match (request (image-url query))
    {"items" data}
    (in (sample data) "link")
    _ "not found"))

(defn- weather-url
  [lat-long]
  (url/format
    :scheme "https"
    :host "api.darksky.net"
    :path (string/format
            "/forecast/%s/%s"
            (c/config :darksky-key)
            lat-long)))

(defn weather
  "Provided the name of a city and its lat,long string,
   makes a request to the Dark Sky API,
   returning a description of the weather."
  [name lat-long]
  (match (request (weather-url lat-long))
    {"currently" data}
    (string/format
      "%s: %d° %s"
      name
      (math/round (in data "temperature"))
      (in data "summary"))
    _ "not found"))

(def- news-sources
  (string/join (c/config :news-sources) ","))

(def- news-url
  (url/format
    :scheme "https"
    :host "newsapi.org"
    :path "/v2/top-headlines"
    :query {:apiKey (c/config :news-key)
            :sources news-sources}))

(defn news
  "Creates a request to News API
   and returns a random headline."
  []
  (match (request news-url)
    {"articles" data}
    (in (sample data) "title")
    _ "not found"))

(defn select-random
  "Queries DB logs using LIKE."
  [query to]
  (let [q (string "%" query "%")]
    (match (db/select-random q to)
      {:sent_by by :message msg}
      (string "<" by "> " msg)
      _ "not found")))
