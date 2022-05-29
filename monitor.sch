(import spiffy intarweb uri-common shell srfi-13)

(define (basic-info)
(string-join (list "Operating system:" (capture "uname -o")))
)



(define (sensors)
 (substring? (capture sensors) "temp1")
)




(define x (list (sensors) (basic-info)))

(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
	(send-response status: 'ok body: (string-join x " "))))

(vhost-map `(("localhost" . ,handle-greeting)))

(sensors)
(server-port 8080)
(start-server)