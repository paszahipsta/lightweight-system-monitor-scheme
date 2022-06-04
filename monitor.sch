(import spiffy intarweb uri-common shell srfi-152 srfi-1)

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
    ((equal? command `RAM) (capture "procinfo -H GiB | grep RAM"))
    (else "error"))
    "invalid type"))


(define (memory-info)
(define divided (string-split (get-output `RAM) " "))
(define titles (list "Memory" "Total:" "Used:" "Free:" "Buffers:"))
(define (clear-empty div)
  (delete " " (delete "" divided)))

(define (create-output i titles divided-list)
  (if (< i 5)
  (string-join (list (list-ref titles i) (list-ref divided-list i) "<li>" (create-output (+ 1 i) titles divided-list)) " ")
  "Health good"
  )

)

(create-output 0 titles (clear-empty divided))


)

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
    ((equal? type `temperature) (string-join (list "<p>" "Temperature:" (temp-info) "°C" "</p>") " "))
    ((equal? type `os ) (string-join (list "<p>" "Operating System:" (system-info) "</p>") " "))
    ((equal? type `user) (string-join (list "<p>User:" (user-info) "</p></br>") " "))
    ((equal? type `RAM) (string-join (list "<p>" (memory-info) "</p>") " "))
    (else "error"))
    "invalid type"))


(define (get-mainpage)
(string-join (list 
  "<head><meta charset=\"utf-8\"></head>"
  (get-content `temperature)
  (get-content `os)
  (get-content `user)
  (get-content `RAM)
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