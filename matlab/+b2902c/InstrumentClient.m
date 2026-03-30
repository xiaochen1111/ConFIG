classdef InstrumentClient < handle
    %InstrumentClient B2902C TCP/SCPI 通信封装

    properties (Access = private)
        tcp = []
    end

    methods
        function connect(self, ip, port)
            if self.isConnected()
                return;
            end
            self.tcp = tcpclient(ip, port, 'Timeout', 10, 'ConnectTimeout', 5);
            configureTerminator(self.tcp, 'LF');
        end

        function disconnect(self)
            self.tcp = [];
        end

        function tf = isConnected(self)
            tf = ~isempty(self.tcp);
        end

        function out = query(self, cmd)
            self.assertConnected();
            out = strtrim(writeread(self.tcp, cmd));
        end

        function write(self, cmd)
            self.assertConnected();
            writeline(self.tcp, cmd);
        end

        function [v, i] = measureChannel(self, ch)
            v = str2double(strtrim(self.query(sprintf(':MEAS:VOLT? (@%d)', ch))));
            i = str2double(strtrim(self.query(sprintf(':MEAS:CURR? (@%d)', ch))));
        end
    end

    methods (Access = private)
        function assertConnected(self)
            if ~self.isConnected()
                error('InstrumentClient:NotConnected', '设备未连接。');
            end
        end
    end
end
