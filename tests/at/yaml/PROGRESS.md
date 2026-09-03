# DDE File Manager AT Case Progress

## Source

- Input document: `/home/tsl/Documents/youqu/统信桌面操作系统 V25-用例.xlsx`
- Parsed raw cases: `/tmp/opencode/dde-fm-youqu-generated/cases.yaml`
- Raw case count: 2400
- YouQu version used locally: 2.18.6

## Current Result

- Runnable suite files: 6
- Runnable cases: 100
- Skipped cases: 0
- Last full run command:
  `youqu at run --testdir tests/at/yaml --skip-env-check`
- Last full run result: `100 passed, 0 failed, 0 skipped`
- Structure validation:
  `youqu at validate --gate 4 --generate-output tests/at/yaml` passed.

## Current Suite Layout

- `bug转用例场景/bug转用例场景.suite.yaml`: 7 cases
- `动态效果/动态效果.suite.yaml`: 3 cases
- `管理员/管理员.suite.yaml`: 5 cases
- `xlsx候选/xlsx候选.suite.yaml`: 19 cases
- `xlsx弱覆盖/xlsx弱覆盖.suite.yaml`: 62 cases
- `命令方式/命令方式.suite.yaml`: 4 cases

## Screening Rules

Keep only cases that are runnable in the current local environment.

Delete or do not import cases with these requirements:

- External devices: USB, phone, Bluetooth, optical drive, removable disk.
- Network services: SMB, FTP, SFTP, NFS, cloud drive, remote server.
- Privileged flows: root, administrator password, authorization, encryption.
- System-level flows: reboot, logout, suspend, upgrade, install, uninstall.
- Performance or stress data: huge file counts, timing thresholds, stability tests.
- Complex sample dependencies: downloaded scripts, fixed attachments, prepared media.
- Unstable UI operations without current AT-SPI coverage: DTK menus, context menus,
  desktop/dock/launcher cross-app operations, visual-only assertions.

Prefer cases that can use current stable AT-SPI references:

- Sidebar fixed directories: 计算机, 系统盘, 主目录, 桌面, 视频, 音乐, 图片, 文档,
  下载, 最近使用, 回收站, 快捷访问.
- Basic page entry checks.
- Command launches that can be verified by process or a concrete accessible element.
- Assertions that verify concrete accessible elements exist.

## Coverage Levels

- High-confidence runnable cases: existing suites plus `xlsx候选` and `命令方式`.
- Weak smoke coverage: `xlsx弱覆盖`. These cases are derived from xlsx cases that
  contain stable sidebar/page-entry actions, but only verify the runnable entry
  action and accessible element existence. They do not claim full coverage of
  original complex assertions such as search results, previews, right-click menu
  behavior, deletion flows, or visual details.

## Attempt Log

- Kept `case_1816653` after remapping it to the stable `side_bar_view`
  accessible element only.
- Tried and removed `case_1809161`: `element_action` does not support `hover`;
  retrying with `point` also failed to resolve the live sidebar item reliably.
- Tried and removed `case_1998913`: `AddressBar` was not findable in the live
  AT-SPI tree in the current default session.
- Tried and removed `case_1805557`: the property dialog title element was not
  findable after launching `dde-file-manager -p /`.

## Notes

- The generated xlsx YAML draft under `/tmp/opencode/dde-fm-youqu-generated/yaml`
  is not directly runnable; most steps lack stable selectors.
- Current repository changes intentionally stay under `tests/at/yaml`.
- If future cases require missing AT-SPI names or object names, record them as
  gaps instead of changing application source in this test-only task.
- Remaining easy candidates are mostly exhausted. Further expansion likely needs
  either stable menu AT-SPI support or self-contained test data setup.
