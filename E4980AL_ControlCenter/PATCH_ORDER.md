# 第一步结构化拆分：粘贴顺序清单

1. 在主文件顶部初始化：
   - `dev = scpi_client();`
   - `measSvc = measurement_service(dev);`
   - `brandSvc = brand_render();`
   - `logoFile = brandSvc.findLogoFile();`
2. 将 `renderLogo(...)` 调用替换为 `brandSvc.renderLogo(...)`。
3. 将 `onConnect/onDisconnect/onReadIDN/onRawQuery/onRawWrite` 改为调用 `dev`。
4. 将 `onApplyMeasurementSettings/onMeasureOnce/onTimerTick` 改为调用 `measSvc`。
5. 将 `checkConn/cleanupTimer/disconnectClient/onMainClose` 替换为统一收口版。
6. 最后清理旧的 `findLogoFile/renderLogo/fetchMeasurement/querySCPI/writeSCPI`（可分阶段）。

> 本目录只提供子模块文件，不直接修改你现有主文件逻辑。
