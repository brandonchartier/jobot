(declare-project
  :name "jobot"
  :description "An IRC bot"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["spork"
                 "sqlite3"
                 {:url "https://github.com/brandonchartier/janet-http"
                  :ref "62ca3b2fc7a8275a8ce349c61dbcc6fa441c3c87"}
                 {:url "https://github.com/brandonchartier/janet-url"
                  :ref "99553df0210bc97813d64e8456e8e7e37c932cdf"}
                 {:url "https://github.com/brandonchartier/janet-irc-client"
                  :ref "d24f05b700bb6b8913a909230cda7d09639a7092"}
                 {:url "https://github.com/brandonchartier/janet-markov"
                  :ref "fec35e81747ae0f196c4885fedfa41350474ecb3"}])

(declare-executable
  :name "jobot"
  :entry "main.janet")
