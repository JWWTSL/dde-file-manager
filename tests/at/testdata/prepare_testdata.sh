#!/usr/bin/env bash
# 预置 dde-file-manager AT 套件所需测试数据。
# 套件大量通过 name 属性定位文件/文件夹，缺数据时 AT-SPI 查找必然失败。
# 用法：bash tests/at/testdata/prepare_testdata.sh   （幂等，可重复执行）
set -euo pipefail

HOME_DIR="${HOME}"
TMP_DIR="${TMPDIR:-/tmp}"

mkdir -p "${HOME_DIR}/文件夹A" "${HOME_DIR}/文件夹B" "${HOME_DIR}/文件夹C" \
    "${HOME_DIR}/文件夹A1" "${HOME_DIR}/文件夹a" "${HOME_DIR}/test" \
    "${HOME_DIR}/test目录" "${HOME_DIR}/test_folder" "${HOME_DIR}/test_files" \
    "${HOME_DIR}/大量文件" "${HOME_DIR}/集合" "${HOME_DIR}/dir-new" \
    "${HOME_DIR}/abc-test" "${HOME_DIR}/测试文件粉碎" "${HOME_DIR}/长文件名" \
    "${HOME_DIR}/用户下载" "${HOME_DIR}/自定义普通目录"

# 批量写入文本文件
cat > /dev/null <<'FILEEOF'
FILEEOF

write_files() {
    local d="${HOME_DIR}"
    # 清理：老版本可能把本应是文件的名称建成了目录（如 test-cc）
    rm -rf "${d}/test-cc" "${d}/1.sh"
    : > "${d}/a.txt"; : > "${d}/b.txt"; : > "${d}/aa.txt"; : > "${d}/bb.txt"
    : > "${d}/test.txt"; : > "${d}/test1"; : > "${d}/test2"; : > "${d}/test3"
    : > "${d}/test4"; : > "${d}/test-cc"; : > "${d}/test_input_123"
    : > "${d}/a-new.txt"; : > "${d}/abc-new.txt"; : > "${d}/abc.txt"
    : > "${d}/1.txt"; : > "${d}/new.txt"; : > "${d}/new-file.txt"; : > "${d}/new-a.txt"
    : > "${d}/black-path.txt"; : > "${d}/black-path-1.txt"
    : > "${d}/a-test.txt"; : > "${d}/a-search.txt"
    : > "${d}/search.txt"; : > "${d}/test-1.txt"
    : > "${d}/same-name.txt"; : > "${d}/update-test.txt"
    : > "${d}/delete-test.txt"; : > "${d}/new-test.txt"
    : > "${d}/1.sh"; : > "${d}/test.iso"
    : > "${d}/文件A"; : > "${d}/test.jpg.png"; : > "${d}/test.tar.7z"
    : > "${d}/新建Excel文档.xlsx"; : > "${d}/新建Word文档.docx"; : > "${d}/演示文档.pptx"
    : > "${d}/搜索专项测试.txt"; : > "${d}/搜索专项测试-仅文件名.txt"
    : > "${d}/搜索结果中的.sh"; : > "${d}/今天创建的文档.md"
    : > "${d}/文件名1234567890"; : > "${d}/search-test.sh"
    # 隐藏文件
    : > "${d}/.hidden-file"; : > "${d}/.hide.txt"; : > "${d}/.git"
    # 长文件名（255 字符，无空格）
    python3 -c "import sys; p='${HOME_DIR}/'+'a'*255; open(p,'w').close(); sys.stdout.write('created 255-char file\n')" >/dev/null
    # 带特殊字符文件名（复制文件地址/重命名用例）
    : > "${d}/有特殊字符+——）（）&……%￥#@！RC!@#$%^&()_+}{L  （副本）.txt"
    # 桌面常用数据
    : > "${HOME_DIR}/Desktop/新建文本1.txt" 2>/dev/null || true
    : > "${HOME_DIR}/Desktop/确定能复现的bug.txt" 2>/dev/null || true
}

write_files

# 图片文本内容搜索用例所需占位图片（生成含简单文字的小 PNG/BMP）
python3 - <<'PYEOF'
import os
from PIL import Image, ImageDraw

def save_png(path, size=(320, 200), color=(200, 60, 60)):
    img = Image.new("RGB", size, color)
    d = ImageDraw.Draw(img)
    d.text((40, 80), "test", fill=(255, 255, 255))
    img.save(path)

def save_bmp(path, size=(160, 120), color=(60, 90, 200)):
    img = Image.new("RGB", size, color)
    img.save(path)

home = os.path.expanduser("~")
png_files = {
    "显示255个字符不带空格符号.png": None,
    "多关键词-1.png": None,
    "石鼓寺.png": None,
    "0007-大图片-29.3M.png": (1280, 800),
    "0007-大图片-29.3M-new.png": (1280, 800),
    "截图_选择区域_202aa（副本）.png": (640, 400),
}
for name, size in png_files.items():
    try:
        save_png(os.path.join(home, name), size or (320, 200))
    except Exception:
        pass
for name in ("石鼓寺.bmp", "石鼓寺-new.bmp", "BA.bmp", "1.bmp"):
    try:
        save_bmp(os.path.join(home, name))
    except Exception:
        pass
print("images done")
PYEOF

echo "== 测试数据预置完成，位置：${HOME_DIR} =="
