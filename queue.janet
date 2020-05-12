(var- *trailing* "")
(var- *messages* @[])

(def- find-pattern "\r\n")

(defn- split-after [str idx]
  (let [len (length find-pattern)
        head (string/slice str 0 (+ idx len))
        tail (string/slice str (+ idx len))]
    [head tail]))

(defn push [bytes]
  (let [val (string *trailing* bytes)
        idx (string/find find-pattern val)]
    (set *trailing* "")
    (if (nil? idx)
      (set *trailing* val)
      (let [[head tail] (split-after val idx)]
        (array/concat *messages* head)
        (push tail)))))

(defn read []
  (unless (empty? *messages*)
    (let [head (*messages* 0)]
      (array/remove *messages* 0)
      head)))

(defn process [f]
  (when-let [line (read)]
    (f line)
    (process f)))
