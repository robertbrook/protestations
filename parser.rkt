#lang racket
(require (planet neil/csv:2:0) racket/future)

(define in-square-brackets
  (regexp "\\[.*\\]"))

(define full-stop
  (regexp "\\."))

(define (line->place line)
  (let* (
         [this (string-split (second line) " - ")]
         [this (regexp-replace full-stop (last this) "")]
         [this (regexp-replace in-square-brackets this "")]
         )
    this)
  )

(define out (open-output-file "urls.txt" #:exists 'truncate))

(for-each 
 (lambda (line)
   ;(thread (lambda () (displayln (format "http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20geo.placefinder%20WHERE%20name%3D%22~a%22%20and%20locale%3D%22GB%22%20%7C%20truncate(count%3D1)&format=json" (line->place line)) out)))
   (thread (lambda () (displayln (line->place line))))
   ) 
 (cdr
  (csv->list 
   (open-input-file "records.csv"))))

(close-output-port out)