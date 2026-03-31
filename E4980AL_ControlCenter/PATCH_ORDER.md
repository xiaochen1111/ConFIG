# 完整模块化文件清单（包含所有阶段 1 文件）

## 目录
- `E4980AL_ControlCenter_v1_Brand.m`：模块化主入口
- `scpi_client.m`：兼容旧调用的 SCPI 客户端
- `measurement_service.m`：兼容旧调用的测量服务
- `brand_render.m`：兼容旧调用的品牌渲染
- `+core/app_state_init.m`：状态初始化
- `+core/app_actions.m`：回调编排
- `+core/app_utils.m`：日志/告警/连接状态 UI 收口
- `+ui/build_main_layout.m`：主布局
- `+ui/build_page_home.m`：首页
- `+ui/build_page_control.m`：控制页
- `+ui/build_page_acq.m`：采样页
- `+ui/build_page_settings.m`：设置页
- `+ui/build_page_about.m`：关于页
- `+ui/ui_nav.m`：导航样式工具
- `+ui/ui_widgets.m`：卡片组件工具
- `+device/scpi_client.m`：package SCPI 客户端
- `+device/measurement_service.m`：package 测量服务
- `+acq/acq_service.m`：采样服务
- `+acq/plot_window.m`：曲线窗口服务
- `+brand/brand_assets.m`：logo 资源查找
- `+brand/brand_render.m`：package logo 渲染

## 集成顺序
1. 使用 `E4980AL_ControlCenter_v1_Brand.m` 作为新入口。
2. 若保留旧主文件，可逐步替换为 `+core/+ui/+device/+acq/+brand` 的 package 函数。
3. 旧的根目录服务文件用于兼容，不影响 package 化迁移。
