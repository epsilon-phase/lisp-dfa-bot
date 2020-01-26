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
      (name-suffixes (:seq "\-The"
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
      (location-suffix (:choice "" (:seq "/;" (:call location-name))))
      (temple (:choice "temple" "lamissary"))
      (city-adjectives "")
      (city (:seq (:call city-adjectives) (:choice "town" "capital")))
      (fortress (:choice "fort" "castle" "post" "citadel" "mesa"))
      (location-type (:choice (:call fortress) (:call city) (:call fortress)))
      (preposition (:choice "before" "at" "upon"))
      (location (:seq (:call location-type) (:call location-suffix) (:choice "" (:seq (:call preposition) "the" (:call terrain)))))
      )))
