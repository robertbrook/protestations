do http://reb4.me/r/altjson

lines: read/lines %records.csv

foreach line lines [
        lineblock: parse/all line ","
        ; print parse first lineblock "/"
        titleparts: parse pick lineblock 2 " - "
        target: last titleparts
        replace target "." ""
        targeturl: join "http://nominatim.openstreetmap.org/search/?format=json&email=robertbrook@fastmail.fm&countrycodes=gb&q=" target
        
    
        pagestring: to-string read to-url targeturl
        jtags: load-json/flat pagestring
        probe first first jtags
    ]
