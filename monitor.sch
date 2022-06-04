(import spiffy intarweb uri-common shell srfi-152 srfi-1)

;;; General use functions ;;;

;Count elements in the given list
(define (count-elements list)
(if (null? list)
      0
      (+ 1 (count-elements (cdr list)))))

; Clean the list from spaces and empty signs
(define (clear-empty div)
    (delete " " (delete "" div)))

;;; End of general use functions ;;; 

; Runs shell commands to retrieve system information
(define (get-output command)
  (if (symbol? command)
  (cond
    ((equal? command `sensors) (capture "sensors"))
    ((equal? command `uname) (capture "uname -o"))
    ((equal? command `poweroff) (capture "sudo shutdown -h now"))
    ((equal? command `reboot) (capture "sudo reboot"))
    ((equal? command `user) (capture "whoami"))
    ((equal? command `RAM) (capture "procinfo -H GiB | grep RAM"))
    ((equal? command `processor) (capture "procinfo | grep -E '(user|system|IOwait|idle)'"))
    ((equal? command `uptime) (capture "uptime -p"))
    (else "error"))
    "invalid type"))


; Retrieve information about RAM memory
; from standard output and style it for HTML
(define (memory-info)
  (define divided (string-split (get-output `RAM) " "))
  (define titles (list "Memory" "Total:" "Used:" "Free:" "Buffers:"))
  (define (create-output i titles divided-list)
    (if (< i (count-elements titles))
    (string-join (list "<li>" (list-ref titles i) (list-ref divided-list i) "</li>" (create-output (+ 1 i) titles divided-list)) " ")
    ""
    )
  )
  (create-output 1 titles (clear-empty divided))
)

; Retrieve information about processor
; from standard output and style it for HTML
(define (processor-info)
  (define titles (list "User:" "System:" "IOwait:" "Idle:"))
  (define divided (string-split (get-output `processor) " "))
  (define (create-output i a titles divided-list)
  (if (< i (count-elements titles))
  (string-join (list "<li>" (list-ref titles i) (list-ref divided-list a) "</li>" (create-output (+ 1 i) (+ a 6) titles divided-list)) " ")
  " " 
  )
  )
  (create-output 0 2 titles (delete ":" (clear-empty divided)))
)

; Retrieve information about operating system
; from standard output and style it for HTML
(define (system-info)
(get-output `uname)
)

; Retrieve information about temperature
; from standard output and style it for HTML
(define (temp-info)
  (define index-x (string-contains (get-output `sensors) "+"))
  (define index-z (string-contains (get-output `sensors) "°C"))
  (define cut-string (string-replace (get-output `sensors) "" 0 index-x))
  (string-trim-both 
    (string-replace 
      cut-string "" (- index-z index-x) (string-length cut-string))
    )
  )

; Retrieve information about user 
; from standard output and style it for HTML
(define (user-info)
(get-output `user)
)

; Retrieve information about uptime 
; from standard output and style it for HTML
(define (uptime-info)
(get-output `uptime)
)

; Styles the content of each information to be more readable
(define (get-content type)
  (if (symbol? type)
  (cond
    ((equal? type `temperature) (string-join (list "<p>" "<b>Temperature:</b>" (temp-info) "°C" "</p>") " "))
    ((equal? type `os ) (string-join (list "<p>" "<b>Operating System:</b>" (system-info) "</p>") " "))
    ((equal? type `user) (string-join (list "<p><b>User:</b>" (user-info) "</p>") " "))
    ((equal? type `RAM) (string-join (list "<p><b>RAM Memory:</b></p>" (memory-info)) " "))
    ((equal? type `processor) (string-join (list "<p><b>Processor Usage:</b></p>" (processor-info)) " "))
    ((equal? type `uptime) (string-join (list "<b>The device is" (uptime-info) "</b></br></br>") " "))
    (else "error"))
    "invalid type"))


; Part of HTML to add javascript, which will reload page every 15 seconds
(define (reload-page) 
"<script>
      function timeRefresh(time) {
        setTimeout(\"location.reload(true);\", time);
      }
timeRefresh(15000)    
</script>
"
)

; Part of HTML to add interactive buttons for rebooting and switching off device
(define (button type)
(if (symbol? type)
  (cond
    ((equal? type `poweroff) "<button onclick=\"window.location.href='/poweroff'\">Poweroff</button>")
    ((equal? type `reboot) "<button onclick=\"window.location.href='/reboot'\">Reboot</button>")
    (else "bad type"))
  "error"
  ))

; Building a HTML document for whole system monitor
; Returns the HTML formatted string
(define (get-mainpage)
(string-join (list 
  "<head><meta charset=\"utf-8\"></head>"
  (get-content `os)
  (get-content `user)
  (get-content `RAM)
  (get-content `processor)
  (get-content `temperature)
  (get-content `uptime)
  (button `poweroff)
  (button `reboot)
  (reload-page)
  )))   
 
; Handle all incoming requests
(define (handle-request continue)
  (let* ((uri (request-uri (current-request))))
  (cond 
  ((equal? (uri-path uri) '(/ "poweroff")) (get-output `poweroff))
  ((equal? (uri-path uri) '(/ "reboot")) (get-output `reboot))
  (else (send-response status: `ok body: (get-mainpage))))))


; Map server to IP and point to request handler
(vhost-map `(("192.168.222.84" . ,handle-request)))

; Select the port and start server
(server-port 80)
(start-server)