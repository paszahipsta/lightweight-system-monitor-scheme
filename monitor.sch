(import spiffy intarweb uri-common)

(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
    (if (equal? (uri-path uri) '(/ "greeting"))
        (send-response status: 'ok body: "<h1>Hello!</h1>")
	(continue))))

(vhost-map `(("localhost" . ,handle-greeting)))

(start-server)
