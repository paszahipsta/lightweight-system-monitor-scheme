(import spiffy intarweb uri-common shell)

(define (basic-info)
(capture "uname -a")
)

(define (sensors)
  (capture sensors)
)




(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
    (if (equal? (uri-path uri) '(/ "gret"))
        (send-response status: 'ok body: (sensors) (basic-info) )
	(continue))))

(vhost-map `(("localhost" . ,handle-greeting)))


(server-port 8080)
(start-server)
