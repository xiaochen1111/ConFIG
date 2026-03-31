function page = build_page_acq(parent, theme, cfg)
page = uipanel(parent, 'Title', '', 'BackgroundColor', theme.C_bg, ...
    'Position', [0 0 1155 700], 'BorderType', 'none');

top = uipanel(page, 'Title', '采样设置', 'FontWeight', 'bold', ...
    'BackgroundColor', theme.C_panel, 'Position', [15 490 1125 195]);
uilabel(top, 'Text', '采样间隔(s)', 'Position', [20 128 90 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtInterval = uieditfield(top, 'numeric', 'Position', [112 128 90 22], 'Value', cfg.interval, 'Limits', [0.05 Inf]);
uilabel(top, 'Text', '总时长(s)', 'Position', [230 128 80 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtDuration = uieditfield(top, 'numeric', 'Position', [308 128 90 22], 'Value', cfg.duration, 'Limits', [0.5 Inf]);
btnStartAcq = uibutton(top, 'push', 'Text', '开始采样', 'Position', [430 124 100 32], 'BackgroundColor', theme.C_success, 'FontColor', [1 1 1], 'FontWeight', 'bold');
btnStopAcq = uibutton(top, 'push', 'Text', '停止采样', 'Position', [540 124 100 32], 'BackgroundColor', theme.C_danger, 'FontColor', [1 1 1], 'FontWeight', 'bold');
btnSaveCsv = uibutton(top, 'push', 'Text', '保存 CSV', 'Position', [650 124 95 32], 'BackgroundColor', theme.C_primarySoft, 'FontColor', theme.C_title);
btnClearData = uibutton(top, 'push', 'Text', '清空数据', 'Position', [755 124 95 32], 'BackgroundColor', theme.C_warningSoft, 'FontColor', theme.C_title);
btnOpenPlot = uibutton(top, 'push', 'Text', '打开曲线窗', 'Position', [860 124 110 32], 'BackgroundColor', theme.C_warning, 'FontColor', [1 1 1], 'FontWeight', 'bold');
chkAutoPlot = uicheckbox(top, 'Text', '开始采样时自动打开曲线窗', 'Position', [20 84 220 22], 'Value', cfg.autoOpenPlot);
lblDataCount = uilabel(top, 'Text', '数据点数：0', 'Position', [270 84 150 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);

logPanel = uipanel(page, 'Title', '采样日志', 'FontWeight', 'bold', ...
    'BackgroundColor', theme.C_panel, 'Position', [15 15 1125 450]);
txtLog = uitextarea(logPanel, 'Position', [15 15 1095 405], 'Editable', 'off', ...
    'BackgroundColor', theme.C_logBg, 'Value', {'程序启动完成。'});

page.UserData = struct('txtLog', txtLog, 'edtInterval', edtInterval, 'edtDuration', edtDuration, ...
    'btnStartAcq', btnStartAcq, 'btnStopAcq', btnStopAcq, 'btnSaveCsv', btnSaveCsv, ...
    'btnClearData', btnClearData, 'btnOpenPlot', btnOpenPlot, 'chkAutoPlot', chkAutoPlot, ...
    'lblDataCount', lblDataCount);
end
