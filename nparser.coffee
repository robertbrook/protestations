fs = require "fs"
csv = require "fast-csv"
request = require "request"
qs = require "querystring"
sqlite3 = require("sqlite3").verbose()

db = new sqlite3.Database("latlongs.db")
db.serialize ->
  db.run "DROP TABLE results"
  db.run "CREATE TABLE results (placename TEXT, yql TEXT)"
  
stream = fs.createReadStream("records.csv")

csvStream = csv()
.on "data", (data) ->
  target = massage data
  qstring = qs.stringify
    q: "SELECT * FROM geo.placefinder WHERE name='" + target + "' and locale='GB' | truncate(count=1)"
    format: "json"
  request 'http://query.yahooapis.com/v1/public/yql?' + qstring, (error, response, body) ->
#    console.log body
    db.run "INSERT INTO yql VALUES (?, ?)", [target, body]

stream.pipe csvStream

massage = (dashedstring) ->
  [..., last] = dashedstring[1].split ' - '
  last.replace(/\[.*\]|\./g, "")

db.close()

