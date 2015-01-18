#lang racket

(require (planet neil/csv:2:0))
(require rackunit)

(define-syntax-rule (re-wiper re string)
  (regexp-replace re string "")
  )

(define (remove-bracketed-text text)
  (regexp-replace #rx"\\[.*\\]" text ""))

(check-equal? (remove-bracketed-text "Hello [World] again!") "Hello  again!" 
              "Removing bracketed text")

(define (parishes)
  (for/list ([csv (cdr (csv->list (open-input-file "records.csv")))])
    (let* ([csv/split (string-split (second csv) " - ")]
           [shire (second csv/split) ]
           [shire (remove-bracketed-text shire)]
           [parish (last csv/split)]
           [parish (string-trim parish ".")]
           [parish (string-trim parish #:repeat? #t)]
           [parish (re-wiper #rx"\\[.*\\]" parish)]
           )
      (string-append parish ", " shire))))
(parishes)