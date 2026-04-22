(declare-project
  :name "jobot"
  :description "An IRC bot"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["spork"
                 "sqlite3"
                 {:url "https://github.com/joy-framework/http"
                  :ref "0aa31e4f65756b6882e1e56cbcb585047fe97939"}
                 {:url "https://github.com/brandonchartier/janet-url"
                  :ref "99553df0210bc97813d64e8456e8e7e37c932cdf"}
                 {:url "https://github.com/brandonchartier/janet-irc-client"
                  :ref "fc5b3af4b9dd8ff587e66f67cac3ae456d8dce88"}
                 {:url "https://github.com/brandonchartier/janet-markov"
                  :ref "cfa10c78aed8073fc4c1d329996f0625586d9443"}])

(declare-executable
  :name "jobot"
  :entry "main.janet")
