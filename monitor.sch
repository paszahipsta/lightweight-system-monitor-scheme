(import spiffy intarweb uri-common shell srfi-152)

(define (basic-info)
(string-join (list "Operating system:" (capture "uname -o")))
)


(define (get-output command)
  (if (symbol? command)
  (cond
    ((equal? command `sensors) (capture "sensors"))
    ((equal? command `uname) (capture "uname -o"))
    ((equal? command `poweroff) (capture "sudo shutdown -h now"))
    ((equal? command `reboot) (capture "sudo reboot"))
    ((equal? command `user) (capture whoami))
    (else "error"))
    "invalid type"))


(define (system-info)
(get-output `uname)
)

(define (temp-info)
  (define index-x (string-contains (get-output `sensors) "+"))
  (define index-z (string-contains (get-output `sensors) "°C"))
  (define cut-string (string-replace (get-output `sensors) "" 0 index-x))
  (string-trim-both 
    (string-replace 
      cut-string "" (- index-z index-x) (string-length cut-string))
    )
  )
(define (user-info)
(get-output `user)
)

(define (get-content type)
  (if (symbol? type)
  (cond
    ((equal? type `temperature) (string-join (list "<h6>" "Temperature:" (temp-info) "°C" "</h6>") " "))
    ((equal? type `os ) (string-join (list "<h6>" "Operating System:" (system-info) "</h6>") " "))
    ((equal? type `user) (string-join (list "User:" (user-info)) " "))
    (else "error"))
    "invalid type"))


(define (get-mainpage)
(string-join (list 
  "<head><meta charset=\"utf-8\"></head>"
  (get-content `temperature)
  (get-content `os)
  (get-content `user)
  "<button onclick=\"window.location.href='/poweroff'\">Power off</button>" 
  "<button onclick=\"window.location.href='/reboot'\">Reboot</button>"
  
  
  )))   
 
 
(define (handle-greeting1 continue)
  (let* ((uri (request-uri (current-request))))
  (if (equal? (uri-path uri) '(/ "poweroff"))
	(send-response status: 'ok body: (capture "sudo shutdown -h now"))
	(send-response status: 'ok body: (get-mainpage)))))

(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
  (cond 
  ((equal? (uri-path uri) '(/ "poweroff")) (get-output `poweroff))
  ((equal? (uri-path uri) '(/ "reboot")) (get-output `reboot))
  (else (send-response status: `ok body: (get-mainpage))))))

(vhost-map `(("192.168.222.84" . ,handle-greeting)))

(server-port 8080)
(start-server)