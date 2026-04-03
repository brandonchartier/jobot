(import ./config :as c)
(import ./db)
(import http)
(import spork/json)
(import url)

(def- not-empty?
  (comp not empty?))

(defn- sample
  "Returns a random item from an indexed data structure."
  [ind]
  (let [rdm (os/cryptorand 10)
        len (length ind)
        idx (math/rng-int (math/rng rdm) len)]
    (in ind idx)))

(defn- request
  "Helper function for making HTTP requests."
  [url]
  (let [response (http/get url)]
    (match (response :status)
      200 (json/decode (response :body))
      _ "not found")))

(defn- image-url
  [query]
  (url/format
    :scheme "https"
    :host "www.googleapis.com"
    :path "/customsearch/v1"
    :query {:key (c/config :google-key)
            :cx (c/config :google-cx)
            :q query
            :searchType "image"}))

(defn google-image
  "Provided a search term,
   makes a request to Google APIS and returns a link."
  [query]
  (match (request (image-url query))
    {"items" data}
    (in (sample data) "link")
    _ "not found"))

(def- weather-codes
  {0 "Clear sky"
   1 "Mainly clear" 2 "Partly cloudy" 3 "Overcast"
   45 "Fog" 48 "Depositing rime fog"
   51 "Light drizzle" 53 "Moderate drizzle" 55 "Dense drizzle"
   61 "Slight rain" 63 "Moderate rain" 65 "Heavy rain"
   66 "Light freezing rain" 67 "Heavy freezing rain"
   71 "Slight snow" 73 "Moderate snow" 75 "Heavy snow"
   77 "Snow grains"
   80 "Slight rain showers" 81 "Moderate rain showers" 82 "Violent rain showers"
   85 "Slight snow showers" 86 "Heavy snow showers"
   95 "Thunderstorm" 96 "Thunderstorm with slight hail" 99 "Thunderstorm with heavy hail"})

(defn- weather-url
  [lat-long]
  (let [[lat long] (string/split "," lat-long)]
    (url/format
      :scheme "https"
      :host "api.open-meteo.com"
      :path "/v1/forecast"
      :query {:latitude lat
              :longitude long
              :current_weather "true"
              :temperature_unit "fahrenheit"})))

(defn weather
  "Provided the name of a city and its lat,long string,
   makes a request to the Open-Meteo API,
   returning a description of the weather."
  [name lat-long]
  (match (request (weather-url lat-long))
    {"current_weather" data}
    (string/format
      "%s: %d° %s"
      name
      (math/round (in data "temperature"))
      (get weather-codes (in data "weathercode") "Unknown"))
    _ "not found"))

(def- news-sources
  (string/join (c/config :news-sources) ","))

(def- news-url
  (url/format
    :scheme "https"
    :host "newsapi.org"
    :path "/v2/top-headlines"
    :query {:apiKey (c/config :news-key)
            :sources news-sources}))

(defn news
  "Creates a request to News API
   and returns a random headline."
  []
  (match (request news-url)
    {"articles" data}
    (in (sample data) "title")
    _ "not found"))

(defn select-random
  "Queries DB logs using LIKE."
  [query to]
  (let [q (string "%" query "%")]
    (match (db/select-random q to)
      {:sent_by by :message msg}
      (string "<" by "> " msg)
      _ "not found")))
