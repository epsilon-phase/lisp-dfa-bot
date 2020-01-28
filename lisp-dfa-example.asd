(asdf:defsystem #:lisp-dfa-example
  :description "A simple example bot"
  :author "Violet white <violet.white.dammit@protonmail.com>"
  :license "GPL V3"
  :version "0.0.1"
  :serial t
  :build-operation "program-op"
  :build-pathname "example.exe"
  :entry-point "lisp-dfa-example:run-bot"
  :depends-on ("lisp-dfa-bot" "glacier")
  :components ((:file "example-package")
               (:file "example")))


#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))
