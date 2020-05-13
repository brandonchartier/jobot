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
   returns the JSON result of a Google image search."
  [search-term]
  (let [url (uri/unparse
              :scheme "https"
              :host "www.googleapis.com"
              :path "/customsearch/v1"
              :query {:key (config :google-key)
                      :cx (config :google-cx)
                      :q search-term
                      :searchType "image"})]
    (curl "GET" url)))


(defn weather
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
    (curl "GET" url)))


(defn ddate
  "Creates a ddate process and returns the result,
   for pattern matching on :ok or :error."
  []
  (def out @"")
  (def err @"")

  (process/run
    ["ddate"]
    :redirects [[stdout out] [stderr err]])

  (cond
    (u/not-empty? out)
    [:ok out]
    (u/not-empty? err)
    [:error err]))
