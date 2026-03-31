function state = app_state_init()
% 初始化应用状态与默认配置

    state.brand.companyName = '陕西微元创界科技有限公司';
    state.brand.companyNameDisplay = sprintf('陕西微元创界\n科技有限公司');
    state.brand.brandTagline = 'Precision & Measurement Solutions';

    state.cfg.ip = '192.168.0.11';
    state.cfg.port = 5025;
    state.cfg.interval = 0.5;
    state.cfg.duration = 10;
    state.cfg.autoOpenPlot = true;
    state.cfg.defaultFolder = pwd;

    state.meas.freq = 1000;
    state.meas.level = 1.0;
    state.meas.param = 'CPD';
    state.meas.aper = 'MED';
    state.meas.trigger = 'INT';

    state.theme.C_bg          = [0.95 0.97 0.99];
    state.theme.C_panel       = [1.00 1.00 1.00];
    state.theme.C_nav         = [0.10 0.15 0.23];
    state.theme.C_navSoft     = [0.17 0.24 0.34];
    state.theme.C_navText     = [0.93 0.96 0.99];
    state.theme.C_title       = [0.11 0.19 0.31];
    state.theme.C_subtext     = [0.36 0.44 0.54];
    state.theme.C_primary     = [0.16 0.45 0.78];
    state.theme.C_primarySoft = [0.87 0.93 0.99];
    state.theme.C_success     = [0.13 0.61 0.35];
    state.theme.C_successSoft = [0.89 0.97 0.92];
    state.theme.C_warning     = [0.95 0.60 0.12];
    state.theme.C_warningSoft = [1.00 0.95 0.87];
    state.theme.C_danger      = [0.80 0.24 0.24];
    state.theme.C_logBg       = [0.985 0.99 0.995];
    state.theme.C_brandLight  = [0.97 0.98 1.00];
end
