#lang racket

(require db
         net/url
         json)

(define mydb (sqlite3-connect #:database "protestations.db"))

(define (url->body myurl) (call/input-url (string->url myurl)
                                          get-pure-port
                                          port->string))

(query-exec mydb "select * from records")

