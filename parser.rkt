#lang racket

(require json)
(require (planet neil/csv:2:0))

(define make-parishes-csv-reader
  (make-csv-reader-maker
   '(
     (strip-leading-whitespace?  . #t)
     (strip-trailing-whitespace? . #t))))

(define parishes-list
  (csv->list (make-parishes-csv-reader (open-input-file "parishes.csv"))))

(define (element-xy->xy element-xy)
  (string->number (regexp-replace* #rx"," element-xy "")))

(define features
  (csv-map (lambda (values)
             (hash 'type "Feature"
                   'geometry
                   (hash 'type "Point"
                         'coordinates 
                         (list (element-xy->xy (list-ref values 15))
                               (element-xy->xy (list-ref values 16))))
                   'properties
                   (hash 
                    'name (list-ref values 0)
                    'area-code (list-ref values 1)
                    'description (list-ref values 2)
                    'file-name (list-ref values 3)
                    'number (list-ref values 4)
                    'number-0 (string->number (list-ref values 5))
                    'polygon-id (list-ref values 6)                         
                    'unit-id (list-ref values 7)
                    'code (list-ref values 8)
                    'hectares (list-ref values 9)
                    'area (list-ref values 10)
                    'type-code (list-ref values 11)
                    'description-0 (list-ref values 12)
                    'type-code-0 (list-ref values 13)
                    'description-1 (list-ref values 14)
                    'longitude (list-ref values 15)
                    'latitude (list-ref values 16)
                    )
                   ))
           
           (make-parishes-csv-reader (open-input-file "parishes.csv"))))

(define out-port (open-output-file "parishes.geojson"
                                   #:exists 'update))

(write-json (hash 'type "FeatureCollection" 'features features) out-port)

(display "done")

