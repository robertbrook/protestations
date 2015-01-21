request = require('request')
sleep = require('sleep')
sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("protestations.db")

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
#  db.serialize ->

	db.each "SELECT * FROM records", (err, row) ->
		target = row['target']
		
		request "http://nominatim.openstreetmap.org/search?format=json&q=#{target}&countrycodes=gb&limit=1", (error, response, body) ->
		  
			if not error and response.statusCode is 200
				console.log target
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
      

populateNominatimLL()   
#db.close()

