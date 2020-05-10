(import json)
(import sh)

(def not-empty? :private
  (comp not empty?))

(def curl :private
  ["curl" "--silent" "--fail" "--show-error"])

(defn make-request :private [method url]
  (def out @"")
  (def err @"")

  (sh/run [(splice curl) "-X" method url]
          :redirects
          [[stdout out] [stderr err]])

  (cond (not-empty? out)
        [:ok (json/decode out)]
        (not-empty? err)
        [:error err]))

(defn get-request [url]
  (make-request "GET" url))

(defn post-request [url]
  (make-request "POST" url))


(defn ddate-request []
  (def out @"")
  (def err @"")

  (sh/run ["ddate"]
          :redirects
          [[stdout out] [stderr err]])

  (cond (not-empty? out)
        [:ok out]
        (not-empty? err)
        [:error err]))
