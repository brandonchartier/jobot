(import uri)


(defn- unparse-scheme [scheme]
  (if (nil? scheme) "" (string scheme "://")))

(defn- unparse-auth [auth]
  (if (nil? auth) "" (string auth "@")))

(defn- unparse-host [host]
  (if (nil? host) "" host))

(defn- unparse-port [port]
  (if (nil? port) "" (string ":" port)))

(defn- unparse-path [path]
  (if (nil? path) "" path))

(defn- query-reducer [acc [k v]]
  (array/concat acc (string k "=" (uri/escape (string v)))))

(defn- unparse-query [query]
  (if (nil? query)
      ""
      (let [strings (reduce query-reducer @[] (pairs query))]
        (string "?" (string/join strings "&")))))

(defn- unparse-hash [hash]
  (if (nil? hash) "" (string "#" hash)))


(defn unparse
  "Creates a URI from optional keys."
  [&keys {:scheme scheme
          :auth auth
          :host host
          :port port
          :path path
          :query query
          :hash hash}]
  (string (unparse-scheme scheme)
          (unparse-auth auth)
          (unparse-host host)
          (unparse-port port)
          (unparse-path path)
          (unparse-query query)
          (unparse-hash hash)))

