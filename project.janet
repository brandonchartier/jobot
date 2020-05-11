(declare-project
  :name "jobot"
  :description "An IRC client library"
  :author "Brandon Chartier"
  :url "https://github.com/brandonchartier/jobot"
  :repo "git+https://github.com/brandonchartier/jobot.git"
  :dependencies
    ["uri"
     "sh"
     "json"])

(declare-source
  :name "jobot"
  :source ["main.janet"])
