(defmodule TRIBUTARIO (import MAIN deftemplate ?ALL))

(deftemplate info
  (slot inventario-final-liquidado )
)

(defrule inventario-final-liquidado
  (exists (partida-inventario-final ))
 =>
  (assert (info (inventario-final-liquidado true)))
)

(defrule inventario-final-no-liquidado
  (not (exists (partida-inventario-final )))
 =>
  (assert (info (inventario-final-liquidado false)))
)



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

(defrule inicio
  ( declare (salience 10000))
  (cuenta (nombre utilidad-tributaria) (partida ?p&:(neq nil ?p)) 
                                (haber ?haber&:(neq nil ?haber))
                                (debe  ?debe&:(neq nil ?debe))  )

 =>
  ( printout t "--modulo-----------CALCULO DE BASE TRIBUTARIA-----------------" crlf )
 ; ( matches estado-de-resultados-mensual)
 ; ( halt )
)

(defrule inicio-en-falso
  ( declare (salience 10000))
  ( not (exists  ( cuenta (nombre utilidad-tributaria) (partida ?p&:(neq nil ?p)))))
 =>
  ( printout t "--modulo-----------CALCULO DE BASE TRIBUTARIA-----------------" crlf )
  ( printout t "La utilidad tributaria no ha sido determinada. " crlf)
;  ( halt )
)


(defrule fin
 ( declare (salience -10000))
 =>
  ( close k )
)

;esto genera un markdown para que jekyll lo publique en el blog necios
(defrule inicio-kindle-k-tributario-rules
   ( declare (salience 10000))
   ( empresa (nombre ?empresa))
  =>
   ( printout t "En inicio-kindle-k-tributario-rules" )
   ( bind ?archivo (str-cat "./doc/" ?empresa "/tributario.markdown"))
   ( open ?archivo k "w")

   ( printout k "--- " crlf)
;   ( printout k "title: " ?empresa "-tributario" crlf)
;  ( printout k "permalink: /" ?empresa "/tributario/ " crlf)
   ( printout k "layout: page" crlf)
   ( printout k "--- " crlf)
   ( printout k "" crlf)
   ( printout k "<li><span style='background-color: lavender'>[    ]</span> partida revisada y resultado bueno. </li>" crlf)
   ( printout k "<li><span style='background-color: lightyellow'>[    ]</span> cuenta mayor del activo </li>" crlf)
   ( printout k "<li><span style='background-color: azure'>[    ]</span> cuenta mayor del pasivo </li>" crlf)
   ( printout k "<li><span style='color: white; background-color: cornflowerblue'>[    ]</span> cuenta de patrimonio </li>" crlf)
   ( printout k "<li><span style='background-color: gold'>[    ]</span> ganancia </li>" crlf)
   ( printout k "<li><span style='color: white; background-color: black'>[    ]</span> p??rdida </li>" crlf)
   ( printout k "<li><span style='background-color: blanchedalmond'>[    ]</span> subtotales de la transacci??n </li>" crlf)
)


(defrule estado-de-resultados-mensual
  ( balance (mes ?mes) (ano ?ano ))

  ( info (inventario-final-liquidado ?inventario-final-liquidado))

  ( empresa (nombre ?empresa))

  ( subtotales (cuenta ingresos-brutos) (acreedor ?ingresos-brutos))
  ( subtotales (cuenta ventas) (acreedor ?ventas))
  ( subtotales (cuenta devolucion-sobre-ventas) (debe ?devolucion-sobre-ventas))
  ( subtotales (cuenta compras) (debe ?compras))
  ( subtotales (cuenta gastos-sobre-compras) (debe ?gastos-sobre-compras))

  ( subtotales (cuenta inventario-inicial) (deber ?inventario-inicial))

  ( subtotales (cuenta inventario)
   (deber ?inventario-final-deber)
   (acreedor ?inventario-final-acreedor))

  ( subtotales (cuenta gastos-administrativos)
    (debe  ?gastos-administrativos-debe)
    (haber ?gastos-administrativos-haber))

  ( subtotales (cuenta salarios ) (deber ?salarios))
  ( subtotales (cuenta gastos-ventas) (deber ?gastos-ventas))
  ( subtotales (cuenta gastos-en-investigacion-y-desarrollo) (debe ?gastos-en-investigacion-y-desarrollo))
  ( subtotales (cuenta gastos-promocionales) (deber ?gastos-en-promocion))
  ( subtotales (cuenta costos-de-ventas) (deber ?costos-de-ventas))
  ( subtotales (cuenta idpc) (haber ?idpc))
  ( subtotales (cuenta reserva-legal) (haber ?reserva-legal))

  ( cuenta (nombre utilidad-tributaria) (partida ?p&:(neq nil ?p))
                                (haber ?utilidad-del-ejercicio-haber)
                                (debe  ?utilidad-del-ejercicio-debe))

  ( subtotales (cuenta utilidad) (acreedor ?utilidad-acreedor) (deber ?utilidad-deber) )

  ( subtotales (cuenta provision-impuesto-a-la-renta ) (acreedor ?provision-impuesto-a-la-renta))
  ( subtotales (cuenta amortizacion-intangibles ) (deber ?amortizacion-intangibles))
  ( subtotales (cuenta depreciacion-acumulada-herramientas ) (acreedor ?depreciacion))

  ( subtotales (cuenta impuesto-a-la-renta-por-pagar) (acreedor ?impuesto-a-la-renta-por-pagar))
  ( subtotales (cuenta perdidas-ejercicios-anteriores) (debe ?pea))

  ( subtotales (cuenta herramientas) (deber ?herramientas))
  ( subtotales (cuenta amortizacion-acumulada-instantanea) (haber ?amortizacion-acumulada-instantanea))

  ( subtotales (cuenta perdida-por-correccion-monetaria) (debe ?perdida-por-correccion-monetaria))
  ( subtotales (cuenta ganancia-por-correccion-monetaria) (haber ?ganancia-por-correccion-monetaria))

  ( subtotales (cuenta aumentos-de-capital-aportes) (haber ?aportes))


  ( cuenta (nombre impuestos-no-recuperables) (haber ?impuestos-no-recuperables))

  ( tasas (idpc ?tasa-idpc) (mes ?mes) (ano ?ano))  

  ( selecciones (regimen ?regimen))
 =>

  (bind ?inventario-final 
    (- ?inventario-final-deber
       ?inventario-final-acreedor))

  (bind ?gastos-administrativos
    (- ?gastos-administrativos-debe
       ?gastos-administrativos-haber))
    
  (bind ?utilidad-del-ejercicio
   (- ?utilidad-del-ejercicio-haber
      ?utilidad-del-ejercicio-debe))

  (bind ?ventas-netas           (- ?ventas ?devolucion-sobre-ventas))

  (bind ?compras-totales        (+ ?compras ?gastos-sobre-compras))
  (bind ?compras-netas          ?compras-totales)

  (bind ?existencias            (+ ?compras-netas ?inventario-inicial))
  ;mercaderia disponible para ventas

  (bind ?costos-de-mercancias   ?inventario-final)

  (if (eq true ?inventario-final-liquidado)
    then
     (if (eq diciembre ?mes) 
       then
        (bind ?utilidad-bruta (- (- ?ventas-netas ?costos-de-ventas) ?costos-de-mercancias))
       else
        (bind ?utilidad-bruta (- ?ventas-netas ?costos-de-ventas))
      )

     else
     (if (eq diciembre ?mes)
       then
        (bind ?utilidad-bruta (- ?ventas-netas ?costos-de-ventas))
       else
        (bind ?utilidad-bruta (- ?ventas-netas ?costos-de-ventas))
      ) )

  (bind ?gastos-de-operacion 
        (+ ?gastos-administrativos
           ?gastos-ventas
           ?gastos-en-investigacion-y-desarrollo 
           ?gastos-en-promocion
           ?amortizacion-intangibles
           ?depreciacion
           ?salarios
        ) ) 

  (bind ?utilidad-de-operacion  (- ?utilidad-bruta ?gastos-de-operacion ?pea))
  (bind ?utilidad-antes-de-reserva ?utilidad-de-operacion)
  (bind ?margen-de-explotacion (- ?utilidad-de-operacion ?reserva-legal))

  (bind ?margen-fuera-de-explotacion (- (+ ?margen-de-explotacion
                                           ?ganancia-por-correccion-monetaria )
                                        ?impuestos-no-recuperables))

  (bind ?utilidad-antes-de-idpc  ?margen-fuera-de-explotacion )

  (bind ?utilidad-tributaria (- ?margen-fuera-de-explotacion   (+ ?herramientas   ?amortizacion-acumulada-instantanea))) 

  (printout k "<table><tbody>" crlf )
  (printout k "<tr><th colspan='3'>" ?empresa "</th></tr>" crlf )

  (printout t "Solo se consideran las transacciones hasta el d??a 31 febrero. Cifras en pesos." crlf)


  (printout t ?empresa crlf)
  (printout t "================================================================================" crlf)
  (printout t "CALCULO DE LA BASE IMPONIBLE PROPYME" crlf)

  (printout k "<tr><td colspan='8'> CALCULO DE LA BASE IMPONIBLE PROPYME </td></tr>" )
  (printout k "<tr><th colspan='8'>Solo se consideran las transacciones hasta el d??a final de " ?mes ". Cifras en pesos. </th></tr>" crlf)

  (printout t "================================================================================" crlf)

  (if (eq true ?inventario-final-liquidado)
   then
     (printout k "<tr style='font-weight:bold;background-color: azure'><td colspan='8' align='center'>" INVENTARIO-FINAL-LIQUIDADO "</td></tr>" crlf)
  )
  (printout t "|" tab tab "|     " ?ingresos-brutos tab "Ingresos Brutos Percibidos A.29-LIR" crlf)
  (printout k "<tr><td></td><td></td><td></td><td></td><td align='right'>" ?ingresos-brutos "</td><td colspan='2'> Ingresos Brutos Percibidos A.29-LIR </td></tr>" crlf)

  (printout t "|" tab tab "|     " ?ventas tab "Ventas" crlf)
  (printout k "<tr><td></td><td></td><td></td><td></td><td align='right'>" ?ventas "</td><td> Ventas </td></tr>" crlf)


  (printout t "|" tab tab "| (-) -  " tab tab "Rebajas sobre ventas" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td> <td align='right'>0 </td> <td>  Rebajas sobre ventas </td></tr>" crlf)


  (printout t "|" tab tab "| (-) " ?devolucion-sobre-ventas tab tab "Devoluciones sobre ventas" crlf)  
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>" ?devolucion-sobre-ventas "</td><td> Devoluciones sobre ventas </td></tr>" crlf)  

  (printout t "|" tab tab "| (-) -  " tab tab "Descuentos sobre ventas" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>0</td><td>Descuentos sobre ventas </td></tr>" crlf)


  (printout t "|" tab tab "| (=) " ?ventas-netas tab "Ventas Netas" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (=) </td><td align='right'>" ?ventas-netas "</td><td> Ventas Netas </td></tr>" crlf)


  (printout t crlf)
  (printout t "|" tab tab "| (-) " ?costos-de-ventas tab "Costos de Ventas A.30-LIR" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>" ?costos-de-ventas "</td> <td>Costos de Ventas A.30-LIR </td></tr>" crlf)



  (printout t crlf) 
  (printout t "|" ?compras tab tab tab tab "Compras" crlf)
  (printout k "<tr><td></td><td align='right'>" ?compras  "</td><td></td><td></td><td></td><td> Compras </td></tr>" crlf)



  (printout t "| (+) " ?gastos-sobre-compras tab tab tab tab"Gastos sobre Compras" crlf)
  (printout k "<tr><td> (+) </td><td align='right'> " ?gastos-sobre-compras "</td><td></td><td> </td><td></td><td> Gastos sobre Compras </td></tr>" crlf)



  (printout t "|" ?compras-totales tab tab tab tab "Compras Totales" crlf)
  (printout k "<tr><td> (=) </td><td align='right'>" ?compras-totales "</td><td></td><td></td><td></td><td>Compras Totales</td></tr> " crlf)



  (printout t "| (-) - " tab tab tab tab "Rebajas sobre Compras" crlf)
  (printout t "| (-) - " tab tab tab tab "Devoluciones sobre Compras" crlf)
  (printout t "| (-) - " tab tab tab tab "Descuentos sobre Compras" crlf)

  (printout k "<tr><td> (-) </td><td align='right'>" 0 "</td><td></td><td></td><td></td><td> Rebajas Cobre Compras </td></tr>" crlf)
  (printout k "<tr><td> (-) </td><td align='right'>" 0 "</td><td></td><td></td><td></td><td> Devoluciones Sobre Compras </td></tr>" crlf)
  (printout k "<tr><td> (-) </td><td align='right'>" 0 "</td><td></td><td></td><td></td><td> Descuentos Sobre Compras </td></tr>" crlf)


  (printout t "|" ?compras-totales tab tab tab tab "Compras Netas" crlf)
  (printout k "<tr><td>(=)</td><td align='right'>" ?compras-totales "</td><td></td><td></td><td></td><td>Compras Netas</td></tr> " crlf)

  (printout t crlf)

  (printout t "| (+) " ?inventario-inicial tab "|" tab tab "Inventario Inicial" crlf)
  (printout k "<tr><td> (+) </td><td align='right'>"  ?inventario-inicial "</td><td></td><td></td><td></td><td colspan='2'>Inventario Inicial</td></tr> " crlf)


  (printout t "| (=) " ?existencias tab "|" tab tab "Mercader??a Disponible para la Venta " crlf)
  (printout k "<tr><td> (=) </td><td align='right'> " ?existencias "</td><td></td><td> </td><td></td><td> Mercader??a Disponible para la Venta </td></tr>" crlf)



  (printout t "|     0  |" tab tab "Costos de Mercanc??as Vendidas" crlf)
  (printout k "<tr><td>     </td> <td align='right'> 0 </td><td> </td><td></td><td></td><td colspan='2'>Costo de Mercanc??as Vendidas</td></tr>" crlf)


  (printout t "| (-) " ?inventario-final tab "|" tab tab "Inventario Final " crlf)
  (printout k "<tr><td> (-) </td> <td align='right'>" ?inventario-final "</td><td> </td><td></td><td></td><td colspan='2'>Inventario Final </td></tr>" crlf)


  (printout t "| (=) " ?costos-de-mercancias tab "|" tab tab "Costos de Mercanc??as " crlf)
  (printout k "<tr><td> (=) </td> <td align='right'>" ?costos-de-mercancias "</td><td> </td><td></td><td></td><td colspan='2'>Costo de Mercanc??as </td></tr>" crlf)



  (printout t crlf)

  
  (if (eq true ?inventario-final-liquidado)
   then

     (printout t "|" tab tab "|     " ?utilidad-bruta tab "UTILIDAD BRUTA (Ventas Netas - Costo de Ventas - Costo de Mercanc??as)" crlf)
     (printout k "<tr><td></td><td></td><td></td><td></td><td align='right'>" ?utilidad-bruta "</td><td colspan='4'>  UTILIDAD BRUTA (Ventas Netas - Costo de Ventas - Costo de Mercanc??as) </td></tr>"  crlf)
   else

     (printout t "|" tab tab "|     " ?utilidad-bruta tab "UTILIDAD BRUTA (Ventas Netas - Costo de Ventas)" crlf)
     (printout k "<tr><td></td><td></td><td></td><td></td><td align='right'>" ?utilidad-bruta "</td><td colspan='4'>  UTILIDAD BRUTA (Ventas Netas - Costo de Ventas) </td></tr>"  crlf)

 )


  (printout k "<tr style='font-weight:bold; background-color: azure'><td></td><td></td><td></td><td></td><td align='right'>" ?utilidad-bruta "</td><td colspan='4'>  Margen de Explotacion </td></tr>"  crlf)



  (printout t "|" tab tab "| (-) " ?gastos-de-operacion tab "Gastos Operacionales (Gastos Admon + Gastos Vtas + I+D + Promocion + Amortiza + Depreciacion)" crlf)
  (printout k "<tr><td></td><td></td><td></td><td>(-)</td><td align='right'>" ?gastos-de-operacion "</td><td colspan='4'> Gastos de Deducibles de Impuesto (Gastos Admon + Gastos Vtas + I+D + Promocion + Amortiza.Int A.31-LIR) </td></tr>"  crlf)



  (printout t "|" ?gastos-administrativos tab tab tab tab  "Gastos del Dpto Administraci??n" crlf)
  (printout t "|" ?gastos-ventas tab tab tab tab "Gastos del Dpto Ventas" crlf)
  (printout t "|" ?gastos-en-investigacion-y-desarrollo tab tab tab tab "Gastos en I+D" crlf)
  (printout t "|" ?gastos-en-promocion tab tab tab tab "Gastos en Promocion" crlf)
  (printout t "|" ?salarios tab tab tab tab "Salarios" crlf)

  (printout t "|" ?perdida-por-correccion-monetaria tab tab tab tab "P??rdida por Correcci??n Monetaria" crlf)

  (printout t "|" ?amortizacion-intangibles tab tab tab tab " (-) Amortizacion Contable Intangibles" crlf)
  (printout t "|" ?depreciacion tab tab tab tab " (-) Depreciacion" crlf)


  (printout k "<tr><td> (-) </td><td align='right'>" ?gastos-administrativos "</td><td></td><td></td><td></td><td> Gastos del Dpto Administraci??n </td></tr>" crlf)

  (printout k "<tr><td> (-) </td><td align='right'>" ?gastos-ventas "</td><td></td><td></td><td></td><td> Gastos del Dpto Ventas </td></tr>" crlf)

  (printout k "<tr><td>(-)</td><td align='right' >" ?gastos-en-investigacion-y-desarrollo "</td><td></td><td></td><td></td><td> Gastos en I+D </td></tr>" crlf)
  (printout k "<tr><td>(-)</td><td align='right'>" ?gastos-en-promocion "</td><td></td><td></td><td></td><td> Gastos en Promoci??n </td></tr>" crlf)

  (printout k "<tr><td>(-)</td><td align='right'>" ?salarios "</td><td></td><td></td><td></td><td> Salarios </td></tr>" crlf)

  (printout k "<tr><td>(-) </td><td align='right'>" ?perdida-por-correccion-monetaria "</td><td></td><td></td><td></td><td> P??rdida Por Correcci??n Monetaria </td></tr>" crlf)

 (printout k "<tr><td>(-) </td><td align='right'>" ?amortizacion-intangibles "</td><td></td><td></td><td></td><td> Amortizaci??n </td></tr>" crlf)

 (printout k "<tr><td>(-) </td><td align='right'>" ?depreciacion "</td><td></td><td></td><td></td><td> Depreciaci??n </td></tr>" crlf)


  (printout t "|" tab tab "| (-) " ?pea tab tab "P??rdida Ejercicio Anterior PEA A.33-LIR)" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>" ?pea "</td><td> P??rdida Ejercicio Anterior PEA A.33-LIR </td></tr>" crlf)

  (printout t "|" tab tab "|     " ?utilidad-de-operacion tab "UTILIDAD DE OPERACION (U.Bruta - G.Ded. - PEA)" crlf)
  (printout k "<tr><td> </td><td></td><td></td><td></td><td align='right'> " ?utilidad-de-operacion "</td><td> UTILIDAD DE OPERACI??N </td></tr>" crlf)

  (printout t "|" tab tab "| (-) " tab "Otros Gastos" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>" 0 "</td><td> Otros Gastos </td></tr>" crlf)


  (printout t "|" tab tab "|     " ?utilidad-antes-de-reserva tab "UTILIDAD ANTES DE RESERVA (U.Op-Reserva Lega)" crlf)
  (printout k "<tr><td></td><td> </td><td> </td><td></td><td align='right'>" ?utilidad-antes-de-reserva "</td><td> Utilidad Antes de Reserva </td></tr>" crlf)


  (printout t "|" tab tab  "| (-) " tab ?reserva-legal tab " Reserva Legal" crlf)

  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>" ?reserva-legal "</td><td> Reserva Legal </td></tr>" crlf)

  (printout t "|" tab tab "| (=) " ?margen-de-explotacion tab "Resultado de Explotaci??n " crlf)
  (printout k "<tr style='font-weight:bold; background-color: azure'><td> <td></td></td><td> </td><td></td><td align='right'>" ?margen-de-explotacion "</td><td> Resultado de Explotacion </td></tr>" crlf)


  (printout t "|" tab tab "| (+) " ?ganancia-por-correccion-monetaria tab "Ganancia Por Correcci??n Monetaria" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (+) </td><td align='right'>" ?ganancia-por-correccion-monetaria "</td><td> Ganancia Por Correcci??n Monetaria </td></tr>" crlf)



  (printout t "|" tab tab "| (-) " ?impuestos-no-recuperables tab "Impuestos No Recuperables" crlf)
  (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right'>"  ?impuestos-no-recuperables "</td><td> Impuestos No Recuperables </td></tr>" crlf)


  (printout t "|" tab tab "| (=)   " ?margen-fuera-de-explotacion tab "Resultado Fuera de Explotaci??n " crlf)
  (printout k "<tr style='font-weight:bold; background-color: azure'><td> <td></td></td><td> </td><td></td><td align='right'>" ?margen-fuera-de-explotacion "</td><td> Resultado Fuera de Explotacion </td></tr>" crlf)



  (printout t "|" tab tab "|     " ?utilidad-antes-de-idpc tab "Resultado Antes de Impuesto" crlf)
  (printout k "<tr style='font-weight:bold; background-color: azure'><td> <td></td></td><td> </td><td></td><td align='right'>" ?utilidad-antes-de-idpc "</td><td> Resultado Antes de Impuesto</td></tr>" crlf)


  ( if (> ?margen-fuera-de-explotacion ?utilidad-del-ejercicio ) then
    (printout t "|" tab tab "| (-) " ?idpc tab "Impuesto Determinado, factor es " ?tasa-idpc " en " ?ano crlf)
    (printout k "<tr style='background-color: lightgreen' ><td></td><td></td><td></td><td> (X) </td><td align='right'> " ?idpc "</td><td> Impuesto No Aplica porque hay p??rdida tributaria </td></tr>" crlf)
    (bind ?utilidad ?utilidad-antes-de-idpc )
  )



  ( if (< ?margen-fuera-de-explotacion ?utilidad-del-ejercicio ) then
    (printout t "|" tab tab "| (-) " ?idpc tab "Impuesto Determinado, factor es " ?tasa-idpc " en " ?ano crlf)
    (printout k "<tr style='font-weight:bold; background-color: azure'><td></td><td></td><td></td><td> (-) </td><td align='right'> " ?idpc "</td><td> Impuesto Determinado, factor es: " ?tasa-idpc " en " ?ano " </td></tr>" crlf)
    (bind ?utilidad (+ ?utilidad-antes-de-idpc ?idpc))
  )


  (printout t "|" tab tab "|     " ?utilidad tab "Utilidad Calculada" crlf)
  (printout k "<tr style='font-weight:bold;background-color: azure'><td> <td></td></td><td> </td><td></td><td align='right'>" ?utilidad "</td><td> Utilidad Calculada</td></tr>" crlf)

  (printout t "|" tab tab "|     " (- ?utilidad-acreedor ?utilidad-deber) tab "Utilidad del ejercico (m??dulo liquidaci??n)" crlf)
  (printout k "<tr style='font-weight:bold;background-color: azure'><td> <td></td></td><td> </td><td></td><td align='right'>" (- ?utilidad-acreedor ?utilidad-deber) "</td><td> Utilidad del Ejercicio (m??dulo liquidaci??n)</td></tr>" crlf)

  (printout t "|" ?herramientas tab tab tab tab "Depreciaci??n Instantanea Propyme" crlf)
  (printout t "|" ?amortizacion-acumulada-instantanea tab tab tab tab "Amortizacion Instantanea Intangibles (no-contable) " crlf)

  (printout k "<tr><td> (-) </td><td align='right'>" ?herramientas "</td><td></td><td></td><td></td><td> Depreciaci??n Instant??nea Activo Fijo Propyme </td></tr>" crlf)
  ( printout k "<tr><td> (-) </td><td align='right'>" ?amortizacion-acumulada-instantanea "</td><td></td><td></td><td></td><td> Amortizaci??n Instant??nea Intangibles </td></tr>" crlf)

  ( printout t "|" ?aportes tab tab tab tab "Aportes" crlf)
  ( printout k "<tr><td> (?) </td><td align='right'>" ?aportes "</td><td></td><td></td><td></td><td> Aportes </td></tr>" crlf)

  (printout t "|" tab tab "| (=) " ?utilidad-tributaria tab "Utilidad Tributaria" crlf)
  (printout k "<tr><td> <td></td></td><td> </td><td> (=) </td><td align='right'>" ?utilidad-tributaria "</td><td> Utilidad Tributaria </td></tr>" crlf)

  
  (printout t "|" tab tab "| (=) " ?utilidad-del-ejercicio tab "BASE IMPONIBLE (U.Antes.idpc - idpc) (m??dulo liquidaciones)" crlf) 


  (if (eq ?utilidad-del-ejercicio ?utilidad-tributaria)
   then
    (printout k "<tr><td></td><td></td><td></td><td> (=) </td><td align='right' style='background-color: lightgreen'>" ?utilidad-del-ejercicio "</td><td> BASE IMPONIBLE (m??dulo liquidaciones) <small> " ?regimen "</small></td></tr>" crlf)
  else
    (printout k "<tr><td></td><td></td><td></td><td> (=) </td><td align='right' style='font-weight:bold; color: white; background-color: crimson'>" ?utilidad-del-ejercicio "</td><td> BASE IMPONIBLE (m??dulo liquidaciones) <small>" ?regimen "</small></td></tr>" crlf)
  )
 
 (if (and (eq ?regimen propyme) (> ?utilidad-del-ejercicio 0))
   then 
    (printout k "<tr><td></td><td></td><td></td><td> (-) </td><td align='right' style=' background-color: gold'>" (* ?utilidad-del-ejercicio 0.5) "</td><td>    Rebaja Art.14 Letra E <small>" ?regimen "</small></td></tr>" crlf)
    (printout k "<tr><td></td><td></td><td></td><td> (=) </td><td align='right' style='font-weight:bold; color: white; background-color: crimson'>" (* ?utilidad-del-ejercicio 0.5) "</td><td> RENTA LIQUIDA IMPONIBLE</td></tr>" crlf)
  ; (printout k "<tr><td></td><td></td><td></td><td> (=) </td><td align='right' style='font-weight:bold; color: white; background-color: crimson'>" (* ?utilidad-del-ejercicio 0.5 ?tasa-idpc)"</td><td> IDPC A PAGAR <small> " ?tasa-idpc " en marzo </small></td></tr>" crlf)
 )  

; (printout t "|" tab tab "|     ------" crlf)

; (printout t "|" tab tab "|     " ?utilidad-antes-de-idpc tab "UTILIDAD ANTES DE IMPUESTO A LA RENTA (U.Antes.Reserva - idpc)" crlf)
; (printout t "|" tab tab "| (-) " ?provision-impuesto-a-la-renta tab " Provisi??n de Impuesto Renta " crlf)
 
; (printout t "|" tab tab "| (=) " (- ?utilidad-antes-de-idpc ?provision-impuesto-a-la-renta) tab "UTILIDAD DEL EJERCICIO AJUSTADA (U.Ejercicio - Provision idpc)" crlf)
  (printout t "================================================================================" crlf)
  
  (printout k "</tbody></table>")
)


