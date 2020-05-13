(import queue)


(var- *trailing* "")

(def new queue/new)

(defn- split-after
  "Splits a string into a head/tail pair,
   after the specified pattern."
  [str idx pattern]
  (let [len (length pattern)
        head (string/slice str 0 (+ idx len))
        tail (string/slice str (+ idx len))]
    [head tail]))

(defn split-and-add
  "Splits bytes and adds them to a queue."
  [queue bytes]
  (let [val (string *trailing* bytes)
        idx (string/find find-pattern val)]
    (set *trailing* "")
    (if (nil? idx)
      (set *trailing* val)
      (let [[head tail] (split-after val idx "\r\n")]
        (queue/enqueue queue head)
        (split-and-add queue tail)))))

(defn read-until-end
  "Recursively reads a queue until empty,
   processing each item with a transform function."
  [queue f]
  (when-let [item (queue/dequeue queue)]
    (f item)
    (read-until-end queue f)))
