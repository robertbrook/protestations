request = require('request')
sleep = require('sleep')
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("protestations.db")
qs = require "querystring"
http = require "http"
csv = require "fast-csv"

#console.log process.argv.slice(2)

massage = (dashedstring) ->
  [..., last] = dashedstring.split ' - '
  last.replace(/\[.*\]|\./g, "")

populatetargets = () ->
  db.parallelize ->

    db.each "SELECT * FROM records", (err, row) ->
      target = massage row['Title']
      console.log row['Catalogue Reference']
      db.run """
      UPDATE records
      SET target = "#{target}"
      WHERE "Catalogue Reference" is '#{row['Catalogue Reference']}';
      """

populateNominatimLL = () ->

  db.each "SELECT * FROM records", (err, row) ->
    target = row['target']
   
    request "http://nominatim.openstreetmap.org/search?format=json&q=#{target}&countrycodes=gb&limit=1", (error, response, body) ->
     
      if not error and response.statusCode is 200
        console.log target
        console.log row['_rowid_']
        myjson = JSON.parse body
        if myjson.length > 0
          mylat = myjson[0].lat
          mylon = myjson[0].lon
          myresult = [mylat, mylon]
          console.log myresult
          db.run """
          UPDATE records
          SET "NominatimLL" = "#{mylat}, #{mylon}"
          WHERE "Catalogue Reference" is '#{row['Catalogue Reference']}';
          """
      sleep.sleep 2

      
populateYahooLL = () ->

  db.each "SELECT * FROM records", (err, row) ->
    target = row['target']
    console.log [target, row['Catalogue Reference']]

    qstring = qs.stringify
      q: "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)"
      format: "json"
        
    request 'http://query.yahooapis.com/v1/public/yql?' + qstring, (error, response, body) ->
      if not error and response.statusCode is 200
        
        jsonbody = JSON.parse body
        if jsonbody.query
          if jsonbody.query.count > 0
            result = jsonbody.query.results.Result
            mylat: result.latitude
            mylon: result.longitude
            console.log [mylat, mylon]
            
    sleep.sleep 2
      
populateYahooLL()   



#db.close()




