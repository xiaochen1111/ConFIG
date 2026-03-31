function utils = app_utils(ui, theme)
% 通用 UI 辅助

    utils.addLog = @addLog;
    utils.setConnectionUI = @setConnectionUI;
    utils.showWarn = @showWarn;

    function addLog(msg)
        if ~isfield(ui, 'txtLog') || isempty(ui.txtLog) || ~isvalid(ui.txtLog)
            return;
        end
        timestamp = datestr(now, 'HH:MM:SS');
        oldVal = ui.txtLog.Value;
        if ischar(oldVal), oldVal = {oldVal}; end
        ui.txtLog.Value = [oldVal; {[timestamp '  ' msg]}];
        drawnow limitrate;
    end

    function setConnectionUI(isConnected, detailText)
        if nargin < 2, detailText = ''; end
        if isConnected
            ui.navLamp.Color = theme.C_success;
            ui.navStatus.Text = '已连接';
            ui.statusLeft.Text = '状态：已连接';
        else
            ui.navLamp.Color = theme.C_danger;
            ui.navStatus.Text = '未连接';
            ui.statusLeft.Text = '状态：未连接';
        end
        if ~isempty(detailText)
            ui.statusRight.Text = detailText;
        end
    end

    function showWarn(titleText, msg)
        uialert(ui.mainFig, msg, titleText, 'Icon', 'warning');
    end
end
