; Common Lisp version (tested using clisp), author: Rune Hammersland
(defun discountp (name)
  (let ((wednesday (= 2 (nth-value 6 (get-decoded-time))))
        (egenkomp  (search "egenkomponert" (string-downcase name))))
    (and wednesday (not egenkomp))))

; Generic class
(defclass pappas-snusk ()
  ((%name  :initform "" :initarg :name  :accessor name)
   (%price :initform 0  :initarg :price :accessor price)))
(defmethod print-object ((p pappas-snusk) (s stream))
  (format s "~60a (NOK ~3d)" (name p) (price p)))

; Pizzas can be discounted
(defclass pizza (pappas-snusk)
  ((%weight :initform 0 :initarg :weight :accessor weight)))
(defmethod price ((pizza pizza))
  (if (discountp (name pizza))
    119
    (slot-value pizza '%price)))

(defclass sauce (pappas-snusk)
  ((%name  :initform "Snuskete saus")
   (%price :initform 20  :initarg :price :accessor :price)))
; Probability of sauce
(defun saucep () 
  (< (random 1.0) 0.7))

; Weighted list of pizzas
(defparameter *choices*
  (loop :for p :in
        ;  NAME        WEIGHT PRICE
        '(("Pappas spesial" 4 159)
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
          ("Egenkomponert Pepperoni Biff Bacon Skinke løk"       9 159)
          ("Egenkomponert Biff Pepperoni Bacon Skinke Tacokjøtt" 9 159))
        ;              Insert WEIGHT times
        :collect (loop :repeat (first (rest p))
                       :collect (make-instance 'pizza :name (first p)
                                               :price (first (last p))))))
; Randomize choices
(defparameter *choices* (reduce #'append *choices* :from-end '()))
(sort *choices* (lambda (a b) (= 0 (random 2))))

; Get number of people and calculate wanted amount of pizzas
(write-string "Number of dudes: " *standard-output*)
(defvar *wanted* (ceiling (* 0.4 (parse-integer (read-line *standard-input*)))))
(defvar *max-price* 1200)

; Create order, respecting max-price
(defun create-order (wanted max-price)
  (defun inc-order (n total)
    (let* ((pizza (nth (random (length *choices*)) *choices*))
           (sum (+ total (price pizza))))
      (if (or (= 0 n) (< max-price sum))
        '() ; NO MOAR
        (cons pizza (inc-order (- n 1) sum)))))
    (inc-order wanted 0))

(defun sum-order (order) (reduce #'+ (mapcar #'price order)))
; I can has sauce overflow?
(defun sauce-it-up (order)
  (let ((total (sum-order order))
        (sauce (make-instance 'sauce)))
    (append order (loop :repeat (length order)
                        :when (or (< *max-price* (+ total (price sauce)))
                                  (saucep))
                        :collect sauce))))

; Create and print order
(defparameter *order* (sauce-it-up (create-order *wanted* *max-price*)))
(format t "~{~a~%~}" *order*)
(format t "~70~~%")
(format t "~59a (NOK ~4d)~%" "TOTAL" (sum-order *order*))
; For added coolness
(let ((natural (format nil "~r" (sum-order *order*))))
  (format t "~va~a" (- 70 (length natural)) #\Space natural))
