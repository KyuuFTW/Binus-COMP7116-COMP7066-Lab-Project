(deftemplate rumah
    (slot type)
    (slot room (type INTEGER))
    (slot price (type INTEGER))
    (slot location)
    (slot garage (type INTEGER))
    (slot match-rate (type INTEGER) (default 0))
    )

(deftemplate update
    (slot type)
    (slot room (type INTEGER))
    (slot price (type INTEGER))
    (slot location)
    (slot garage (type INTEGER))
    (slot index (type INTEGER))
    )

(deftemplate del
    (slot con (type INTEGER))
    (slot index (type INTEGER))
    )

(deftemplate with-garage
    (slot con)
    )

(deftemplate user-info
    (slot name)
    (slot gender)
    (slot interest)
    (slot location)
    (slot type)
    (slot income (type INTEGER))
    (slot carCount (type INTEGER))
    )

(defglobal ?*counter* = 0 )
(defglobal ?*position* = 0)

(deffacts data
    (rumah (type "Light House") (room 3) (price 10000) (location "West Jakarta") (garage 0) )
    (rumah (type "Cottage") (room 2) (price 5000) (location "North Jakarta") (garage 0) )
    (rumah (type "Skyscraper") (room 4) (price 100000) (location "West Jakarta") (garage 0) )
    (rumah (type "Light House") (room 3) (price 25000) (location "South Jakarta") (garage 0) )
    (rumah (type "Cottage") (room 3) (price 7500) (location "South Jakarta") (garage 0) )
    (rumah (type "Light House") (room 4) (price 7500) (location "West Jakarta") (garage 1) )
    (rumah (type "Skyscraper") (room 5) (price 175000) (location "South Jakarta") (garage 3) )
    (rumah (type "Cottage") (room 3) (price 4500) (location "North Jakarta") (garage 1) )
    (rumah (type "Light House") (room 2) (price 7500) (location "South Jakarta") (garage 2) )
    (rumah (type "Cottage") (room 3) (price 30000) (location "West Jakarta") (garage 2) )
    )

(defquery get-info
    (user-info (name ?name) (gender ?gender) (income ?income) (interest ?interest) (location ?location) (type ?type) (carCount ?carCount))
    )

(defquery get-result
    (rumah {match-rate > 0} (type ?type) (room ?roomNumber) (price ?price) (location ?location) (garage ?number) (match-rate ?match-rate))
    )

(deffunction val-int(?l ?r ?c)
    (if (and (numberp ?c) (and (>= ?c ?l) (<= ?c ?r)) ) then
        	(return TRUE)
        else
            (return FALSE)
    	)
    )

(deffunction menu()
    (printout t "================" crlf)
    (printout t "|| Beli Rumah ||" crlf)
    (printout t "================" crlf)
    (printout t "1. View House" crlf)
    (printout t "2. Add a New House" crlf)
    (printout t "3. Update House Detail" crlf)
    (printout t "4. Delete House" crlf)
    (printout t "5. Search Match" crlf)
    (printout t "6. Exit" crlf)
    (bind ?cmd 0)
    (while (eq (val-int 1 6 ?cmd) FALSE)
        (printout t ">> Input [1-6]: ")
        (bind ?cmd (read))
        )
	(return ?cmd)
    )

(deffunction print-format-string (?width ?str)
    (printout t "| ")
    (bind ?width (- ?width (str-length ?str)))
    (printout t ?str)
    (while (> ?width 0)
        (printout t " ")
        (bind ?width (- ?width 1))
        )
    )

(deffunction get-length-int(?x)
    (bind ?ret 0)
    (while (> ?x 0)
        (bind ?x (div ?x 10))
        (bind ?ret (+ ?ret 1))
        )
    (return ?ret)
    )

(deffunction print-format (?width ?str)
    (printout t "| ")
    (bind ?width (- ?width (get-length-int ?str)))
    (printout t ?str)
    (while (> ?width 0)
        (printout t " ")
        (bind ?width (- ?width 1))
        )
    )

(deffunction print-border(?width)
    (while (> ?width 0)
        (printout t "=")
        (bind ?width (- ?width 1))
        )
    (printout t crlf)
    )

(deffunction print-row (?no ?type ?room ?price ?location ?garage ?width)
    (print-format 3 ?no)
    (print-format-string ?width ?type)
    (print-format 6 ?room)
    (print-format 10 ?price)
    (print-format-string ?width ?location)
    (if (> ?garage 0) then
    	(print-format 8 ?garage)
    	)
    (printout t "|" crlf)
    )

(deffunction print-header (?no ?type ?room ?price ?location ?garage ?width)
    (print-format-string 3 ?no)
    (print-format-string ?width ?type)
    (print-format-string 6 ?room)
    (print-format-string 10 ?price)
    (print-format-string ?width ?location)
    (if (eq ?garage "Garage") then
        (print-format-string 8 ?garage)
        )
    (printout t "|" crlf)
    )

(defrule view
    (with-garage (con ?con))
    ?index<-(rumah (type ?type) (room ?room) (price ?price) (location ?location) (garage ?garage))
    =>
    (if (and (> ?garage 0) (eq ?con 1) ) then
        (bind ?*counter* (+ ?*counter* 1))
        (print-row ?*counter* ?type ?room ?price ?location ?garage 15)
        else (if (and (eq ?garage 0) (eq ?con 2)) then
             (bind ?*counter* (+ ?*counter* 1))
	         (print-row ?*counter* ?type ?room ?price ?location ?garage 15)
            )
        )
    )

(defrule update-row
    ?index<-(rumah (garage ?garage))
    ?tmp<-(update (type ?type2) (room ?room2) (price ?price2) (location ?location2) (garage ?garage2) (index ?ix))
    =>
    (if (and (eq ?garage2 0) (eq ?garage 0)) then
        (bind ?*counter* (+ ?*counter* 1))
        )
    (if (and (> ?garage2 0) (> ?garage 0)) then
        (bind ?*counter* (+ ?*counter* 1))
        )
    (if (eq ?*counter* ?ix) then
    	(modify ?index (type ?type2) (room ?room2) (price ?price2) (location ?location2) (garage ?garage2))
        )
    )

(defrule delete-row
    ?index<-(rumah (garage ?garage))
    ?tmp<-(del (index ?ix) (con ?con))
    =>
    (if (and (eq ?garage 0) (eq ?con 2)) then
        (bind ?*counter* (+ ?*counter* 1))
        (if (eq ?*counter* ?ix) then
        	(retract ?index)
        )
        )
    (if (and (> ?garage 0) (eq ?con 1)) then
        (bind ?*counter* (+ ?*counter* 1))
        (if (eq ?*counter* ?ix) then
        	(retract ?index)
        )
        )
    )
    

(defrule matching
    (user-info (income ?income) (location ?location2) (type ?type2) (carCount ?car) )
    ?index<-(rumah (type ?type) (location ?location) (garage ?garage) (price ?price) )
    =>
    (bind ?tempo 100)
    (if (or (and(eq ?car 0) (eq ?garage 0)) (and (> ?car 0) (> ?garage 0) )) then
        (if (neq ?location ?location2) then
            (bind ?tempo (- ?tempo 10))
            )
        (if (neq ?type ?type2) then
            (bind ?tempo (- ?tempo 5))
            )
        (if (< ?income ?price) then
            (bind ?tempo (- ?tempo 10))
            )
        (if (< ?garage ?car) then
            (bind ?tempo (- ?tempo 10))
            )
        else
        (bind ?tempo 0)
        )
    (modify ?index (match-rate ?tempo))
    )

(defrule done
    ?index<-(with-garage)
    =>
    (bind ?*position* ?index)
    )

(defrule done2
    ?index<-(update)
    =>
    (bind ?*position* ?index)
    )

(defrule done3
    ?index<-(del)
    =>
    (bind ?*position* ?index)
    )

(defrule done4
    ?index<-(user-info)
    =>
    (bind ?*position* ?index)
    )

(deffunction menu1()
    (printout t "List of house to be viewed" crlf)
    (printout t "================================" crlf)
    (printout t "1. House with Garage" crlf)
    (printout t "2. House without Garage" crlf)
    (bind ?choose -1)
    (while (eq (val-int 0 2 ?choose) FALSE)
    	(printout t ">> Choose [1..2 | 0 back to main menu]: ")
        (bind ?choose (read))
        )
    (if (eq ?choose 0) then
        (return)
        )
    (if(eq ?choose 1) then
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 5))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" "Garage" 15)
	    (print-border ?tmp-width)
        else
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 3))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" 0 15)
	    (print-border ?tmp-width)
        )
    (bind ?*counter* 0)
    (assert (with-garage (con ?choose)))
    (run)
    (retract ?*position*)
    (print-border ?tmp-width)
    (printout t "Press Enter to Continue... ")
    (bind ?temp (readline))
    )

(deffunction menu2()
    (printout t "Type of houses to be added" crlf)
    (printout t "================================" crlf)
    (printout t "1. House with Garage" crlf)
    (printout t "2. House without Garage" crlf)
    (bind ?choose -1)
    (while (eq (val-int 0 2 ?choose) FALSE)
        (printout t ">> Choose [1..2 | 0 back to main menu]: ")
        (bind ?choose (read))
        )
    (if (eq ?choose 0) then
        (return)
        )
    (bind ?type "")
    (while TRUE
        (printout t "Input house type [Cottage | Light House | Skyscraper](CASE-SENSITIVE): ")
        (bind ?type (readline))
        (if (eq ?type "Cottage") then (break))
        (if (eq ?type "Light House") then (break))
        (if (eq ?type "Skyscraper") then (break))
        )
    (bind ?room 0)
    (while (eq (val-int 1 5 ?room) FALSE)
        (printout t "Input room number [1 - 5]: ")
        (bind ?room (read))
        )
    (bind ?price 0)
    (while (eq (val-int 1000 500000 ?price) FALSE)
        (printout t "Input house price [1000 - 500000] (dollars) : ")
        (bind ?price (read))
        )
    (bind ?location "")
    (while TRUE
        (printout t "Input house location [West Jakarta | North Jakarta | South Jakarta](CASE-SENSITIVE): ")
        (bind ?location (readline))
        (if (eq ?location "West Jakarta") then (break))
        (if (eq ?location "North Jakarta") then (break))
        (if (eq ?location "South Jakarta") then (break))
        )
    (bind ?garage 0)
    (if (eq ?choose 1) then
        (while (eq (val-int 1 5 ?garage) FALSE)
            (printout t "Input garage number [1 - 5] : ")
            (bind ?garage (read))
            )
        )
    (assert (rumah (type ?type) (room ?room) (price ?price) (location ?location) (garage ?garage)))
    (printout t "Press Enter to Continue... ")
    (bind ?temp (readline))
    )

(deffunction menu3()
    (printout t "Types of houses to be updated" crlf)
    (printout t "================================" crlf)
    (printout t "1. House with Garage" crlf)
    (printout t "2. House without Garage" crlf)
    (bind ?choose -1)
    (while (eq (val-int 0 2 ?choose) FALSE)
        (printout t ">> Choose [1..2 | 0 back to main menu]: ")
        (bind ?choose (read))
        )
    (if (eq ?choose 0) then
        (return)
        )
    (if(eq ?choose 1) then
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 5))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" "Garage" 15)
	    (print-border ?tmp-width)
        else
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 3))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" 0 15)
	    (print-border ?tmp-width)
        )
    (bind ?*counter* 0)
    (assert (with-garage (con ?choose)))
    (run)
    (retract ?*position*)
    (print-border ?tmp-width)
    (bind ?ix -1)
    (while (eq (val-int 0 ?*counter* ?ix) FALSE)
        (printout t "Which house to be updated [1.."?*counter*" | 0 back to main menu]:	")
        (bind ?ix (read))
        )
    (if (eq ?ix 0) then
        (return)
        )
    (bind ?type "")
    (while TRUE
        (printout t "Input house type [Cottage | Light House | Skyscraper](CASE-SENSITIVE): ")
        (bind ?type (readline))
        (if (eq ?type "Cottage") then (break))
        (if (eq ?type "Light House") then (break))
        (if (eq ?type "Skyscraper") then (break))
        )
    (bind ?room 0)
    (while (eq (val-int 1 5 ?room) FALSE)
        (printout t "Input room number [1 - 5]: ")
        (bind ?room (read))
        )
    (bind ?price 0)
    (while (eq (val-int 1000 500000 ?price) FALSE)
        (printout t "Input house price [1000 - 500000] (dollars) : ")
        (bind ?price (read))
        )
    (bind ?location "")
    (while TRUE
        (printout t "Input house location [West Jakarta | North Jakarta | South Jakarta](CASE-SENSITIVE): ")
        (bind ?location (readline))
        (if (eq ?location "West Jakarta") then (break))
        (if (eq ?location "North Jakarta") then (break))
        (if (eq ?location "South Jakarta") then (break))
        )
    (bind ?garage 0)
    (if (eq ?choose 1) then
        (while (eq (val-int 1 5 ?garage) FALSE)
            (printout t "Input garage number [1 - 5] : ")
            (bind ?garage (read))
            )
        )
    (bind ?*counter* 0)
    (assert (update (type ?type) (room ?room) (price ?price) (location ?location) (garage ?garage) (index ?ix)))
    (run)
    (retract ?*position*)
    (printout t "Press Enter to Continue... ")
    (bind ?temp (readline))
    )

(deffunction menu4()
    (printout t "Types of houses to be deleted" crlf)
    (printout t "================================" crlf)
    (printout t "1. House with Garage" crlf)
    (printout t "2. House without Garage" crlf)
    (bind ?choose -1)
    (while (eq (val-int 0 2 ?choose) FALSE)
        (printout t ">> Choose [1..2 | 0 back to main menu]: ")
    	(bind ?choose (read))
        )
    (if (eq ?choose 0) then
        (return)
        )
    (if(eq ?choose 1) then
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 5))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" "Garage" 15)
	    (print-border ?tmp-width)
        else
    	(bind ?tmp-width (+ (* 15 2) (+ 19 (* 4 3))))
        (print-border ?tmp-width)
	    (print-header "No." "Type" "Room" "Price" "Location" 0 15)
	    (print-border ?tmp-width)
        )
    (bind ?*counter* 0)
    (assert (with-garage (con ?choose)))
    (run)
    (retract ?*position*)
    (print-border ?tmp-width)
    (bind ?ix -1)
    (while (eq (val-int 0 ?*counter* ?ix ) FALSE)
        (printout t "Which house to be deleted[1.." ?*counter*" | 0 back to main menu]: ")
        (bind ?ix (read))
        )
    (if (eq ?ix 0) then
        (return)
        )
    (bind ?*counter* 0)
    (assert (del (index ?ix) (con ?choose)))
    (run)
    (retract ?*position*)
    )

(deffunction menu5()
    (bind ?name "")
    (while (or (< (str-length ?name) 3) (> (str-length ?name) 20))
        (printout t "Input your name [3 - 20 characters length]: ")
        (bind ?name (readline))
        )
    (bind ?gender "")
    (while TRUE
        (printout t "Input your gender [ Male | Female ](CASE-SENSITIVE): ")
        (bind ?gender (readline))
        (if (eq ?gender "Male") then (break))
        (if (eq ?gender "Female") then (break))
        )
    (bind ?preference "")
    (while TRUE
        (printout t "Input your house preference [ With Garage | Without Garage ](CASE-SENSITIVE): ")
        (bind ?preference (readline))
        (if (eq ?preference "With Garage") then (break))
        (if (eq ?preference "Without Garage") then (break))
        )
    (bind ?income -1)
    (while (neq (val-int 10000 500000 ?income) TRUE)
        (printout t "Input your income [10000 - 500000] (dollars) : ")
        (bind ?income (read))
        )
    (bind ?location "")
    (while TRUE
        (printout t "Input your work location [West Jakarta | North Jakarta | South Jakarta](CASE-SENSITIVE): ")
        (bind ?location (readline))
        (if (eq ?location "West Jakarta") then (break))
        (if (eq ?location "North Jakarta") then (break))
        (if (eq ?location "South Jakarta") then (break))
        )
    (bind ?type "")
    (while TRUE
        (printout t "Input your preferred house type [Cottage | Light House | Skyscraper](CASE-SENSITIVE): ")
        (bind ?type (readline))
        (if (eq ?type "Cottage") then (break))
        (if (eq ?type "Light House") then (break))
        (if (eq ?type "Skyscraper") then (break))
        )
    (bind ?car 0)
    (if (eq ?preference "With Garage") then
        (while (neq (val-int 1 5 ?car) TRUE)
            (printout t "Input number of car you own [1 - 5](cars): ")
            (bind ?car (read))
            )
        )
    (assert (user-info (name ?name) (gender ?gender) (income ?income) (interest ?preference ) (location ?location) (type ?type) (carCount ?car)))
    (run)
    (new Template)
    (retract ?*position*)
    )

(reset)

(while TRUE
    (facts)
    (bind ?cmd (menu))
    (if (eq ?cmd 1) then
        (menu1)
        )
    (if (eq ?cmd 2) then
        (menu2)
        )
    (if (eq ?cmd 3) then
        (menu3)
        )
    (if (eq ?cmd 4) then
        (menu4)
        )
    (if (eq ?cmd 5) then
        (menu5)
        )
    (if (eq ?cmd 6) then
    	(break)
        )
    )