(import json)
(import sh)


(def- not-empty?
  (comp not empty?))


(def- curl
  "Provide these options to curl:
   1. --silent: removes the progress bar usally sent to stdout.
   2. --fail and --show-error:
      use in combination to send HTTP errors to stderr."
  ["curl" "--silent" "--fail" "--show-error"])

(defn- make-request
  "Creates a curl process and returns the result,
   for pattern matching on :ok or :error.
   Decode:ok responses as JSON."
  [method url]
  (def out @"")
  (def err @"")

  (sh/run [(splice curl) "-X" method url]
          :redirects
          [[stdout out] [stderr err]])

  (cond (not-empty? out)
          [:ok (json/decode out)]
        (not-empty? err)
          [:error err]))

(defn get-request
  "Curl GET request,
   created with the private make-request function."
  [url]
  (make-request "GET" url))

(defn post-request
  "Curl POST request,
   created with the private make-request function."
  [url]
  (make-request "POST" url))


(defn ddate-request
  "Creates a ddate process and returns the result,
   for pattern matching on :ok or :error."
  []
  (def out @"")
  (def err @"")

  (sh/run ["ddate"]
          :redirects
          [[stdout out] [stderr err]])

  (cond (not-empty? out)
          [:ok out]
        (not-empty? err)
          [:error err]))
