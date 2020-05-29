(import ./config :as c)
(import ./db)
(import json)
(import process)
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

(defn- run
  [& cmds]
  (def out @"")
  (def err @"")
  (process/run
    cmds
    :redirects [[stdout out] [stderr err]])
  (cond
    (not-empty? out)
    [:ok out]
    (not-empty? err)
    [:error err]))

(defn ddate
  "Creates a ddate process and
   returns the Discordian date."
  []
  (match (run "ddate")
    [:ok data]
    (string/trim data)
    _ "not found"))

(defn- curl
  "Creates a curl process and returns the result,
   for pattern matching on :ok or :error.
   Decode :ok responses as JSON.

   Provide these options to curl:
   1. --silent: removes the progress bar normally sent to stdout.
   2. --fail and --show-error:
      use in combination to send HTTP errors to stderr."
  [url]
  (match (run "curl" "-sfS" url)
    [:ok data]
    (json/decode data)
    err err))

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
  (match (curl (image-url query))
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
  (match (curl (weather-url lat-long))
    {"currently" data}
    (string/format
      "%s: %d° %s"
      name
      (math/round (in data "temperature"))
      (in data "summary"))
    _ "not found"))

(def- sources
  (string/join (c/config :news-sources) ","))

(def- news-url
  (url/format
    :scheme "https"
    :host "newsapi.org"
    :path "/v2/top-headlines"
    :query {:apiKey (c/config :news-key)
            :sources sources}))

(defn news
  "Creates a request to News API
   and returns a random headline."
  []
  (match (curl news-url)
    {"articles" data}
    (in (sample data) "title")
    _ "not found"))

(defn select-random
  []
  (match (db/select-random)
    {:sent_by by :message msg}
    (string "<" by "> " msg)
    _ "not found"))

(defn select-search
  [query]
  (let [q (string "%" query "%")]
    (match (db/select-search q)
      {:sent_by by :message msg}
      (string "<" by "> " msg)
      _ "not found")))
