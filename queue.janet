(import queue)


(var- *trailing* "")
(def- find-pattern "\r\n")

(def new queue/new)

(defn- split-after [str idx]
  (let [len (length find-pattern)
        head (string/slice str 0 (+ idx len))
        tail (string/slice str (+ idx len))]
    [head tail]))

(defn split-and-add [queue bytes]
  (let [val (string *trailing* bytes)
        idx (string/find find-pattern val)]
    (set *trailing* "")
    (if (nil? idx)
      (set *trailing* val)
      (let [[head tail] (split-after val idx)]
        (queue/enqueue queue head)
        (split-and-add queue tail)))))

(defn read-until-end [queue f]
  (when-let [item (queue/dequeue queue)]
    (f item)
    (read-until-end queue f)))
