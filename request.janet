(import ./config :as c)
(import json)
(import process)
(import url)

(defn- log
  "Prints error message if debugging is enabled,
   returns an optional value."
  [message &opt value]
  (when (c/config :debug) (pp message))
  value)

(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (let [rdm (os/cryptorand 10)
        len (length ind)
        idx (math/rng-int (math/rng rdm) len)]
    (in ind idx)))

(def- not-empty?
  (comp not empty?))

(def- no-result "No result.")
(def- not-found "Not found.")

(defn ddate
  "Creates a ddate process and
   returns the Discordian date."
  []
  (def out @"")
  (def err @"")

  (process/run
    ["ddate"]
    :redirects [[stdout out] [stderr err]])

  (cond
    (not-empty? out)
    (string/trim out)
    (not-empty? err)
    (log err not-found)))

(defn- curl
  "Creates a curl process and returns the result,
   for pattern matching on :ok or :error.
   Decode :ok responses as JSON.

   Provide these options to curl:
   1. --silent: removes the progress bar normally sent to stdout.
   2. --fail and --show-error:
      use in combination to send HTTP errors to stderr."
  [method url]
  (def out @"")
  (def err @"")

  (process/run
    ["curl" "--silent" "--fail" "--show-error" "-X" method url]
    :redirects [[stdout out] [stderr err]])

  (cond
    (not-empty? out)
    [:ok (json/decode out)]
    (not-empty? err)
    [:error err]))

(defn google-image
  "Provided a search term,
   makes a request to Google APIS and returns a link."
  [search-term]
  (let [url (url/format
              :scheme "https"
              :host "www.googleapis.com"
              :path "/customsearch/v1"
              :query {:key (c/config :google-key)
                      :cx (c/config :google-cx)
                      :q search-term
                      :searchType "image"})]
    (match (curl "GET" url)
      [:ok {"items" items}]
      (if (not-empty? items)
        (in (sample items) "link")
        (log no-result not-found))
      [:error err]
      (log err not-found))))

(defn weather
  "Provided the name of a city and its lat,long string,
   makes a request to the Dark Sky API,
   returning a description of the weather."
  [name lat-long]
  (let [url (url/format
              :scheme "https"
              :host "api.darksky.net"
              :path (string/format
                      "/forecast/%s/%s"
                      (c/config :darksky-key)
                      lat-long))]
    (match (curl "GET" url)
      [:ok {"currently" current}]
      (string/format
        "%s: %d° %s"
        name
        (math/round (in current "temperature"))
        (in current "summary"))
      [:error err]
      (log err not-found))))

(def- sources
  (string/join (c/config :news-sources) ","))

(defn news
  "Creates a request to News API
   and returns a random headline."
  []
  (let [url (url/format
              :scheme "https"
              :host "newsapi.org"
              :path "/v2/top-headlines"
              :query {:apiKey (c/config :news-key)
                      :sources sources})]
    (match (curl "GET" url)
      [:ok {"articles" articles}]
      (if (not-empty? articles)
        (in (sample articles) "title")
        (log no-result not-found))
      [:error err]
      (log err not-found))))
