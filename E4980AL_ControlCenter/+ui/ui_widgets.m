function widgets = ui_widgets(theme)
% 小组件工厂

    widgets.createInfoCard = @createInfoCard;

    function panel = createInfoCard(parent, pos, ttl, lines)
        panel = uipanel(parent, 'Title', '', 'BackgroundColor', theme.C_panel, ...
            'Position', pos, 'BorderType', 'line', ...
            'HighlightColor', [0.88 0.91 0.95], 'ShadowColor', [0.94 0.96 0.98]);
        uilabel(panel, 'Text', ttl, 'Position', [18 pos(4)-46 pos(3)-40 24], ...
            'FontSize', 14, 'FontWeight', 'bold', 'FontColor', theme.C_title);
        y = pos(4)-78;
        for k = 1:numel(lines)
            uilabel(panel, 'Text', ['• ' lines{k}], 'Position', [20 y pos(3)-36 22], ...
                'FontColor', theme.C_subtext, 'FontSize', 11);
            y = y - 26;
        end
    end
end
