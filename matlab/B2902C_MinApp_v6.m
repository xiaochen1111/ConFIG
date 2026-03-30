function B2902C_MinApp_v6
% B2902C_MinApp_v6
% 模块化版本入口：
% - App: 总控与状态
% - InstrumentClient: 设备通信
% - AcquisitionManager: 采样
% - PlotManager: 绘图
% - UiFactory/UiBinder: UI 构建与绑定

    app = b2902c.App();
    app.run();
end
