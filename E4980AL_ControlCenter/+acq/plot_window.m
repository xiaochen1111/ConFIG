function plotSvc = plot_window(theme, brand)
% 曲线窗口服务（第一阶段）

    plotFig = [];
    ax = [];
    hPrimary = [];
    hSecondary = [];

    plotSvc.open = @openImpl;
    plotSvc.update = @updateImpl;
    plotSvc.clear = @clearImpl;
    plotSvc.close = @closeImpl;

    function openImpl(mainFig)
        if nargin < 1 || isempty(mainFig) || ~isvalid(mainFig)
            pos = [100 100 980 680];
        else
            m = mainFig.Position;
            pos = [m(1)+m(3)+20, m(2), 980, 680];
        end

        if isempty(plotFig) || ~isvalid(plotFig)
            plotFig = uifigure('Name', 'E4980AL Sampling Curves', 'Position', pos, 'Color', theme.C_bg);
            hdr = uipanel(plotFig, 'Title', '', 'BackgroundColor', theme.C_panel, 'Position', [15 620 950 45]);
            uilabel(hdr, 'Text', '实时采样曲线', 'Position', [16 10 220 24], 'FontSize', 15, 'FontWeight', 'bold', 'FontColor', theme.C_title);
            uilabel(hdr, 'Text', brand.companyName, 'Position', [520 10 380 24], 'HorizontalAlignment', 'right', 'FontColor', theme.C_subtext);
            panel = uipanel(plotFig, 'Title', '', 'BackgroundColor', theme.C_panel, 'Position', [15 15 950 595]);
            ax = uiaxes(panel, 'Position', [28 26 885 545], 'BackgroundColor', [1 1 1]);
            hPrimary = plot(ax, nan, nan, '-o', 'DisplayName', 'Primary', 'LineWidth', 1.6, 'MarkerSize', 5);
            hold(ax, 'on');
            hSecondary = plot(ax, nan, nan, '-s', 'DisplayName', 'Secondary', 'LineWidth', 1.6, 'MarkerSize', 5);
            legend(ax, 'show', 'Location', 'eastoutside');
            grid(ax, 'on');
        else
            plotFig.Visible = 'on';
        end
    end

    function updateImpl(x, y1, y2)
        if isempty(plotFig) || ~isvalid(plotFig)
            return;
        end
        hPrimary.XData = x;
        hPrimary.YData = y1;
        hSecondary.XData = x;
        hSecondary.YData = y2;
        drawnow limitrate;
    end

    function clearImpl()
        if isempty(plotFig) || ~isvalid(plotFig)
            return;
        end
        hPrimary.XData = nan;
        hPrimary.YData = nan;
        hSecondary.XData = nan;
        hSecondary.YData = nan;
    end

    function closeImpl()
        if ~isempty(plotFig) && isvalid(plotFig)
            delete(plotFig);
        end
        plotFig = [];
        ax = [];
        hPrimary = [];
        hSecondary = [];
    end
end
