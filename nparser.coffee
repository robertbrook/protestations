csv = require "fast-csv"
request = require "request"
qs = require "querystring"

csv.fromPath "records.csv"
.on "data", (data) ->
  yql data
  os data
  osm data
  #google data
  edina data
#.on "end", ->
#  console.log "ENDS"
 
massage = (dashedstring) ->
  [..., last] = dashedstring[1].split ' - '
  last.replace(/\[.*\]|\./g, "")

yql = (data) ->
  target = massage data
  qstring = qs.stringify
    q: "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)"
    format: "json"
  request 'http://query.yahooapis.com/v1/public/yql?' + qstring, (error, response, body) ->
   jsonbody = JSON.parse body
   if jsonbody.query
     if jsonbody.query.count
       result = jsonbody.query.results.Result
       console.log ["YQL", target, result.latitude, result.longitude]

     else
       "NO RESULT FOR " + target
   
osm = (data) ->
  target = massage data
  qstring = qs.stringify
    format: "json"
    email: "robertbrook@fastmail.fm"
    countrycodes: "gb"
    q: target
  request 'http://nominatim.openstreetmap.org/search/?' + qstring, (error, response, body) ->
   jsonbody = JSON.parse body
   firstresult = jsonbody[0]
   if firstresult
     console.log ["OSM", target, firstresult.lat, firstresult.lon]
   else
     "NO RESULT FOR " + target
  
os = (data) ->
  target = massage data
  qstring = qs.stringify
    query: target
  request 'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?' + qstring, (error, response, body) ->
   jsonbody = JSON.parse body
   
   results = (item for item in jsonbody.results when item.type is "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish")
   if results > 0
     firstresult = results[0]
     console.log ["OSV", target, firstresult.latitude, firstresult.longitude]
   else
     "NO RESULT FOR " + target

  
google = (data) ->
  target = massage data
  qstring = qs.stringify
    address: target
    region: "gb"
  request 'http://maps.googleapis.com/maps/api/geocode/json?' + qstring, (error, response, body) ->
   jsonbody = JSON.parse body
   results = jsonbody.results
   if results > 0
     firstresult = results[0]
     console.log ["GOO", target, firstresult.geometry.location.lat, firstresult.geometry.location.lng]
   else
     "NO RESULT FOR " + target

edina = (data) ->
  target = massage data
  console.log ["EDI", target, "edina_latitude", "edina_longitude"]
