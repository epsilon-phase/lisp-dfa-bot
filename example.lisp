(in-package #:lisp-dfa-example)
(defparameter *bot*
   (lisp-dfa-bot:compile-bot
    '(
      (color (:choice "green" "blue" "yellow" "red"))
      (mountain-noun
       (:choice
        "hills"
        "foothills"
        "mount"
        (:seq
         (:choice "devil's"
          "angel's"
          "dickhead's"
          "broken"
          "shart")
         "mountain")
        (:seq (:choice "dragon's"
               "ogre's"
               "warlock's"
               "quaterback's"
               "")
         (:choice "teeth" "crag"))))
      (mountain (:seq
                 (:choice (:call color) "")
                 (:call mountain-noun)))
      (field (:choice "plains" "delta" "desert"))
      (terrain (:choice
                (:call mountain)
                (:call field)))
      (name-suffixes (:seq "\\-The"
                      (:choice "Destruction" "Motion" "Evaporation" "Dissolution" "Congregation"
                       "Attainment")
                      "of"
                      (:choice (:seq "Acid" (:choice "" "Rains"))
                       "Armies" "Efforts" "Goals" "Kings" "Queens" "Royalty")))
      (location-name (:seq "The"
                      (:choice "" "Dreaded" "Dreadful" "Hateful" "")
                      (:choice "Ghastly" "Remembered"
                       "Memorable" "Caustic"
                       "Wonderful" "Horrible"
                       "Mousey" "Chocolate"
                       "Momentary" "Compact"
                       "Expansive" "Hopeful"
                       "Moving" "Forgetting"
                       )
                      (:choice "Archives" "Yells" "Horses" "Whirls" "Greetings" "Barrows"
                       "Colors" "Mines" "Agreement" "Congregation" "Harrowing")
                      (:choice "" (:call name-suffixes))
                      ))
      (location-suffix (:choice "" (:seq "\\;" (:call location-name))))
      (temple (:choice "temple" "lamissary"))
      (city-adjectives (:choice "" "dingy" "dirty" "immaculate" "clean"
                        "poorly built" "well built" "shoddy" "stone"
                        "ruined" "silent"))
      (city (:seq (:call city-adjectives) (:choice "town" "capital")))
      (fortress (:choice "fort" "castle" "post" "citadel" "mesa"))
      (location-type (:choice (:call fortress) (:call city) (:call fortress)))
      (preposition (:choice "before" "at" "upon"))
      (location (:seq (:call location-type) (:call location-suffix) (:choice "" (:seq (:call preposition) "the" (:call terrain)))))
      (arrival (:choice "stumble into" "come upon" "arrive at" (:seq "look" (:choice "upon" "at"))))
      (actor-aggregate (:seq (:store actor-type (:choice "monk" "soldier" "politician" "kid" "artisan" "smith" )) "\\s"))
      (action-aggregate (:choice (:seq "eating" (:choice "lunch" "dinner" "breakfast"))
                         "marching"
                         (:seq "milling-around" (:choice "" (:seq "and"
                                                             (:choice "talking"
                                                                      (:seq "preparing a" (:choice "festival" "\n embankment" "camp"))))))))
      (actor-distinction (:choice ""
                          (:seq (:choice "very" "") "tall")
                          (:seq (:choice "slightly" "") "short")
                          "gangly" "thick-waisted"
                          "long-haired" "bald" "balding"))
      (actor-single (:choice "One" (:seq "A" (:call actor-distinction) (:retrieve actor-type))))
      (gift-quality (:choice "fine" "crude" "unusual" "average"))
      (metals (:choice "brass" "steel" "iron" "rusted" "copper" "tin" "strontium"
               (:seq "unusual" (:call 'color) "alloy")))
      (action-gift (:seq (:choice "" (:call gift-quality))
                    (:choice (:call metals) (:choice "watch" "clock")
                     (:s "clockwork" (:store clockwork
                                      (:choice "animal" "cat" "mouse" "bat" "bird"))
                      (:choice "" (:s "made of" (:ca metals)))
                      (:choice "" (:s "\\." (:c "it" (:s "the" (:r clockwork)))
                                      (:c "performs simple math problems"
                                          "chirps contentedly"
                                          "scrawls illegible fortunes in the dirt"
                                          "lets out a belch of flame before dismantling itself")))))))
      (action-gift-prefix (:c "says nothing and passes you a" "hands you a"
                           "laughs and hands you a" "tosses you a"
                           "gives you a :stuck_out_tongue_winking_eye: and hands you a"))
      (action-single (:c (:s "waves at you as you" (:c "approach" "pass"))
                       "offers you a meal"
                       (:s "gives you a" (:c "harsh" "curious") "look")
                       (:s (:ca action-gift-prefix) (:ca action-gift))
                       ))
      (action-total (:s (:c "there are" "you observe")
                     (:ca actor-aggregate)
                     (:ca action-aggregate) "\\."
                     (:ca actor-single) (:ca action-single) "\\."))
      (total (:s "You" (:ca arrival) (:c "a" "the") (:ca location) "\\." (:ca action-total)))
      )))
(defvar *poster* (make-instance 'glacier:mastodon-bot :config-file "basic.config"))
(defvar *current-thread*)
(defun run-bot()
  (glacier:run-bot (*poster*)
    (glacier:add-command "help" #'show-help
                         :add-prefix t)
    (glacier:add-command "list-rules" (list-rules *bot*) :add-prefix t)
    (loop for i being the hash-keys of (lisp-dfa-bot:automaton-rules *bot*)
          do(glacier:add-command (format nil "~a" i) (rule-runner *bot* i) :add-prefix t)
          do(glacier:add-command (format nil "explain-~a" i)
                                 (let ((rule i))
                                   (lambda(status)
                                   (glacier:reply status
                                                  (format nil "~s" (gethash rule (lisp-dfa-bot:automaton-rules-raw *bot*)))
                                                  :visibility (visibility-from status))))
                                 :add-prefix t))
    (glacier:after-every (30 :minutes)
      (glacier:post (lisp-dfa-bot:run-rule *bot* 'total)
                    :cw "Yet another text generator"
                    ))))
