(in-package #:lisp-dfa-example)
(defun visibility-from(status)
  (if (eq (tooter:visibility status) :public)
      :unlisted
      (tooter:visibility status)))
(defun poster(bot rule)
  (lambda()
    (glacier:post (lisp-dfa-bot:run-rule bot rule))))
(defun show-help(status)
  (glacier:reply status "!help Show this help
!list-rules Display rules that can be run"))
(defun list-rules(bot)
  (lambda (status)
    (glacier:reply status (apply #'concatenate
           (alexandria:flatten
            (list 'string
                  "Rules available:"
                  (loop for i being the hash-keys of (lisp-dfa-bot:automaton-rules bot)
                        collect(format nil "!~a~%" i)))))
                   :visibility (visibility-from status)))
  )
(defun rule-runner(bot rule)
  (lambda (status)
    (glacier:reply status
                   (lisp-dfa-bot:run-rule bot rule)
                   :visibility (visibility-from status))))
