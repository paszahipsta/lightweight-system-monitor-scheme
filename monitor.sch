(import spiffy intarweb uri-common shell srfi-13)

(define (basic-info)
(capture "uname -a")
)

(define (sensors)
  (capture sensors)
)

(define x (list (sensors) (basic-info)))

(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
    (if (equal? (uri-path uri) '(/ "gret"))
        (send-response status: 'ok body: (string-join x " ") )
	(continue))))

(vhost-map `(("localhost" . ,handle-greeting)))


(server-port 8080)
(start-server)
