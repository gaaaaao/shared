#!r6rs

;; op data structure
;; an op is a list of (str num str func)
;; which are (name arity doc code)
(define (make-action name arity doc action) (list name arity doc action))
(define (op-name op) (car op))
(define (op-arity op) (cadr op))
(define (op-doc op) (caddr op))
(define (op-action op) (cadddr op))

;; action : line stack -> stack
;; given an input line and the current stack, take the action requested and return
;; the updated stack
(define (action line stack)
  (cond
   [(eof-object? line) (newline) (exit)]
   [(string->number line) => (lambda (n) (cons n stack))]
   [(asss/ci line action-list) => (lambda (a)
                                    (if (>= (length stack) (op-arity a))
                                        ((op-action a) stack)
                                        (begin
                                          (signal-error "stack underflow")
                                          stack)))]
   [else (signal-error "unknown operation") stack]))

(define action-list
  (list (make-action "." 1 "display top value on the stack"
                     (lambda (stack)
                         (display (car stack))
                         (newline)
                         stack))
        (make-action "#" 0 "display number of values on the stack"
                     (lambda (stack)
                         (display (length stack))
                         (newline)
                         stack))
        (make-action "+" 2 "replace top two values on the stack with their sum"
                       (lambda (stack) (cons (+ (cadr stack) (car stack)) (cddr stack))))
        (make-action "-" 2 "replace top two values on the stack with their difference"
                     (lambda (stack)
                       (cons (- (cadr stack) (car stack)) (cddr stack))))
        (make-action "*" 2 "replace top two values on the stack with their product"
                     (lambda (stack)
                       (cons (* (cadr stack) (car stack)) (cddr stack))))
        (make-action "/" 2 "replace top two values on the stack with their quotient"
                     (lambda (stack)
                       (cons (/ (cadr stack) (car stack)) (cddr stack))))
        (make-action "^" 2 "replace top two values on the stack, x and y, with x to the yth power "
                     (lambda (stack)
                       (cons (expt (car stack) (cadr stack)) (cddr stack))))
        (make-action "drop" 1 "remove top value from the stack"
                     (lambda (stack) (cdr stack)))
        (make-action "dup" 1 "duplicate top value on the stack"
                     (lambda (stack) (cons (car stack) stack)))
        (make-action "swap" 2 "swap top two values on the stack"
                     (lambda (stack)
                       (cons (cadr stack) (cons (car stack) (cddr stack)))))
        (make-action "help" 0 "show this help"
                     (lambda (stack)
                       (display (format "~a Commands:~%" (length action-list)))
                       (map (lambda (a) (display (format "  ~a -- ~a~%" (op-name a) (op-doc a)))) action-list)
                       stack))))

;; from (draga utils)
;; asss/ci : string alist -> alist or boolean
;; as assq, but uses string-ci=? for comparisons
(define (asss/ci str alist)
  (cond
   [(null? alist) #f]
   [(and (string? (caar alist)) (string-ci=? str (caar alist))) (car alist)]
   [else (asss/ci str (cdr alist))]))

;; signal-error : str -> void
;; given an error message, pass it to the user in a standardish way
(define (signal-error str)
  (display (format "*** ERROR: ~a~%" str)))

(define (rpn)
  (display "> ")
  (let ([in (current-input-port)])
    (let loop ([l (get-line in)]
               [s '()])
      (let ([new-s (action l s)])
        (display "> ")
        (loop (get-line in) new-s)))))
  
(rpn)
