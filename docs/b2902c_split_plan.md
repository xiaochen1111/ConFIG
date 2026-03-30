# B2902C_MinApp_v5 拆分方案（可直接落地）

> 目标：把单文件、重回调、强耦合版本拆成“UI层 + 业务层 + 设备层 + 采样层 + 绘图层”，降低维护成本。

## 建议目录

```text
matlab/
  B2902C_MinApp_v6.m                % 入口（仅初始化和组装）
  +b2902c/
    App.m                           % 主控制器（classdef handle）
    InstrumentClient.m              % 设备连接/SCPI读写/测量
    AcquisitionManager.m            % timer/预分配table/CSV保存
    PlotManager.m                   % 曲线窗口与绘制
    UiFactory.m                     % 全部UI构建
    UiBinder.m                      % 回调绑定
```

## 设计原则

- `App` 只持有模块实例，不直接发 SCPI。
- `InstrumentClient` 不依赖 UI。
- `AcquisitionManager` 不依赖具体控件，使用回调上报数据。
- `PlotManager` 只做图，不做测量。
- `UiFactory` 只创建控件并返回句柄结构体。

---

## 1) 入口文件示例：`B2902C_MinApp_v6.m`

```matlab
function B2902C_MinApp_v6
    app = b2902c.App();
    app.run();
end
```

---

## 2) 主控制器示例：`+b2902c/App.m`

```matlab
classdef App < handle
    properties
        ui
        client      % b2902c.InstrumentClient
        acq         % b2902c.AcquisitionManager
        plotter     % b2902c.PlotManager

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
            self.plotter = b2902c.PlotManager();
            self.acq = b2902c.AcquisitionManager();

            self.ui = b2902c.UiFactory.buildMainUi();
            b2902c.UiBinder.bind(self);
            self.showPage('home');
        end

        function showPage(self, page)
            pages = {'home','control','acq','settings','about'};
            for i = 1:numel(pages)
                self.ui.pages.(pages{i}).Visible = 'off';
            end
            self.ui.pages.(page).Visible = 'on';
        end

        function onConnect(self)
            self.client.connect(self.cfg_ip, self.cfg_port);
            self.ui.status.left.Text = '状态：已连接';
        end

        function onDisconnect(self)
            self.acq.stop();
            self.client.disconnect();
            self.ui.status.left.Text = '状态：未连接';
        end
    end
end
```

---

## 3) 设备层示例：`+b2902c/InstrumentClient.m`

```matlab
classdef InstrumentClient < handle
    properties
        tcp = []
    end

    methods
        function connect(self, ip, port)
            if ~isempty(self.tcp)
                return;
            end
            self.tcp = tcpclient(ip, port, 'Timeout', 10, 'ConnectTimeout', 5);
            configureTerminator(self.tcp, 'LF');
        end

        function disconnect(self)
            self.tcp = [];
        end

        function tf = isConnected(self)
            tf = ~isempty(self.tcp);
        end

        function out = query(self, cmd)
            out = strtrim(writeread(self.tcp, cmd));
        end

        function write(self, cmd)
            writeline(self.tcp, cmd);
        end

        function [v, i] = measureChannel(self, ch)
            v = str2double(strtrim(self.query(sprintf(':MEAS:VOLT? (@%d)', ch))));
            i = str2double(strtrim(self.query(sprintf(':MEAS:CURR? (@%d)', ch))));
        end
    end
end
```

---

## 4) 采样层示例：`+b2902c/AcquisitionManager.m`

```matlab
classdef AcquisitionManager < handle
    properties
        timerObj = []
        data = table()
        idx = 0
        t0

        onTick  % function handle: onTick(data, idx)
        onStop  % function handle: onStop(data, idx)
    end

    methods
        function start(self, interval, duration, measureFn)
            self.stop();
            nMax = max(1, floor(duration/interval));
            self.data = table(NaN(nMax,1), NaN(nMax,1), NaN(nMax,1), NaN(nMax,1), NaN(nMax,1), ...
                'VariableNames', {'Time_s','CH1_V','CH1_I','CH2_V','CH2_I'});
            self.idx = 0;
            self.t0 = tic;

            self.timerObj = timer( ...
                'ExecutionMode', 'fixedSpacing', ...
                'Period', interval, ...
                'TasksToExecute', nMax, ...
                'BusyMode', 'drop', ...
                'TimerFcn', @(~,~)self.tick(measureFn), ...
                'StopFcn', @(~,~)self.stopFcn());
            start(self.timerObj);
        end

        function stop(self)
            if ~isempty(self.timerObj) && isvalid(self.timerObj)
                try, stop(self.timerObj); catch, end
                try, delete(self.timerObj); catch, end
            end
            self.timerObj = [];
        end

        function saveCsv(self, file)
            if self.idx > 0
                writetable(self.data(1:self.idx,:), file);
            end
        end
    end

    methods (Access = private)
        function tick(self, measureFn)
            self.idx = self.idx + 1;
            [v1, i1, v2, i2] = measureFn();
            self.data.Time_s(self.idx) = toc(self.t0);
            self.data.CH1_V(self.idx) = v1;
            self.data.CH1_I(self.idx) = i1;
            self.data.CH2_V(self.idx) = v2;
            self.data.CH2_I(self.idx) = i2;
            if ~isempty(self.onTick), self.onTick(self.data, self.idx); end
        end

        function stopFcn(self)
            if ~isempty(self.onStop), self.onStop(self.data, self.idx); end
        end
    end
end
```

---

## 5) 绘图层示例：`+b2902c/PlotManager.m`

```matlab
classdef PlotManager < handle
    properties
        fig = []
        ax = []
        h1v = []; h1i = []; h2v = []; h2i = []
    end

    methods
        function open(self)
            if isempty(self.fig) || ~isvalid(self.fig)
                self.fig = uifigure('Name','B2902C Sampling Curves','Position',[1440 60 980 680]);
                self.ax = uiaxes(self.fig, 'Position',[30 30 920 620]);
                hold(self.ax,'on'); grid(self.ax,'on');
                self.h1v = plot(self.ax,nan,nan,'-o','DisplayName','CH1 Voltage');
                self.h1i = plot(self.ax,nan,nan,'-s','DisplayName','CH1 Current');
                self.h2v = plot(self.ax,nan,nan,'-^','DisplayName','CH2 Voltage');
                self.h2i = plot(self.ax,nan,nan,'-d','DisplayName','CH2 Current');
                legend(self.ax,'show');
            else
                self.fig.Visible = 'on';
            end
        end

        function update(self, data, idx)
            if idx <= 0 || isempty(self.ax) || ~isvalid(self.ax), return; end
            x = data.Time_s(1:idx);
            self.h1v.XData = x; self.h1v.YData = data.CH1_V(1:idx);
            self.h1i.XData = x; self.h1i.YData = data.CH1_I(1:idx);
            self.h2v.XData = x; self.h2v.YData = data.CH2_V(1:idx);
            self.h2i.XData = x; self.h2i.YData = data.CH2_I(1:idx);
            drawnow limitrate;
        end

        function clear(self)
            if isempty(self.h1v) || ~isvalid(self.h1v), return; end
            self.h1v.XData = nan; self.h1v.YData = nan;
            self.h1i.XData = nan; self.h1i.YData = nan;
            self.h2v.XData = nan; self.h2v.YData = nan;
            self.h2i.XData = nan; self.h2i.YData = nan;
        end
    end
end
```

---

## 迁移顺序（推荐）

1. 先把 `querySCPI/writeSCPI/measureChannel` 迁到 `InstrumentClient`。  
2. 再把采样逻辑迁到 `AcquisitionManager`（保留你当前预分配 table 方案）。  
3. 再迁移曲线相关到 `PlotManager`。  
4. 最后才拆 `UiFactory/UiBinder`。  

这样每次只动一层，风险最低。
