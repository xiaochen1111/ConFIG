function E4980AL_ControlCenter_v1_Brand()
% 模块化入口文件（第一阶段）
% 说明：
% 1) 保持原有功能语义：连接、测量、采样、品牌展示
% 2) 通过 package 子模块拆分结构，便于后续逐步迁移完整业务逻辑

    state = core.app_state_init();
    appUi = ui.build_main_layout(state.theme, state.brand, state.cfg);

    pages.home = ui.build_page_home(appUi.contentPanel, state.theme, state.brand);
    pages.control = ui.build_page_control(appUi.contentPanel, state.theme, state.meas);
    pages.acq = ui.build_page_acq(appUi.contentPanel, state.theme, state.cfg);
    pages.settings = ui.build_page_settings(appUi.contentPanel, state.theme, state.cfg);
    pages.about = ui.build_page_about(appUi.contentPanel, state.theme, state.brand);

    dev = device.scpi_client();
    measSvc = device.measurement_service(dev);
    plotSvc = acq.plot_window(state.theme, state.brand);
    acqSvc = acq.acq_service(measSvc, plotSvc);

    actions = core.app_actions(state, appUi, pages, dev, measSvc, acqSvc, plotSvc);
    actions.showPage('home');

    appUi.mainFig.CloseRequestFcn = @actions.onMainClose;
end
