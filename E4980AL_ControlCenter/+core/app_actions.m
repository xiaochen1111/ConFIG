function actions = app_actions(state, ui, pages, dev, measSvc, acqSvc, plotSvc)
% 回调编排中心（第一阶段）

    currentPage = 'home';
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

    function showPage(pageName)
        currentPage = pageName;
        names = fieldnames(pages);
        for i = 1:numel(names)
            pages.(names{i}).Visible = 'off';
        end
        pages.(pageName).Visible = 'on';
        ui.hdrTitle.Text = pageName;
    end

    function onConnect(~,~)
        if dev.isConnected()
            utils.addLog('已经处于连接状态。');
            return;
        end
        try
            dev.connect(state.cfg.ip, state.cfg.port);
            utils.setConnectionUI(true, state.brand.companyName);
            utils.addLog(sprintf('已连接到 %s:%d', state.cfg.ip, state.cfg.port));
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
        if ~dev.isConnected()
            utils.showWarn('未连接', '请先连接仪器。');
            return;
        end
        try
            idn = dev.query('*IDN?');
            ui.txtIDN.Value = {idn};
            utils.addLog(['IDN: ' idn]);
        catch ME
            utils.addLog(['读取 IDN 失败: ' ME.message]);
            utils.showWarn('读取 IDN 失败', ME.message);
        end
    end

    function onMainClose(~,~)
        try, acqSvc.stop(); catch, end
        try, dev.disconnect(); catch, end
        try, plotSvc.close(); catch, end
        delete(ui.mainFig);
    end
end
