(import ./config :prefix "")
(import ./uri)
(import json)
(import sh)


(def- not-empty?
  (comp not empty?))


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

  (sh/run curl --silent --fail --show-error -X ,method ,url
    > [stdout out]
    > [stderr err])

  (cond (not-empty? out)
          [:ok (json/decode out)]
        (not-empty? err)
          [:error err]))


(defn google-image
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

  (sh/run ddate
    > [stdout out]
    > [stderr err])

  (cond (not-empty? out)
          [:ok out]
        (not-empty? err)
          [:error err]))
