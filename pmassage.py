import fileinput
import csv
import sys
import time
import requests

for line in fileinput.input("protestations.csv", inplace=0):
  for row in csv.reader([line]):
    if len(row) > 9:
      target = row[9]
      time.sleep(2)
      payload = {'q': "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)", 'format': 'json'}

      r = requests.get("http://query.yahooapis.com/v1/public/yql", params=payload)
      j = r.json()

      if j['query']['count'] == 1:
        mylat = j['query']['results']['Result']['latitude']
        mylon = j['query']['results']['Result']['longitude']
        latlon = mylat + ", " + mylon
        print "yahooll: " + latlon
      

      else:
        print "nothing for " + target
#   sys.stdout.write(line)
