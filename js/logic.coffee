map = L.map("map").setView([
  52
  -1
], 8)

L.tileLayer("http://api.tiles.mapbox.com/v4/robertbrook.k6mnk6k8/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoicm9iZXJ0YnJvb2siLCJhIjoiQ3poVXdJTSJ9.yGKvwJFPE9vuqs606-byrA",
  attribution: "Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://mapbox.com\">Mapbox</a>"
  maxZoom: 18
).addTo map


$.ajax
  dataType: "json"
  url: "file.json"
  success: (data) ->
    returns = L.geoJson(data,
#      style: (feature) ->
#        console.log feature
#        color: feature.properties.color

      onEachFeature: (feature, layer) ->
        layer.bindPopup "<b>#{feature.properties.name}</b><br>#{feature.properties.reference}<br>Source: #{feature.properties.source}<br>#{feature.properties.href || ''}"
    ).addTo map
    
    
    

      


  


