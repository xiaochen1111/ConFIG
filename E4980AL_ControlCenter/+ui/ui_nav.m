function nav = ui_nav(uiStruct, theme)
% 导航工具（可选）

    nav.resetNavButtons = @resetNavButtons;
    nav.highlightButton = @highlightButton;

    function resetNavButtons()
        uiStruct.btnHome.BackgroundColor = theme.C_navSoft;
        uiStruct.btnControl.BackgroundColor = theme.C_navSoft;
        uiStruct.btnAcq.BackgroundColor = theme.C_navSoft;
        uiStruct.btnSettings.BackgroundColor = theme.C_navSoft;
        uiStruct.btnAbout.BackgroundColor = theme.C_navSoft;
    end

    function highlightButton(name)
        resetNavButtons();
        switch lower(name)
            case 'home', uiStruct.btnHome.BackgroundColor = theme.C_primary;
            case 'control', uiStruct.btnControl.BackgroundColor = theme.C_primary;
            case 'acq', uiStruct.btnAcq.BackgroundColor = theme.C_primary;
            case 'settings', uiStruct.btnSettings.BackgroundColor = theme.C_primary;
            case 'about', uiStruct.btnAbout.BackgroundColor = theme.C_primary;
        end
    end
end
