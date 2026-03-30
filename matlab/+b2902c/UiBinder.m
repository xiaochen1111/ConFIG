classdef UiBinder
    %UiBinder 统一绑定 UI 回调

    methods (Static)
        function bind(app)
            app.ui.btnHome.ButtonPushedFcn = @(~, ~)app.showPage('home');
            app.ui.btnControl.ButtonPushedFcn = @(~, ~)app.showPage('control');
            app.ui.btnAcq.ButtonPushedFcn = @(~, ~)app.showPage('acq');
            app.ui.btnSettings.ButtonPushedFcn = @(~, ~)app.showPage('settings');
            app.ui.btnAbout.ButtonPushedFcn = @(~, ~)app.showPage('about');

            app.ui.btnConnect.ButtonPushedFcn = @(~, ~)app.onConnect();
            app.ui.btnDisconnect.ButtonPushedFcn = @(~, ~)app.onDisconnect();
            app.ui.btnReadIDN.ButtonPushedFcn = @(~, ~)app.onReadIDN();

            app.ui.ctrl.ch{1}.btnApply.ButtonPushedFcn = @(~, ~)app.onApplyChannel(1);
            app.ui.ctrl.ch{2}.btnApply.ButtonPushedFcn = @(~, ~)app.onApplyChannel(2);
            app.ui.ctrl.ch{1}.btnOn.ButtonPushedFcn = @(~, ~)app.onOutputChannel(1, true);
            app.ui.ctrl.ch{2}.btnOn.ButtonPushedFcn = @(~, ~)app.onOutputChannel(2, true);
            app.ui.ctrl.ch{1}.btnOff.ButtonPushedFcn = @(~, ~)app.onOutputChannel(1, false);
            app.ui.ctrl.ch{2}.btnOff.ButtonPushedFcn = @(~, ~)app.onOutputChannel(2, false);
            app.ui.ctrl.ch{1}.btnMeasure.ButtonPushedFcn = @(~, ~)app.onMeasureChannel(1);
            app.ui.ctrl.ch{2}.btnMeasure.ButtonPushedFcn = @(~, ~)app.onMeasureChannel(2);

            app.ui.acq.btnStart.ButtonPushedFcn = @(~, ~)app.onStartAcq();
            app.ui.acq.btnStop.ButtonPushedFcn = @(~, ~)app.onStopAcq();
            app.ui.acq.btnSave.ButtonPushedFcn = @(~, ~)app.onSaveCsv();
            app.ui.acq.btnClear.ButtonPushedFcn = @(~, ~)app.onClearData();
            app.ui.acq.btnPlot.ButtonPushedFcn = @(~, ~)app.onOpenPlotWindow();
            app.ui.acq.chkAutoPlot.ValueChangedFcn = @(src, ~)app.onAutoPlotChanged(src.Value);

            app.ui.settings.btnApply.ButtonPushedFcn = @(~, ~)app.onApplySettings();
            app.ui.mainFig.CloseRequestFcn = @(~, ~)app.onMainClose();
        end
    end
end
