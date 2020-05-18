(import ./config :as c)
(import ./helper :as h)
(import ./uri)
(import json)
(import process)

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
    (h/not-empty? out)
    (string/trim out)
    (h/not-empty? err)
    (h/log err "today")))

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
    (h/not-empty? out)
    [:ok (json/decode out)]
    (h/not-empty? err)
    [:error err]))

(defn google-image
  "Provided a search term,
   makes a request to Google APIS and returns a link."
  [search-term]
  (let [url (uri/unparse
              :scheme "https"
              :host "www.googleapis.com"
              :path "/customsearch/v1"
              :query {:key (c/config :google-key)
                      :cx (c/config :google-cx)
                      :q search-term
                      :searchType "image"})]
    (match (curl "GET" url)
      [:ok {"items" items}]
      (in (h/sample items) "link")
      [:error err]
      (h/log err "not found"))))

(defn weather
  "Provided the name of a city and its lat,long string,
   makes a request to the Dark Sky API,
   returning a description of the weather."
  [name lat-long]
  (let [url (uri/unparse
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
      (h/log err "not found"))))

(defn news
  [query]
  (let [url (uri/unparse
              :scheme "https"
              :host "newsapi.org"
              :path "/v2/top-headlines"
              :query {:apiKey (c/config :news-key)
                      :country "us"
                      :q query})]
    (pp url)
    (match (curl "GET" url)
      [:ok {"articles" articles}]
      (if (h/not-empty? articles)
        (in (h/sample articles) "title")
        "not found")
      [:error err]
      (h/log err "not found"))))
