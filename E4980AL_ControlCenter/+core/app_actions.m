function actions = app_actions(state, ui, pages, dev, measSvc, acqSvc, plotSvc)
% 回调编排中心（增强版，向原始单文件行为对齐）

    currentPage = 'home';
    cfg = state.cfg;
    measCfg = state.meas;
    utils = core.app_utils(ui, state.theme);

    actions.showPage = @showPage;
    actions.onMainClose = @onMainClose;

    ui.btnHome.ButtonPushedFcn = @(~,~)showPage('home');
    ui.btnControl.ButtonPushedFcn = @(~,~)showPage('control');
    ui.btnAcq.ButtonPushedFcn = @(~,~)showPage('acq');
    ui.btnSettings.ButtonPushedFcn = @(~,~)showPage('settings');
    ui.btnAbout.ButtonPushedFcn = @(~,~)showPage('about');

    ui.btnConnect.ButtonPushedFcn = @onConnect;
    ui.btnDisconnect.ButtonPushedFcn = @onDisconnect;
    ui.btnReadIDN.ButtonPushedFcn = @onReadIDN;

    % control 页面
    if isfield(ui, 'btnApplyMeas'), ui.btnApplyMeas.ButtonPushedFcn = @onApplyMeasurementSettings; end
    if isfield(ui, 'btnMeasureOnce'), ui.btnMeasureOnce.ButtonPushedFcn = @onMeasureOnce; end
    if isfield(ui, 'btnRawQuery'), ui.btnRawQuery.ButtonPushedFcn = @onRawQuery; end
    if isfield(ui, 'btnRawWrite'), ui.btnRawWrite.ButtonPushedFcn = @onRawWrite; end

    % acq 页面
    if isfield(ui, 'btnStartAcq'), ui.btnStartAcq.ButtonPushedFcn = @onStartAcq; end
    if isfield(ui, 'btnStopAcq'), ui.btnStopAcq.ButtonPushedFcn = @onStopAcq; end
    if isfield(ui, 'btnSaveCsv'), ui.btnSaveCsv.ButtonPushedFcn = @onSaveCsv; end
    if isfield(ui, 'btnClearData'), ui.btnClearData.ButtonPushedFcn = @onClearData; end
    if isfield(ui, 'btnOpenPlot'), ui.btnOpenPlot.ButtonPushedFcn = @(~,~)plotSvc.open(ui.mainFig); end

    function showPage(pageName)
        currentPage = pageName;
        names = fieldnames(pages);
        for i = 1:numel(names)
            pages.(names{i}).Visible = 'off';
        end
        pages.(pageName).Visible = 'on';
        ui.hdrTitle.Text = pageName;
    end

    function tf = checkConn()
        tf = dev.isConnected();
        if ~tf
            utils.showWarn('未连接', '请先连接仪器。');
            utils.addLog('请先连接仪器。');
        end
    end

    function onConnect(~,~)
        if dev.isConnected()
            utils.addLog('已经处于连接状态。');
            return;
        end
        try
            dev.connect(cfg.ip, cfg.port);
            utils.setConnectionUI(true, state.brand.companyName);
            utils.addLog(sprintf('已连接到 %s:%d', cfg.ip, cfg.port));
        catch ME
            utils.setConnectionUI(false, state.brand.companyName);
            utils.addLog(['连接失败: ' ME.message]);
            utils.showWarn('连接失败', ME.message);
        end
    end

    function onDisconnect(~,~)
        try, acqSvc.stop(); catch, end
        try, dev.disconnect(); catch, end
        utils.setConnectionUI(false, state.brand.companyName);
        utils.addLog('连接已断开。');
    end

    function onReadIDN(~,~)
        if ~checkConn(), return; end
        try
            idn = measSvc.readIDN();
            ui.txtIDN.Value = {idn};
            if isfield(ui, 'txtRawResp') && ~isempty(ui.txtRawResp)
                ui.txtRawResp.Value = {idn};
            end
            utils.addLog(['IDN: ' idn]);
        catch ME
            utils.addLog(['读取 IDN 失败: ' ME.message]);
            utils.showWarn('读取 IDN 失败', ME.message);
        end
    end

    function onApplyMeasurementSettings(~,~)
        if ~checkConn(), return; end
        try
            measCfg.freq = ui.edtFreq.Value;
            measCfg.level = ui.edtLevel.Value;
            measCfg.param = ui.ddParam.Value;
            measCfg.aper = ui.ddAper.Value;
            measCfg.trigger = ui.ddTrigger.Value;
            measSvc.applySettings(measCfg.freq, measCfg.level, measCfg.param, measCfg.aper, measCfg.trigger);
            ui.edtResultMode.Value = measCfg.param;
            ui.measStatus.Text = sprintf('状态：已应用参数 | F=%g Hz | V=%g Vrms | %s | %s', measCfg.freq, measCfg.level, measCfg.param, measCfg.aper);
            ui.measStatus.BackgroundColor = state.theme.C_successSoft;
            utils.addLog(sprintf('已应用测量参数：频率=%g Hz，电平=%g Vrms，参数=%s，速度=%s，触发=%s', measCfg.freq, measCfg.level, measCfg.param, measCfg.aper, measCfg.trigger));
        catch ME
            ui.measStatus.Text = '状态：参数应用失败';
            ui.measStatus.BackgroundColor = state.theme.C_warningSoft;
            utils.addLog(['应用测量参数失败: ' ME.message]);
            utils.showWarn('应用测量参数失败', ME.message);
        end
    end

    function onMeasureOnce(~,~)
        if ~checkConn(), return; end
        try
            [p1, p2, stat] = measSvc.fetchOnce(measCfg.trigger);
            ui.edtPrimary.Value = num2str(p1, '%.10g');
            ui.edtSecondary.Value = num2str(p2, '%.10g');
            ui.edtStatusCode.Value = stat;
            ui.edtResultMode.Value = measCfg.param;
            utils.addLog(sprintf('单次测量完成：%s -> 主值=%g, 副值=%g, 状态=%s', measCfg.param, p1, p2, stat));
        catch ME
            utils.addLog(['单次测量失败: ' ME.message]);
            utils.showWarn('单次测量失败', ME.message);
        end
    end

    function onRawQuery(~,~)
        if ~checkConn(), return; end
        try
            cmd = strtrim(ui.edtRawCmd.Value);
            resp = measSvc.rawQuery(cmd);
            ui.txtRawResp.Value = {resp};
            utils.addLog(['SCPI Query: ' cmd]);
        catch ME
            utils.addLog(['SCPI Query 失败: ' ME.message]);
            utils.showWarn('SCPI Query 失败', ME.message);
        end
    end

    function onRawWrite(~,~)
        if ~checkConn(), return; end
        try
            cmd = strtrim(ui.edtRawCmd.Value);
            measSvc.rawWrite(cmd);
            ui.txtRawResp.Value = {'Write 成功'};
            utils.addLog(['SCPI Write: ' cmd]);
        catch ME
            utils.addLog(['SCPI Write 失败: ' ME.message]);
            utils.showWarn('SCPI Write 失败', ME.message);
        end
    end

    function onStartAcq(~,~)
        if ~checkConn(), return; end
        if acqSvc.isRunning()
            utils.addLog('采样已在运行。');
            return;
        end
        try
            interval = ui.edtInterval.Value;
            duration = ui.edtDuration.Value;
            if isfield(ui, 'chkAutoPlot') && ui.chkAutoPlot.Value
                plotSvc.open(ui.mainFig);
            end
            acqSvc.start(interval, duration, measCfg.trigger, @onAcqTick, @onAcqStop);
            utils.addLog(sprintf('开始采样：间隔=%g s，总时长=%g s', interval, duration));
            ui.statusRight.Text = '采样进行中';
        catch ME
            utils.addLog(['启动采样失败: ' ME.message]);
            utils.showWarn('启动采样失败', ME.message);
        end
    end

    function onAcqTick(idx, p1, p2, stat)
        if isfield(ui, 'lblDataCount'), ui.lblDataCount.Text = sprintf('数据点数：%d', idx); end
        ui.statusRight.Text = sprintf('采样中 | %d 点', idx);
        utils.addLog(sprintf('采样点 %d: 主=%g 副=%g 状态=%s', idx, p1, p2, stat));
    end

    function onAcqStop(idx)
        ui.statusRight.Text = sprintf('采样结束 | %d 点', idx);
        utils.addLog('采样结束。');
    end

    function onStopAcq(~,~)
        acqSvc.stop();
        ui.statusRight.Text = '采样已停止';
        utils.addLog('用户手动停止采样。');
    end

    function onSaveCsv(~,~)
        try
            [file, path] = uiputfile('*.csv', '保存采样数据', fullfile(cfg.defaultFolder, ['E4980AL_Data_' datestr(now, 'yyyymmdd_HHMMSS') '.csv']));
            if isequal(file, 0)
                utils.addLog('用户取消保存 CSV。');
                return;
            end
            acqSvc.saveCsv(fullfile(path, file));
            utils.addLog(['采样数据已保存到: ' fullfile(path, file)]);
        catch ME
            utils.addLog(['保存 CSV 失败: ' ME.message]);
            utils.showWarn('保存 CSV 失败', ME.message);
        end
    end

    function onClearData(~,~)
        acqSvc.clear();
        if isfield(ui, 'lblDataCount'), ui.lblDataCount.Text = '数据点数：0'; end
        ui.statusRight.Text = state.brand.companyName;
        utils.addLog('采样数据已清空。');
    end

    function onMainClose(~,~)
        try, acqSvc.stop(); catch, end
        try, dev.disconnect(); catch, end
        try, plotSvc.close(); catch, end
        delete(ui.mainFig);
    end
end
