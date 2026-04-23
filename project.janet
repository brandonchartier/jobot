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
                  :ref "b8999e3fccb119fe934783e6192ad5065aa22266"}
                 {:url "https://github.com/brandonchartier/janet-markov"
                  :ref "fec35e81747ae0f196c4885fedfa41350474ecb3"}])

(declare-executable
  :name "jobot"
  :entry "main.janet")
