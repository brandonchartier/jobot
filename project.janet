(declare-project
  :name "jobot"
  :description "An IRC bot"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["spork"
                 "sqlite3"
                 {:url "https://github.com/brandonchartier/janet-http"
                  :ref "1e79af794780fc7f9ab0bccfb76d465272b1838f"}
                 {:url "https://github.com/brandonchartier/janet-url"
                  :ref "99553df0210bc97813d64e8456e8e7e37c932cdf"}
                 {:url "https://github.com/brandonchartier/janet-irc-client"
                  :ref "de9452d999d8ca10d7c2344c53d5ce52f1af03f3"}
                 {:url "https://github.com/brandonchartier/janet-markov"
                  :ref "fec35e81747ae0f196c4885fedfa41350474ecb3"}])

(declare-executable
  :name "jobot"
  :entry "main.janet")
