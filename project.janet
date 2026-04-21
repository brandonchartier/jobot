(declare-project
  :name "jobot"
  :description "An IRC bot"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["spork"
                 "sqlite3"
                 ["https://github.com/joy-framework/http" :ref "0aa31e4f65756b6882e1e56cbcb585047fe97939"]
                 ["https://github.com/brandonchartier/janet-url" :ref "99553df0210bc97813d64e8456e8e7e37c932cdf"]
                 ["https://github.com/brandonchartier/janet-irc-client" :ref "64cc266d20fd783a5db9ba7b0e25337c14568c94"]
                 ["https://github.com/brandonchartier/janet-markov" :ref "fe7ddd99f9928761a19b1b0a3fe4d05545cc19da"]])

(declare-executable
  :name "jobot"
  :entry "main.janet")
