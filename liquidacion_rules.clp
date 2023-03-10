(defmodule LIQUIDACION (import MAIN deftemplate ?ALL ) )


(deffunction mes_to_numero ( ?mes )
  ( switch ?mes
    ( case enero      then 1)
    ( case febrero    then 2)
    ( case marzo      then 3)
    ( case abril      then 4)
    ( case mayo       then 5)
    ( case junio      then 6)
    ( case julio      then 7)
    ( case agosto     then 8)
    ( case septiembre then 9)
    ( case octubre    then 10)
    ( case noviembre  then 11)
    ( case diciembre  then 12)
  )
)

(deffunction to_serial_date( ?dia ?mes ?ano)
  (+ (* 10000 ?ano) (* 100 ( mes_to_numero ?mes)) ?dia)
)


(defrule fin-liquidacion
  ( declare (salience -100) )
 =>
  ( close k )
)

;esto genera un markdown para que jekyll lo publique en el blog necios
(defrule inicio-kindle-k-liquidacion-rules
   ( declare (salience 10000))
   ( empresa (nombre ?empresa))
  =>

   ( bind ?archivo (str-cat "./doc/" ?empresa "/liquidacion.markdown"))
   ( open ?archivo k "w")

   ( printout k "--- " crlf)
;   ( printout k "title: " ?empresa "-liquidacion" crlf)
;  ( printout k "permalink: /" ?empresa "-liquidacion/ " crlf)
   ( printout k "layout: page" crlf)
   ( printout k "--- " crlf)
   ( printout k "" crlf)
   ( printout k "Contabilidad para Necios® usa el siguiente código de colores para este documento." crlf)
   ( printout k "<li><span style='background-color: lavender'>[    ]</span> partida revisada y resultado bueno. </li>" crlf)
   ( printout k "<li><span style='background-color: lightyellow'>[    ]</span> cuenta mayor del activo </li>" crlf)
   ( printout k "<li><span style='background-color: azure'>[    ]</span> cuenta mayor del pasivo </li>" crlf)
   ( printout k "<li><span style='color: white; background-color: cornflowerblue'>[    ]</span> cuenta de patrimonio </li>" crlf)
   ( printout k "<li><span style='background-color: gold'>[    ]</span> ganancia </li>" crlf)
   ( printout k "<li><span style='color: white; background-color: black'>[    ]</span> pérdida </li>" crlf)
   ( printout k "<li><span style='background-color: blanchedalmond'>[    ]</span> subtotales de la transacción </li>" crlf)
)


(defrule inicio-de-modulo-liquidacion
 (declare ( salience 10000))
=>
 ( printout t  "---------------------- LIQUIDACION --------------------" crlf)
)

(defrule liquidacion-mostrar-tributacion
  ( declare (salience 8000))
  ?partida<-(partida (numero ?numero) )
  ( tributacion (partida ?numero) ) 
 => 
  ( assert (cabeza ?numero))
)


(defrule liquidacion-mostrar-partida
  ( declare (salience 8000))
  ?partida<-(partida (numero ?numero) )
  (or ( liquidacion (partida ?numero))
      ( provision   (partida ?numero))
  )
 =>
  ( assert (cabeza ?numero))
)


(defrule tributacion
  ( cabeza 1155)
  ( no )
 =>
  ( printout t crlf crlf crlf)
  ( printout t "==================================================================" crlf)
  ( printout t FECHA tab Parcial tab Debe tab Haber tab Descripcion crlf)
  ( printout t "==================================================================" crlf)
  ( printout t "Partida 1155 " crlf)
  ( printout t ".................................................................." crlf)
  ( assert (fila 1155))
)

;============================== Tabla de la Partida ================================
(defrule encabezado
  ( cabeza ?numero )
  ;( balance ( dia ?top ) (mes ?mes) (ano ?ano))
 ; ( empresa (nombre ?empresa) (razon ?razon))
  ;( test (>= ?top ?dia))
 =>
  ( printout t crlf crlf crlf)
  ( printout t "==================================================================" crlf)
  ( printout t FECHA tab Parcial tab Debe tab Haber tab Descripcion crlf)
  ( printout t "==================================================================" crlf)
  ( printout t "Partida " ?numero crlf)
  ( printout t ".................................................................." crlf)

  ( printout k "<table style='background-color: lightyellow' ><tbody>" crlf)
  ( printout k "<tr style='color: white; background-color: black'><td colspan='9'> Partida " ?numero  "</td></tr>" crlf)
  ( printout k "<tr><th>DEBE</th><th> HABER </th> <th colspan='6'> Cuenta </th></tr>" crlf)


  ( assert (fila ?numero))
)



(defrule footer
  ?fila <- ( fila ?numero )
;  ( balance ( dia ?top ) (mes ?mes) (ano ?ano))
  ( empresa (nombre ?empresa) (razon ?razon))
  ( partida (numero ?numero) (debe ?debe) (haber ?haber) (dia ?dia) (mes ?mes) (ano ?ano) (descripcion ?descripcion))
 ; ( test (>= ?top ?dia))
 =>
  ;:( retract ?fila )
  ( printout t "------------------------------------------------------------------" crlf)
  ( printout t tab tab ?debe tab ?haber tab "( " ?dia " de " ?mes tab ?ano tab " )" crlf)
  ( printout t "==================================================================" crlf)
  ( printout t ?razon crlf)
  ( printout t ?descripcion crlf)
  ( printout t crlf crlf)
  
  ( printout k "<tr style='color: white; background-color: black'> <td> " ?debe "</td><td> " ?haber "</td><td colspan='3'>( " ?dia " de " ?mes tab ?ano tab " ) </td></tr>" crlf)
  ( printout k "<tr><td colspan='9'>" ?razon "</td></tr>" crlf)
  ( printout k "<tr><td colspan='9'>" ?descripcion "</td></tr>" crlf)
  ( printout k "<table><tbody> " crlf )

)



(defrule muestra-saldo-liquidadora-saldo-nulo
  (no)
   ?f1 <- (cuenta (nombre ?nombre) (debe ?debe) (haber ?haber) (saldo ?saldo))
   ;test (eq false ?verificada))
   (test (= ?debe ?haber))
  =>
   ( bind ?saldo (- ?debe ?haber ) )
;  ( modify  ?f1 ( saldo ?saldo ) (verificada (not ?verificada)))
 ;  ( retract ?f1)
   ( printout t crlf)
   ( printout t "-----------------------------------------------------" crlf)
   ( printout t tab tab ?nombre  tab saldo-nulo crlf)
   ( printout t "----------------------------------------------------" crlf)
   ( printout t tab (round ?debe) tab "|" tab (round ?haber) crlf)
   ( printout t tab (round ?saldo) crlf)
   ( printout t crlf)

)



(defrule muestra-saldo-liquidadora-saldo-deudor
   ?f1 <- (cuenta (nombre ?nombre) (partida ?partida) (debe ?debe) (haber ?haber) (saldo ?saldo) (tipo liquidadora))  
   (test (> ?debe ?haber))
  => 
   ( bind ?saldo (- ?debe ?haber ) )
   ( printout t crlf)
   ( printout t "-----------------------------------------------------" crlf)
   ( printout t tab tab ?nombre  tab saldo-deudor crlf)
   ( printout t "----------------------------------------------------" crlf)
   ( printout t ?partida tab (round ?debe) tab "|" tab (round ?haber) crlf)
   ( printout t tab tab tab (round ?saldo) crlf)
   ( printout t crlf)

   ( printout k "<tr  style='background-color: blanchedalmond'><td></td><td> " ?nombre "</td><td>" saldo-deudor "</td></tr>" crlf)
   ( printout k "<tr> <td> " ?partida "</td> <td>" (round ?debe)  "</td> <td>" (round ?haber) "</td></tr>" crlf)
   ( printout k "<tr style='background-color: blanchedalmond'><td>" (round ?saldo)  "</td></tr>" crlf) 


)


(defrule muestra-saldo-liquidadora-saldo-acreedor 
   ?f1 <- (cuenta (nombre ?nombre) ( partida ?partida) (debe ?debe) (haber ?haber) (saldo ?saldo) (tipo liquidadora) ) 
   (test (< ?debe ?haber))
  => 
   ( bind ?saldo (- ?haber ?debe ) )
   ( printout t crlf)
   ( printout t "-----------------------------------------------------" crlf)
   ( printout t tab tab ?nombre tab saldo-acreedor crlf)
   ( printout t "-----------------------------------------------------" crlf)
   ( printout t ?partida tab (round ?debe) tab "|" tab (round ?haber) crlf)
   ( printout t tab tab "|" tab (round ?saldo) crlf)
   ( printout t crlf)

   ( printout k "<table>" crlf)
   ( printout k "<tr style='background-color: blanchedalmond'><td> </td><td>" ?nombre "</td><td>" saldo-acreedor "</td></tr>" crlf)
   ( printout k "<tr> <td> " ?partida "</td> <td>" (round ?debe)  "</td><td> " (round ?haber) "</td></tr>" crlf)
   ( printout k "<tr style='background-color: blanchedalmond'><td>" (round ?saldo)  "</td></tr>" crlf)
   ( printout k "</table>" crlf)

)


(defrule liquidar-deudora-con-saldo-acreedor-version-original
   (declare (salience 80))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (numero ?numero) (debe ?debep) (haber ?haberp)) 
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (tipo-de-saldo acreedor))
   ?deudora     <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo deudor) (liquidada false) )
   ?liquidadora <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) (saldo ?saldo2) (grupo ?grupo))
   (test (< ?debe ?haber))
  =>
   (printout t ?debe tab ?haber crlf) 

   (printout k "<tr><td>" ?debe "</td><td>" ?haber "</td></tr>" crlf)

   ( bind ?saldo (- ?haber ?debe))

   ( modify ?deudora
     ( liquidada true )
;     ( debe (+ ?debe ?saldo) )
   )

   ( modify ?liquidadora
     ( ano ?ano)
     ( empresa ?empresa )
     ( haber (+ ?haber2 ?saldo ))
     ( saldo (- ?saldo2  ?saldo)) )
  ( modify ?partida (debe (+ ?debep ?saldo)) (haber (+ ?haberp ?saldo)))
 ; ( printout t "x--- Liquidando deudora con saldo acreedor " ?nombre " a través de " ?liquidora " partida " ?numero crlf)
; (halt)
  ;( printout t tab tab ?nombre tab saldo-acreedor crlf)
  ;( printout t "-----------------------------------------------------" crlf)
; ( printout t tab (round ?debe) tab "|" tab (round ?haber) crlf)
  ;( printout t tab (round ?saldo) tab "|"  crlf)
  ;( printout t crlf)
   ( printout t tab tab "  | --" tab (round ?haber) tab ?nombre tab ?grupo crlf)
   ( printout t tab (round ?saldo) tab "<-|" tab  tab tab "r<" ?liquidora ">" crlf)
   ( printout t  crlf )

   ( printout k "<tr><td></td><td>" (round ?haber) "</td><td> </td><td>" ?nombre "</td><td>" ?grupo "</td></tr>" crlf)
   ( printout k "<tr><td>" (round ?saldo) "</td><td> </td><td> r(" ?liquidora ") </td></tr>" crlf)


)

(defrule liquidar-deudora-con-saldo-deudor
  (declare (salience 80))
  (fila ?numero )

  (empresa (nombre ?empresa ))

  ?partida     <- (partida (numero ?numero ) (dia ?dia) (mes ?mes) (debe ?debep) (haber ?haberp))
  ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (tipo-de-saldo deudor))
  ?deudora     <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber) (tipo deudor) (grupo ?grupo) (liquidada false) )
  ?l <- (cuenta (nombre ?liquidora) (tipo liquidadora) (saldo ?saldol) (debe ?debel) (grupo ?grupol))
  (test (> ?debe ?haber))

=>
   ( bind ?saldo (- ?debe ?haber))

   ( modify ?deudora
     ( liquidada true )
  ;   ( haber (+ ?haber ?saldo))
   )

   ( modify ?l
     ( ano ?ano)
     ( empresa ?empresa )

     ( debe (+ ?debel ?saldo))
     ( saldo (+ ?saldol ?saldo))
   )

   ( modify ?partida (debe (+ ?debep ?saldo)) (haber (+ ?haberp ?saldo)))
   ( printout t tab tab "   |--" tab (round ?saldo) tab ?nombre tab ?grupo crlf)
   ( printout t tab (round ?saldo) tab " <-| " tab tab tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )
  ; ( printout t "x--- Liquidando deudora con saldo deudor " ?nombre " a través de " ?nombrel " partida " ?numero crlf)
  ; ( printout t "Encontrado" ?nombre crlf)

   ( printout k "<tr><td></td> <td>"  (round ?saldo) "</td><td> </td><td colspan='5'>" ?nombre "#" ?grupo "</td></tr>" crlf)
   ( printout k "<tr><td> " (round ?saldo) "</td><td></td><td colspan='6'>  r(" ?liquidora ") </td></tr>" crlf)

)

(defrule liquidar-acreedora-con-saldo-deudor
   (declare (salience 80))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (numero ?numero ) (dia ?dia) (mes ?mes) (debe ?debep) (haber ?haberp))
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (tipo-de-saldo deudor))
   ?deudora     <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) )
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) (saldo ?saldo2) )
   (test (> ?debe ?haber))
  => 
   ( bind ?saldo (- ?debe ?haber))

;   ( modify ?deudora
;     ( liquidada true )
;     ( haber (+ ?haber ?saldo))
;   )

   ;Realmente no se hace la liquidación, para que se pueda volver a usar en otra liquidación
   ( modify ?deudora
     ( liquidada true )
   )



   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )

     ( debe (+ ?debe2 ?saldo))
     ( saldo (+ ?saldo2 ?saldo))
   ) 
   ( modify ?partida (debe (+ ?debep ?saldo)) (haber (+ ?haberp ?saldo)))

 ;  ( printout t "x-- Liquidando acreedora con saldo deudor " ?nombre " en " ?liquidora crlf)
 ;  ( printout t tab tab ?nombre tab saldo-deudor crlf)
 ;  ( printout t "-----------------------------------------------------" crlf)
   ( printout t tab tab "    |--" tab (round ?saldo) tab tab ?nombre crlf)
   ( printout t tab (round ?saldo) tab "  <-|" tab tab "r<" ?liquidora ">" crlf)

 ;  ( printout t tab (round ?saldo) tab "|" crlf)
   ( printout t crlf)

   ( printout k "<tr> <td></td><td>" (round ?saldo) "</td><td> </td><td colspan='2'> " ?nombre "</td></tr>" crlf)
   ( printout k "<tr> <td> " (round ?saldo) "</td><td></td><td colspan='4'>  r(" ?liquidora ") </td></tr>" crlf)


)

(defrule liquidar-cuentas-de-resultado-acreedor
   (declare (salience 80))
   (fila ?numero)
   (empresa (nombre ?empresa ))
   ?partida     <- (partida (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (tipo-de-saldo acreedor))
   ?deudora     <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) )
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) (saldo ?saldo2) )
   (test (> ?haber ?debe))
  => 
   ( bind ?saldo (- ?haber ?debe))
   
;   ( modify ?deudora
;     ( liquidada true )
;     ( debe (+ ?saldo ?debe))
;   )

   ;realmente no se liquida para que se pueda usar nuevamente en la liquidación de las cuentas tributarias
   ( modify ?deudora
     ( liquidada true )
   )


   ( modify ?liquidador 
     ( ano ?ano)
     ( empresa ?empresa )

     ( haber (+ ?haber2 ?saldo))
     ( saldo (+ ?saldo2 ?saldo))
   ) 
   
; ( printout t "x-- Liquidando acreedora con saldo acreedor " ?nombre " en " ?liquidora crlf)
 ;  ( printout t tab tab ?nombre tab saldo-acreedor crlf)
 ;  ( printout t "-----------------------------------------------------" crlf)
;   ( printout t tab (round ?debe) tab "|" tab (round ?haber) crlf)
 ;  ( printout t tab tab tab tab "|" tab (round ?saldo) crlf)
  ; ( printout t crlf)
   ( modify ?partida (debe (+ ?debep ?saldo)) (haber (+ ?haberp ?saldo)))

   ( printout t tab (round ?saldo) tab "--|" tab tab ?nombre crlf)
   ( printout t tab tab "  |->" tab (round ?saldo)  tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )


   ( printout k "<tr><td>" (round ?saldo) "</td><td></td><td colspan='2'>" ?nombre "</td></tr>" crlf)
   ( printout k "<tr><td></td><td>"  (round ?saldo) "</td><td></td><td> r(" ?liquidora ") </td></tr>"  crlf)

)


;--------------------------------------- determinación de utilidad tributaria y la financiera-
(defrule determinacion-de-la-base-imponible-efecto-aporte
   (declare (salience 180))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (tributacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (efecto aporte))
   ?acreedora   <- (cuenta (partida ?numero2&:(neq nil ?numero2)) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber&:(> ?haber 0))  (tipo ?tipo) (liquidada ?liquidada) (tributada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
   (cuenta (nombre base-imponible) (partida nil))
 =>
;  ( printout t "nombre " tab ?nombre tab ?liquidora tab ?haber2 crlf)
  ( bind ?saldo ?haber)
  ( modify ?acreedora  (tributada true))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( haber (+ ?haber2 ?saldo) )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
 ;  ( printout t "t-- Tributando cuenta " ?nombre " en " ?liquidora crlf)
  ; ( printout t "La cuenta de base imponible tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )
 ;  ( printout t "determinacion-de-la-base-imponible-efecto-aporte" clrf)

   ( printout k "<tr><td>" ?saldo "</td><td> </td><td colspan='2'> r(" ?nombre ") partida " ?numero2 " </td></tr>" crlf)
   ( printout k "<tr><td></td><td>" ?saldo "</td><td> </td><td>" ?liquidora "</td></tr>" crlf)
)


(defrule determinacion-de-la-base-imponible-efecto-deduccion
   (declare (salience 181))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (tributacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora) (efecto deduccion))
   ?acreedora   <- (cuenta (partida ?numero2&:(neq nil ?numero2)) (parte ?parte) (nombre ?nombre)  (debe ?debe&:(> ?debe 0))  (haber ?haber)  (tipo ?tipo) (liquidada ?liquidada) (tributada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
   (cuenta (nombre base-imponible) (partida nil))
 =>
;  ( printout t "nombre " tab ?nombre tab ?liquidora tab ?haber2 crlf)
  ( bind ?saldo ?debe)
  ( modify ?acreedora  (tributada true))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( debe (+ ?debe2 ?saldo) )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
 ; ( printout t "t-- Tributando cuenta " ?nombre " en " ?liquidora crlf)
 ; ( printout t "La cuenta de base imponible tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab "r<" ?liquidora "> partida " crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab ?nombre crlf)
   ( printout t crlf )

   ( printout k "<tr><td>" ?saldo "</td><td> </td><td colspan='2'> r(" ?liquidora ") partida " ?numero2 " </td></tr>" crlf)
   ( printout k "<tr><td></td><td>" ?saldo "</td><td> </td><td>" ?nombre "</td></tr>" crlf)
)


(defrule obtencion-base-imponible
   (declare (salience 180))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (tributacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora1))
   ?acreedora   <- (cuenta (partida ?partida) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo ?tipo) (liquidada true) (tributada false) (grupo ?grupo) (circulante ?circulante))
;   ?acreedora   <- (cuenta (partida nil) (parte ?parte) (nombre ?nombre) (debe ?debe) (haber ?haber) (tributada false) (grupo ?grupo) (circulante ?circulante))

;   ?acreedora   <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tributada false) )

   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
;   (test (and (= ?debe 0) (= ?haber 0)))
;   ( test (< ?haber2 ?debe2))
;   ( test (eq ?nombre utilidad ))
;    ( test (neq nil ?partida))
  =>
   ( bind ?saldo (round (* 1 (- ?haber ?debe))))
   ( modify ?acreedora  (tributada true))

   ( assert ( cuenta
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( tributada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
  ( printout t "t-- Tributando cuenta " ?nombre " en " ?liquidora crlf)
;  ( printout t "La cuenta de base imponible tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )
   ( printout t "obtencion-base-imponible" crlf)

   ( printout k "<tr><td colspan='6'>t-- Tributando cuenta " ?nombre " en " ?liquidora "</td></tr>" crlf)
   ( printout k "<tr><td colspan='6'>t--La cuenta de base imponible tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 "</td><tr>" crlf)

   ( printout k "<tr style='background-color: azure'><td colspan='6'>La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> " ?saldo "</td><td></td><td colspan='2'>"  ?nombre "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> </td><td>" ?saldo "</td><td></td><td> r(" ?liquidora ") </td></tr>" crlf)
   ( printout k" Detenido en la regla obtencion-base-imponible " crlf)
   ( halt )
)

(defrule obtencion-utilidad-tributaria-negativa
   (declare (salience 81))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))
   ?acreedora   <- (cuenta (de-resultado true) (partida nil) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
   (test (and (= ?debe 0) (= ?haber 0)))
   ( test (< ?haber2 ?debe2))
   ( test (eq ?nombre utilidad-tributaria))
 =>
   ( bind ?saldo (round (* 1 (- ?haber2 ?debe2))))
   ( modify ?acreedora  (liquidada true))

   ( assert ( cuenta
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( liquidada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
  ;  ( printout t "x-- Liquidando cuenta de resultados, cuando no hay utilidad" ?nombre " en " ?liquidora crlf)
   ;( printout t "La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )
   ( printout t "obtencion-utilidad-tributaria-negativa" crlf)

   ( printout k "<tr><td colspan='6'>x-- Liquidando cuenta de resultados ( cuando hay perdida tributaria en " ?nombre " en " ?liquidora "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td colspan='6'>La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> " ?saldo "</td><td></td><td colspan='2'>"  ?nombre "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> </td><td>" ?saldo "</td><td></td><td> r(" ?liquidora ") </td></tr>" crlf)
)




(defrule obtencion-utilidad-negativa
   (declare (salience 81))
   (fila ?numero)
   (empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))
   ?acreedora   <- (cuenta (de-resultado true) (partida nil) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
   (test (and (= ?debe 0) (= ?haber 0)))
   ( test (< ?haber2 ?debe2))
   ( test (eq ?nombre utilidad ))
  =>
   ( bind ?saldo (round (* 1 (- ?haber2 ?debe2))))
   ( modify ?acreedora  (liquidada true))

   ( assert ( cuenta
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( liquidada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
  ;  ( printout t "x-- Liquidando cuenta de resultados, cuando no hay utilidad" ?nombre " en " ?liquidora crlf)
   ;( printout t "La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )
   ( printout t "obtencion-utilidad-negativa" crlf)

   ( printout k "<tr> <td colspan='8'>x-- Liquidando cuenta de resultados (cuando hay pérdidas tributarias) en: " ?nombre " en " ?liquidora "</td></tr>" crlf)

   ( printout k "<tr style='font-weight:bold; color: white; background-color: crimson'> <td>" ?saldo "</td><td></td><td>" ?nombre "</td><tr>" crlf)
   ( printout k "<tr><td></td><td>" ?saldo "</td><td> </td><td colspan='2'> r(" ?liquidora ") </td></tr>" crlf)


)




(defrule obtencion-utilidad-tributaria-positiva
   ( declare (salience 81)) 
   ( fila ?numero)
   ( empresa (nombre ?empresa))
   
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))

   (cuenta (nombre reserva-legal) (haber ?reserva-legal))
   (cuenta (nombre idpc) (haber ?idpc))

   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))

   ?acreedora   <- (cuenta (de-resultado true) (partida nil) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )

   ( test (and (= ?debe 0) (= ?haber 0)))
   ( test (> ?haber2 ?debe2))
   ( test (eq ?nombre utilidad-tributaria))
  =>
   ( bind ?saldo (round (- (- (- ?haber2 ?debe2) ?reserva-legal  ) ?idpc )))
   ( modify ?acreedora  (liquidada true))
   ( assert ( cuenta
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( liquidada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
;:   ( printout t "x-- Liquidando cuenta de resultados, cuando hay ganancia" ?nombre " en " ?liquidora crlf)
 ;:  ( printout t "La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )


   ( printout k "<tr><td colspan='6'>x-- Liquidando cuenta de resultados ( cuando hay ganancia) en " ?nombre " en " ?liquidora "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td colspan='6'>La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> " ?saldo "</td><td></td><td colspan='2'>"  ?nombre "</td></tr>" crlf)
   ( printout k "<tr style='background-color: azure'><td> </td><td>" ?saldo "</td><td></td><td> r(" ?liquidora ") </td></tr>" crlf)
   ( printout t  "obtencion-utilidad-tributaria-positiva" crlf)
)





(defrule obtencion-utilidad-positiva
   ( declare (salience 81))
   ( fila ?numero)
   ( empresa (nombre ?empresa))

   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))

   (cuenta (nombre reserva-legal) (haber ?reserva-legal))
  ; (cuenta (nombre idpc) (haber ?idpc))

   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))

   ?acreedora   <- (cuenta (de-resultado true) (partida nil) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )

   ( test (and (= ?debe 0) (= ?haber 0)))
   ( test (> ?haber2 ?debe2))
   ( test (eq ?nombre utilidad ))
  =>
;   ( bind ?saldo (round (- (- (- ?haber2 ?debe2) ?reserva-legal  ) ?idpc )))
   ( bind ?saldo (round (- (- ?haber2 ?debe2) ?reserva-legal  ) ))

   ( modify ?acreedora  (liquidada true))

   ( assert ( cuenta
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( liquidada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
;:   ( printout t "x-- Liquidando cuenta de resultados, cuando hay utilidad" ?nombre " en " ?liquidora crlf)
 ;:  ( printout t "La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )

;   ( printout k "</tbody> </table>" crlf)

 ;  ( printout k "<table><tbody>" crlf)
   ( printout k "<tr> <td colspan='8'>x-- Liquidando cuenta de resultados (cuando hay ganancia) en: " ?nombre " en " ?liquidora "</td></tr>" crlf)

   ( printout k "<tr style='font-weight:bold; color: white; background-color: crimson'> <td>" ?saldo "</td><td></td><td>" ?nombre "</td><tr>" crlf)
   ( printout k "<tr><td></td><td>" ?saldo "</td><td> </td><td colspan='2'> r(" ?liquidora ") </td></tr>" crlf)
 ;  ( printout k "</tbody> </table>" crlf)
   ( printout t  "obtencion-utilidad-positiva" crlf)

)

;------------------- liquidaciones --------------------------------------------------


;toma lo que se ha tirado a la cuenta liquidadora y lo reparte entre
;reserva, impuesto y utilidad
(defrule liquidar-cuenta-de-resultados
   ( declare (salience 81))
   ( fila ?numero)
   ( empresa (nombre ?empresa))
   ?partida     <- (partida (dia ?dia) (mes ?mes) (numero ?numero) (debe ?debep) (haber ?haberp))
   ?f1          <- (liquidacion (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))
   ?acreedora   <- (cuenta (de-resultado true) (partida nil) (parte ?parte) (nombre ?nombre)  (debe ?debe)  (haber ?haber)  (tipo acreedora) (liquidada false) (grupo ?grupo) (circulante ?circulante))
   ?liquidador  <- (cuenta (nombre ?liquidora) (debe ?debe2) (haber ?haber2) (tipo liquidadora) )
   ( test (and (= ?debe 0) (= ?haber 0)))
   ( test (> ?haber2 ?debe2))
   ( test (> ?parte 0))
  =>
   ( bind ?saldo (round (* ?parte (- ?haber2 ?debe2))))
   ( modify ?acreedora  (liquidada true))

   ( assert ( cuenta  
                ( dia ?dia)
                ( mes ?mes)
                ( ano ?ano)
                ( empresa ?empresa)
                ( de-resultado true)
                ( parte ?parte)
                ( circulante ?circulante)
                ( nombre ?nombre)
                ( grupo ?grupo)
                ( tipo acreedora)
                ( partida ?numero)
                ( liquidada true)
                ( origen real )
                ( haber (+ ?haber ?saldo))))
   ( modify ?liquidador
     ( ano ?ano)
     ( empresa ?empresa )
     ( saldo ?saldo )
   )
   ( modify ?partida (debe (+ ?debep ?saldo)) ( haber (+ ?haberp ?saldo)))
   ( printout t "x-- Liquidando cuenta de resultados " ?nombre " en " ?liquidora crlf)
   ( printout t "La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 crlf)
   ( printout t tab tab ?saldo tab "--|" tab tab tab ?nombre crlf)
   ( printout t tab tab tab "  |->" tab ?saldo tab tab "r<" ?liquidora ">" crlf)
   ( printout t crlf )

   ( printout k "<tr> <td colspan='7'> x-- Liquidando cuenta de resultados " ?nombre " en " ?liquidora "</td></tr>" crlf)
   ( printout k "<tr> <td colspan='7'> La cuenta de liquidacion tiene un debe de " tab ?debe2 " y un haber de " tab ?haber2 "</td></tr>" crlf)
   ( printout k "<tr style='background-color: lightgreen'><td>" ?saldo "</td> <td></td> <td colspan='2' >"    ?nombre     "</td></tr>" crlf)
   ( printout k "<tr style='background-color: lightgreen'><td></td><td>" ?saldo "</td> <td> </td><td colspan='2'> r(" ?liquidora ") </td></tr> "  crlf)
   
)


(defrule crea-cuenta-perdidas-y-ganancias
   ( declare (salience 2))
   ( empresa (nombre ?empresa))
   ( balance (dia ?dia_b) (mes ?mes_b) (ano ?ano ))
   ( partida (numero ?partida ) (dia ?dia) (mes ?mes) (ano ?ano) (empresa ?empresa) (descripcion ?descripcion))
   ( cuenta (nombre perdidas-y-ganancias) (partida nil) (grupo ?grupo-i) (padre ?padre-i) (circulante ?circulante-i) (naturaleza ?naturaleza-i) (tipo ?tipo-i) (origen ?origen-i) (de-resultado ?de-resultado-i))
  =>
  ; ( printout t "creando cuenta perdidas-y-ganancias - partida " tab ?partida crlf)
   ( assert (cuenta (partida ?partida) (descripcion liquidando-inventario) (dia ?dia) (mes ?mes) (ano ?ano) (nombre perdidas-y-ganancias) (grupo ?grupo-i) (empresa ?empresa) (padre ?padre-i) (circulante ?circulante-i) (naturaleza ?naturaleza-i)(tipo ?tipo-i) (origen ?origen-i) (de-resultado ?de-resultado-i) (liquidada true)))
)


(defrule crea-cuenta-base-imponible
   ( declare (salience 2))
   ( empresa (nombre ?empresa))
   ( balance (dia ?dia_b) (mes ?mes_b) (ano ?ano ))
   ( partida (numero ?partida-cuenta ) (dia ?dia) (mes ?mes) (ano ?ano) (empresa ?empresa) (descripcion ?descripcion))
   ( not (cuenta (partida ?part&:(neq nil ?part)) (nombre base-imponible)))
   ( exists (tributacion (partida ?partida-cuenta) ))
   ( cuenta (nombre base-imponible) (partida nil) (grupo ?grupo-i) (padre ?padre-i) (circulante ?circulante-i) (naturaleza ?naturaleza-i) (tipo ?tipo-i) (origen ?origen-i) (de-resultado ?de-resultado-i))
  =>
   ( printout t "creando cuenta base-imponible "  ?partida-cuenta crlf)
   ( assert (cuenta (partida ?partida-cuenta) (descripcion base-imponible) (dia ?dia) (mes ?mes) (ano ?ano) (nombre base-imponible) (grupo ?grupo-i) (empresa ?empresa) (padre ?padre-i) (circulante ?circulante-i) (naturaleza ?naturaleza-i)(tipo ?tipo-i) (origen ?origen-i) (de-resultado ?de-resultado-i) (tributada true)))
)



;inventario-----------------------------------------------------------------------------------


;La operación de inventario final se hace al final del período
;Pero necesito que funciones para cualquier perído, así que
;las operaciones de cargo y abono estarán fijadas para los datos
;de balance que sean ingreados y no por la fecha de la partida 
;de inventario-final

(defrule caratula-de-inventario-final
  ( declare (salience 3))
  ?f1          <- ( partida-inventario-final (partida ?partida) )
=>
   ( printout t " Inicio de Cuenta de Inventario Final ----------------------------"  crlf)

   ( printout k "<table><tbody> " crlf)
   ( printout k "<tr><td colspan='3'> Inicio de Cuenta de Inventario Final </td></tr>"  crlf)
   ( printout k "<tr style='background-color: cornflowerblue'><td> Partida </td> <td> DEBE </td> <td> HABER </td> </tr>" crlf)

)

(defrule pie-de-inventario-final
  ( declare (salience 1))
  ?f1          <- ( partida-inventario-final (partida ?partida) )
=>
   ( printout t " Fin de Cuenta de Inventario Final ----------------------------"  crlf)

   ( printout k "<tr><td colspan='2'> Fin de Cuenta de Inventario Final </td></tr>"  crlf)
   ( printout k "</tbody></table>" crlf)
)



(defrule liquidando-inventario-corriente-a-inventario-final-deudor
   ( declare (salience 2))
   ( empresa (nombre ?empresa))
   ( balance (dia ?dia_b) (mes ?mes_b) (ano ?ano_top))
   ( partida (numero ?partida ) (dia ?dia) (mes ?mes) (ano ?ano) (empresa ?empresa) (descripcion ?descripcion))
   ?perdidas-y-ganancias <- ( cuenta (nombre perdidas-y-ganancias) (debe ?debe-i) (haber ?haber-i))

   (or
     ?i  <- ( cuenta (nombre inventario) (partida ?partida-inventario) (debe ?debe) (liquidada false) (grupo ?grupo) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado))
     ?i  <- ( cuenta (nombre inventario-inicial) (partida ?partida-inventario) (debe ?debe) (liquidada false) (grupo ?grupo) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado))
   )

   ?f1          <- ( partida-inventario-final (partida ?partida) )
   ( test (> ?debe 0) )
   ( test (>= (to_serial_date ?dia_b ?mes_b ?ano_top) (to_serial_date ?dia ?mes ?ano)))
  =>
   ( printout t ?partida tab ?debe tab "|" crlf)
   ( printout k "<tr style='color: white; background-color: black' ><td>" ?partida "</td><td>" ?debe "</td></tr>" crlf)
   ( modify ?i (liquidada true) )


   ( assert (abono (partida ?partida-inventario) (dia ?dia_b) (mes ?mes_b) (ano ?ano) (empresa ?empresa) (cuenta inventario) (monto ?debe) (glosa final)))
   ( assert (cuenta (partida ?partida-inventario) (descripcion liquidando-inventario) (dia ?dia) (mes ?mes) (ano ?ano) (nombre inventario) (grupo ?grupo) (empresa ?empresa) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (haber ?debe) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado) (liquidada true)))
   ( modify ?perdidas-y-ganancias (partida ?partida) (debe (+ ?debe-i ?debe)) (liquidada true))
)

(defrule liquidando-inventario-en-inventario-final-acreedor
   ( declare (salience 2))
   ( empresa (nombre ?empresa))
   ( balance (dia ?dia_b) (mes ?mes_b) (ano ?ano_top ))
   ( partida (numero ?partida ) (dia ?dia) (mes ?mes) (ano ?ano) (empresa ?empresa) (descripcion ?descripcion))
   ?perdidas-y-ganancias <- ( cuenta (nombre perdidas-y-ganancias) (debe ?debe-i) (haber ?haber-i) (grupo ?grupo-i) (padre ?padre-i))

   (or
     ?i  <- ( cuenta (nombre inventario) (partida ?partida-inventario) (haber ?haber) (liquidada false) (grupo ?grupo) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado))
     ?i  <- ( cuenta (nombre inventario-inicial) (partida ?partida-inventario) (haber ?haber) (liquidada false) (grupo ?grupo) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado))
   )

   ?f1 <- ( partida-inventario-final (partida ?partida) )
   ( test (> ?haber 0))
   ( test (>= (to_serial_date ?dia_b ?mes_b ?ano_top) (to_serial_date ?dia ?mes ?ano)))
  =>
   ( printout t ?partida tab tab "|" tab ?haber crlf)
   ( printout k "<tr> <td>"  ?partida "</td><td></td><td>" ?haber "</td></tr>" crlf)
   ( modify ?i (liquidada true) ) 
   ( assert (cargo (partida ?partida-inventario) (dia ?dia_b) (mes ?mes_b) (ano ?ano) (empresa ?empresa) (cuenta inventario) (monto ?haber) (glosa final)))
   ( assert (cuenta (partida ?partida-inventario) (descripcion liquidando-inventario) (dia ?dia) (mes ?mes) (ano ?ano) (nombre inventario) (grupo ?grupo) (empresa ?empresa) (padre ?padre) (circulante ?circulante) (naturaleza ?naturaleza) (haber ?haber) (tipo ?tipo) (origen ?origen) (de-resultado ?de-resultado) (liquidada true)))
   ( modify ?perdidas-y-ganancias (partida ?partida) (haber (+ ?haber-i ?haber)) (liquidada true))
)




(defrule provisionando-idpc
   ( declare (salience 81))
   (fila ?numero)
   ( empresa (nombre ?empresa))
   ( balance (dia ?dia_b) (mes ?mes_b) (ano ?ano_top))
   ?partida <-  ( partida (numero ?numero ) (debe ?debep) (haber ?haberp) (dia ?dia) (mes ?mes) (ano ?ano) (empresa ?empresa) (descripcion ?descripcion))
   ?f1          <- (provision (partida ?numero) (cuenta ?nombre) (ano ?ano) (liquidadora ?liquidora))

   ?acreedora   <- (cuenta (nombre ?nombre)  (debe ?debe)  (haber ?haber) (ano ?ano) (grupo ?grupo))
   ?liquidador  <- (cuenta (partida nil) (nombre ?liquidora) (debe ?debe2) (haber ?haber2)  )

   ( test (> ?haber ?debe))
   ( test (>= (to_serial_date ?dia_b ?mes_b ?ano_top) (to_serial_date ?dia ?mes ?ano)))

  =>
   ( modify ?partida (debe (+ ?debep ?haber)) ( haber (+ ?haberp ?haber)))

   ( assert (abono (partida ?numero) (dia ?dia_b) (mes ?mes_b) (ano ?ano) (empresa ?empresa) (cuenta impuesto-a-la-renta-por-pagar) (monto ?haber) (glosa final)))

   ( assert (cargo (partida ?numero) (dia ?dia_b) (mes ?mes_b) (ano ?ano) (empresa ?empresa) (cuenta ?liquidora) (monto ?haber) (glosa final)))

   ( printout t tab tab (round ?haber) tab "|" tab tab ?nombre tab ?grupo crlf)
   ( printout t tab tab tab "|" tab (round ?haber) tab tab "r<" ?liquidora ">" crlf)
   ( printout t  crlf )
   ( retract ?f1 )
;  ( printout t "Provisionando deudor <<" ?nombre ">> hacia <<" ?liquidora ">>" crlf)

   ( printout k "<tr> <td> " (round ?haber) "</td><td> </td><td>" ?nombre "#" ?grupo  "</td></tr>" crlf)
   ( printout k "<tr><td> </td><td>" (round ?haber) "</td><td> r(" ?liquidora ") </td></tr>" crlf)

)
 
