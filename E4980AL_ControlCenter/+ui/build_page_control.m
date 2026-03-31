function page = build_page_control(parent, theme, meas)
page = uipanel(parent, 'Title', '', 'BackgroundColor', theme.C_bg, ...
    'Position', [0 0 1155 700], 'BorderType', 'none');

idnPanel = uipanel(page, 'Title', '设备信息', 'FontWeight', 'bold', ...
    'BackgroundColor', theme.C_panel, 'Position', [15 545 1125 140]);
txtIDN = uitextarea(idnPanel, 'Position', [15 15 1095 95], 'Editable', 'off', ...
    'BackgroundColor', theme.C_logBg, 'Value', {'仪器信息显示区'});

measPanel = uipanel(page, 'Title', '测量参数设置', 'FontWeight', 'bold', ...
    'BackgroundColor', theme.C_panel, 'Position', [15 280 760 240]);
uilabel(measPanel, 'Text', '频率 (Hz)', 'Position', [20 168 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtFreq = uieditfield(measPanel, 'numeric', 'Position', [120 168 130 24], 'Value', meas.freq, 'LowerLimit', 20);
uilabel(measPanel, 'Text', '测试电平 (Vrms)', 'Position', [290 168 120 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtLevel = uieditfield(measPanel, 'numeric', 'Position', [410 168 130 24], 'Value', meas.level, 'LowerLimit', 1e-4, 'UpperLimit', 2.0);
uilabel(measPanel, 'Text', '参数对', 'Position', [20 122 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
ddParam = uidropdown(measPanel, 'Position', [120 122 130 24], 'Items', {'CPD','CPQ','CSD','CSQ','LPD','LPQ','LSD','LSQ','RX','ZTD','ZTR','GB','YTD','YTR','DCR'}, 'Value', meas.param);
uilabel(measPanel, 'Text', '测量速度', 'Position', [290 122 120 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
ddAper = uidropdown(measPanel, 'Position', [410 122 130 24], 'Items', {'SHORT','MED','LONG'}, 'Value', meas.aper);
uilabel(measPanel, 'Text', '触发源', 'Position', [20 76 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
ddTrigger = uidropdown(measPanel, 'Position', [120 76 130 24], 'Items', {'INT','BUS'}, 'Value', meas.trigger);
btnApplyMeas = uibutton(measPanel, 'push', 'Text', '应用参数', 'Position', [580 160 140 34], 'BackgroundColor', theme.C_primary, 'FontColor', [1 1 1], 'FontWeight', 'bold');
btnMeasureOnce = uibutton(measPanel, 'push', 'Text', '单次测量', 'Position', [580 115 140 34], 'BackgroundColor', theme.C_success, 'FontColor', [1 1 1], 'FontWeight', 'bold');
measStatus = uilabel(measPanel, 'Text', '状态：参数未应用', 'Position', [20 20 520 28], 'FontWeight', 'bold', 'BackgroundColor', theme.C_warningSoft, 'FontColor', theme.C_title);

resultPanel = uipanel(page, 'Title', '测量结果', 'FontWeight', 'bold', 'BackgroundColor', theme.C_panel, 'Position', [790 280 350 240]);
uilabel(resultPanel, 'Text', '主测量值', 'Position', [20 168 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtPrimary = uieditfield(resultPanel, 'text', 'Position', [120 168 180 24], 'Editable', 'off', 'BackgroundColor', theme.C_logBg);
uilabel(resultPanel, 'Text', '副测量值', 'Position', [20 122 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtSecondary = uieditfield(resultPanel, 'text', 'Position', [120 122 180 24], 'Editable', 'off', 'BackgroundColor', theme.C_logBg);
uilabel(resultPanel, 'Text', '状态码', 'Position', [20 76 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtStatusCode = uieditfield(resultPanel, 'text', 'Position', [120 76 180 24], 'Editable', 'off', 'BackgroundColor', theme.C_logBg);
uilabel(resultPanel, 'Text', '参数对', 'Position', [20 30 100 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtResultMode = uieditfield(resultPanel, 'text', 'Position', [120 30 180 24], 'Editable', 'off', 'BackgroundColor', theme.C_logBg, 'Value', meas.param);

rawPanel = uipanel(page, 'Title', '原始 SCPI 调试', 'FontWeight', 'bold', 'BackgroundColor', theme.C_panel, 'Position', [15 15 1125 240]);
uilabel(rawPanel, 'Text', 'SCPI 命令', 'Position', [18 180 80 22], 'FontWeight', 'bold', 'FontColor', theme.C_subtext);
edtRawCmd = uieditfield(rawPanel, 'text', 'Position', [95 180 780 24], 'Value', '*IDN?');
btnRawQuery = uibutton(rawPanel, 'push', 'Text', 'Query', 'Position', [890 176 90 32], 'BackgroundColor', theme.C_primarySoft, 'FontColor', theme.C_title);
btnRawWrite = uibutton(rawPanel, 'push', 'Text', 'Write', 'Position', [990 176 90 32], 'BackgroundColor', theme.C_warningSoft, 'FontColor', theme.C_title);
txtRawResp = uitextarea(rawPanel, 'Position', [18 16 1062 150], 'Editable', 'off', 'BackgroundColor', theme.C_logBg, 'Value', {'SCPI 返回显示区'});

page.UserData = struct('txtIDN', txtIDN, 'edtFreq', edtFreq, 'edtLevel', edtLevel, ...
    'ddParam', ddParam, 'ddAper', ddAper, 'ddTrigger', ddTrigger, ...
    'btnApplyMeas', btnApplyMeas, 'btnMeasureOnce', btnMeasureOnce, 'measStatus', measStatus, ...
    'edtPrimary', edtPrimary, 'edtSecondary', edtSecondary, 'edtStatusCode', edtStatusCode, ...
    'edtResultMode', edtResultMode, 'edtRawCmd', edtRawCmd, 'btnRawQuery', btnRawQuery, ...
    'btnRawWrite', btnRawWrite, 'txtRawResp', txtRawResp);
end
