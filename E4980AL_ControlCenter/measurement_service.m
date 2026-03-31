function measApi = measurement_service(dev)
% 测量服务层（增强版，兼容最小封装调用）
% - 保留: applySettings/fetchOnce/parseFetchResponse
% - 新增: getSettings/readIDN/rawQuery/rawWrite/fetchRaw/fetchWithSettings
%
% 用法：
%   meas = measurement_service(dev);
%   applied = meas.applySettings(freq, level, param, aper, trig);
%   [p1,p2,st] = meas.fetchOnce('INT');
%   idn = meas.readIDN();

    settings = defaultSettings();

    measApi.applySettings = @applySettingsImpl;
    measApi.getSettings = @getSettingsImpl;
    measApi.fetchOnce = @fetchOnceImpl;
    measApi.fetchWithSettings = @fetchWithSettingsImpl;
    measApi.fetchRaw = @fetchRawImpl;
    measApi.parseFetchResponse = @parseFetchResponseImpl;
    measApi.readIDN = @readIDNImpl;
    measApi.rawQuery = @rawQueryImpl;
    measApi.rawWrite = @rawWriteImpl;

    function s = defaultSettings()
        s = struct( ...
            'freq', 1000, ...
            'level', 1.0, ...
            'param', 'CPD', ...
            'aper', 'MED', ...
            'trigger', 'INT', ...
            'settleDelay', 0.05);
    end

    function applied = applySettingsImpl(freq, level, param, aper, trig)
        validateattributes(freq, {'numeric'}, {'scalar', 'finite', '>=', 20}, mfilename, 'freq');
        validateattributes(level, {'numeric'}, {'scalar', 'finite', '>=', 1e-4, '<=', 2.0}, mfilename, 'level');
        param = upper(string(param));
        aper = upper(string(aper));
        trig = upper(string(trig));

        dev.write(sprintf(':FREQ %g', freq));
        dev.write(sprintf(':VOLT %g', level));
        dev.write(sprintf(':FUNC:IMP %s', param));
        dev.write(sprintf(':APER %s', aper));
        dev.write(sprintf(':TRIG:SOUR %s', trig));

        settings.freq = freq;
        settings.level = level;
        settings.param = char(param);
        settings.aper = char(aper);
        settings.trigger = char(trig);

        applied = settings;
    end

    function s = getSettingsImpl()
        s = settings;
    end

    function [primary, secondary, stat, resp] = fetchWithSettingsImpl(freq, level, param, aper, trig)
        applySettingsImpl(freq, level, param, aper, trig);
        [primary, secondary, stat, resp] = fetchOnceImpl(settings.trigger);
    end

    function [primary, secondary, stat, resp] = fetchOnceImpl(triggerMode)
        triggerMode = upper(string(triggerMode));
        if triggerMode == "BUS"
            dev.write(':TRIG:SOUR BUS');
            dev.write(':INIT');
            dev.write('*TRG');
        else
            dev.write(':TRIG:SOUR INT');
            dev.write(':INIT');
        end

        pause(settings.settleDelay);
        resp = dev.query(':FETC?');
        [primary, secondary, stat] = parseFetchResponseImpl(resp);
    end

    function resp = fetchRawImpl(triggerMode)
        [~, ~, ~, resp] = fetchOnceImpl(triggerMode);
    end

    function idn = readIDNImpl()
        idn = strtrim(dev.query('*IDN?'));
    end

    function out = rawQueryImpl(cmd)
        cmd = strtrim(string(cmd));
        if strlength(cmd) == 0
            error('SCPI Query 命令不能为空。');
        end
        out = strtrim(dev.query(char(cmd)));
    end

    function rawWriteImpl(cmd)
        cmd = strtrim(string(cmd));
        if strlength(cmd) == 0
            error('SCPI Write 命令不能为空。');
        end
        dev.write(char(cmd));
    end

    function [primary, secondary, stat] = parseFetchResponseImpl(resp)
        parts = strsplit(strtrim(resp), ',');
        nums = nan(1, numel(parts));
        for k = 1:numel(parts)
            nums(k) = str2double(strtrim(parts{k}));
        end

        if numel(nums) < 1 || isnan(nums(1))
            error('FETC? 返回格式异常：无法解析主测量值。原始响应：%s', resp);
        end
        primary = nums(1);

        if numel(nums) >= 2 && ~isnan(nums(2))
            secondary = nums(2);
        else
            secondary = NaN;
        end

        if numel(parts) >= 3
            stat = strtrim(parts{3});
            if isempty(stat)
                stat = 'N/A';
            end
        else
            stat = 'N/A';
        end
    end
end
