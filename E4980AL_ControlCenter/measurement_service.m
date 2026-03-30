function measApi = measurement_service(dev)
% 测量服务层（最小封装版）
% 用法：
%   meas = measurement_service(dev);
%   meas.applySettings(freq, level, param, aper, trig);
%   [p1,p2,st] = meas.fetchOnce(trig);

    measApi.applySettings = @applySettingsImpl;
    measApi.fetchOnce = @fetchOnceImpl;
    measApi.parseFetchResponse = @parseFetchResponseImpl;

    function applySettingsImpl(freq, level, param, aper, trig)
        dev.write(sprintf(':FREQ %g', freq));
        dev.write(sprintf(':VOLT %g', level));
        dev.write(sprintf(':FUNC:IMP %s', param));
        dev.write(sprintf(':APER %s', aper));
        dev.write(sprintf(':TRIG:SOUR %s', trig));
    end

    function [primary, secondary, stat] = fetchOnceImpl(triggerMode)
        if strcmpi(triggerMode, 'BUS')
            dev.write(':TRIG:SOUR BUS');
            dev.write(':INIT');
            dev.write('*TRG');
        else
            dev.write(':TRIG:SOUR INT');
            dev.write(':INIT');
        end
        pause(0.05);
        resp = dev.query(':FETC?');
        [primary, secondary, stat] = parseFetchResponseImpl(resp);
    end

    function [primary, secondary, stat] = parseFetchResponseImpl(resp)
        parts = strsplit(strtrim(resp), ',');
        nums = nan(1, numel(parts));
        for k = 1:numel(parts)
            nums(k) = str2double(strtrim(parts{k}));
        end
        if numel(nums) >= 1 && ~isnan(nums(1))
            primary = nums(1);
        else
            error('FETC? 返回格式异常：无法解析主测量值。');
        end
        if numel(nums) >= 2 && ~isnan(nums(2))
            secondary = nums(2);
        else
            secondary = NaN;
        end
        if numel(parts) >= 3
            stat = strtrim(parts{3});
        else
            stat = 'N/A';
        end
    end
end
