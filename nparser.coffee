csv = require "fast-csv"
request = require "request"
qs = require "querystring"
fs = require 'fs'
cconv = require 'cconv' # ENs to LLs in parish csv
sleep = require 'sleep'

stream = fs.createReadStream("records.csv")

#http://c2fo.github.io/fast-csv/

csvStream = csv.createWriteStream(headers: true)
writableStream = fs.createWriteStream("out.csv")
writableStream.on "finish", ->
  csvStream.end()
  console.log "finished"
  
csvStream.pipe writableStream

parse = () ->
  csv.fromStream stream
  .validate (data) ->
   data[0].length > 0
  .on "data-invalid", (data) ->
   console.log "invalid data: " + data[1]

  .on "data", (data) ->
#   console.log data
    yql data
    #os data
    osm data
    #google data
    #edina data
    console.log data[0]
  .on "end", ->
    console.log "parsers running"
 
massage = (dashedstring) ->
  [..., last] = dashedstring[1].split ' - '
  last.replace(/\[.*\]|\./g, "")

yql = (data) ->
  target = massage data
  console.log "yql"
  qstring = qs.stringify
    q: "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)"
    format: "json"
  request 'http://query.yahooapis.com/v1/public/yql?' + qstring, (error, response, body) ->
   jsonbody = JSON.parse body
   if jsonbody.query
     if jsonbody.query.count
       result = jsonbody.query.results.Result
       csvStream.write
         target: target
         src: "YQL"
         lat: result.latitude
         lng: result.longitude
   
osm = (data) ->
  sleep.sleep 2
  target = massage data
  qstring = qs.stringify
    format: "json"
    email: "robertbrook@fastmail.fm"
    countrycodes: "gb"
    q: target
  request 'http://nominatim.openstreetmap.org/search/?' + qstring, (error, response, body) ->
    console.log body
    jsonbody = JSON.parse body
    
    firstresult = jsonbody[0]
    if firstresult
      csvStream.write
        target: target
        src: "OSM"
       lat: firstresult.lat
       lng: firstresult.lon
  
os = (data) ->
  target = massage data
  if target isnt ""
    qstring = qs.stringify
      query: target
    request 'http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search?' + qstring, (error, response, body) ->
     jsonbody = JSON.parse body
   
     results = (item for item in jsonbody.results when item.type is "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish")
     
     if results.length > 0
       firstresult = results[0]
       csvStream.write
         target: target
         src: "OSM"
         lat: firstresult.latitude
         lng: firstresult.longitude
         
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

edina = (data) ->
  target = massage data
  console.log ["EDI", target, "0.0", "0.0"]

parse()