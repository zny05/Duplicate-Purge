# Czkawka CLI - 说明

Czkawka CLI 是 `czkawka_core` 的终端前端，将所有扫描工具作为子命令公开，适用于脚本和自动化。

## 目录

- [术语表](#术语表)
- [要求](#要求)
- [快速入门](#快速入门)
- [常见标志](#常见标志)
- [输出格式和退出码](#输出格式和退出码)
- [工具](#工具)
  - [dup - 重复文件](#dup---重复文件)
  - [empty-folders](#empty-folders)
  - [big - 大文件](#big---大文件)
  - [empty-files](#empty-files)
  - [temp - 临时文件](#temp---临时文件)
  - [image - 相似图像](#image---相似图像)
  - [video - 相似视频](#video---相似视频)
  - [music - 同类音乐](#music---同类音乐)
  - [symlinks - 无效符号链接](#symlinks---无效符号链接)
  - [broken - 损坏文件](#broken---损坏文件)
  - [ext - 错误扩展名](#ext---错误扩展名)
  - [bad-names](#bad-names)
  - [exif-remover](#exif-remover)
  - [video-optimizer](#video-optimizer)
- [自动化示例](#自动化示例)

---

## 术语表

关于共享概念（参考路径、缓存、预哈希、硬链接）请参见 [主指南中的术语表](Instruction.md#terminology-shared-across-all-frontends)。CLI 特定术语如下。

| 术语 | 定义 |
|------|------|
| **包含目录** (`-d`) | 要扫描的目录。所有工具均为必需。可以列出多个值。 |
| **排除目录** (`-e`) | 扫描期间完全跳过的目录。比项目级别排除更快。 |
| **排除项目** (`-E`) | 与完整路径匹配的通配符模式（例如 `*/tmp*`、`*/.git`）。比 `-e` 更灵活，但略慢。 |
| **参考目录** (`-r`) | 文件仅在结果中用于比较的目录。`--delete-method` 不会删除或修改其中的文件。可用于：`dup`、`image`、`video`、`music`。 |
| **删除方式** (`-D`) | 选择每个组中保留哪个文件、删除哪个文件。代码：AEN、AEO、AEB、AES、ON、OO、OB、OS、HARD、NONE。详情见 [dup 部分](#dup---重复文件)。 |
| **干运行** (`-Q`) | 显示将要执行的操作，而不实际执行。在真正的删除运行前始终使用。 |
| **扩展名宏** | `-x`/`-P` 的简写组：`IMAGE`（jpg,kra,gif,png,bmp,tiff,...）、`VIDEO`（mp4,flv,mkv,webm,...）、`MUSIC`（mp3,flac,ogg,...）、`TEXT`（txt,doc,docx,...）。 |

---

## 要求

预构建的二进制文件适用于 Linux（Ubuntu 22.04+）、Windows 10+ 和 macOS 10.15+。

可选运行时依赖：
- **ffmpeg** - `video`（相似视频）和 `video-optimizer` 所必需
- **libheif / libraw / libavif** - 仅在源码编译且带有这些功能时需要

安装 ffmpeg：

| OS | 命令 |
|----|------|
| Linux | `sudo apt install ffmpeg` |
| macOS | `brew install ffmpeg` |
| Windows | `choco install ffmpeg` 或从 ffmpeg.org 下载并将 `ffmpeg.exe` 放在 `PATH` 中 |

从源码编译：
```shell
cargo build --release --bin czkawka_cli
# 带可选图像格式支持：
cargo build --release --bin czkawka_cli --features "heif,libraw,libavif"
```

---

## 快速入门

<img width="600" alt="Screenshot From 2026-06-28 07-19-24" src="https://github.com/user-attachments/assets/4a98567a-68b1-4be9-a6de-e7eb5f9d9ca3" />


```shell
# 列出所有工具
czkawka_cli --help

# 显示特定工具的选项
czkawka_cli dup --help

# 在目录中查找重复文件（结果打印到控制台）
czkawka_cli dup -d /home/user/Documents

# 将结果保存到文件，不打印
czkawka_cli dup -d /home/user/Documents -f results.txt -N

# 干运行 - 预览将被删除的文件（每组保留最新的）
czkawka_cli dup -d /home/user/Documents -D AEN -Q

# 删除重复文件，保留最新的，将其他移动到垃圾桶
czkawka_cli dup -d /home/user/Documents -D AEN -y
```

---

## 常见标志

以下标志可用于每个工具：

| 标志 | 长标志 | 默认值 | 说明 |
|------|--------|--------|------|
| `-d` | `--directories` | (必需) | 一个或多个要扫描的目录 |
| `-e` | `--excluded-directories` | - | 完全跳过的目录 |
| `-E` | `--excluded-items` | - | 要排除的通配符模式（例如 `*/tmp*`） |
| `-x` | `--allowed-extensions` | (全部) | 仅扫描这些扩展名。宏：`IMAGE`、`VIDEO`、`MUSIC`、`TEXT` |
| `-P` | `--excluded-extensions` | - | 跳过具有这些扩展名的文件 |
| `-f` | `--file-to-save` | - | 将结果保存到人类可读的文本文件 |
| `-C` | `--compact-file-to-save` | - | 将结果保存为紧凑（压缩）JSON |
| `-p` | `--pretty-file-to-save` | - | 将结果保存为美观打印的 JSON |
| `-R` | `--not-recursive` | false | 仅扫描顶级目录（不递归） |
| `-X` | `--exclude-other-filesystems` | false | 跳过其他文件系统上的文件（Linux/macOS） |
| `-T` | `--thread-number` | 0 (全部) | 限制 CPU 线程；0 = 全部可用 |
| `-N` | `--do-not-print-results` | false | 抑制控制台结果输出 |
| `-M` | `--do-not-print-messages` | false | 抑制所有消息、警告、错误 |
| `-W` | `--ignore-error-code-on-found` | false | 即使找到文件也返回退出码 0 |
| `-H` | `--disable-cache` | false | 完全禁用哈希/元数据缓存 |

### 分组删除标志

由产生分组的工具使用（dup、image、video、music）：

| 标志 | 长标志 | 默认值 | 说明 |
|------|--------|--------|------|
| `-D` | `--delete-method` | NONE | 删除策略（见下方代码） |
| `-Q` | `--dry-run` | false | 预览操作而不执行 |
| `-y` | `--move-to-trash` | false | 移动到系统垃圾桶而非永久删除 |

**删除方式代码：**

| 代码 | 保留 | 删除 |
|------|------|------|
| `AEN` | 最新文件 | 所有其他文件 |
| `AEO` | 最旧文件 | 所有其他文件 |
| `AEB` | 最大文件 | 所有其他文件 |
| `AES` | 最小文件 | 所有其他文件 |
| `ON` | 最新文件仅 | 其他一切 |
| `OO` | 最旧文件仅 | 其他一切 |
| `OB` | 最大文件仅 | 其他一切 |
| `OS` | 最小文件仅 | 其他一切 |
| `HARD` | (全部，链接) | 将重复项替换为硬链接 |
| `NONE` | (全部) | 无 - 仅结果，默认值 |

### 简单删除标志

由产生扁平列表的工具使用（empty-folders、empty-files、temp、symlinks、broken）：

| 标志 | 长标志 | 默认值 | 说明 |
|------|--------|--------|------|
| `-D` | `--delete-files` | false | 删除所有找到的项目 |
| `-Q` | `--dry-run` | false | 仅预览 |
| `-y` | `--move-to-trash` | false | 移动到垃圾桶而非永久删除 |

---

## 输出格式和退出码

三种输出格式可以在一个命令中组合：
- **文本** (`-f results.txt`) - 人类可读，每行一个条目，带组标题
- **紧凑 JSON** (`-C results.json`) - 压缩 JSON，可用 `jq` 或脚本解析
- **美观打印 JSON** (`-p results_pretty.json`) - 缩进 JSON，结构与紧凑 JSON 相同

**退出码：**

| 代码 | 含义 |
|------|------|
| `0` | 成功，未找到匹配文件（或设置了 `-W` 标志） |
| `1` | 发生错误 |
| `11` | 成功，找到了匹配文件 |

在 CI/脚本中，使用 `-W` / `--ignore-error-code-on-found`，其中“找到文件”不是错误条件。

---

## 工具

### dup - 重复文件

```shell
czkawka_cli dup -d <dirs> [options]
```


<img width="600" alt="Screenshot From 2026-06-28 07-19-24" src="https://github.com/user-attachments/assets/138148f4-e360-45d7-9adc-810c6f2b6605" />

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-s` / `--search-method` | `HASH` | `NAME`, `SIZE`, `SIZE_NAME`, `HASH` |
| `-t` / `--hash-type` | `BLAKE3` | `BLAKE3`, `XXH3`, `CRC32` |
| `-m` / `--minimal-file-size` | 8192 | 最小文件大小（字节） |
| `-i` / `--maximal-file-size` | (max u64) | 最大文件大小（字节） |
| `-u` / `--use-prehash-cache` | false | 缓存部分哈希以加速重新扫描 |
| `-Z` / `--minimal-prehash-cache-file-size` | 257144 | 存储到预哈希缓存的最小文件大小 |
| `-c` / `--minimal-cached-file-size` | 257144 | 存储到哈希缓存的最小文件大小 |
| `-l` / `--case-sensitive-name-comparison` | false | 名称比较区分大小写（NAME 方法） |
| `-L` / `--allow-hard-links` | false | 将硬链接视为独立文件 |
| `-r` / `--reference-directories` | - | 参考目录（扫描但从不删除） |
| `-D` / `-Q` / `-y` | NONE/false/false | 删除方式 / 干运行 / 移动到垃圾桶 |

**哈希方法建议：**
- 对于可靠去重，使用 `HASH`（默认）。
- 仅作为快速实验使用 `NAME` - 许多误报。
- 使用 `SIZE` / `SIZE_NAME` 仅作为粗略预筛。

示例：
```shell
# 在 /home/rafal 中查找 >= 25 字节的重复文件，跳过 Obrazy 目录，仅扫描 IMAGE 扩展名
czkawka_cli dup -d /home/rafal -e /home/rafal/Obrazy -m 25 -x IMAGE -f results.txt

# 干运行：显示保留最新时将被删除的文件
czkawka_cli dup -d /home/data -D AEN -Q

# 保护 /backup，从 /incoming 删除重复文件，移动到垃圾桶
czkawka_cli dup -d /incoming -r /backup -D AEN -y
```

---

### empty-folders

```shell
czkawka_cli empty-folders -d <dirs> [options]
```

查找没有文件或子目录的目录。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-D` / `-Q` / `-y` | false/false/false | 删除 / 干运行 / 移动到垃圾桶 |

示例：
```shell
czkawka_cli empty-folders -d /home/rafal/rr /home/gateway -f results.txt
```

---

### big - 大文件

```shell
czkawka_cli big -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-n` / `--number-of-files` | 50 | 要显示的文件数量 |
| `-J` / `--smallest-mode` | false | 查找最小文件而非最大文件 |
| `-D` / `-Q` / `-y` | | 删除 / 干运行 / 垃圾桶 |

示例：
```shell
czkawka_cli big -d /home/rafal/ /home/piszczal -e /home/rafal/Roman -n 25 -x VIDEO -f results.txt
```

---

### empty-files

```shell
czkawka_cli empty-files -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `--zero-byte-content` | false | 还查找内容全为空字节 (`\0`) 的文件 |
| `--non-printable-content` | false | 还查找仅包含不可打印 ASCII 字符的文件（隐含 `--zero-byte-content`） |
| `-D` / `-Q` / `-y` | | 删除 / 干运行 / 垃圾桶 |

示例：
```shell
czkawka_cli empty-files -d /home/rafal /home/szczekacz -e /home/rafal/Pulpit -R -f results.txt
```

---

### temp - 临时文件

```shell
czkawka_cli temp -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-L` / `--extensions` | (内置列表) | 覆盖临时模式列表。如果指定，将完全替换默认值。使用小写文件名的 `ends_with` 匹配。 |
| `-D` / `-Q` / `-y` | | 删除 / 干运行 / 垃圾桶 |

默认模式：`#`, `thumbs.db`, `.bak`, `~`, `.tmp`, `.temp`, `.ds_store`, `.crdownload`, `.part`, `.cache`, `.dmp`, `.download`, `.partial`

示例：
```shell
czkawka_cli temp -d /home/rafal/ -E */.git */tmp* *Pulpit -f results.txt -D
```

---

### image - 相似图像

```shell
czkawka_cli image -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-s` / `--max-difference` | 5 | 最大哈希距离 (0-40)。越低越严格。 |
| `-g` / `--hash-alg` | `Gradient` | `Mean`, `Gradient`, `Blockhash`, `VertGradient`, `DoubleGradient`, `Median` |
| `-c` / `--hash-size` | 16 | 哈希分辨率：`8`, `16`, `32`, `64` |
| `-z` / `--image-filter` | `Nearest` | `Lanczos3`, `Nearest`, `Triangle`, `Gaussian`, `CatmullRom` |
| `--geometric-invariance` | `off` | `off`, `mirror-flip`, `mirror-flip-rotate90` |
| `-m` / `--minimal-file-size` | 16384 | 最小大小（字节） |
| `-i` / `--maximal-file-size` | (max) | 最大大小（字节） |
| `-J` / `--ignore-same-size` | false | 跳过相同字节大小的图像 |
| `-Z` / `--ignore-same-resolution` | false | 跳过相同像素尺寸的图像 |
| `-L` / `--allow-hard-links` | false | 将硬链接视为独立文件 |
| `-r` / `--reference-directories` | - | 参考目录 |
| `-D` / `-Q` / `-y` | | 删除方式 / 干运行 / 垃圾桶 |

**参数选择：**
- 从 `--max-difference 5`、`--hash-size 16`、`--hash-alg Gradient` 开始，然后据此调整。
- 对于高相似度匹配（例如缩略图与原图），降低 `--max-difference` (0-3)。
- 对于匹配跨压缩/水印，提高它 (哈希大小 16 时为 10-20)。
- `--geometric-invariance mirror-flip-rotate90` 捕获镜像或旋转的副本，但更慢。

示例：
```shell
czkawka_cli image -d /home/rafal/ -E */.git */tmp* *Pulpit -f results.txt
```

---

### video - 相似视频

需要 `ffmpeg` 已安装。

```shell
czkawka_cli video -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-t` / `--tolerance` | 10 | 帧差异阈值 (0-20) |
| `-A` / `--scan-duration` | 10 | 每个文件扫描的视频秒数 |
| `-U` / `--skip-forward-amount` | 15 | 每个视频开头跳过的秒数 |
| `-B` / `--crop-detect` | true | 哈希前检测并忽略信箱黑边 |
| `--window-count` | (默认值) | 每个视频的时间窗口数 (1-20；更多更准确，更慢) |
| `--duration-tolerance-pct` | (默认值) | 两个视频可比较的最大持续时间差异百分比 |
| `--min-matching-windows` | (默认值) | 将视频称为相似所需的匹配窗口最小分数 |
| `--subclip-min-match` | (默认值) | 子片段检测的分数（一个片段包含在更长视频中） |
| `--check-audio-content` | false | 还比较音频指纹（非常慢，选择性启用） |
| `--generate-thumbnails` | false | 预填充 GUI 的缩略图缓存 |
| `-J` / `--ignore-same-size` | false | 忽略相同文件大小的组 |
| `-Z` / `--ignore-same-resolution` | false | 忽略相同视频分辨率的组 |
| `-r` / `--reference-directories` | - | 参考目录 |
| `-D` / `-Q` / `-y` | | 删除方式 / 干运行 / 垃圾桶 |

示例：
```shell
czkawka_cli video -d /home/rafal -f results.txt
```

---

### music - 同类音乐

```shell
czkawka_cli music -d <dirs> [options]
```

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-s` / `--search-method` | `TAGS` | `TAGS` 或 `CONTENT` |
| `-z` / `--music-similarity` | `track_title,track_artist` | 要比较的逗号分隔标签字段 |
| `-a` / `--approximate-comparison` | false | 允许标签值存在小差异 |
| `-c` / `--compare-fingerprints-only-with-similar-titles` | false | 在 CONTENT 模式下，通过先按标题相似度预筛选来加速 |
| `-l` / `--minimum-segment-duration` | 10.0 | 要比较的最小音频段长度（秒） |
| `-Y` / `--maximum-difference` | 2.0 | 最大允许音频段差异 (0.0-10.0) |
| `-m` / `--minimal-file-size` | 8192 | 最小文件大小（字节） |
| `-r` / `--reference-directories` | - | 参考目录 |
| `-D` / `-Q` / `-y` | | 删除方式 / 干运行 / 垃圾桶 |

用于 `-z` 的可用标签字段：`track_title`, `track_artist`, `year`, `bitrate`, `genre`, `length`

示例：
```shell
czkawka_cli music -d /home/rafal -e /home/rafal/Pulpit -z "track_artist,year" -f results.txt
```

---

### symlinks - 无效符号链接

```shell
czkawka_cli symlinks -d <dirs> [options]
```

查找指向不存在目标或形成循环链 (>20 跳) 的符号链接。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-D` / `-Q` / `-y` | false/false/false | 删除 / 干运行 / 垃圾桶 |

示例：
```shell
czkawka_cli symlinks -d /home/kicikici/ /home/szczek -e /home/kicikici/jestempsem -x jpg -f results.txt
```

---

### broken - 损坏文件

```shell
czkawka_cli broken -d <dirs> [options]
```

查找无法使用其预期库正确打开的文件。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-c` / `--checked-types` | `PDF,AUDIO,IMAGE,ARCHIVE,FONT,MARKUP` | 要检查的类型 (逗号分隔列表) |
| `-D` / `-Q` / `-y` | | 删除 / 干运行 / 垃圾桶 |

**可用类型值：**

| 值 | 检查 |
|-------|--------|
| `IMAGE` | jpg, jpeg, png, tiff, gif, bmp, ico, webp, exr, avif, 其他 |
| `AUDIO` | mp3, flac, wav, ogg, m4a, aac, 其他 |
| `PDF` | pdf |
| `ARCHIVE` | zip, 7z, gz/tgz, tar, zst, bz2, xz |
| `FONT` | ttf, otf, ttc |
| `MARKUP` | JSON, XML, TOML, YAML, SVG |
| `VIDEO_FFPROBE` | 快速仅头部视频检查 (需要 ffmpeg) |
| `VIDEO_FFMPEG` | 完整解码检查 - 慢，最彻底 (需要 ffmpeg) |

可能出现误报。删除前请手动验证文件。

示例：
```shell
czkawka_cli broken -d /home/kicikici/ -x jpg -f results.txt
```

---

### ext - 错误扩展名

```shell
czkawka_cli ext -d <dirs> [options]
```

查找内容 (通过魔数检测) 与当前扩展名不匹配的文件。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-F` / `--fix-extensions` | false | 自动将文件重命名为正确的扩展名 |

示例：
```shell
czkawka_cli ext -d /home/czokolada/ -f results.txt
```

---

### bad-names

```shell
czkawka_cli bad-names -d <dirs> [options]
```

至少必须启用一个检查标志，否则不会有任何文件匹配。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-u` / `--uppercase-extension` | false | 检测大写扩展名 (例如 `.JPG`) |
| `-j` / `--emoji-used` | false | 检测文件名中的表情符号字符 |
| `-w` / `--space-at-start-or-end` | false | 检测开头或结尾空格 |
| `-n` / `--non-ascii-graphical` | false | 检测非 ASCII 图形字符 |
| `-r` / `--restricted-charset` | - | 允许的特殊字符；其他将被标记 (例如 `_- .`) |
| `-a` / `--remove-duplicated-non-alphanumeric` | false | 检测重复的非字母数字字符 (例如 `file__name`) |
| `-F` / `--fix-names` | false | 自动将文件重命名为建议的修正名称 |
| `-D` / `-Q` / `-y` | | 删除 / 干运行 / 垃圾桶 |

示例：
```shell
czkawka_cli bad-names -d /home/rafal -u -j -w -n -f results.txt
```

---

### exif-remover

```shell
czkawka_cli exif-remover -d <dirs> [options]
```

查找包含 EXIF 元数据的图像文件。可选地删除标签。

支持的格式：`jpg`, `jpeg`, `jfif`, `png`, `tiff`, `tif`, `avif`, `jxl`, `webp`, `heic`, `heif`。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-i` / `--ignored-tags` | - | 要保留的逗号分隔标签名称 (例如 `Orientation,DateTime`) |
| `-F` / `--fix-exif` | false | 实际删除 EXIF 标签 |
| `-o` / `--override-file` | false | 覆盖原始文件 (默认：写入 `_cleaned` 副本) |

示例：
```shell
czkawka_cli exif-remover -d /home/rafal -x IMAGE -F -f results.txt
```

---

### video-optimizer

```shell
czkawka_cli video-optimizer -d <dirs> transcode [options]
czkawka_cli video-optimizer -d <dirs> crop [options]
```

在使用 `-F` 实际处理视频时，运行时需要 **ffmpeg**。

#### transcode

识别使用低效编解码器的视频。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-c` / `--excluded-codecs` | - | 要跳过/排除的编解码器 (例如 `h265,av1,vp9`) |
| `--target-codec` | `h265` | 设置 `-F` 时的目标编解码器：`h264`, `h265`, `av1`, `vp9` |
| `--quality` | 23 | 编码质量 (0-51；越低质量越高，文件越大) |
| `--noise-reduction` | `none` | `none` 或 `hqdn3d` (通用降噪器) |
| `--noise-reduction-strength` | 5 | 降噪器强度 (1-10) |
| `--custom-ffmpeg-command` | - | 自定义 ffmpeg 参数；覆盖大多数编码选项 |
| `-t` / `--generate-thumbnails` | false | 生成缩略图缓存 |
| `-V` / `--thumbnail-percentage` | 10 | 缩略图帧位置百分比 (1-99) |
| `-F` / `--fix-videos` | false | 实际转码找到的视频 |
| `--overwrite-original` | false | 替换原始文件 |
| `--fail-if-not-smaller` | false | 跳过输出不比原始文件小的文件 |
| `--limit-video-size` | false | 限制视频尺寸 |
| `--max-width` | 1920 | 最大宽度 (像素) (仅与 `--limit-video-size` 一起使用) |
| `--max-height` | 1080 | 最大高度 (像素) (仅与 `--limit-video-size` 一起使用) |

#### crop

识别带有黑边 (letterbox/pillarbox) 或静态边缘内容的视频。

| 标志 | 默认值 | 说明 |
|------|--------|------|
| `-m` / `--crop-mechanism` | `blackbars` | `blackbars` 或 `staticcontent` |
| `-k` / `--black-pixel-threshold` | 32 | “黑色”像素值阈值 (0-128；越低越严格) |
| `-b` / `--black-bar-percentage` | 90 | 行/列中黑色像素被视为黑边的最小百分比 |
| `-s` / `--max-samples` | 20 | 要采样的最大帧数 (5-1000) |
| `-z` / `--min-crop-size` | 10 | 最小裁剪区域大小 (像素) |
| `-t` / `--generate-thumbnails` | false | 生成缩略图缓存 |
| `-F` / `--fix-videos` | false | 实际裁剪找到的视频 |
| `--overwrite-original` | false | 替换原始文件 |
| `--target-codec` | - | 可选：在裁剪期间同时转码 |

示例：
```shell
# 查找尚未为 h265 或 av1 的视频
czkawka_cli video-optimizer -d /home/rafal transcode -c h265,av1 -f results.txt

# 干运行：预览将被转码为 h265 的内容
czkawka_cli video-optimizer -d /home/rafal transcode -F -Q

# 查找带有黑边的视频
czkawka_cli video-optimizer -d /home/rafal crop -m blackbars -f results.txt
```

---

## 自动化示例

### 夜间重复文件报告，保存为 JSON (cron)

```shell
#!/bin/bash
czkawka_cli dup \
    -d /home/user/Documents /home/user/Downloads \
    -e /home/user/.cache \
    -p /home/user/logs/duplicates_$(date +%Y%m%d).json \
    -N -M -W
```

### CI：如果构建输出中存在空文件则失败

```shell
czkawka_cli empty-files -d ./build_output -N -M
# 如果找到空文件，退出码 11；如果没有，退出码 0
```

### 带干运行确认的交互式清理

```shell
#!/bin/bash
dir="${1:?Usage: $0 <directory>}"

echo "=== 干运行：$dir 中的临时文件 ==="
czkawka_cli temp -d "$dir" -Q -D

echo ""
read -p "继续删除？[y/N] " answer
if [[ "$answer" == "y" ]]; then
    czkawka_cli temp -d "$dir" -D
    echo "完成。"
fi
```

### 保护原始文件，清理传入的重复文件

```shell
# /archive 是参考文件夹 - 永不删除
# /incoming 将被清理 - 重复文件移动到垃圾桶
czkawka_cli dup \
    -d /incoming \
    -r /archive \
    -D AEN \
    -y
```

### 通过 CLI 预填充视频缩略图缓存，加快 GUI 加载

```shell
# 运行 CLI 扫描，以便 Krokiet 下次打开时能立即显示缩略图
czkawka_cli video -d /your/videos --generate-thumbnails -N -M -W
```

### 查找带 GPS 数据的图像并删除 EXIF

```shell
# 干运行 - 首先查看哪些文件有 EXIF
czkawka_cli exif-remover -d /home/user/Photos -x IMAGE -f exif_report.txt

# 删除所有 EXIF 标签 (保留 Orientation)，覆盖原始文件
czkawka_cli exif-remover -d /home/user/Photos -x IMAGE -F -o -i "Orientation"
```
