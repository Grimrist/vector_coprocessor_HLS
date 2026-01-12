function write2dev(filename, block, port)
    data = readmatrix(filename);
    num_datos = 1024;
    size_data = size(data,1);
    diff = num_datos - size_data;
    if (diff > 0)
        data(size_data+1:num_datos) = zeros([diff 1]);
    end
    
    %% Select block
    switch (block)
        case 'BRAMA'
            cmd = 0x00;
        case 'BRAMB'
            cmd = 0x11;
        otherwise
            warning('Invalid bram block')
            return
    end

    %% Configuracion de UART
    puerto = serialport(port, 115200);

    %% Enviar comando write2dev
    write(puerto, uint8(0), "uint8");
    write(puerto, uint8(cmd), "uint8");
    for k = 1:num_datos
        dato = data(k);
    
        % separa el número de 10 bits en dos bytes
        low  = bitand(dato, 255);    % 8 bits bajos
        high = bitshift(dato, -8);   % 2 bits altos
    
        % enviar al puerto serial
        write(puerto, uint8(low), "uint8");
        write(puerto, uint8(high), "uint8");
    end
    % indicar fin de trama
    write(puerto, uint8(0xFF), "uint8");
    write(puerto, uint8(0xFF), "uint8");
end