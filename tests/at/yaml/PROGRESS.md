# DDE File Manager AT Case Progress

## Source

- Input document: `/home/tsl/Documents/youqu/统信桌面操作系统 V25-用例.xlsx`
- Parsed raw cases: `/tmp/opencode/dde-fm-youqu-generated/cases.yaml`
- Raw case count: 2400
- YouQu version used locally: 2.18.6

## Current Result

- Suite files: 55
- Suite cases: 1473
- `cases_mapped.yaml` mappings: 1203
- Structure validation:
  `youqu at validate --gate 4 --generate-output tests/at/yaml` passed.
  `youqu at validate --gate 5 --cases-mapped tests/at/cases_mapped.yaml --generate-output tests/at/yaml` passed.

### PR #4493 batch (757 generated cases)

- Generated: 757 cases across 11 suites
- Verified passing (isolated per-case run): 612
- Removed: 145 (wrong AT-SPI element mappings, e.g. `显示预览`, `ToggleModeBtn`,
  `取消`, `保险箱`, unreachable menu items)

> Note: the original isolation runner trusted `youqu at run`'s exit code, which is
> `0` even when a case fails, so failures were first mis-recorded as PASS. Results
> must be parsed from the `Specs: N passed, M failed` log line.

### Coverage (automatable baseline 569)

- Covered (automatable): 502 / 569 = 88.22%
- Full raw coverage: 52.42%
- Backlog (unfiltered & uncovered): 67

## Current Suite Layout

PR #4493 batch suites (subset kept, see branch `agent/at/pr4493-757-*`):

- `topui/topui.suite.yaml`
- `u1req/u1req.suite.yaml`
- `desktop/desktop.suite.yaml`
- `desktop_水印/desktop_水印.suite.yaml`
- `clouddisk/clouddisk.suite.yaml`
- `config/config.suite.yaml`
- `teamstd/teamstd.suite.yaml`
- `u2req/u2req.suite.yaml`
- `interact/interact.suite.yaml`
- `cmdmode/cmdmode.suite.yaml`
- `fourprop/fourprop.suite.yaml`

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
