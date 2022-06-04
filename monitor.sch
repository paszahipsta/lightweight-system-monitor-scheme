(import spiffy intarweb uri-common shell srfi-152 srfi-1)


(define (count-elements list)
(if (null? list)
      0
      (+ 1 (count-elements (cdr list)))))



(define (get-output command)
  (if (symbol? command)
  (cond
    ((equal? command `sensors) (capture "sensors"))
    ((equal? command `uname) (capture "uname -o"))
    ((equal? command `poweroff) (capture "sudo shutdown -h now"))
    ((equal? command `reboot) (capture "sudo reboot"))
    ((equal? command `user) (capture whoami))
    ((equal? command `RAM) (capture "procinfo -H GiB | grep RAM"))
    ((equal? command `processor) (capture "procinfo | grep -E '(user|system|IOwait|idle)'"))
    (else "error"))
    "invalid type"))

(define (clear-empty div)
    (delete " " (delete "" div)))

(define (memory-info)
  (define divided (string-split (get-output `RAM) " "))
  (define titles (list "Memory" "Total:" "Used:" "Free:" "Buffers:"))
  (define (create-output i titles divided-list)
    (if (< i (count-elements titles))
    (string-join (list (list-ref titles i) (list-ref divided-list i) "<li>" (create-output (+ 1 i) titles divided-list)) " ")
    "Health good"
    )
  )

  (create-output 0 titles (clear-empty divided))
)

(define (processor-info)
  (define titles (list "User" "System" "IOwait" "idle"))
  (define divided (string-split (get-output `processor) " "))
  (display (delete ":" (clear-empty divided)))  
  (define (create-output i a titles divided-list)
  (if (< i (count-elements titles))
  (string-join (list (list-ref titles i) (list-ref divided-list a) (create-output (+ 1 i) (+ a 6) titles divided-list)) " ")
  " " 
  )
  )
  (create-output 0 2 titles (delete ":" (clear-empty divided)))
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
    ((equal? type `user) (string-join (list "<p>User:" (user-info) "</p>") " "))
    ((equal? type `RAM) (string-join (list "<p>" (memory-info) "</p>") " "))
    ((equal? type `processor) (string-join (list "<p>" (processor-info) "</p>") " "))
    (else "error"))
    "invalid type"))


(define (get-mainpage)
(string-join (list 
  "<head><meta charset=\"utf-8\"></head>"
  (get-content `os)
  (get-content `user)
  (get-content `RAM)
  (get-content `processor)
  (get-content `temperature)
  "<button onclick=\"window.location.href='/poweroff'\">Power off</button>" 
  "<button onclick=\"window.location.href='/reboot'\">Reboot</button>"  
  )))   
 
 
(define (handle-greeting continue)
  (let* ((uri (request-uri (current-request))))
  (cond 
  ((equal? (uri-path uri) '(/ "poweroff")) (get-output `poweroff))
  ((equal? (uri-path uri) '(/ "reboot")) (get-output `reboot))
  (else (send-response status: `ok body: (get-mainpage))))))

(vhost-map `(("192.168.222.84" . ,handle-greeting)))


#(processor-info)
(server-port 8080)
(start-server)