(function(){var e;e=L.map("map").setView([52,-1],8),L.tileLayer("http://api.tiles.mapbox.com/v4/robertbrook.k6mnk6k8/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoicm9iZXJ0YnJvb2siLCJhIjoiQ3poVXdJTSJ9.yGKvwJFPE9vuqs606-byrA",{attribution:'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://mapbox.com">Mapbox</a>',maxZoom:18}).addTo(e),$.ajax({dataType:"json",url:"file.json",success:function(r){var o;return o=L.geoJson(r,{onEachFeature:function(e,r){return r.bindPopup("<b>"+e.properties.name+"</b><br>"+e.properties.reference+"<br>Source: "+e.properties.source+"<br>"+(e.properties.href||""))}}).addTo(e)}})}).call(this);
//# sourceMappingURL=./logic.js.map