(import uri)


(defn query-reducer :private [acc [k v]]
  (array/concat acc (string k "=" (uri/escape v))))

(defn build-query :private [query]
  (let [strings (reduce query-reducer @[] (pairs query))]
    (string "?" (string/join strings "&"))))


(defn create [&keys {:scheme scheme
                     :host host
                     :path path
                     :query query}]
  (string scheme "://" host path (build-query query)))

