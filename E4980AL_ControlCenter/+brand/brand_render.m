function render(parentPanel, pos, logoFile, titleColor)
% package 版本 logo 渲染

    if isempty(logoFile) || ~exist(logoFile, 'file')
        uilabel(parentPanel, 'Text', 'LOGO', 'Position', pos, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
            'FontSize', 16, 'FontColor', titleColor);
        return;
    end

    try
        img = uiimage(parentPanel, 'Position', pos);
        img.ImageSource = logoFile;
    catch
        try
            axTmp = uiaxes(parentPanel, 'Position', pos, 'XTick', [], 'YTick', []);
            axTmp.Box = 'off';
            I = imread(logoFile);
            image(axTmp, I);
            axis(axTmp, 'image');
            axis(axTmp, 'off');
        catch
            uilabel(parentPanel, 'Text', 'LOGO', 'Position', pos, ...
                'HorizontalAlignment', 'center', 'FontWeight', 'bold', ...
                'FontSize', 16, 'FontColor', titleColor);
        end
    end
end
