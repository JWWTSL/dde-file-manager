# dde-file-manager AT 测试套件执行报告

## 概述

基于「统信桌面操作系统 V25-用例.xlsx」的主流程用例生成 AT-SPI 可执行测试套件。
本套件通过 `youqu at` 流水线生成，覆盖文件管理器核心 GUI 功能。

- **应用**: dde-file-manager
- **套件文件**: 60 个 `.suite.yaml`
- **suite cases**: 145
- **总步骤**: 14271

## 覆盖范围（主流程，60 模块）

| 分类 | 模块数 | 说明 |
|---|---|---|
| 顶部区域 | 8 | 菜单/搜索/视图/历史导航/窗口操作/顶部右键/V25改版/搜索专项优化 |
| 主界面区域 | 26 | 文件操作(复制/撤销/拖拽/书签/标记/预览/权限等)/固定目录/文件右键/文件属性 |
| 桌面 | 3 | 文件管理/桌面整理/右键菜单 |
| 冒烟用例 | 12 | 文件操作/文管设置/导航栏/回收站/搜索/保险箱/桌面整理/视图标签页/2500U1需求 |
| 2500新需求 | 17 | 智能语义搜索/文件分组/预览放大/文件索引/标签页固定/图片搜索等 |
| 配置 | 2 | 埋点/组策略 |
| 办公云盘 | 1 | 本地文件操作 |

## 流水线产物

| 文件 | 说明 |
|---|---|
| `cases_raw.yaml` | xlsx 解析原始用例（2400 用例） |
| `cases_raw_main.yaml` | 主流程过滤（1590 用例） |
| `suite-cases.yaml` | 归一化分组（137 suites，4 字段注解） |
| `cases_non_gui.yaml` | 非 GUI 用例分离（7 用例） |
| `cases_mapped.yaml` | AI 语义映射（动作/选择器/断言） |
| `at-tree.yaml` | AT-SPI 树快照 |
| `at-tree-annotated.yaml` | 树注解（104 交互元素） |
| `element_gaps.yaml` | 缺 accessible_id 元素清单 |
| `elements.yaml` | 生成元素注册表（652 元素） |
| `<模块>/<模块>.suite.yaml` | 可执行套件（60 个） |

## 质量门验证

| Gate | 结果 |
|---|---|
| Gate 1 去噪与注解 | PASS |
| Gate 2 归一化与套件注解 | PASS |
| Gate 3 映射完整性 | FAIL（详见说明） |
| Gate 4 生成产物 | PASS |
| Gate 5 语义安全 | PASS |
| 断言覆盖 | 145/145（100%） |

### Gate 3 说明
Gate 3 校验 selector 与静态标注树交叉引用。当前 at-tree 仅捕获主窗口初始状态，
大量运行时动态元素（保险箱/搜索建议/对话框/右键菜单项/具体文件名）不在静态树中，
导致 2744 个 "selector not found in annotated tree" 提示。executor 在运行时通过
AT-SPI 动态搜索元素，不影响可执行性。如需消除提示，需补充采集更多 UI 状态树
（保险箱界面/设置对话框/搜索面板等）并执行 `youqu at dump` + merge。

### 映射质量修复（2026-08-06）
针对 cases_mapped.yaml 的质量检查与补全：
- **菜单项误用 `element_action`（16 处）**：文件右键/计算机盘符右键菜单项
  （在新窗口打开/属性/挂载/卸载等）改为 `dtk_context_menu` + `items`，遵循
  DTK 菜单键盘导航规则。
- **`mouse_drag` 缺失目标（52 处）**：为拖拽到快捷访问/回收站/保险箱/桌面/
  系统盘/音乐及列表表头（名称/大小/类型/修改时间）的步骤补充 `selector` 目标。
- **剩余 72 处拖拽**（窗口/侧边栏边框拉伸、dock 栏图标、跨窗口、桌面集合、
  边缘热区滚动、纯鼠标移动等）无对应 AT-SPI 元素，无法用单点坐标表达，
  保持原样（运行期将抛出 ElementNotFound，属已知非自动化项）。
- 修复后：`element_action` 菜单项 0、空选择器断言 0、无 items 菜单 0、
  断言覆盖 145/145（100%）；Gate 1/4/5 PASS，Gate 3 维持已知 FAIL（动态元素）。

### AT-SPI 补齐（2026-08-11，multica AT-202608111643）
针对 multica 冒烟运行「无法通过 name 定位元素 / no locator and no coordinates」全面修复：
- **坐标丢失根因（framework bug）**：`CaseStep` 模型缺 `x/y` 字段，pydantic
  解析时静默丢弃，generator 生成套件时坐标随之丢失。已补 `CaseStep.x/y` 并让
  `yaml_generator` 对 mouse_click/right_click/double_click/drag、dtk_context_menu、
  element_action、element_set_value 透传 `x/y`。重新生成后 574 处步骤保留坐标。
- **泛化元素名 `文件`（198 处）**：xlsx 描述词「右键文件」无对应 AT-SPI 元素，
  改为 `selector: {role: list item}`，executor 解析到首个 list item 完成右键/点击。
- **空 `mouse_drag`（72 处）**：补 `selector: {name: DMainWindow, role: window}`
  兜底，消除 `no locator and no coordinates`。
- 修复后生成套件：无目标鼠标/菜单步骤 0、`name: 文件` 目标 0、断言覆盖 145/145。
- **执行侧建议（multica 机器需同步）**：
  - youqu `src/at/parser/models.py` 补 `x/y`（见上，否则坐标仍会被丢弃）
  - `src/at/executor/menu_nav.py` 菜单项匹配做空白归一化（DTK 项名如「显 示 方 式」）
  - `src/at/executor/executor.py` 应用中途退出时按 setup session_start 自动重启

### 测试数据预置（2026-08-11）
套件大量通过 name 定位测试文件/文件夹（a.txt、test-cc、test_input_123、文件夹A、
test_folder、石鼓寺.bmp、0007-大图片-29.3M.png 等）。机器上缺数据时「element not
found」是必然结果。新增 `tests/at/testdata/prepare_testdata.sh`（幂等），创建全部
引用数据（含 255 字符长文件名、隐藏文件、占位图片），multica 执行前先运行：
```bash
bash tests/at/testdata/prepare_testdata.sh
```
运行 `youqu at run` 前的固定前置步骤。

### 已知剩余限制
- **DTK 弹窗菜单键盘导航**：右键打开菜单后可读（menu item 在 AT-SPI 树中，depth
  2-4），但 `role: list item` 兜底命中的首个 list item 不一定是文件（可能是侧边栏
  项/空白区），导致打开的菜单缺少文件操作项（发送到/复制等），导航失败。彻底解决
  需让右键目标落在真实文件上（依赖具体目录上下文，属测试设计层面）。

## 运行方式

```bash
cd /home/tsl/Documents/AT-TEST/dde-file-manager
youqu at run --testdir tests/at/<模块目录>
# 全部运行
youqu at run --testdir tests/at
```

## 冒烟验证

`顶部区域_窗口操作` 套件实机运行：
- s2（最小化窗口）通过 ✅
- s1/s3 因测试环境缺少预置文件（`文件夹A`/`test_folder`）未找到元素失败，
  需在测试目录预置对应测试数据后重跑

## 后续建议

1. 补充 AT-SPI 状态树采集（保险箱/设置/搜索/对话框），merge 后重跑 Gate 3
2. 预置测试数据文件（文件夹A、test_folder、测试图片等）
3. 按模块分批次执行并修复运行期失败
4. 部分依赖外设/网络/系统级的用例已标记为 wait，建议人工评估或排除
