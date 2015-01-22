import apsw
import requests
import time

connection=apsw.Connection("protestations.db")
connection.setbusytimeout(100000)
cursor=connection.cursor()

for target, yahooll, catref in cursor.execute('select target, YahooLL, "Catalogue Reference" from records'):
    time.sleep(2)
    payload = {'q': "SELECT * FROM geo.placefinder WHERE text='" + target + "' and countrycode='GB' | truncate(count=1)", 'format': 'json'}

    r = requests.get("http://query.yahooapis.com/v1/public/yql", params=payload)
    j = r.json()

    if j['query']['count'] == 1:
      mylat = j['query']['results']['Result']['latitude']
      mylon = j['query']['results']['Result']['longitude']
      latlon = mylat + ", " + mylon
      print latlon
      cursor.execute('UPDATE records SET YahooLL=? WHERE "Catalogue Reference"=?', (latlon, catref))

    else:
      print "nothing for " + target
      

   
connection.close(True)
