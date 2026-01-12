clc,close,clear all; % borra el workspace

%% Configuracion de UART
N_ELEMENTS=1024;  % define el numero de elementos de cada vector, maximo 1024
BIT_WIDTH = 10;
% Configurar puerto serial
COM_port = "COM4"; % Cambiar a puerto de usuario

%% Generacion de vectores

%Genera vectores A y B de 1024 elementos con numeros positivos 
%(puede adaptarse facilmente si usan negativos y positivos).
A=ceil((rand(N_ELEMENTS,1)*2^BIT_WIDTH - 1));
B=ceil((rand(N_ELEMENTS,1)*2^BIT_WIDTH - 1));

%Guarda vectores A y B (cada uno de una columna de 1024 filas) en un
%archivo de texto. Cada linea del archivo contiene un elemento.
h= fopen('VectorA.txt', 'w');
fprintf(h, '%i\n', A);
fclose(h);

h= fopen('VectorB.txt', 'w');
fprintf(h, '%i\n', B);
fclose(h);

%% Calcula valores de referencia para las operaciones, realizadas en forma local en el host
euc_host = round(sqrt(sum((A-B).^2))); % Llevado a entero ya que procesador no entrega flotantes
dot_host = dot(A,B);
%% A partir de aca se realizan las operaciones por medio de comandos al coprocesador

%writeVec escribe un vector almacenado en un archivo de texto en la BRAM indicada por medio de la UART
write2dev('VectorA.txt','BRAMA',COM_port);
write2dev('VectorB.txt','BRAMB',COM_port); 

%readVec lee el contenido de la BRAM indicada por medio de la UART
VecA_device = command2dev('readVec', 'BRAMA', COM_port);
VecB_device = command2dev('readVec', 'BRAMB', COM_port);
euc_device = command2dev('eucDist', COM_port); %realiza el calculo de la distancia Euclideana entre dos vectores y envia el resultado por la UART
dot_device = command2dev('dotProd', COM_port);
%% Validacion.
% Los resultados _diff deberian ser 0 (o cercanos, dependiendo de su
% decision de diseno en el diseno del coprocesador). Si no es 0, indique
% claramente por que en su informe.

readVec_A__diff = sum(A - VecA_device(1:N_ELEMENTS))
readVec_B_diff = sum(B - VecB_device(1:N_ELEMENTS))

euc_diff = euc_host - euc_device
dot_diff = dot_host - dot_device

