classdef App < handle
    %App B2902C 模块化主控制器

    properties
        ui
        client b2902c.InstrumentClient
        acq b2902c.AcquisitionManager
        plotter b2902c.PlotManager

        cfg_ip = '192.168.0.2'
        cfg_port = 5025
        cfg_interval = 0.5
        cfg_duration = 10
        cfg_autoOpenPlot = true
        cfg_defaultFolder = pwd
    end

    methods
        function run(self)
            self.client = b2902c.InstrumentClient();
            self.acq = b2902c.AcquisitionManager();
            self.plotter = b2902c.PlotManager();

            self.ui = b2902c.UiFactory.buildMainUi();
            b2902c.UiBinder.bind(self);

            self.acq.onTick = @(data, idx)self.onAcqTick(data, idx);
            self.acq.onStop = @(~, idx)self.onAcqStop(idx);

            self.applyCfgToUi();
            self.showPage('home');
            self.addLog('应用启动完成。');
        end

        function showPage(self, pageName)
            pages = fieldnames(self.ui.pages);
            for i = 1:numel(pages)
                self.ui.pages.(pages{i}).Visible = 'off';
            end
            self.ui.pages.(pageName).Visible = 'on';
        end

        function onConnect(self)
            try
                self.client.connect(self.cfg_ip, self.cfg_port);
                self.ui.statusLeft.Text = '状态：已连接';
                self.addLog(sprintf('已连接到 %s:%d', self.cfg_ip, self.cfg_port));
            catch ME
                self.ui.statusLeft.Text = '状态：连接失败';
                self.addLog(['连接失败: ' ME.message]);
                uialert(self.ui.mainFig, ME.message, '连接失败');
            end
        end

        function onDisconnect(self)
            self.onStopAcq();
            self.safeAllOutputOff();
            self.client.disconnect();
            self.ui.statusLeft.Text = '状态：未连接';
            self.ui.statusRight.Text = '采样未启动';
            self.addLog('连接已断开。');
        end

        function onReadIDN(self)
            try
                self.ensureConnected();
                idn = self.client.query('*IDN?');
                self.ui.ctrl.txtIDN.Value = {idn};
                self.addLog(['IDN: ' idn]);
            catch ME
                self.addLog(['读取 IDN 失败: ' ME.message]);
                uialert(self.ui.mainFig, ME.message, '读取 IDN 失败');
            end
        end

        function onApplyChannel(self, chNum)
            try
                self.ensureConnected();
                ch = self.ui.ctrl.ch{chNum};
                mode = upper(strtrim(ch.ddMode.Value));
                setVal = ch.edtSet.Value;
                currProt = ch.edtCurrProt.Value;
                voltProt = ch.edtVoltProt.Value;

                switch mode
                    case 'VOLT'
                        self.client.write(sprintf(':SOUR%d:FUNC:MODE VOLT', chNum));
                        self.client.write(sprintf(':SOUR%d:VOLT %g', chNum, setVal));
                        self.client.write(sprintf(':SENS%d:CURR:PROT %g', chNum, currProt));
                        self.addLog(sprintf('CH%d 应用参数：模式=VOLT, 设定=%g V, 限流=%g A', chNum, setVal, currProt));
                    case 'CURR'
                        self.client.write(sprintf(':SOUR%d:FUNC:MODE CURR', chNum));
                        self.client.write(sprintf(':SOUR%d:CURR %g', chNum, setVal));
                        self.client.write(sprintf(':SENS%d:VOLT:PROT %g', chNum, voltProt));
                        self.addLog(sprintf('CH%d 应用参数：模式=CURR, 设定=%g A, 限压=%g V', chNum, setVal, voltProt));
                    otherwise
                        error('App:InvalidMode', '未知源模式。');
                end
            catch ME
                self.addLog(sprintf('CH%d 应用参数失败: %s', chNum, ME.message));
                uialert(self.ui.mainFig, ME.message, sprintf('CH%d 应用参数失败', chNum));
            end
        end

        function onOutputChannel(self, chNum, isOn)
            try
                self.ensureConnected();
                if isOn
                    self.client.write(sprintf(':OUTP%d ON', chNum));
                    self.ui.ctrl.ch{chNum}.lblOutput.Text = '输出已开';
                    self.ui.ctrl.ch{chNum}.lblOutput.BackgroundColor = self.colorSuccessSoft();
                    self.ui.ctrl.ch{chNum}.lampOutput.Color = self.colorSuccess();
                    self.addLog(sprintf('CH%d 输出已打开。', chNum));
                else
                    self.client.write(sprintf(':OUTP%d OFF', chNum));
                    self.ui.ctrl.ch{chNum}.lblOutput.Text = '输出已关';
                    self.ui.ctrl.ch{chNum}.lblOutput.BackgroundColor = self.colorWarningSoft();
                    self.ui.ctrl.ch{chNum}.lampOutput.Color = self.colorWarning();
                    self.addLog(sprintf('CH%d 输出已关闭。', chNum));
                end
            catch ME
                self.addLog(sprintf('CH%d 输出切换失败: %s', chNum, ME.message));
                uialert(self.ui.mainFig, ME.message, sprintf('CH%d 输出切换失败', chNum));
            end
        end

        function onMeasureChannel(self, chNum)
            try
                self.ensureConnected();
                [v, i] = self.client.measureChannel(chNum);
                self.ui.ctrl.ch{chNum}.edtMeasV.Value = num2str(v, '%.8g');
                self.ui.ctrl.ch{chNum}.edtMeasI.Value = num2str(i, '%.8g');
                self.addLog(sprintf('CH%d 单次测量完成：V=%g V, I=%g A', chNum, v, i));
            catch ME
                self.addLog(sprintf('CH%d 测量失败: %s', chNum, ME.message));
                uialert(self.ui.mainFig, ME.message, sprintf('CH%d 测量失败', chNum));
            end
        end

        function onApplySettings(self)
            self.cfg_ip = strtrim(self.ui.settings.edtIP.Value);
            self.cfg_port = self.ui.settings.edtPort.Value;
            self.cfg_interval = self.ui.settings.edtInterval.Value;
            self.cfg_duration = self.ui.settings.edtDuration.Value;
            self.cfg_autoOpenPlot = self.ui.settings.chkAutoPlot.Value;
            self.cfg_defaultFolder = strtrim(self.ui.settings.edtFolder.Value);
            self.applyCfgToUi();
            self.addLog('设置已应用到当前会话。');
        end

        function onAutoPlotChanged(self, value)
            self.cfg_autoOpenPlot = logical(value);
            self.ui.settings.chkAutoPlot.Value = self.cfg_autoOpenPlot;
        end

        function onStartAcq(self)
            try
                self.ensureConnected();
                if self.acq.isRunning()
                    self.addLog('采样已在运行。');
                    return;
                end
                if self.cfg_autoOpenPlot
                    self.plotter.open();
                    self.plotter.clear();
                end
                self.acq.start(self.ui.acq.edtInterval.Value, self.ui.acq.edtDuration.Value, @()self.measureBoth());
                self.ui.statusRight.Text = '采样进行中';
                self.ui.acq.lblCount.Text = '数据点数：0';
                self.addLog('采样已启动。');
            catch ME
                self.addLog(['启动采样失败: ' ME.message]);
                uialert(self.ui.mainFig, ME.message, '启动采样失败');
            end
        end

        function onStopAcq(self)
            self.acq.stop();
            self.ui.statusRight.Text = '采样已停止';
            self.addLog('采样已停止。');
        end

        function onSaveCsv(self)
            try
                if self.acq.idx <= 0
                    uialert(self.ui.mainFig, '当前没有可保存的数据。', '提示');
                    return;
                end
                defaultName = ['B2902C_Data_' datestr(now, 'yyyymmdd_HHMMSS') '.csv'];
                [file, path] = uiputfile('*.csv', '保存采样数据', fullfile(self.cfg_defaultFolder, defaultName));
                if isequal(file, 0)
                    self.addLog('用户取消保存 CSV。');
                    return;
                end
                fullName = fullfile(path, file);
                self.acq.saveCsv(fullName);
                self.addLog(['采样数据已保存到: ' fullName]);
            catch ME
                self.addLog(['保存 CSV 失败: ' ME.message]);
                uialert(self.ui.mainFig, ME.message, '保存 CSV 失败');
            end
        end

        function onClearData(self)
            self.acq.clearData();
            self.plotter.clear();
            self.ui.acq.lblCount.Text = '数据点数：0';
            self.ui.statusRight.Text = '采样数据已清空';
            self.addLog('采样数据已清空。');
        end

        function onOpenPlotWindow(self)
            self.plotter.open();
            self.addLog('曲线窗口已打开。');
        end

        function onMainClose(self)
            try
                self.acq.stop();
            catch
            end
            try
                self.safeAllOutputOff();
            catch
            end
            try
                self.client.disconnect();
            catch
            end
            try
                self.plotter.close();
            catch
            end
            delete(self.ui.mainFig);
        end
    end

    methods (Access = private)
        function [v1, i1, v2, i2] = measureBoth(self)
            [v1, i1] = self.client.measureChannel(1);
            [v2, i2] = self.client.measureChannel(2);
            self.ui.ctrl.ch{1}.edtMeasV.Value = num2str(v1, '%.8g');
            self.ui.ctrl.ch{1}.edtMeasI.Value = num2str(i1, '%.8g');
            self.ui.ctrl.ch{2}.edtMeasV.Value = num2str(v2, '%.8g');
            self.ui.ctrl.ch{2}.edtMeasI.Value = num2str(i2, '%.8g');
        end

        function onAcqTick(self, data, idx)
            self.ui.acq.lblCount.Text = sprintf('数据点数：%d', idx);
            self.ui.statusRight.Text = sprintf('采样中 | %d 点', idx);
            self.plotter.update(data, idx);
        end

        function onAcqStop(self, idx)
            self.ui.statusRight.Text = sprintf('采样结束 | %d 点', idx);
            self.addLog('采样结束。');
        end

        function ensureConnected(self)
            if ~self.client.isConnected()
                error('App:NotConnected', '请先连接仪器。');
            end
        end

        function safeAllOutputOff(self)
            if ~self.client.isConnected()
                return;
            end
            try
                self.client.write(':OUTP1 OFF');
            catch
            end
            try
                self.client.write(':OUTP2 OFF');
            catch
            end
            self.ui.ctrl.ch{1}.lblOutput.Text = '输出已关';
            self.ui.ctrl.ch{1}.lblOutput.BackgroundColor = self.colorWarningSoft();
            self.ui.ctrl.ch{1}.lampOutput.Color = self.colorWarning();
            self.ui.ctrl.ch{2}.lblOutput.Text = '输出已关';
            self.ui.ctrl.ch{2}.lblOutput.BackgroundColor = self.colorWarningSoft();
            self.ui.ctrl.ch{2}.lampOutput.Color = self.colorWarning();
        end

        function c = colorSuccess(self)
            c = [0.14 0.63 0.36];
        end

        function c = colorSuccessSoft(self)
            c = [0.88 0.97 0.91];
        end

        function c = colorWarning(self)
            c = [0.96 0.62 0.14];
        end

        function c = colorWarningSoft(self)
            c = [1.00 0.95 0.86];
        end

        function addLog(self, msg)
            t = datestr(now, 'HH:MM:SS');
            oldVal = self.ui.acq.txtLog.Value;
            if ischar(oldVal)
                oldVal = {oldVal};
            end
            self.ui.acq.txtLog.Value = [oldVal; {[t '  ' msg]}];
            drawnow limitrate;
        end

        function applyCfgToUi(self)
            self.ui.settings.edtIP.Value = self.cfg_ip;
            self.ui.settings.edtPort.Value = self.cfg_port;
            self.ui.settings.edtInterval.Value = self.cfg_interval;
            self.ui.settings.edtDuration.Value = self.cfg_duration;
            self.ui.settings.chkAutoPlot.Value = self.cfg_autoOpenPlot;
            self.ui.settings.edtFolder.Value = self.cfg_defaultFolder;

            self.ui.acq.edtInterval.Value = self.cfg_interval;
            self.ui.acq.edtDuration.Value = self.cfg_duration;
            self.ui.acq.chkAutoPlot.Value = self.cfg_autoOpenPlot;
        end
    end
end
