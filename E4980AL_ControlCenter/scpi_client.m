function clientApi = scpi_client()
% SCPI 通信层（最小封装版）
% 用法：
%   dev = scpi_client();
%   dev.connect(ip,port);
%   txt = dev.query('*IDN?');
%   dev.write(':FREQ 1000');
%   tf = dev.isConnected();
%   dev.disconnect();

    client = [];

    clientApi.connect = @connectImpl;
    clientApi.disconnect = @disconnectImpl;
    clientApi.query = @queryImpl;
    clientApi.write = @writeImpl;
    clientApi.isConnected = @isConnectedImpl;

    function connectImpl(ip, port)
        if ~isempty(client)
            return;
        end
        client = tcpclient(ip, port, 'Timeout', 10, 'ConnectTimeout', 5);
        configureTerminator(client, 'LF');
    end

    function disconnectImpl()
        client = [];
    end

    function out = queryImpl(cmd)
        assert(~isempty(client), 'SCPI:NotConnected', '设备未连接。');
        out = strtrim(writeread(client, cmd));
    end

    function writeImpl(cmd)
        assert(~isempty(client), 'SCPI:NotConnected', '设备未连接。');
        writeline(client, cmd);
    end

    function tf = isConnectedImpl()
        tf = ~isempty(client);
    end
end
