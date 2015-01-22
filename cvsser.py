import csv
import requests
import time

with open('protestations.csv', 'rb') as f:
  reader = csv.reader(f)
  for row in reader:
    target = row[9]
    time.sleep(2)
    payload = {'q': "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)", 'format': 'json'}

    r = requests.get("http://query.yahooapis.com/v1/public/yql", params=payload)
    j = r.json()

    if j['query']['count'] == 1:
      mylat = j['query']['results']['Result']['latitude']
      mylon = j['query']['results']['Result']['longitude']
      latlon = mylat + ", " + mylon
      print latlon
      

    else:
      print "nothing for " + target
        