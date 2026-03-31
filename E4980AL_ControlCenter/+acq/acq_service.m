function svc = acq_service(measSvc, plotSvc)
% 采样服务（第一阶段）

    acqTimer = [];
    acqData = table();
    acqIndex = 0;
    acqStartTic = [];

    svc.start = @startImpl;
    svc.stop = @stopImpl;
    svc.tick = @tickImpl;
    svc.data = @dataImpl;
    svc.count = @countImpl;

    function startImpl(interval, duration, triggerMode)
        nMax = max(1, floor(duration / interval));
        acqData = table(NaN(nMax,1), NaN(nMax,1), NaN(nMax,1), strings(nMax,1), ...
            'VariableNames', {'Time_s', 'Primary', 'Secondary', 'Status'});
        acqIndex = 0;
        acqStartTic = tic;

        acqTimer = timer('ExecutionMode', 'fixedSpacing', 'Period', interval, ...
            'TasksToExecute', nMax, 'BusyMode', 'drop', ...
            'TimerFcn', @(~,~)tickImpl(triggerMode));
        start(acqTimer);
    end

    function stopImpl()
        if ~isempty(acqTimer) && isvalid(acqTimer)
            try, stop(acqTimer); catch, end
            try, delete(acqTimer); catch, end
        end
        acqTimer = [];
    end

    function [p1, p2, stat] = tickImpl(triggerMode)
        [p1, p2, stat] = measSvc.fetchOnce(triggerMode);
        acqIndex = acqIndex + 1;
        acqData.Time_s(acqIndex) = toc(acqStartTic);
        acqData.Primary(acqIndex) = p1;
        acqData.Secondary(acqIndex) = p2;
        acqData.Status(acqIndex) = string(stat);
        plotSvc.update(acqData.Time_s(1:acqIndex), acqData.Primary(1:acqIndex), acqData.Secondary(1:acqIndex));
    end

    function out = dataImpl()
        out = acqData;
    end

    function n = countImpl()
        n = acqIndex;
    end
end
