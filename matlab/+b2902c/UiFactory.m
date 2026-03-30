classdef UiFactory
    %UiFactory UI 组件构建

    methods (Static)
        function ui = buildMainUi()
            ui = struct();
            C = b2902c.UiFactory.palette();

            ui.mainFig = uifigure( ...
                'Name', 'B2902C Control Center v6', ...
                'Position', [90 50 1200 760], ...
                'Color', C.bg);

            ui.header = uipanel(ui.mainFig, 'Position', [15 700 1170 45], 'BackgroundColor', C.panel);
            ui.content = uipanel(ui.mainFig, 'Position', [15 70 1170 620], 'BackgroundColor', C.bg);
            ui.statusPanel = uipanel(ui.mainFig, 'Position', [15 15 1170 45], 'BackgroundColor', C.panel);

            ui.btnHome = uibutton(ui.header, 'push', 'Text', '首页', 'Position', [10 8 70 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ui.btnControl = uibutton(ui.header, 'push', 'Text', '控制台', 'Position', [90 8 70 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ui.btnAcq = uibutton(ui.header, 'push', 'Text', '采样', 'Position', [170 8 70 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ui.btnSettings = uibutton(ui.header, 'push', 'Text', '设置', 'Position', [250 8 70 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ui.btnAbout = uibutton(ui.header, 'push', 'Text', '关于', 'Position', [330 8 70 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);

            ui.btnConnect = uibutton(ui.header, 'push', 'Text', '连接', 'Position', [860 8 70 30], 'BackgroundColor', C.primary, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ui.btnDisconnect = uibutton(ui.header, 'push', 'Text', '断开', 'Position', [940 8 70 30], 'BackgroundColor', C.darkBtn, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ui.btnReadIDN = uibutton(ui.header, 'push', 'Text', '读取IDN', 'Position', [1020 8 100 30], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);

            ui.statusLeft = uilabel(ui.statusPanel, 'Text', '状态：未连接', 'Position', [15 12 260 20], 'FontColor', C.subtext, 'FontWeight', 'bold');
            ui.statusRight = uilabel(ui.statusPanel, 'Text', '采样未启动', 'Position', [910 12 240 20], 'HorizontalAlignment', 'right', 'FontColor', C.subtext);

            ui.pages = struct();
            ui.pages.home = uipanel(ui.content, 'Position', [0 0 1170 620], 'BackgroundColor', C.bg);
            ui.pages.control = uipanel(ui.content, 'Position', [0 0 1170 620], 'BackgroundColor', C.bg);
            ui.pages.acq = uipanel(ui.content, 'Position', [0 0 1170 620], 'BackgroundColor', C.bg);
            ui.pages.settings = uipanel(ui.content, 'Position', [0 0 1170 620], 'BackgroundColor', C.bg);
            ui.pages.about = uipanel(ui.content, 'Position', [0 0 1170 620], 'BackgroundColor', C.bg);

            uilabel(ui.pages.home, 'Text', '欢迎使用 B2902C Control Center v6', 'Position', [25 565 450 30], 'FontSize', 18);
            uilabel(ui.pages.about, 'Text', '模块化版本：v6', 'Position', [25 565 250 30], 'FontSize', 16);

            % 控制页（最小可用）
            ui.ctrl = struct();
            uilabel(ui.pages.control, 'Text', '设备信息:', 'Position', [20 560 80 22]);
            ui.ctrl.txtIDN = uitextarea(ui.pages.control, 'Position', [20 480 1120 80], 'Editable', 'off', 'Value', {'仪器信息显示区'}, 'BackgroundColor', C.logBg);

            ui.ctrl.ch = cell(1, 2);
            ui.ctrl.ch{1} = b2902c.UiFactory.createChannelCard(ui.pages.control, [20 185 550 275], 1);
            ui.ctrl.ch{2} = b2902c.UiFactory.createChannelCard(ui.pages.control, [590 185 550 275], 2);

            % 采样页
            ui.acq = struct();
            uilabel(ui.pages.acq, 'Text', '采样间隔(s)', 'Position', [20 575 80 22]);
            ui.acq.edtInterval = uieditfield(ui.pages.acq, 'numeric', 'Position', [105 575 80 22], 'Value', 0.5, 'Limits', [0.05 Inf]);
            uilabel(ui.pages.acq, 'Text', '总时长(s)', 'Position', [210 575 70 22]);
            ui.acq.edtDuration = uieditfield(ui.pages.acq, 'numeric', 'Position', [280 575 80 22], 'Value', 10, 'Limits', [0.5 Inf]);
            ui.acq.btnStart = uibutton(ui.pages.acq, 'push', 'Text', '开始采样', 'Position', [380 572 90 28], 'BackgroundColor', C.success, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ui.acq.btnStop = uibutton(ui.pages.acq, 'push', 'Text', '停止采样', 'Position', [480 572 90 28], 'BackgroundColor', C.danger, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ui.acq.btnSave = uibutton(ui.pages.acq, 'push', 'Text', '保存CSV', 'Position', [580 572 80 28], 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ui.acq.btnClear = uibutton(ui.pages.acq, 'push', 'Text', '清空数据', 'Position', [670 572 80 28], 'BackgroundColor', C.warningSoft, 'FontColor', C.title);
            ui.acq.btnPlot = uibutton(ui.pages.acq, 'push', 'Text', '打开曲线窗', 'Position', [760 572 90 28], 'BackgroundColor', C.warning, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ui.acq.chkAutoPlot = uicheckbox(ui.pages.acq, 'Text', '自动打开曲线窗', 'Position', [860 575 140 22], 'Value', true);
            ui.acq.lblCount = uilabel(ui.pages.acq, 'Text', '数据点数：0', 'Position', [1020 575 120 22]);
            ui.acq.txtLog = uitextarea(ui.pages.acq, 'Position', [20 20 1120 530], 'Editable', 'off', 'Value', {'程序启动完成。'}, 'BackgroundColor', C.logBg);

            % 设置页
            ui.settings = struct();
            uilabel(ui.pages.settings, 'Text', '默认 IP', 'Position', [20 575 80 22]);
            ui.settings.edtIP = uieditfield(ui.pages.settings, 'text', 'Position', [90 575 160 22], 'Value', '192.168.0.2');
            uilabel(ui.pages.settings, 'Text', '端口', 'Position', [275 575 40 22]);
            ui.settings.edtPort = uieditfield(ui.pages.settings, 'numeric', 'Position', [320 575 80 22], 'Value', 5025, 'RoundFractionalValues', true);
            uilabel(ui.pages.settings, 'Text', '间隔(s)', 'Position', [420 575 55 22]);
            ui.settings.edtInterval = uieditfield(ui.pages.settings, 'numeric', 'Position', [475 575 80 22], 'Value', 0.5, 'Limits', [0.05 Inf]);
            uilabel(ui.pages.settings, 'Text', '时长(s)', 'Position', [575 575 55 22]);
            ui.settings.edtDuration = uieditfield(ui.pages.settings, 'numeric', 'Position', [630 575 80 22], 'Value', 10, 'Limits', [0.5 Inf]);
            ui.settings.chkAutoPlot = uicheckbox(ui.pages.settings, 'Text', '自动打开曲线窗', 'Position', [730 575 140 22], 'Value', true);
            ui.settings.edtFolder = uieditfield(ui.pages.settings, 'text', 'Position', [20 540 550 22], 'Value', pwd);
            ui.settings.btnApply = uibutton(ui.pages.settings, 'push', 'Text', '应用设置', 'Position', [590 538 90 26], 'BackgroundColor', C.primary, 'FontColor', [1 1 1], 'FontWeight', 'bold');
        end
    end

    methods (Static, Access = private)
        function C = palette()
            C.bg          = [0.95 0.97 0.99];
            C.panel       = [1.00 1.00 1.00];
            C.title       = [0.12 0.20 0.32];
            C.subtext     = [0.38 0.45 0.55];
            C.primary     = [0.18 0.47 0.80];
            C.primarySoft = [0.86 0.92 0.99];
            C.success     = [0.14 0.63 0.36];
            C.successSoft = [0.88 0.97 0.91];
            C.warning     = [0.96 0.62 0.14];
            C.warningSoft = [1.00 0.95 0.86];
            C.danger      = [0.80 0.24 0.24];
            C.darkBtn     = [0.21 0.28 0.36];
            C.logBg       = [0.985 0.99 0.995];
        end

        function ch = createChannelCard(parent, pos, chNum)
            ch = struct();
            C = b2902c.UiFactory.palette();

            panel = uipanel(parent, ...
                'Title', sprintf('通道 %d 控制', chNum), ...
                'Position', pos, ...
                'BackgroundColor', C.panel, ...
                'ForegroundColor', C.title);

            g = uigridlayout(panel, [6 4]);
            g.RowHeight = {24, 30, 30, 34, 30, '1x'};
            g.ColumnWidth = {85, 130, 90, '1x'};
            g.Padding = [12 10 12 10];
            g.RowSpacing = 8;
            g.ColumnSpacing = 8;
            g.BackgroundColor = C.panel;

            head = uilabel(g, 'Text', sprintf('CH%d 参数设置', chNum), 'FontWeight', 'bold', 'FontColor', C.title);
            head.Layout.Row = 1;
            head.Layout.Column = [1 4];

            mLbl = uilabel(g, 'Text', '源模式');
            mLbl.Layout.Row = 2;
            mLbl.Layout.Column = 1;
            ch.ddMode = uidropdown(g, 'Items', {'VOLT', 'CURR'}, 'Value', 'VOLT');
            ch.ddMode.Layout.Row = 2;
            ch.ddMode.Layout.Column = 2;

            setLbl = uilabel(g, 'Text', '设定值');
            setLbl.Layout.Row = 2;
            setLbl.Layout.Column = 3;
            ch.edtSet = uieditfield(g, 'numeric', 'Value', 1);
            ch.edtSet.Layout.Row = 2;
            ch.edtSet.Layout.Column = 4;

            currLbl = uilabel(g, 'Text', '限流(A)');
            currLbl.Layout.Row = 3;
            currLbl.Layout.Column = 1;
            ch.edtCurrProt = uieditfield(g, 'numeric', 'Value', 0.01);
            ch.edtCurrProt.Layout.Row = 3;
            ch.edtCurrProt.Layout.Column = 2;

            voltLbl = uilabel(g, 'Text', '限压(V)');
            voltLbl.Layout.Row = 3;
            voltLbl.Layout.Column = 3;
            ch.edtVoltProt = uieditfield(g, 'numeric', 'Value', 10);
            ch.edtVoltProt.Layout.Row = 3;
            ch.edtVoltProt.Layout.Column = 4;

            ch.btnApply = uibutton(g, 'push', 'Text', '应用参数', 'BackgroundColor', C.primary, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ch.btnApply.Layout.Row = 4;
            ch.btnApply.Layout.Column = 1;

            ch.btnOn = uibutton(g, 'push', 'Text', '输出 ON', 'BackgroundColor', C.success, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ch.btnOn.Layout.Row = 4;
            ch.btnOn.Layout.Column = 2;

            ch.btnOff = uibutton(g, 'push', 'Text', '输出 OFF', 'BackgroundColor', C.danger, 'FontColor', [1 1 1], 'FontWeight', 'bold');
            ch.btnOff.Layout.Row = 4;
            ch.btnOff.Layout.Column = 3;

            ch.btnMeasure = uibutton(g, 'push', 'Text', '单次测量', 'BackgroundColor', C.primarySoft, 'FontColor', C.title);
            ch.btnMeasure.Layout.Row = 4;
            ch.btnMeasure.Layout.Column = 4;

            measVLbl = uilabel(g, 'Text', '测得电压(V)');
            measVLbl.Layout.Row = 5;
            measVLbl.Layout.Column = 1;
            ch.edtMeasV = uieditfield(g, 'text', 'Editable', 'off', 'BackgroundColor', C.logBg);
            ch.edtMeasV.Layout.Row = 5;
            ch.edtMeasV.Layout.Column = 2;

            measILbl = uilabel(g, 'Text', '测得电流(A)');
            measILbl.Layout.Row = 5;
            measILbl.Layout.Column = 3;
            ch.edtMeasI = uieditfield(g, 'text', 'Editable', 'off', 'BackgroundColor', C.logBg);
            ch.edtMeasI.Layout.Row = 5;
            ch.edtMeasI.Layout.Column = 4;

            ch.lampOutput = uilamp(g, 'Color', C.warning);
            ch.lampOutput.Layout.Row = 6;
            ch.lampOutput.Layout.Column = 1;

            ch.lblOutput = uilabel(g, ...
                'Text', '输出未知', ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', C.warningSoft, ...
                'FontColor', C.title);
            ch.lblOutput.Layout.Row = 6;
            ch.lblOutput.Layout.Column = [2 4];
        end
    end
end
