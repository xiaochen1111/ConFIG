function svc = acq_service(measSvc, plotSvc)
% 采样服务（增强版）

    acqTimer = [];
    acqData = table();
    acqIndex = 0;
    acqStartTic = [];
    tickCb = [];
    stopCb = [];

    svc.start = @startImpl;
    svc.stop = @stopImpl;
    svc.data = @dataImpl;
    svc.count = @countImpl;
    svc.clear = @clearImpl;
    svc.saveCsv = @saveCsvImpl;
    svc.isRunning = @isRunningImpl;

    function startImpl(interval, duration, triggerMode, onTickCb, onStopCb)
        if nargin < 4, onTickCb = []; end
        if nargin < 5, onStopCb = []; end
        if isRunningImpl()
            return;
        end

        nMax = max(1, floor(duration / interval));
        acqData = table(NaN(nMax,1), NaN(nMax,1), NaN(nMax,1), strings(nMax,1), ...
            'VariableNames', {'Time_s', 'Primary', 'Secondary', 'Status'});
        acqIndex = 0;
        acqStartTic = tic;
        tickCb = onTickCb;
        stopCb = onStopCb;

        acqTimer = timer('ExecutionMode', 'fixedSpacing', 'Period', interval, ...
            'TasksToExecute', nMax, 'BusyMode', 'drop', ...
            'TimerFcn', @(~,~)tickImpl(triggerMode), ...
            'StopFcn', @(~,~)notifyStopImpl());
        start(acqTimer);
    end

    function tickImpl(triggerMode)
        [p1, p2, stat] = measSvc.fetchOnce(triggerMode);
        acqIndex = acqIndex + 1;
        acqData.Time_s(acqIndex) = toc(acqStartTic);
        acqData.Primary(acqIndex) = p1;
        acqData.Secondary(acqIndex) = p2;
        acqData.Status(acqIndex) = string(stat);
        plotSvc.update(acqData.Time_s(1:acqIndex), acqData.Primary(1:acqIndex), acqData.Secondary(1:acqIndex));

        if ~isempty(tickCb)
            tickCb(acqIndex, p1, p2, stat);
        end
    end

    function notifyStopImpl()
        if ~isempty(stopCb)
            stopCb(acqIndex);
        end
    end

    function stopImpl()
        if ~isempty(acqTimer) && isvalid(acqTimer)
            try, stop(acqTimer); catch, end
            try, delete(acqTimer); catch, end
        end
        acqTimer = [];
    end

    function out = dataImpl()
        if acqIndex == 0
            out = table();
        else
            out = acqData(1:acqIndex,:);
        end
    end

    function n = countImpl()
        n = acqIndex;
    end

    function clearImpl()
        acqData = table();
        acqIndex = 0;
        plotSvc.clear();
    end

    function saveCsvImpl(filename)
        if acqIndex == 0
            error('当前没有可保存的数据。');
        end
        writetable(acqData(1:acqIndex,:), filename);
    end

    function tf = isRunningImpl()
        tf = ~isempty(acqTimer) && isvalid(acqTimer) && strcmpi(acqTimer.Running, 'on');
    end
end
