sqlite3 = require("sqlite3").verbose()
db = new sqlite3.Database("protestations.db")

massage = (dashedstring) ->
  [..., last] = dashedstring.split ' - '
  last.replace(/\[.*\]|\./g, "")

  
db.parallelize ->

  db.each "SELECT Title FROM records", (err, row) ->
    console.log massage row['Title']
    
db.close()
