# syntax=docker/dockerfile:1
FROM cupercupu/clipspy AS build

#oputput from contabilidad.py
RUN mkdir /doc
RUN mkdir /doc/alectrico-2021
RUN mkdir /doc/_posts
RUN mkdir /doc/_data

#input to contabilidad.py
COPY *.bat                    ./
COPY *.clp                    ./

COPY alectrico-2021-facts.txt              ./
COPY alectrico-2021-revisiones.txt         ./
COPY alectrico-2021-revisiones-cuentas.txt ./
COPY alectrico-2021-valor-activos.txt      ./
COPY alectrico-2021-tasas.txt              ./

COPY contratos.txt                ./
copy cuentas.txt                  ./
copy proveedores.txt              ./
COPY remuneraciones.txt           ./
COPY trabajadores.txt             ./
COPY salud.txt                    ./
COPY tipos_de_depreciaciones.txt  ./
COPY selecciones.txt              ./
COPY accionistas.txt              ./
COPY afc.txt                      ./
COPY afps.txt                     ./
COPY tramos-de-impuesto-unico.txt ./
COPY 404.html                     ./
COPY contabilidad.py              ./

WORKDIR .

RUN ./contabilidad.py

FROM jekyll/jekyll 

#Estos son manuales
#OPY ./*.markdown         ./
COPY ./contaible.markdown ./
COPY ./acerca.markdown    ./
COPY ./nota.markdown      ./

#estos resultan de contabilidad.py
COPY --from=build ./doc/alectrico-2021/ ./alectrico-2021/

#Este copy a veces falla y hace abortar el proceso
#Ocurre cuando no hay *.markdown que copiar
COPY --from=build ./doc/*.markdown      ./




#Estos son manuales
#En alectrico-2021 se guardan los archivos que se son referidos 
#dese las paginas del servidor que pone en funcionamiento jekyll
COPY ./alectrico-2021/ ./alectrico-2021/
COPY ./_config.yml     ./


WORKDIR ./
VOLUME /doc
