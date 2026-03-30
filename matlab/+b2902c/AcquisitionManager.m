classdef AcquisitionManager < handle
    %AcquisitionManager 预分配采样管理

    properties (SetAccess = private)
        data = table()
        idx = 0
    end

    properties (Access = private)
        timerObj = []
        t0
        measureFn
    end

    properties
        onTick = []  % function handle: f(data, idx)
        onStop = []  % function handle: f(data, idx)
    end

    methods
        function start(self, interval, duration, measureFn)
            self.stop();

            if interval <= 0
                error('AcquisitionManager:InvalidInterval', '采样间隔必须大于 0。');
            end
            if duration <= 0
                error('AcquisitionManager:InvalidDuration', '采样时长必须大于 0。');
            end

            nMax = max(1, floor(duration / interval));
            self.data = table( ...
                NaN(nMax, 1), NaN(nMax, 1), NaN(nMax, 1), NaN(nMax, 1), NaN(nMax, 1), ...
                'VariableNames', {'Time_s', 'CH1_V', 'CH1_I', 'CH2_V', 'CH2_I'});
            self.idx = 0;
            self.t0 = tic;
            self.measureFn = measureFn;

            self.timerObj = timer( ...
                'ExecutionMode', 'fixedSpacing', ...
                'Period', interval, ...
                'TasksToExecute', nMax, ...
                'BusyMode', 'drop', ...
                'TimerFcn', @(~, ~)self.tick(), ...
                'StopFcn', @(~, ~)self.stopCallback());

            start(self.timerObj);
        end

        function stop(self)
            if ~isempty(self.timerObj) && isvalid(self.timerObj)
                try
                    stop(self.timerObj);
                catch
                end
                try
                    delete(self.timerObj);
                catch
                end
            end
            self.timerObj = [];
        end

        function tf = isRunning(self)
            tf = ~isempty(self.timerObj) && isvalid(self.timerObj) ...
                && strcmpi(self.timerObj.Running, 'on');
        end

        function saveCsv(self, fullFile)
            if self.idx <= 0
                error('AcquisitionManager:NoData', '没有可保存的数据。');
            end
            writetable(self.data(1:self.idx, :), fullFile);
        end

        function clearData(self)
            self.data = table();
            self.idx = 0;
        end
    end

    methods (Access = private)
        function tick(self)
            self.idx = self.idx + 1;
            [v1, i1, v2, i2] = self.measureFn();
            self.data.Time_s(self.idx) = toc(self.t0);
            self.data.CH1_V(self.idx) = v1;
            self.data.CH1_I(self.idx) = i1;
            self.data.CH2_V(self.idx) = v2;
            self.data.CH2_I(self.idx) = i2;

            if ~isempty(self.onTick)
                self.onTick(self.data, self.idx);
            end
        end

        function stopCallback(self)
            if ~isempty(self.onStop)
                self.onStop(self.data, self.idx);
            end
        end
    end
end
