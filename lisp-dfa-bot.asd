;;;; lisp-dfa-bot.asd

(asdf:defsystem #:lisp-dfa-bot
  :description "Define a tracery like text generator"
  :author "Violet White <violet.white.dammit@protonmail.com>"
  :license  "GPL v3"
  :version "0.0.1"
  :serial t
  :depends-on ("alexandria")
  :components ((:file "package")
               (:file "lisp-dfa-bot")))
