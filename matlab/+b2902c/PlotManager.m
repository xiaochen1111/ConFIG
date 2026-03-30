classdef PlotManager < handle
    %PlotManager 负责曲线窗创建与更新

    properties (Access = private)
        fig = []
        ax = []
        h1v = []
        h1i = []
        h2v = []
        h2i = []
    end

    methods
        function open(self)
            if isempty(self.fig) || ~isvalid(self.fig)
                self.fig = uifigure('Name', 'B2902C Sampling Curves', ...
                    'Position', [1440 60 980 680]);
                p = uipanel(self.fig, 'Position', [15 15 950 650]);
                self.ax = uiaxes(p, 'Position', [28 26 885 600]);
                title(self.ax, '实时采样曲线');
                xlabel(self.ax, '时间(s)');
                ylabel(self.ax, '数值');
                grid(self.ax, 'on');
                hold(self.ax, 'on');
                self.h1v = plot(self.ax, nan, nan, '-o', 'DisplayName', 'CH1 Voltage');
                self.h1i = plot(self.ax, nan, nan, '-s', 'DisplayName', 'CH1 Current');
                self.h2v = plot(self.ax, nan, nan, '-^', 'DisplayName', 'CH2 Voltage');
                self.h2i = plot(self.ax, nan, nan, '-d', 'DisplayName', 'CH2 Current');
                legend(self.ax, 'show', 'Location', 'eastoutside');
            else
                self.fig.Visible = 'on';
            end
        end

        function update(self, data, idx)
            if idx <= 0 || isempty(self.ax) || ~isvalid(self.ax)
                return;
            end
            x = data.Time_s(1:idx);
            self.h1v.XData = x; self.h1v.YData = data.CH1_V(1:idx);
            self.h1i.XData = x; self.h1i.YData = data.CH1_I(1:idx);
            self.h2v.XData = x; self.h2v.YData = data.CH2_V(1:idx);
            self.h2i.XData = x; self.h2i.YData = data.CH2_I(1:idx);
            drawnow limitrate;
        end

        function clear(self)
            if isempty(self.h1v) || ~isvalid(self.h1v)
                return;
            end
            self.h1v.XData = nan; self.h1v.YData = nan;
            self.h1i.XData = nan; self.h1i.YData = nan;
            self.h2v.XData = nan; self.h2v.YData = nan;
            self.h2i.XData = nan; self.h2i.YData = nan;
            drawnow limitrate;
        end

        function close(self)
            if ~isempty(self.fig) && isvalid(self.fig)
                delete(self.fig);
            end
            self.fig = [];
            self.ax = [];
            self.h1v = [];
            self.h1i = [];
            self.h2v = [];
            self.h2i = [];
        end
    end
end
