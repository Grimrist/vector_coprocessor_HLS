Interfaz MATLAB para coprocesador de vectores
Para utilizar esta interfaz, se debe incluir los archivos "write2dev.m" y "command2dev.m" en el workspace de MATLAB.
Ademas, se puede utilizar el archivo "coprocessorTesting.m" en conjunto con ellos para probar el sistema.
Dentro de "coprocessorTesting.m", se debe ajustar la variable COM_port para apuntar al puerto serial de la FPGA,
y se puede ajustar N_ELEMENTS para cambiar las dimensiones de los vectores utilizados para los calculos.
N_ELEMENTS debe ser un valor entre 1 y 1024.
BIT_WIDTH controla el tamaño de los elementos generados, medido en bits, y debe ser un valor entre 1 y 10.

Comandos disponibles:

----------------------------------
write2dev(archivo, bram, puerto) 
----------------------------------
Esta funcion permite guardar un vector a la memoria BRAM especificada.

Parametros:
archivo ->  Archivo de texto que contiene entre 1 y 1024 elementos
bram    ->  "BRAMA" o "BRAMB" dependiendo del bloque al que se desea escribir
puerto  ->  Puerto serial al cual el procesador esta conectado (e.g. COM4 en Windows, /dev/ttyUSB1 en Linux)

----------------------------------
command2dev(comando, puerto) -> Matriz 1024x1 de enteros
command2dev(comando, bram, puerto) -> Matriz 1024x1 de enteros
----------------------------------
Esta funcion ejecutar el comando indicado en el coprocesador, y retorna una matriz de 1024x1 elementos.

Parametros:
comando -> String que indica el comando a ejecutar en el coprocesador. La lista de comandos es la siguiente:
            - "readVec" Este comando lee los contenidos de la memoria BRAM seleccionada. Requiere el uso de la funcion de 3 parametros, 
                        indicando "BRAMA" o "BRAMB" dependiendo del bloque el cual se desea leer
            - "eucDist" Este comando calcula la distancia euclideana entre los dos puntos indicados por los vectores en la memoria del coprocesador.
                        Dado que el coprocesador trabaja con enteros, entrega un valor aproximado de 16 bits, con los decimales truncados.
            - "dotProd" Este comando calcula el producto punto entre los dos vectores almacenados en la memoria del coprocesador.
bram    ->  Indica el bloque BRAM a leer, solo se utiliza para el comando "readVec"
puerto  ->  Puerto serial al cual el procesador esta conectado (e.g. COM4 en Windows, /dev/ttyUSB1 en Linux)