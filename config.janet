(def config
  (parse (slurp (or (os/getenv "JOBOT_CONFIG") "config.jdn"))))
