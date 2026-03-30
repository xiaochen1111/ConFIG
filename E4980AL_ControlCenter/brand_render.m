function brandApi = brand_render()
% 品牌资源模块（最小封装版）
% 用法：
%   brand = brand_render();
%   logoFile = brand.findLogoFile();
%   brand.renderLogo(parentPanel, pos, logoFile, titleColor);

    brandApi.findLogoFile = @findLogoFileImpl;
    brandApi.renderLogo = @renderLogoImpl;

    function p = findLogoFileImpl()
        baseDir = fileparts(mfilename('fullpath'));
        candidates = { ...
            fullfile(baseDir, 'company_logo.png'), ...
            fullfile(baseDir, 'company_logo.jpg'), ...
            fullfile(baseDir, 'logo.png'), ...
            fullfile(baseDir, 'logo.jpg')};
        p = '';
        for ii = 1:numel(candidates)
            if exist(candidates{ii}, 'file')
                p = candidates{ii};
                return;
            end
        end
    end

    function renderLogoImpl(parentPanel, pos, logoFile, titleColor)
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
end
