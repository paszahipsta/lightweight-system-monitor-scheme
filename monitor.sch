(import spiffy intarweb uri-common shell srfi-152)

(define (basic-info)
(string-join (list "Operating system:" (capture "uname -o")))
)


(define (get-output command)
  (if (symbol? command)
  (cond
    ((equal? command `sensors) (capture "sensors"))
    ((equal? command `uname) (capture "uname -o"))
    (else "error"))
    "invalid type"))


(define (temp-info)
  (define index-x (string-contains (get-output `sensors) "+"))
  (define index-z (string-contains (get-output `sensors) "rpi_volt"))
  (define cut-string (string-replace (get-output `sensors) "" 0 index-x))
  (string-trim-both 
    (string-replace 
      cut-string "" (- index-z index-x) (string-length cut-string))
    )
  )

(define (get-content type)
  (if (symbol? type)
  (cond
    ((equal? type `temperature) (string-join (list "Temperature:" (temp-info)) "     " ))
    ((equal? type `uname ) (capture "uname -o"))
    (else "error"))
    "invalid type"))

   
 
 
 (define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
	(send-response status: 'ok body: (get-content `temperature))))

(vhost-map `(("localhost" . ,handle-greeting)))

(display (get-content `temperature))
(server-port 8080)
(start-server)