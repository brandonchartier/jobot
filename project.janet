(declare-project
  :name "jobot"
  :description "An IRC bot"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["json"
                 "process"
                 "uri"
                 "https://github.com/brandonchartier/janet-irc-client"])

(declare-executable
  :name "jobot"
  :entry "main.janet")
