#lang racket
(require (planet neil/csv:2:0))
(require (planet neil/webscraperhelper:1:2))

(define protestations
  (csv->list (open-input-file "records.csv")
             ))

