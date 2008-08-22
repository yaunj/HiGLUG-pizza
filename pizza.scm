; HiGLUG Pizza order generator, scheme implementation.
; First: Handy vars.
(define prize-max 1200)
(define el-cheapo 119)
(define pizza-per-head 0.4)
(define menu
  (let ((pizzas '(("Pappas spesial" 4 159)
                  ("Texas"          3 149)
                  ("Blue Hawai"     7 149)
                  ("Floriad"        4 149)
                  ("Buffalo"        4 149)
                  ("Chicken"        4 149)
                  ("New York"       0 149)
                  ("Las Vegas"      6 149)
                  ("Vegetarianer"   0 149)
                  ("FILADELFIA"     4 149)
                  ("Hot Chicago"    7 149)
                  ("Hot Express"    5 149)
                  ("Kebab pizza spesial" 3 169)
                  ("Egenkomponert Pepperoni Biff Bacon Skinke løk"   9 159)
                  ("Egenkomponert Biff Pepperoni Bacon Skinke Tacokjøtt" 9 159)))
        (wednesday? (eq? 3 (date-week-day (seconds->date (current-seconds))))))
  (if wednesday?
      (map (lambda (pizza) (list (name pizza) (weight pizza) el-cheapo)) pizzas)
      pizzas)))

(define (name pizza)   (car pizza))
(define (weight pizza) (car (cdr pizza)))
(define (price pizza)  (car (cdr (cdr pizza))))

; Stolen! Used to randomize the list of choices.
(define *rand* 42)
(define (browse-random)
  (set! *rand* (remainder (* *rand* 17) 251))
  *rand*)
(define (randomize l)
  (do ((a '())) ((null? l) a)
   (let ((n (remainder (browse-random) (length l))))
    (cond ((zero? n)
	   (set! a (cons (car l) a))
	   (set! l (cdr l))
	   l)
	  (else (do ((n n (- n 1)) (x l (cdr x)))
		  ((= n 1)
		   (set! a (cons (cadr x) a))
		   (set-cdr! x (cddr x))
		   x)))))))

; Creates new list of choices, where each pizza is inserted n times,
; where n is the weight given in the menu.
(define (get-weighted-list pizzas)
  (define (cons-n-times elem n lst)
    (if (eq? 0 n)
        lst
        (cons elem (cons-n-times elem (- n 1) lst))))
  (if (null? pizzas)
      pizzas
      (cons-n-times (car pizzas) (weight (car pizzas))
                    (get-weighted-list (cdr pizzas)))))

(define (create-order desired-amount choices)
  ; Basically cons-n-times but with a prize check.
  (define (add-n-to-order n current-price)
    (let ((pizza (list-ref choices (random (length choices))))
          (new-total (delay (+ current-price (price (car choices))))))
      (if (or (> (force new-total) prize-max) (eq? 0 n))
          '() ; NO MOAR FOR YOU!
          (cons pizza (add-n-to-order (- n 1) (force new-total))))))
  (add-n-to-order desired-amount 0))

(define (print-order-line pizza)
  (display "NOK ")
  (display (price pizza))
  (display ": ")
  (display (name pizza))
  (newline)
  pizza)

(define (foldl fn default lst)
  (if (null? lst)
    default
    (foldl fn (fn default (car lst)) (cdr lst))))

; Get number of pizzas to order.
(define (get-peeps)
  (if (> (vector-length (current-command-line-arguments)) 0)
      (string->number (vector-ref (current-command-line-arguments) 0))
      ((lambda ()
         (display "Number of peoples: ")
         (read)))))

; Create the order based on how many people we are and the randomized list.
(define order
  (create-order (inexact->exact (ceiling (* pizza-per-head (get-peeps))))
                (randomize (get-weighted-list menu))))
(map print-order-line order)
(display "--------\nTOT ")
(display (foldl + 0 (map price order)))
(newline)
