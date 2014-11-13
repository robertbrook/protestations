map = L.map("map").setView([
  51.505
  -0.09
], 8)

L.tileLayer("http://api.tiles.mapbox.com/v4/robertbrook.k6mnk6k8/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoicm9iZXJ0YnJvb2siLCJhIjoiQ3poVXdJTSJ9.yGKvwJFPE9vuqs606-byrA",
  attribution: "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"
  maxZoom: 18
).addTo map

district_boundary = new L.geoJson()
district_boundary.addTo map
$.ajax
  dataType: "json"
  url: "file.json"
  success: (data) ->
#    console.log data
    $(data.features).each (key, data) ->
      district_boundary.addData data
      
      
yql_url = "https://query.yahooapis.com/v1/public/yql"
oldurl = "https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/electoral/eng/wpc.json"
url = "http://martinjc.github.io/UK-GeoJSON/json/eng/topo_wpc.json"
wpc = new L.geoJson()
wpc.addTo map
$.ajax
  url: yql_url
  data:
    q: "SELECT * FROM json WHERE url=\"" + url + "\""
    format: "json"
    jsonCompat: "new"
  dataType: "jsonp"
  success: (data) ->
    $(data.features).each (key, data) ->
      wpc.addData data
      




