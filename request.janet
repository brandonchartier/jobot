(import ./config :prefix "")
(import ./uri)
(import ./utility :as u)
(import json)
(import process)


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
    (u/not-empty? out)
    [:ok (json/decode out)]
    (u/not-empty? err)
    [:error err]))


(defn google-image
  "Provided a search term,
   makes a request to Google APIS and returns a link."
  [search-term]
  (let [url (uri/unparse
              :scheme "https"
              :host "www.googleapis.com"
              :path "/customsearch/v1"
              :query {:key (config :google-key)
                      :cx (config :google-cx)
                      :q search-term
                      :searchType "image"})]
    (match (curl "GET" url)
      [:ok {"items" items}]
      (in (u/sample items) "link")
      [:error err]
      (u/debugging err "not found"))))


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
                      (config :darksky-key)
                      lat-long))]
    (match (curl "GET" url)
      [:ok {"currently" current}]
      (string/format
        "%s: %d° %s"
        name
        (math/round (in current "temperature"))
        (in current "summary"))
      [:error err]
      (u/debugging err "not found"))))


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
    (u/not-empty? out)
    (string/trim out)
    (u/not-empty? err)
    (u/debugging err "today")))
