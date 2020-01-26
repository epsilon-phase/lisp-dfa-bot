;;;; lisp-dfa-bot.lisp

(in-package #:lisp-dfa-bot)
#|
 | Syntax desired:
 | <rule> = (rule <name> <body>);
 | <body> = (seq <body>+)
 |        | (choice <body>+)
 |        | (store <name> <body>)
 |        | (retrieve <body>)
 |        | (call <name>);
|#

(defstruct automaton
           (rules (make-hash-table :test 'equal)))
(defun get-rule(automaton name)
  (gethash name (automaton-rules automaton))
  )
(defun compile-bot(rules)
  (let ((a (make-automaton)))
    (loop for i in rules
          do(compile-rule a i))
    a
    ))
(defun run-rule(bot name)
  (funcall (gethash name (automaton-rules bot)) bot (make-hash-table)))

(defun compile-rule(automaton body)
  (destructuring-bind (name body) body
      (setf (gethash name (automaton-rules automaton))
            (compile nil
                     `(lambda (automaton store)
                        ,(compile-body body))))))

(defun compile-body(item)
  (if (stringp item)
      item
      (case (car item)
        (:seq (compile-sequence (cdr item)))
        (:choice (compile-choice (cdr item)))
        (:store (compile-store (cdr item)))
        (:retrieve (compile-retrieve (cdr item)))
        (:call (compile-call (cdr item)))
        ))
  )
(defun compile-sequence(contents)
  (cons 'list
        (loop for i in contents
              collect (compile-body i))))
(defun compile-choice(contents)
  (append
   `(case (random ,(length contents)))
   (loop for i in contents
         for idx from 0
         collect (list idx (compile-body i)))))
(defun compile-store(contents)
  (destructuring-bind (name body) contents
  `(setf (gethash ',name store)
         ,(compile-body body))))
(defun compile-retrieve(contents)
  (destructuring-bind (name) contents
    `(gethash ',name store)))
(defun compile-call(contents)
  (destructuring-bind (name) contents
    `(funcall (get-rule automaton ',name) automaton store)))


(export '(compile-body compile-bot run-rule))
