function p = brand_assets()
% 查找 logo 资源

    baseDir = fileparts(mfilename('fullpath'));
    candidates = { ...
        fullfile(baseDir, '..', 'company_logo.png'), ...
        fullfile(baseDir, '..', 'company_logo.jpg'), ...
        fullfile(baseDir, '..', 'logo.png'), ...
        fullfile(baseDir, '..', 'logo.jpg')};
    p = '';
    for ii = 1:numel(candidates)
        if exist(candidates{ii}, 'file')
            p = candidates{ii};
            return;
        end
    end
end
