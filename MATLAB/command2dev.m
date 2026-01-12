function res = command2dev(varargin)
    %% Validar entrada
    if length(varargin) > 3 || length(varargin) < 2
        warning('Invalid argument count')
        return
    end
    BRAM_bit = 0;
    if length(varargin) == 3
        switch (char(varargin(2)))
            case 'BRAMA'
                BRAM_bit = 0;
            case 'BRAMB'
                BRAM_bit = 1;
            otherwise
                warning('Invalid BRAM block')
                return
        end
        COM_port = char(varargin{3});
    else 
        COM_port = char(varargin{2});
    end
    %% Leer comando
    switch (char(varargin(1)))
        case 'readVec'
            cmd = 0b001;
            N_ELEMENTS = 1024;
            BIT_WIDTH = 32;
        % case 'sumVec'
        %     cmd = 0b10;
        %     N_ELEMENTS = 1024;
        %     BIT_WIDTH = 24;
        % case 'avgVec'
        %     cmd = 0b11;
        %     N_ELEMENTS = 1024;
        %     BIT_WIDTH = 24;
        case 'eucDist'
            cmd = 0b100;
            N_ELEMENTS = 1;
            BIT_WIDTH = 32;
        % case 'manDist'
        %     cmd = 0b110;
        %     N_ELEMENTS = 1;
        %     BIT_WIDTH = 24;
        case 'dotProd'
            cmd = 0b110;
            N_ELEMENTS = 1;
            BIT_WIDTH = 32;
        otherwise
            warning('Invalid command')
            return
    end
    %% Configuracion de UART
    % Configurar puerto serial
    puerto = serialport(COM_port, 115200);

    %% Crear variables para sujetar salida
    res = zeros([N_ELEMENTS 1]);
    byte_count = ceil(BIT_WIDTH/8);
    

    %% Enviar comando read2dev
    bram_set = bitshift(BRAM_bit, 3);
    read_cmd = bitor(cmd, bram_set);
    write(puerto, uint8(read_cmd), "uint8");
    
    for k = 1:N_ELEMENTS
        rx_bytes = read(puerto, byte_count, "uint8");
        for j = 1:byte_count
            res(k)  = bitor(res(k), bitshift(rx_bytes(j), 8*(j-1)));
        end
    end
end
