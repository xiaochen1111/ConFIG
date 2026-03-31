function page = build_page_home(parent, theme, brand)
page = uipanel(parent, 'Title', '', 'BackgroundColor', theme.C_bg, ...
    'Position', [0 0 1155 700], 'BorderType', 'none');

hero = uipanel(page, 'Title', '', 'BackgroundColor', theme.C_panel, 'Position', [15 510 1125 170]);
uilabel(hero, 'Text', '欢迎使用 E4980AL Control Center', 'Position', [24 105 500 34], ...
    'FontSize', 24, 'FontWeight', 'bold', 'FontColor', theme.C_title);
uilabel(hero, 'Text', brand.companyName, 'Position', [24 78 520 22], ...
    'FontSize', 12, 'FontColor', theme.C_subtext);
end
