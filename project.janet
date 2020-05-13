(declare-project
  :name "jobot"
  :description "An IRC client library"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies ["json"
                 "process"
                 "uri"
                 "https://github.com/brandonchartier/janet-queue"])

(declare-executable
  :name "jobot"
  :entry "main.janet")
