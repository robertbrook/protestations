import csv
import requests
import time
from random import randint

with open('protestations.csv', 'r') as f:
  
    reader = csv.reader(f)
    
    for row in reader:
      if reader.line_num > 1426:
      
#       THIS IS HOW FAR THE THING HAS RUN!!

        print reader.line_num

        if len(row) > 9:
          target = row[9]
          catref = row[0]
  
          time.sleep(randint(1,4))
          payload = {'address': target, 'region': 'GB'}
          r = requests.get("http://maps.googleapis.com/maps/api/geocode/json", params=payload)
          j = r.json()
          if len(j['results']) > 0:
          
            with open('google-results.csv', 'a') as csvfile:
              writer = csv.writer(csvfile)
              mylat = j['results'][0]['geometry']['location']['lat']
              mylon = j['results'][0]['geometry']['location']['lng']
              latlon = str(mylat) + ", " + str(mylon)
              print (catref, str(latlon))
              writer.writerow([catref, str(latlon)])

