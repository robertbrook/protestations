import csv
import requests
import time
from random import randint

with open('protestations.csv', 'r') as f:
  
    reader = csv.reader(f)
    
    for row in reader:
      if reader.line_num > 161:

        print reader.line_num

        if len(row) > 9:
          target = row[9]
          catref = row[0]
  
          time.sleep(randint(1,4))
          payload = {'query': target}
          r = requests.get("http://data.ordnancesurvey.co.uk/datasets/os-linked-data/apis/search", params=payload)
          print r.status_code
          if r.status_code == 200:
						j = r.json()
					
					
						if len(j['results']) > 0:
							if j['results'][0]['type'] == "http://data.ordnancesurvey.co.uk/ontology/admingeo/CivilParish":

					
								with open('os-results.csv', 'a') as csvfile:
									writer = csv.writer(csvfile)
									mylat = j['results'][0]['latitude']
									mylon = j['results'][0]['longitude']
									latlon = str(mylat) + ", " + str(mylon)
									print (catref, str(latlon))
									writer.writerow([catref, str(latlon)])



