# Vector Coprocessor - HLS

## Descripción
Este repositorio contiene los códigos fuentes para un co-procesador de vectores, ademas de un script de MATLAB que provee una interfaz para interactuar con el procesador. Este proyecto fue creado utilizando Vivado 2025.1 y Vitis Unified IDE 2025.1.

Este co-procesador trabaja con dos vectores de 10 bit con 1024 elementos, y es capaz de efectuar cuatro operaciones:
- write2dev: Permite almacenar un vector enviado desde el host a una de sus dos memorias internas.
- readVec: Lee una de las dos memorias internas y las envía hacia el host, retornando 1024 elementos de 10 bits.
- eucDist: Calcula la distancia euclidiana entre el vector A y el vector B, retornando un valor de 15 bits.
- dotProd: Calcula el producto punto entre el vector A y el vector B, retornando un valor de 30 bits.
Para la implementación de la distancia euclidiana y el producto punto, se utilizo HLS, en particular utilizando Vitis para describir las operaciones utilizando C++.
## Estructura de Repositorio
Este repositorio esta estructurado de la siguiente manera:
- _Vitis_: Archivos fuente HLS (.cpp, .hpp) para las operaciones eucDist y dotProd
- _Vivado_: Archivos fuente del RTL para el sistema completo del procesador
- _MATLAB_: Scripts de MATLAB para enviar comandos hacia el co-procesador implementado.
- _images_: Imágenes utilizadas para este README.
## Pragmas utilizados
Las operaciones eucDist y dotProd utilizan los siguientes pragma:

| Operacion | Array Partition (Input A) | Array Partition (Input B) | Unroll |
| --------- | ------------------------- | ------------------------- | ------ |
| EucDist   | 1024                      | 1024                      | 128    |
| DotProd   | 1024                      | 1024                      | 64     |

Al maximizar el valor de array partition en 1024, se reduce la latencia y uso de recursos requerida para la lógica de acceso de memoria, accediendo ambos vectores en paralelo. Los valores de unroll fueron elegidos de tal manera de utilizar el factor de dos mas grande posible. Mientras que habría sido posible utilizar un unroll de 128 o mas grande en DotProd, esto hubiera ocupado mas DSP y LUT de lo que hay disponible en el sistema, por lo cual se optó por 64.
## Uso de recursos
El sistema implementado utiliza los siguientes recursos:

| LUT   | FF    | DSP |
| ----- | ----- | --- |
| 22329 | 53789 | 192 |

Ademas, el tiempo de sintetización e implementación del co-procesador completo utilizando un procesador Intel Core i5-11400H 2.70GHz es el siguiente:

| Sintetizacion (mm:ss) | Implementacion (mm:ss) | Bitstream (mm:ss) |
| --------------------- | ---------------------- | ----------------- |
| 02:12                 | 10:53                  | 00:20             |

## Métricas de desempeño
El sistema es capaz de funcionar a una frecuencia maxima de 122 MHz. A través de mediciones con el Integrated Logic Analyzer (ILA), se obtuvo el tiempo efecto en ciclos que se tarda cada operación en ejecutar dentro del Processing Core, sin considerar los tiempos de comunicación, midiendo solamente el tiempo desde el gatillado de la operación hasta que el ultimo bit de la salida este listo para enviar.  Con este análisis, se obtiene los siguientes valores de latencia y throughput para cada operación:

| Operacion | Latencia (ns) | Throughput (Mbit/s) |
| --------- | ------------- | ------------------- |
| EucDist   | 204.92        | 78.08               |
| DotProd   | 163.93        | 183.00              |

## Como utilizar este proyecto

Para generar este proyecto correctamente, primero es necesario crear las IPs necesarias para el funcionamiento del Processing Core. Para esto, es necesario descargar Vitis Unified IDE 2025.1.
Se debe crear dos componentes, una para la operación EucDist y otra para la operación DotProd. El proceso de creación de componentes es el siguiente:

1. Primero, se debe crear un componente HLS nuevo utilizando la barra de herramientas superior ![](/images/vitis_new_comp.png)
2. Luego, se debe crear un componente con el nombre correspondiente (DotProd o EucDist)![](/images/vitis_comp_name.png)
3. El archivo de configuración debe ser uno vacío (opción por defecto).
4. Se debe agregar el codigo fuente para la operación respectiva (dot_product.cpp y .hpp para DotProd, eucDist.cpp y .hpp para EucDist). Ademas, se debe fijar el Top Function a la funcion top correspondiente (dot_product para DotProd, eucDist para EucDist)![](/images/vitis_comp_sources.png)
5. Se debe seleccionar el hardware al cual se desea implementar. Este proyecto fue probado en un Artix-7 XC7A100TCSG324-1.![](/images/vitis_comp_hardware.png)
6. Finalmente, la configuracion inicial se puede dejar en defecto. En particular, flow_target debe ser Vivado IP Flow Target, y package.output.format debe ser Generate Vivado IP and .zip archive ![](/images/vitis_comp_settings.png)
7. Luego de crear esta componente nueva, se debe correr el paso de C Synthesis, obteniendo el siguiente reporte dependiendo de la operacion:
	- DotProd:![](/images/vitis_perf_dotprod.png)
	- EucDist:![](/images/vitis_perf_eucdist.png)
8. Luego, se debe ejecutar el paso de Package, utilizando la configuración por defecto (en particular, output.format debe ser ip_catalog). Al completar este paso, se generara un archivo .zip con el IP en la ubicación {component_dir}/dot_product/hls/impl/ip/. 
9. En un proyecto nuevo de Vivado, se debe agregar como Sources todos los archivos contenidos en la carpeta Vivado del repositorio.
10. Los ZIP generados previamente se debe extraer a carpetas individuales nueva (e.g. EucDist puede ir en una carpeta ./ip/EucDist, y DotProd en una carpeta ./ip/DotProd). En el menu "IP Catalog" de Vivado, se debe hacer click derecho y seleccionar "Add Repository", y luego agregar la carpeta base creada ("./ip" en nuestro ejemplo). Los IP deben aparecer de la siguiente manera: ![](/images/ip_catalog.png)
11. Se debe hacer doble click (o click derecho -> Customize IP) para crear un bloque IP para cada operación, seleccionando "OK" y luego "Generate". Las fuentes contienen templates ya inicializados de los IP, por lo cual hecho esto se puede ejecutar todo el flujo de síntesis e implementacion, y generar el bitstream.
