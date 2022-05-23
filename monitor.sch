(import spiffy intarweb uri-common shell)

(define (app)
  (capture sensors)
)

(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
    (if (equal? (uri-path uri) '(/))
        (send-response status: 'ok body: (app) )
	(continue))))

(vhost-map `(("localhost" . ,handle-greeting)))

(server-port 8080)
(start-server)
