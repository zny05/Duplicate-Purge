## Version 12.0.2 - 09.09.2026r

### Core
- 在 `make_hard_link`/`make_file_symlink` 中显式抛出回滚重命名失败，而非静默忽略 - [#1995](https://github.com/qarmin/czkawka/pull/1995)
- 将 XDG 门户垃圾桶实现切换为 `async-io`，避免与 Slint 的 async-io 后端共存时需要 Tokio 运行时 - [#2025](https://github.com/qarmin/czkawka/pull/2025)
- 修复 AVIF 许可证元数据 - [#2060](https://github.com/qarmin/czkawka/pull/2060)
- 修复 AVIF 测试 - [#2061](https://github.com/qarmin/czkawka/pull/2061)

### CLI
- 拒绝非有限用户输入（例如 `NaN`/`inf`）作为数值参数 - [#2038](https://github.com/qarmin/czkawka/pull/2038)
- 增加通过 CLI 参数在 Krokiet 中启动扫描的功能 - [#2069](https://github.com/qarmin/czkawka/pull/2069)

### Krokiet
- 修复弹出窗口 OK/Close 按钮文本截断，并更合理地居中弹出窗口 - [#2043](https://github.com/qarmin/czkawka/pull/2043)

## Version 12.0.1 - 29.07.2026r

### Core
- 修复 Windows 上内部运行 FFmpeg 时控制台窗口弹出的问题 - [#1989](https://github.com/qarmin/czkawka/pull/1989)
- 新增 `BuildRuntimeInfo` 模块，在启动时检测编译期特性（HEIF、LibRAW、AVIF）以及 FFmpeg 和 FFprobe 的运行时可用性 - [#1989](https://github.com/qarmin/czkawka/pull/1989)

### Krokiet
- 新增“关于 / 诊断”面板，用于查看构建/运行时特性并验证特定图像文件是否被正确识别 - [#1989](https://github.com/qarmin/czkawka/pull/1989)
- 修复排序弹出窗口未显示背景的问题 - [#2011](https://github.com/qarmin/czkawka/pull/2011)
- 修复部分语言下弹出窗口文本溢出的问题 - [#2011](https://github.com/qarmin/czkawka/pull/2011)
- 修复视频优化器确认弹出窗口内容被截断的问题 - [#2011](https://github.com/qarmin/czkawka/pull/2011)
- 新增设置下拉选项的翻译 - [#2011](https://github.com/qarmin/czkawka/pull/2011)
- 将 Slint 锁定到 1.17.0 版本，以避免 1.17.1 版本引入的导致启动时窗口大小无法正确恢复的 Wayland Bug - [#2011](https://github.com/qarmin/czkawka/pull/2011)

### Cedinia
- 修复进度条状态不正确的问题 - [#1989](https://github.com/qarmin/czkawka/pull/1989)
- 修复首次启动时的自动语言检测问题 - [#1989](https://github.com/qarmin/czkawka/pull/1989)
- 将所有原始和 unsafe 的 JNI 用法（文件选择器、通知、Android 路径设置）迁移到新的 `jni-high` crate - [#2011](https://github.com/qarmin/czkawka/pull/2011)

## Version 12.0.0 - 28.06.2026r

### Czkawka GTK 弃用通知
**版本 12.0 是 Czkawka GTK 的最后一个发布版本。** 从现在起将不再提供新的二进制文件。鼓励所有用户迁移到 Krokiet，即新的基于 Slint 的 GUI 前端。

源代码将保留在仓库中，并与 `czkawka_core` 保持一段时间的兼容性，以便应用仍可手动构建。但是，除非是影响 Debian 或 Docker 包等广泛使用的非官方构建的关键问题，否则特定于 Czkawka GTK 的所有问题和功能请求都将被关闭。

### 破坏性变更

#### 用户
- 由于损坏文件模式的变更，现在支持多个检查器并包含额外检查，文件类型不再存储在缓存中。现有缓存文件与此版本不兼容，将自动重新生成
- 预哈希方法已更新，缓存的哈希不再有效，将自动重新生成
- 相似图像缓存文件与此版本不兼容，因为添加了几何不变性支持，将自动重新生成
- 相似视频缓存文件与此版本不兼容，因为切换到了新的视觉匹配引擎，将自动重新生成
- 相似视频的 `--crop-detect` CLI 选项现在接受 `true`/`false`，而不再是 `none`/`letterbox`/`motion` - `motion` 模式已被移除

### Core
- AV1 编码从非常慢的 `libaom-av1` 切换为 `libsvtav1` - [#1888](https://github.com/qarmin/czkawka/pull/1888)
- 为视频优化器模式添加噪声降低选项，可显著减小噪点视频的文件体积 - [#1888](https://github.com/qarmin/czkawka/pull/1888)
- 为视频优化器模式添加自定义优化命令支持 - [#1888](https://github.com/qarmin/czkawka/pull/1888)
- 添加实验性硬件加速视频编码支持 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 损坏文件现在可以使用多个检查器进行检查 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 检查损坏视频已分为快速模式（ffprobe - 仅头部）和慢速模式（ffmpeg - 完整解码） - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 添加停止硬链接检查的功能，并附带此操作的进度跟踪 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 添加排除分辨率相同的图像/视频的功能 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 添加通过比较音频查找相似视频的功能 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 空文件模式现在允许检测仅包含不可打印 ASCII 字符或空字节（`\0`）的文件 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 临时文件模式现在允许自定义搜索的文件扩展名 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 预哈希现在也会对文件末尾进行哈希计算，以更早检测差异 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 添加对损坏字体（TTF、OTF、TTC）、标记（JSON、XML、TOML、YAML、SVG）和存档（7z、gz/tgz、tar、zst、bz2、xz）损坏检测的支持 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 为相似图像模式添加几何不变性支持，允许匹配镜像、翻转和旋转的图像 - [#1944](https://github.com/qarmin/czkawka/pull/1944)
- 修复相对符号链接未考虑父目录即被解析的 Bug - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 修复预哈希缓存绕过问题，该问题导致第二次扫描时某些文件进行完整哈希计算 - [#1907](https://github.com/qarmin/czkawka/pull/1907)
- 扩展集成测试，以防止未来回归 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 修复当 `read` 系统调用返回少于请求字节数时预哈希不稳定的问题 - [#1948](https://github.com/qarmin/czkawka/pull/1948)
- 将可视视频重复检测引擎从 `vid_dup_finder_lib` 切换为 `similario_core`，添加可配置的窗口数量、持续时间容差和子片段检测 - [#1948](https://github.com/qarmin/czkawka/pull/1948)
- 修复在引用文件夹模式下不删除相似视频的 Bug - [#1948](https://github.com/qarmin/czkawka/pull/1948)
- 用 `little_exif` 替换 `nom-exif` 以读取 EXIF 方向数据 - [#1948](https://github.com/qarmin/czkawka/pull/1948)
- 修复相似图像/视频模式中隐藏硬链接的逻辑颠倒 Bug - [#1952](https://github.com/qarmin/czkawka/pull/1952)
- 添加 `$TRASH` 排除项目预设（与现有的 `DEFAULT` 并列），用于从扫描中排除常见的垃圾桶/回收站路径 - [#1962](https://github.com/qarmin/czkawka/pull/1962)
- 重构内部进度阶段跟踪，以统一所有后端的进度计算 - [#1962](https://github.com/qarmin/czkawka/pull/1962)

### CLI

### GTK GUI
- 修复使用排序按钮时崩溃的问题 - [#1837](https://github.com/qarmin/czkawka/pull/1837)

### Krokiet
- 新增分别用于将文件移至垃圾桶和永久删除的按钮 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 新增自定义选择弹出窗口 - [#1809](https://github.com/qarmin/czkawka/pull/1809)
- 新增图像比较工具，用于检测相似图像之间的视觉差异 - [#1888](https://github.com/qarmin/czkawka/pull/1888)
- 新增右键上下文菜单 - [#1888](https://github.com/qarmin/czkawka/pull/1888)
- 文件和文件夹选择对话框不再阻塞主线程 - [#1809](https://github.com/qarmin/czkawka/pull/1809)
- 修复相似视频模式中未尊重缩略图生成设置的问题 - [#1809](https://github.com/qarmin/czkawka/pull/1809)
- 新增通知支持 - [#1837](https://github.com/qarmin/czkawka/pull/1837)
- femtovg 后端不再产生模糊字体 - [#1900](https://github.com/qarmin/czkawka/pull/1900)
- 将默认选择行为从“选择一个项目”更改为“除了一个项目外全部选择” - [#1913](https://github.com/qarmin/czkawka/pull/1913)
- 新增配置哪些选择按钮在 UI 中可见的功能 - [#1913](https://github.com/qarmin/czkawka/pull/1913)
- 新增组内反向选择 - [#1915](https://github.com/qarmin/czkawka/pull/1915)
- 修复最短/最长路径选择模式，这些模式以前仅比较路径而未比较文件名 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 新增在自定义弹出窗口中保存/恢复数据的功能 - [#1919](https://github.com/qarmin/czkawka/pull/1919)
- 为移动/复制弹出窗口新增“冲突时重命名”选项，以自动重命名文件而不是跳过它们 - [#1948](https://github.com/qarmin/czkawka/pull/1948)
- 新增重命名项目的功能 - [#1962](https://github.com/qarmin/czkawka/pull/1962)

### Cedinia
- Cedinia 初始实验性发布，一个具有触摸支持的新 Android 应用 - [#1821](https://github.com/qarmin/czkawka/pull/1821)

### 预构建二进制文件
- Linux 预构建二进制文件现在包含 AVIF 支持（需要 `libavif` 和 `libdav1d`）
- Windows ZIP 包现在包含 Krokiet 二进制文件和一个 README 以简化迁移到新前端
- 所有后端的 Krokiet 二进制文件现在打包在 ZIP 文件中，并附有用于选择后端启动它们的额外脚本
- 由于 GitHub CI 上的构建时间非常长，不再提供 Mac Intel 二进制文件
- 新增安装脚本（`misc/install_scripts/`），适用于 Linux（apt/dnf/pacman/zypper）、macOS（Homebrew）和 Windows（winget）

## Version 11.0.1 - 20.02.2026r
### Core
- 修复 Windows 上排除文件夹无效的问题 - [#1808](https://github.com/qarmin/czkawka/pull/1808)

### GTK GUI
- 为相似视频选项卡添加缺失的 Duration 列，修复视频分析后发生的 panic - [#1793](https://github.com/qarmin/czkawka/pull/1793)
- 移除对不存在的排除目录显示的警告日志消息 - [#1795](https://github.com/qarmin/czkawka/pull/1795)
- 修复双击包含或排除目录列表中的文件夹时发生的 panic - [#1799](https://github.com/qarmin/czkawka/pull/1799)
- 更新到稳定版 gtk4-rs 0.11 - [#1808](https://github.com/qarmin/czkawka/pull/1808)

### Krokiet
- 提高默认最大文件大小限制 - [#1808](https://github.com/qarmin/czkawka/pull/1808)

### 预构建二进制文件
- 新增 Krokiet wgpu 二进制文件
- 新增包含所有后端的全能 Krokiet 二进制文件

### CI
- 新增运行 `cargo test` 的 Windows CI 作业

## Version 11.0.0 - 14.02.2026r

### 破坏性变更
#### 用户
- Czkawka GUI 配置文件已从自定义的、损坏的格式迁移到 JSON。所有设置都需要重新配置。旧的 TXT 文件未被删除，可作为参考使用。
- 在损坏文件模式中，文件类型不再存储在缓存中。现有缓存文件与此版本不兼容，将自动重新生成。
- 相似图像模式中的 `Similarity Preset` 枚举已被整数参数 `Max Difference`（范围 0-40）替换。
- HEIF 图像现在只旋转一次，而不是两次。现有缓存可能包含旋转不正确的图像，应通过删除缓存来重新生成（但这需要手动干预）。

#### 开发者
- 公共 API 函数进行了轻微调整，以避免不必要的复制和引用可复制类型。
- `Similarity` 变量重命名为 `Difference`。
- 应用程序必须在启动时调用 `register_image_decoding_hooks();` 以启用读取 HEIF 和 JXL 图像。

### Core
- 在相似图像模式和预览中，大多数情况下已移除扩展名验证 - [#1623](https://github.com/qarmin/czkawka/pull/1623)
- 编译时和运行时的 Musl 和 Glibc 版本现在会打印到日志中 - [#1604](https://github.com/qarmin/czkawka/pull/1604/files)
- 符号链接期间的目标文件移除现在会延迟执行，以防止失败时发生数据丢失 - [#1672](https://github.com/qarmin/czkawka/pull/1672)
- 修复 Windows 上无效的路径规范化 - [#1604](https://github.com/qarmin/czkawka/pull/1604/files)
- 比较结果现在是确定性的 - [#1654](https://github.com/qarmin/czkawka/pull/1654)
- 内置 JPEG 预览现在在可用时从 RAW 图像中读取 - [#1655](https://github.com/qarmin/czkawka/pull/1655)
- 修复当日志程序无法写入终端时的静默 panic - [#1658](https://github.com/qarmin/czkawka/pull/1658)
- 提交哈希现在包含在日志中 - [#1672](https://github.com/qarmin/czkawka/pull/1672)
- 改进和修复按相似度级别对相似图像进行分组的逻辑 - [#1685](https://github.com/qarmin/czkawka/pull/1685)
- 新增扫描时间测量 - [#1674](https://github.com/qarmin/czkawka/pull/1674), [#1685](https://github.com/qarmin/czkawka/pull/1685)
- 新增通过外部 ffmpeg 和 ffprobe 检测损坏视频文件的功能，用于损坏文件工具 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增视频优化器模式，通过外部 ffmpeg 和 ffprobe 用更高效的编解码器重新编码视频并裁剪黑边/静态条 - [#1726](https://github.com/qarmin/czkawka/pull/1726), [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增 exif 移除模式，用于从文件中移除选定的 EXIF 标签 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增错误名称模式，用于查找和重命名带有问题名称的文件，例如非 ASCII 字符或大写扩展名 - [#1754](https://github.com/qarmin/czkawka/pull/1754)
- 新增扫描单个文件的功能，而不仅仅是文件夹 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 将支持的图像大小限制为 2000 MP - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 过时条目的自动清理现在每周最多运行一次 - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 新增手动从缓存文件中移除过时条目的功能 - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 新增相似视频工具的视频属性信息，包括比特率、编解码器、FPS、尺寸、持续时间 - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 修复 HEIF 图像的双重旋转问题 - [#1783](https://github.com/qarmin/czkawka/pull/1783)
- 修复使用内置 libheif-rs 解码方法时对某些 HEIF 图像处理不正确的问题 - [#1783](https://github.com/qarmin/czkawka/pull/1783)

### CLI
- 默认启用彩色终端输出，可通过功能标志禁用 - [#1672](https://github.com/qarmin/czkawka/pull/1672)
- 修复结果未打印到终端的回归问题 - [#1672](https://github.com/qarmin/czkawka/pull/1672)
- 为大多数工具新增 `dry_run` 和 `move_to_trash` 选项 - [#1685](https://github.com/qarmin/czkawka/pull/1685)
- 修复未绑定的 `--excluded-extensions` 选项 - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 新增模式：视频优化器、exif 移除和错误名称 - [#1760](https://github.com/qarmin/czkawka/pull/1760)

### GTK GUI
- 恢复排序按钮并修复与排序相关的崩溃 - [#1623](https://github.com/qarmin/czkawka/pull/1623)
- 配置现在使用 JSON 格式，而非自定义格式 - [#1623](https://github.com/qarmin/czkawka/pull/1623)
- 新增多线程创建硬链接、符号链接和文件删除 - [#1672](https://github.com/qarmin/czkawka/pull/1672)
- 修复导致图像预览极小的 GTK 回归问题 - [#1658](https://github.com/qarmin/czkawka/pull/1658)
- 新增轻松在比较图像之间切换的按钮 - [#1658](https://github.com/qarmin/czkawka/pull/1658)
- 执行重构以评估可能的 GTK 5 迁移，目前不可行 - [#1658](https://github.com/qarmin/czkawka/pull/1658)
- 修复大文件模式中的按大小排序问题 - [#1691](https://github.com/qarmin/czkawka/pull/1691)
- 修复因 gtk4-rs 中无效函数声明导致的冻结问题 - [#1691](https://github.com/qarmin/czkawka/pull/1691)
- 新增关于弹出窗口，告知 Krokiet 是继承应用 - [#1718](https://github.com/qarmin/czkawka/pull/1718)
- 新增 `--cache` 和 `--config` CLI 选项，用于打开缓存和配置路径 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增最短和最长路径选择模式 - [#1738](https://github.com/qarmin/czkawka/pull/1738)

### Krokiet
- 新增新标志 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 新增视频缩略图、单视图和网格视图 - [#1714](https://github.com/qarmin/czkawka/pull/1714)
- 在设置中显示缓存、缩略图和日志的大小 - [#1714](https://github.com/qarmin/czkawka/pull/1714)
- 新增点击列标题排序功能 - [#1718](https://github.com/qarmin/czkawka/pull/1718)
- 引入默认 500 条消息行限制，防止因 TextEdit 性能慢而导致冻结 - [#1718](https://github.com/qarmin/czkawka/pull/1718)
- 略微增大字体尺寸以提高可读性 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 新增运行时应用程序缩放，有一些限制 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 新扫描开始时清除底部面板中的消息 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 修复在新扫描进行中时单击先前结果导致崩溃的问题 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 将默认行为更改为将文件移至垃圾桶，而不是永久删除 - [#1726](https://github.com/qarmin/czkawka/pull/1726)
- 新增当应用程序无法打开时的通知对话框 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增 `--cache` 和 `--config` CLI 选项，用于打开缓存和配置路径 - [#1745](https://github.com/qarmin/czkawka/pull/1745)
- 新增模式：视频优化器、exif 移除和错误名称 - [#1726](https://github.com/qarmin/czkawka/pull/1726), [#1745](https://github.com/qarmin/czkawka/pull/1745), [#1754](https://github.com/qarmin/czkawka/pull/1754)
- 修改日期现在显示为本地时间，而不是 UTC - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 新增手动移除过时缓存条目的菜单选项 - [#1748](https://github.com/qarmin/czkawka/pull/1748)
- 新增可选扫描完成声音，隐藏在 `audio` 功能标志后面 - [#1754](https://github.com/qarmin/czkawka/pull/1754)
- 修复排序选项因多个无效信号连接而未更新的问题 - [#1760](https://github.com/qarmin/czkawka/pull/1760)
- 新增创建硬链接和符号链接的支持 - [#1760](https://github.com/qarmin/czkawka/pull/1760)
- 新增最短和最长路径选择模式 - [#1738](https://github.com/qarmin/czkawka/pull/1738)
- 修复因选择缓存不同步导致的崩溃 - [#1783](https://github.com/qarmin/czkawka/pull/1783)

### External
- Wine 10.20 包含修复在 Czkawka GUI 中打开文件对话框时崩溃的 Bug - [Wine 49987 issue](https://bugs.winehq.org/show_bug.cgi?id=49987)

### 预构建二进制文件
- Krokiet Windows 二进制文件（Skia 后端）现在可用，仅适用于 MSVC 构建，并需要 Visual C++ Redistributable
- Intel Mac 二进制文件现在使用最新可用的 macOS 版本构建，当前为 15
- Windows 预构建二进制文件现在捆绑 libEGL 和 libGLES，修复某些系统上运行 GTK 4.12 构建的问题，不再提供 GTK 4.6 构建
- Krokiet macOS OpenGL 二进制文件已弃用，因 Apple OpenGL 驱动程序过时且损坏，现在提供并推荐 Skia Vulkan 二进制文件
- 某些 Linux 二进制文件现在在 Ubuntu 24.04 上构建，以支持更新的 libheif-rs，包括读取非 rgb8 像素格式图像的改进
- Windows 二进制文件现在使用 8 MB 栈大小以匹配 Linux，修复调试构建中的栈溢出
- Windows 二进制文件现在包含内置图标

## Version 10.0.0 - 18.08.2025r
### 破坏性变更
#### 用户
- 某些语言现在在 Crowdin 中具有统一名称（例如 `es` → `es-ES`）。GUI 可能找不到它们并将回退到默认语言。
- 缓存文件现在使用内存限制，与先前版本不兼容。
- CLI 图像筛选参数从 `faussian` 更改为 `gaussian`

#### 开发者
- `stop_flag` 现在是大多数核心函数的必需参数
- 部分核心函数的可见性已降低为 `pub(crate)`
- czkawka_core 中的模块已拆分和重新组织 - 导入需要调整，尽管实际行为和项目名称不应发生太大变化

### Core
- 将 `println`/`eprintln` 替换为日志函数 - [#1478](https://github.com/qarmin/czkawka/pull/1478)
- 轻微改进缓存加载和保存速度 - [#1478](https://github.com/qarmin/czkawka/pull/1478)
- 消息和 panic 现在也会记录到文件中（可通过设置 `DISABLE_FILE_LOGGING` 环境变量禁用） - [#1508](https://github.com/qarmin/czkawka/pull/1508)
- 加载或保存缓存时添加 8GB 内存限制，以避免因损坏的缓存文件导致内存溢出崩溃 - [#1508](https://github.com/qarmin/czkawka/pull/1508)
- Czkawka 二进制文件现在可复现 - [#1565](https://github.com/qarmin/czkawka/pull/1565)
- 新增防止删除扫描后不再为空的文件夹的保护 - [#1566](https://github.com/qarmin/czkawka/pull/1566)
- 将 `pdf-rs` 替换为更流行的 `lopdf` 库，后者依赖也更少 - [#1566](https://github.com/qarmin/czkawka/pull/1566)
- 将 `imagepipe` + `rawloader` 替换为仍受支持且解码 raw 文件更快的 `rawler` - [#1572](https://github.com/qarmin/czkawka/pull/1572)
- 在视频查找器中添加更多配置选项 - [#1578](https://github.com/qarmin/czkawka/pull/1578)
- 移除 `fast_image_resize` 特性，并无条件启用 `image_hasher/fast_resize_unstable` - [#1586](https://github.com/qarmin/czkawka/pull/1586)

### CLI
- 改进文件删除逻辑并为此操作添加进度条 - [#1571](https://github.com/qarmin/czkawka/pull/1571)

### GTK GUI
- 新图标 - 视觉吸引力较低，但由我创建并采用真正免费的 CC BY 许可证发布 - [#1478](https://github.com/qarmin/czkawka/pull/1478)
- 修复移除过时缓存时的崩溃 - [#1508](https://github.com/qarmin/czkawka/pull/1508)
- 修复引用文件夹中相似视频缺失的文件和文件夹名称 - [#1520](https://github.com/qarmin/czkawka/pull/1520)
- 修复 SVG pixbuf 加载器不可用时的崩溃 - [#1565](https://github.com/qarmin/czkawka/pull/1565)
- 修复在引用文件夹上使用自定义选择的问题 - [#1581](https://github.com/qarmin/czkawka/pull/1581)

### Krokiet
- 新增使用鼠标和键盘选择多个项目的功能 - [#1478](https://github.com/qarmin/czkawka/pull/1478)
- 新增排序按钮 - [#1501](https://github.com/qarmin/czkawka/pull/1501)
- 窗口大小现在会被记住 - [#1508](https://github.com/qarmin/czkawka/pull/1508)
- 新增翻译 - [#1508](https://github.com/qarmin/czkawka/pull/1508), [#1513](https://github.com/qarmin/czkawka/pull/1513)
- 改进弹出窗口样式 - [#1520](https://github.com/qarmin/czkawka/pull/1520)
- 深色和浅色主题现在可以在运行时切换 - [#1520](https://github.com/qarmin/czkawka/pull/1520)
- 为深色主题下改善可见性，将图标颜色更改为白色 - [#1520](https://github.com/qarmin/czkawka/pull/1520)
- 新增隐藏按钮文本的功能 - [#1520](https://github.com/qarmin/czkawka/pull/1520)
- 文件的多线程移除、移动和重命名 - [#1565](https://github.com/qarmin/czkawka/pull/1565)
- 移除、重命名或移动失败的文件不再从结果列表中删除 - [#1565](https://github.com/qarmin/czkawka/pull/1565)
- 在移除、重命名或移动文件时显示进度信息，并可停止进程 - [#1565](https://github.com/qarmin/czkawka/pull/1565)
- 扫描文件夹现在可以通过 CLI 设置，例如 `krokiet /home/rafal` - 有关更多信息请参阅 `krokiet --help` - [#1566](https://github.com/qarmin/czkawka/pull/1566)
- 改进底部目录面板的外观 - [#1569](https://github.com/qarmin/czkawka/pull/1569)
- 当未选择任何文件时，某些按钮被禁用 - [#1586](https://github.com/qarmin/czkawka/pull/1586)
- 新增要删除的项目数量信息 - [#1589](https://github.com/qarmin/czkawka/pull/1589)
- 将图像预览限制为最大 1024 宽/高，以加快预览加载速度并修复软件渲染器中的崩溃 - [#1590](https://github.com/qarmin/czkawka/pull/1590)

### External
- 新的非官方基于 Tauri 的 Czkawka 前端 - [Czkawka Tauri](https://github.com/shixinhuang99/czkawka-tauri)
- Czkawka 8.0.0 现在在 Debian Sid 中可用 - [Cli](https://packages.debian.org/sid/czkawka-cli)/[Gui Gtk](https://packages.debian.org/sid/czkawka-gui)

### CI
- CI 中现在检查 32 位目标的编译
- CI 中现在检查 Czkawka 二进制文件的可复现性

### 预构建二进制文件
- 不再提供 AppImage 二进制文件，因存在随机 Bug（其他打包格式中不存在），且相比预构建 Linux 二进制文件或 Flatpak 增加价值极小
- 现在提供 HEIF Mac 二进制文件
- CI 现在在 Ubuntu 22.04 上构建 Linux 二进制文件，而非 20.04（GitHub 移除了 20.04 镜像）
- `czkawka_cli` 的 `musl` 构建现在替代 `eyra` 构建提供（略好于维护）。GUI 构建不包含在内，因 `musl` 和 `eyra` 的限制 :(
- 不再提供预构建 Windows 控制台二进制文件 - 日志现在保存到文件中，比终端输出更易读
- Krokiet 在 Linux 上提供 Skia opengl 和 vulkan 后端（Windows 上无二进制文件，因为不知道如何替换 `sed`）
- 预构建二进制文件现在使用 `lto fat` 而非 `lto thin` 和 `codegen-units=1` 构建，大幅减小二进制体积（~25% 更小的二进制文件）

## Version 9.0.0 - 16.03.2025r

## 破坏性变更

- 视频、重复（更小的预哈希大小）和图像缓存（EXIF 方向 + 更快的调整大小实现）与先前版本不兼容，需要重新生成。

### Core
- 根据 EXIF 方向自动旋转所有图像 - [#1368](https://github.com/qarmin/czkawka/pull/1368)
- 修复某些操作系统上因负时间值导致的崩溃 - [#1369](https://github.com/qarmin/czkawka/pull/1369)
- 更新 `vid_dup_finder`；现在可以检测短于 30 秒的相似视频 - [#1425](https://github.com/qarmin/czkawka/pull/1425)
- 新增对更多 JXL 图像格式的支持（使用内置的 JXL → image-rs 转换器） - [#1425](https://github.com/qarmin/czkawka/pull/1425)
- 通过使用更大、可重用的缓冲区进行文件读取，改进重复文件检测 - [#1425](https://github.com/qarmin/czkawka/pull/1425)
- 新增显著更快的图像调整大小选项，以加快图像哈希计算 - [#1458](https://github.com/qarmin/czkawka/pull/1458)
- 日志现在包含操作系统和已编译应用特性的信息（仅 x86_64 版本） - [#1458](https://github.com/qarmin/czkawka/pull/1458)
- 在特定模式中新增大小进度跟踪 - [#1458](https://github.com/qarmin/czkawka/pull/1458), [#1464](https://github.com/qarmin/czkawka/pull/1464)
- 新增在大文件哈希计算过程中中途停止的功能 - [#1458](https://github.com/qarmin/czkawka/pull/1458)
- 实现多线程以加速硬链接过滤 - [#1458](https://github.com/qarmin/czkawka/pull/1458)
- 将预哈希读取文件大小减少到最大 4 KB - [#1458](https://github.com/qarmin/czkawka/pull/1458)
- 修复在 CPU 核心数量较多的系统上扫描末尾时的减速问题 - [#1460](https://github.com/qarmin/czkawka/pull/1460)
- 改进收集要检查的文件时的扫描取消速度 - [#1460](https://github.com/qarmin/czkawka/pull/1460)
- 新增使用 `CZKAWKA_CONFIG_PATH` 和 `CZKAWKA_CACHE_PATH` 环境变量配置配置/缓存路径的支持 - [#1464](https://github.com/qarmin/czkawka/pull/1464)
- 修复调试模式下检查名为 `.mp3` 的损坏文件时的崩溃 - [#1464](https://github.com/qarmin/czkawka/pull/1464)
- 在损坏文件模式中捕获来自 symphonia 崩溃的 panic - [#1466](https://github.com/qarmin/czkawka/pull/1466)
- 当使用 `panic=abort` 时打印警告（这可能加快应用速度并导致偶尔崩溃） - [#1466](https://github.com/qarmin/czkawka/pull/1466)

### Krokiet
- 将默认选项卡更改为“重复文件” - [#1368](https://github.com/qarmin/czkawka/pull/1368)

### GTK GUI
- 在 Wayland 中添加窗口图标 - [#1400](https://github.com/qarmin/czkawka/pull/1400)
- 禁用损坏的排序按钮 - [#1400](https://github.com/qarmin/czkawka/pull/1400)

### CLI
- 新增 `-N` 和 `-M` 标志以抑制向控制台打印结果/警告 - [#1464](https://github.com/qarmin/czkawka/pull/1464)
- 修复扫描结束时消息未清除的问题 - [#1464](https://github.com/qarmin/czkawka/pull/1464)
- 新增通过 `-H` 标志禁用缓存的功能（用于基准测试） - [#1466](https://github.com/qarmin/czkawka/pull/1466)

### Prebuild-binaries
- 这是最后一个支持 Ubuntu 20.04 的版本 - GitHub actions 在这些运行器上移除了此操作系统
- Linux 和 Mac 二进制文件现在提供 x86_64 和 arm64 两个选项
- Arm Linux 构建至少需要 Ubuntu 24.04
- Windows GTK GUI 构建使用 Gtk 4.12 而非 Gtk 4.10
- 放弃对 snap 构建的支持 - 维护和测试耗时太多（而且目前已损坏）
- 移除原生 Windows Krokiet 版本 - 现在仅从 Linux 交叉编译提供（不应有任何区别）

## Version 8.0.0 - 11.10.2024r

### 破坏性变更

- 由于移除了 image 结构体中的 image_type，旧缓存文件与新版本不兼容，应从头重新生成（它使用新名称）
- 某些 CLI 参数的短名称可能会更改，因为修复了名称歧义

### 已知回归

- Slint 1.8 是 Krokiet 使用的版本，它需要 femtovg 0.9.2，这破坏了字体渲染 - https://github.com/slint-ui/slint/issues/6298

### CI

- 提供每夜构建 - [#1360](https://github.com/qarmin/czkawka/pull/1360) - https://github.com/qarmin/czkawka/releases/tag/Nightly
- 添加 CLI 中查找重复选项 - [#1364](https://github.com/qarmin/czkawka/pull/1364)

### Core

- 移除一些不必要的 panic - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 简化发送/接收进度信息时使用的结构体 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 新增 Median 哈希算法 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 修复与 Rust >=1.80 的编译问题 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 提取工具输入参数，这有助于发现未使用的参数 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 新增仅在标题标签相似的组中查找相似音乐的新模块 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 打印到文件/控制台不再在 Windows 路径中使用两个反斜杠 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 修复解码 raw 图片失败时的 panic - [#1355](https://github.com/qarmin/czkawka/pull/1355)
- 当没有文件可检查时，移除无用的缓存保存/加载 - [#1358](https://github.com/qarmin/czkawka/pull/1358)
- Windows 上过滤硬链接 - [#1316](https://github.com/qarmin/czkawka/pull/1316)
- 新增 jxl 支持 - [#1358](https://github.com/qarmin/czkawka/pull/1358)
- 新增 avif 支持（通过外部 C 库，默认未启用） - [#1358](https://github.com/qarmin/czkawka/pull/1358)
- 默认启用整数溢出检查（为报告 Bug、性能变慢和一般不稳定性做准备） - [#1358](https://github.com/qarmin/czkawka/pull/1358)
- 修复加载无效图像缓存时的崩溃 - [#1230](https://github.com/qarmin/czkawka/pull/1230)

### Krokiet

- 修复相似图像中无效的默认哈希大小 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 修复并添加更多应用程序输入参数 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 修复加载无效预设的问题 - [#1226](https://github.com/qarmin/czkawka/pull/1226)
- 修复使用 8 个哈希大小和小相似度时的崩溃 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 当未找到文件时禁用按钮 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 更改打开/关闭底部面板的方式 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 略微修改标志 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 避免尝试加载不受支持文件的预览时出错 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 新增显示引用文件夹预览的功能 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 启用使用空格选择、使用方向键跳过条目并用 Enter 键打开 - [#1359](https://github.com/qarmin/czkawka/pull/1359)
- 新增重命名无效扩展名文件的按钮 - [#1364](https://github.com/qarmin/czkawka/pull/1364)

### GTK GUI

- 修复并添加更多应用程序输入参数 - [#1355](https://github.com/qarmin/czkawka/pull/1355)
- 新增使用外部库而非 gtk pixbuf 加载器进行预览的选项 - [#1358](https://github.com/qarmin/czkawka/pull/1358)
- 在 appimage 中使用带 zstd 压缩的静态运行时 - [#1350](https://github.com/qarmin/czkawka/pull/1355)
- 恢复 flatpak 构建 - [#1275](https://github.com/qarmin/czkawka/pull/1275)
- [外部] Mac homebrew 版本的应用 - https://formulae.brew.sh/formula/czkawka

### CLI

- 新增按大小查找/移除图像的选项 - [#1255](https://github.com/qarmin/czkawka/pull/1255)
- 修复并添加更多应用程序输入参数 - [#1354](https://github.com/qarmin/czkawka/pull/1354)
- 修复多次停止扫描时的崩溃 - [#1355](https://github.com/qarmin/czkawka/pull/1355)
- 调试构建中也打印结果 - [#1355](https://github.com/qarmin/czkawka/pull/1355)
- 新增选择引用目录的支持 - [#1364](https://github.com/qarmin/czkawka/pull/1364)

## Version 7.0.0 - 19.02.2024r

### 破坏性变更

- 缩小缓存文件大小，使旧缓存文件与新版本不兼容
- CLI 中的 `-C` 现在保存为紧凑 JSON

### GTK GUI

- 新增包含/排除文件夹的拖放支持 - [#1106](https://github.com/qarmin/czkawka/pull/1106)
- 新增保存扫描结果位置的信息 - [#1102](https://github.com/qarmin/czkawka/pull/1102)

### CLI

- 使用 [Eyra](https://github.com/sunfishcode/eyra) 提供完整的静态 Rust 二进制文件 - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 修复重复的 `-c` 参数，现在保存为紧凑 JSON 通过 `-C` 处理 - [#1153](https://github.com/qarmin/czkawka/pull/1153)
- 新增扫描进度条 - [#1183](https://github.com/qarmin/czkawka/pull/1183)
- 干净且安全地取消扫描 - [#1183](https://github.com/qarmin/czkawka/pull/1183)
- 统一 CLI 参数 - [#1183](https://github.com/qarmin/czkawka/pull/1183)
- 相似图像/视频的硬链接支持 - [#1201](https://github.com/qarmin/czkawka/pull/1201)

### Krokiet GUI

- 新 GUI 的初始发布 - [#1102](https://github.com/qarmin/czkawka/pull/1102)

### Core

- 使用普通 crossbeam 通道，而非 asyncio tokio 通道 - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 修复使用空文件夹进度时的工具类型 - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 修复保存大小和名称重复结果时缺少的 JSON 支持 - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 修复交叉编译的 Windows 调试构建 - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 默认添加更大的栈大小（修复某些 musl 应用中的栈溢出） - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 新增可选 libraw 依赖（更好的单核性能和支持更多 raw 文件） - [#1102](https://github.com/qarmin/czkawka/pull/1102)
- 加速通配符检查并修复识别长排除项目的问题 - [#1152](https://github.com/qarmin/czkawka/pull/1152)
- 在搜索空文件夹时大幅提升速度（尤其是多线程 + 缓存的 FS 架构） - [#1152](https://github.com/qarmin/czkawka/pull/1152)
- 由于懒文件元数据收集，扫描文件收集可以快得多 - [#1152](https://github.com/qarmin/czkawka/pull/1152)
- 修复将不可访问的文件夹识别为非空的问题 - [#1152](https://github.com/qarmin/czkawka/pull/1152)
- 统一扫描文件收集的代码 - [#1159](https://github.com/qarmin/czkawka/pull/1159)
- 通过移除自定义文件条目结构体中的未使用字段，减少收集文件时的内存使用 - [#1159](https://github.com/qarmin/czkawka/pull/1159)
- 略微减小缓存大小并提高加载/保存速度 - [#1159](https://github.com/qarmin/czkawka/pull/1159)
- 新增从扫描中移除带有排除扩展名的文件的功能 - [#1184](https://github.com/qarmin/czkawka/pull/1102)
- 修复在引用文件夹使用时，相似图像结果中未显示具有相同哈希的文件 - [#1184](https://github.com/qarmin/czkawka/pull/1102)
- 使用 LTO 优化发布二进制文件（~25/50% 更小，~5/10% 更快） - [#1184](https://github.com/qarmin/czkawka/pull/1102)

## Version 6.1.0 - 15.10.2023r

- 破坏性变更 - 更改缓存保存方法，对所有文件进行了去重、优化和简化（所有文件都需要重新哈希） - [#1072](https://github.com/qarmin/czkawka/pull/1072), [#1086](https://github.com/qarmin/czkawka/pull/1086)
- 移除等待结果时最多 340ms 的延迟 - [#1070](https://github.com/qarmin/czkawka/pull/1070)
- 新增带有调试时有用信息的日志记录器（级别可通过例如 `RUST_LOG=debug` 环境变量调整） - [#1072](https://github.com/qarmin/czkawka/pull/1072), [#1070](https://github.com/qarmin/czkawka/pull/1070)
- Core 代码清理 - [#1072](https://github.com/qarmin/czkawka/pull/1072), [#1070](https://github.com/qarmin/czkawka/pull/1070), [#1082](https://github.com/qarmin/czkawka/pull/1082)
- 更新错误扩展名列表并支持查找无效的 jar 文件 - [#1070](https://github.com/qarmin/czkawka/pull/1070)
- Windows 上更多默认排除项目（如 pagefile） - [#1074](https://github.com/qarmin/czkawka/pull/1074)
- 统一打印/保存到文件/终端的方法并修复一些差异/错误 - [#1082](https://github.com/qarmin/czkawka/pull/1082)
- 使用 fun_time 库打印函数耗时 - [#1082](https://github.com/qarmin/czkawka/pull/1082)
- 新增将结果导出为 JSON 文件格式 - [#1083](https://github.com/qarmin/czkawka/pull/1083)
- 新增用于 CI 的测试/回归套件 - [#1083](https://github.com/qarmin/czkawka/pull/1083)
- 新增使用相对路径的功能 - [#1083](https://github.com/qarmin/czkawka/pull/1083)
- 允许从 CLI 移除相似图像/视频/音乐 - [#1087](https://github.com/qarmin/czkawka/pull/1087)
- 新增在重复和音乐模式中关于保存/加载缓存项的信息 - [#1091](https://github.com/qarmin/czkawka/pull/1091)
- 修复重复模式中要检查的文件数量 - [#1091](https://github.com/qarmin/czkawka/pull/1091)
- 新增对 qoi 图像格式的支持（尚无预览） - [e92a](https://github.com/qarmin/czkawka/commit/e92a8a65de9bd1250be482dbce06959125554849)
- 修复可能在 CLI 中移除无效文件的稳定性问题 - [#1083](https://github.com/qarmin/czkawka/pull/1083)
- 使用 gtk 4.6 而不是 4.8 或 4.10 修复 Windows GUI 崩溃 - [#992](https://github.com/qarmin/czkawka/pull/992)
- 修复打印重复音乐文件信息的问题 - [#1016](https://github.com/qarmin/czkawka/pull/1016)
- 修复打印重复视频文件信息的问题 - [#1017](https://github.com/qarmin/czkawka/pull/1017)

## Version 6.0.0 - 11.06.2023r

- 新增按内容查找相似音频文件的功能 - [#970](https://github.com/qarmin/czkawka/pull/970)
- 新增同时按名称/大小查找重复文件的功能 - [#956](https://github.com/qarmin/czkawka/pull/956)
- 修复、简化并加速查找相似图像 - [#983](https://github.com/qarmin/czkawka/pull/956)
- 修复音乐标签缓存未工作的 Bug - [#970](https://github.com/qarmin/czkawka/pull/970)
- 新增从 CLI 设置线程数量的功能 - [#972](https://github.com/qarmin/czkawka/pull/972)
- 修复错误扩展名模式中无效项目排序的问题 - [#972](https://github.com/qarmin/czkawka/pull/972)
- 大规模代码重构/清理 - [#956](https://github.com/qarmin/czkawka/pull/956)/[#970](https://github.com/qarmin/czkawka/pull/970)/[#972](https://github.com/qarmin/czkawka/pull/972)
- 为预览使用内置 gtk webp 加载器 - [#923](https://github.com/qarmin/czkawka/pull/923)
- 修复 Docker 构建 - [#947](https://github.com/qarmin/czkawka/pull/947)
- 恢复自 GTK 4 移植以来损坏的 snap 构建 - [#965](https://github.com/qarmin/czkawka/pull/947)
- 如何在 Mac 上构建原生 ARM64 二进制文件的说明 - [#945](https://github.com/qarmin/czkawka/pull/945)/[#971](https://github.com/qarmin/czkawka/pull/971)

## Version 5.1.0 - 19.02.2023r

- 新增排序按钮 - [#894](https://github.com/qarmin/czkawka/pull/894)
- 新增设置扫描使用的线程数量的功能 - [#839](https://github.com/qarmin/czkawka/pull/839)
- 加快使用引用文件夹的相似图像比较 - [#826](https://github.com/qarmin/czkawka/pull/826)
- 更新到 clap 4 - [#878](https://github.com/qarmin/czkawka/pull/878)
- 使用 FileChooserNative 而不是 FileChooserDialog - [#894](https://github.com/qarmin/czkawka/pull/894)
- 修复使用引用文件夹时音乐文件中无效的音乐标签 - [#894](https://github.com/qarmin/czkawka/pull/894)
- 更新 pdf 依赖（大大减少破损 PDF 的误报） - [#894](https://github.com/qarmin/czkawka/pull/894)
- 将奇怪的 PDF 错误消息 “Try at” 更改 - [#894](https://github.com/qarmin/czkawka/pull/894)
- 将 Mp4 和 m4v 扩展名视为相同 - [#834](https://github.com/qarmin/czkawka/pull/834)
- 提高缩略图质量 - [#895](https://github.com/qarmin/czkawka/pull/895)
- 验证硬链接是否工作，如果不工作，则带适当消息禁用按钮 - [#881](https://github.com/qarmin/czkawka/pull/881)
- 在项目上应用一些 pydantic clippy lint - [#901](https://github.com/qarmin/czkawka/pull/901)

## Version 5.0.2 - 30.08.2022r

- 修复使用相似度 > 0 时丢失某些相似图像的问题 - [#799](https://github.com/qarmin/czkawka/pull/799)
- 预构建 Linux 二进制文件不带 heif 支持编译 - [24b](https://github.com/qarmin/czkawka/commit/24b64a32c65904c506b54270f0977ccbe5098cc8)
- 相似视频在处理视频一定时间后停止（修复冻结） - [#815](https://github.com/qarmin/czkawka/pull/815)
- 为 czkawka_cli 新增 --version 参数 - [#806](https://github.com/qarmin/czkawka/pull/806)
- 重写关于最小文件大小的有点无意义的消息 - [#807](https://github.com/qarmin/czkawka/pull/807)

## Version 5.0.1 - 03.08.2022r

- 修复带有空磁盘窗口路径的末尾斜杠移除问题 - [975](https://github.com/qarmin/czkawka/commit/97563a7b2a70fb5fcf6463f28069e6ea3b0ff5c2)
- 为 CLI 新增错误扩展名模式 - [#795](https://github.com/qarmin/czkawka/pull/795)
- 在 CLI 查找最大文件时恢复默认排序方法 - [5d7](https://github.com/qarmin/czkawka/commit/5d79dc7ccfee6d5426e37c4e6a860fa555c5927a)
- 向 CI 新增测试 - [#791](https://github.com/qarmin/czkawka/pull/791)
- 当所有目录都设置为引用文件夹时显示错误消息 - [#795](https://github.com/qarmin/czkawka/pull/795)
- 添加关于 Linux 上新要求的更多信息 - [#795](https://github.com/qarmin/czkawka/pull/795)

## Version 5.0.0 - 28.07.2022r

- GUI 移植到使用 GTK 4 - [#466](https://github.com/qarmin/czkawka/pull/466)
- 使用多线程和改进的算法来比较图像哈希 - [#762](https://github.com/qarmin/czkawka/pull/762)
- 随窗口调整预览大小 - [#466](https://github.com/qarmin/czkawka/pull/466)
- 修复列表视图中只移除一个项目的问题 - [#466](https://github.com/qarmin/czkawka/pull/466)
- 修复重复 CLI 模式中显示帮助命令的问题 - [#720](https://github.com/qarmin/czkawka/pull/720)
- 修复在相似音乐模式中未选择任何标签时的冻结问题 - [#732](https://github.com/qarmin/czkawka/pull/732)
- 修复非小写扩展名文件的预览 - [#694](https://github.com/qarmin/czkawka/pull/694)
- 从音乐文件中读取更多标签 - [#705](https://github.com/qarmin/czkawka/pull/705)
- 改进无效扩展名检查 - [#705](https://github.com/qarmin/czkawka/pull/705), [#747](https://github.com/qarmin/czkawka/pull/747), [#749](https://github.com/qarmin/czkawka/pull/749)
- 支持查找无效的 PDF 文件 - [#705](https://github.com/qarmin/czkawka/pull/705)
- 重新启用检查损坏的音乐文件（不再需要 `libasound.so.2`） - [#705](https://github.com/qarmin/czkawka/pull/705)
- 修复使用无效设置时相似音乐中的 UI 禁用问题 - [#740](https://github.com/qarmin/czkawka/pull/740)
- 加速无效扩展名搜索 - [#740](https://github.com/qarmin/czkawka/pull/740)
- 支持查找最小文件 - [#741](https://github.com/qarmin/czkawka/pull/741)
- 改进 Windows CI - [#749](https://github.com/qarmin/czkawka/pull/749)
- 新增按类型检查损坏文件的功能 - [#749](https://github.com/qarmin/czkawka/pull/749)
- 新增 heif 和 Webp 文件支持 - [#750](https://github.com/qarmin/czkawka/pull/750)
- 在 CLI 中使用 Clap 库代替 StructOpt - [#759](https://github.com/qarmin/czkawka/pull/759)
- 多个目录可以通过手动添加按钮添加 - [#782](https://github.com/qarmin/czkawka/pull/782)
- 在 GUI(Linux) 中新增排除来自其他文件系统的文件选项 - [#776](https://github.com/qarmin/czkawka/pull/776)

## Version 4.1.0 - 24.04.2022r

- 新模式 - 查找内容与扩展名不匹配的文件 - [#678](https://github.com/qarmin/czkawka/pull/678)
- 内置图标 - 不再使用无效的、依赖主题/OS 的图标 - [#659](https://github.com/qarmin/czkawka/pull/659)
- 显示图像预览的速度大幅提升（通常为 2 倍，包括扫描和比较窗口中的预览） - [#660](https://github.com/qarmin/czkawka/pull/660)
- 修复通过自定义选择弹出窗口选择记录的问题 - [#632](https://github.com/qarmin/czkawka/pull/632)
- 比较音乐文件时支持更多标签 - [#590](https://github.com/qarmin/czkawka/pull/590)
- 修复选择路径不正确的问题 - [#656](https://github.com/qarmin/czkawka/pull/656)
- Windows 上扫描相似视频时不再出现弹出窗口 - [#656](https://github.com/qarmin/czkawka/pull/656) - 外部更改 [4056](https://github.com/Farmadupe/ffmpeg_cmdline_utils/commit/405687514f9d9e8984cbe2547c53e85b71e08b27)
- 自定义选择现在默认不区分大小写 - [#657](https://github.com/qarmin/czkawka/pull/657)
- 更好的标签近似比较 - [#641](https://github.com/qarmin/czkawka/pull/641)
- 修复由于累积停止事件导致的搜索问题 - [#623](https://github.com/qarmin/czkawka/pull/623)
- Unix OS 中新增忽略其他文件系统的选项（目前仅在 CLI 中） - [#673](https://github.com/qarmin/czkawka/pull/673)
- 修复 Windows 上的文件硬链接问题 - [#668](https://github.com/qarmin/czkawka/pull/668)
- 支持文件的不区分大小写名称分组 - [#669](https://github.com/qarmin/czkawka/pull/669)
- 搜索的目录可以通过 CLI 传递到 GUI - [#677](https://github.com/qarmin/czkawka/pull/677)
- 防止从显示服务器获取应用程序无响应通知 - [#625](https://github.com/qarmin/czkawka/pull/625)

## Version 4.0.0 - 20.01.2022r

- 收集要检查的文件的多线程支持（4 线程处理器和 SSD 上速度提升 2/3 倍） - [#502](https://github.com/qarmin/czkawka/pull/502), [#504](https://github.com/qarmin/czkawka/pull/504)
- 新增多个翻译 - 波兰语、意大利语、法语、德语、俄语 ... - [#469](https://github.com/qarmin/czkawka/pull/469), [#508](https://github.com/qarmin/czkawka/pull/508), [5be](https://github.com/qarmin/czkawka/commit/5be801e76395855f07ab1da43cdbb8bd0b843834)
- 新增查找相似视频的支持 - [#460](https://github.com/qarmin/czkawka/pull/460)
- GUI 代码重构和搜索代码统一 - [#462](https://github.com/qarmin/czkawka/pull/462), [#531](https://github.com/qarmin/czkawka/pull/531)
- 修复尝试硬链接/符号链接 0 个文件时的崩溃 - [#462](https://github.com/qarmin/czkawka/pull/462)
- GTK 4 兼容性改进，为未来的工具包更改做准备 - [#467](https://github.com/qarmin/czkawka/pull/467), [#468](https://github.com/qarmin/czkawka/pull/468), [#473](https://github.com/qarmin/czkawka/pull/473), [#474](https://github.com/qarmin/czkawka/pull/474), [#503](https://github.com/qarmin/czkawka/pull/503), [#505](https://github.com/qarmin/czkawka/pull/505)
- 将最低支持 OS 更改为 Ubuntu 20.04（GTK 所需） - [#468](https://github.com/qarmin/czkawka/pull/468)
- 通过避免创建不必要的图像预览来提高性能 - [#468](https://github.com/qarmin/czkawka/pull/468)
- 由于缓存损坏/不支持图像/视频的哈希，性能得到提升 = [#471](https://github.com/qarmin/czkawka/pull/471)
- 新增不从不存在的文件移除缓存的选项（例如从拔出的 U 盘） - [#472](https://github.com/qarmin/czkawka/pull/472)
- 新增多个带有有用消息的工具提示 - [#472](https://github.com/qarmin/czkawka/pull/472)
- 新增缓存预哈希功能 - [#477](https://github.com/qarmin/czkawka/pull/477)
- 改进记录的自定义选择（允许使用 Rust 正则表达式） - [#489](https://github.com/qarmin/czkawka/pull/478)
- 移除查找零填充文件的支持 - [#461](https://github.com/qarmin/czkawka/pull/461)
- 移除 HashMB 模式 - [#476](https://github.com/qarmin/czkawka/pull/476)
- 音乐的近似比较 - [#483](https://github.com/qarmin/czkawka/pull/483)
- 为简单 treeview 启用列排序 - [#487](https://github.com/qarmin/czkawka/pull/487)
- 新增隐藏上方面板的功能 - [#491](https://github.com/qarmin/czkawka/pull/491)
- 使 UI 占用更少空间 - [#500](https://github.com/qarmin/czkawka/pull/500)
- 新增对 raw 图像（NEF, CR2, KDC...）的支持 - [#532](https://github.com/qarmin/czkawka/pull/532)
- 图像比较性能和可用性改进 - [#529](https://github.com/qarmin/czkawka/pull/529), [#528](https://github.com/qarmin/czkawka/pull/528), [#530](https://github.com/qarmin/czkawka/pull/530), [#525](https://github.com/qarmin/czkawka/pull/525)
- 重新组织（统一）从文件保存/加载数据 - [#524](https://github.com/qarmin/czkawka/pull/524)
- 新增“引用文件夹” - [#516](https://github.com/qarmin/czkawka/pull/516)
- 新增相似音乐文件的缓存 - [#558](https://github.com/qarmin/czkawka/pull/558)

## Version 3.3.1 - 22.11.2021r

- 修复移动按钮时的崩溃 [#457](https://github.com/qarmin/czkawka/pull/457)
- 开始时隐藏移动按钮 [c9ca230](https://github.com/qarmin/czkawka/commit/c9ca230dfd05e2166b2d68683b091cfd45037edd)

## Version 3.3.0 - 20.11.2021r

- 按空格键选择文件 [#415](https://github.com/qarmin/czkawka/pull/415)
- 向打印的错误添加更多信息 [#446](https://github.com/qarmin/czkawka/pull/446)
- 新增相似图像工具中支持多个图像筛选器、哈希和大小 [#447](https://github.com/qarmin/czkawka/pull/447), [#448](https://github.com/qarmin/czkawka/pull/448)
- 将文件/文件夹移动到提供位置的按钮 [#449](https://github.com/qarmin/czkawka/pull/449)
- 添加不可点击的按钮以修复白色主题 [#450](https://github.com/qarmin/czkawka/pull/450)
- 修复在同一线程中打开文件/文件夹时的冻结 [#448](https://github.com/qarmin/czkawka/pull/448)
- 用于检查不同图像筛选器、哈希类型和大小性能的工具 [#447](https://github.com/qarmin/czkawka/pull/447)
- 添加定时 CI 并将其固定以支持 Rust 1.53.0 [7bb](https://github.com/qarmin/czkawka/commit/7bbdf742739a513b80d0cc06ba61dfafec976b23), [#431](https://github.com/qarmin/czkawka/pull/431)
- 更新 snap 文件以使用内置 Rust 插件并更新 GNOME 扩展 [8f2](https://github.com/qarmin/czkawka/commit/8f232285e5c34bee6d5da8e1453d7f40a0ffd08d)
- 禁用在相似图像中检查 `webp`、`gif`、`bmp`、`ico` 扩展名，因为这些导致了崩溃 [#445](https://github.com/qarmin/czkawka/pull/446), [49e](https://github.com/qarmin/czkawka/commit/49effca169adb57b33f666757966d43b244319cc)

## Version 3.2.0 - 07.08.2021r

- 使用复选框而不是选择来选择文件 [#392](https://github.com/qarmin/czkawka/pull/392)
- 在 Windows 上重新启用硬链接 - [#410](https://github.com/qarmin/czkawka/pull/410)
- 修复符号链接和硬链接创建 - [#409](https://github.com/qarmin/czkawka/pull/409)
- 为重复查找器添加图像预览 [#408](https://github.com/qarmin/czkawka/pull/408)
- 新增设置最大文件大小 [#407](https://github.com/qarmin/czkawka/pull/407)
- 为相似图像添加新的分组算法 [#405](https://github.com/qarmin/czkawka/pull/405)
- 更新到 Rust 1.54 [#400](https://github.com/qarmin/czkawka/pull/400)
- 为相似图像添加 webp 支持 [#396](https://github.com/qarmin/czkawka/pull/396)
- 使用 GtkScale 而不是单选按钮来设置相似度 [#397](https://github.com/qarmin/czkawka/pull/397)
- 更新所有依赖 [#405](https://github.com/qarmin/czkawka/pull/405), [#395](https://github.com/qarmin/czkawka/pull/395)
- 将 UI 拆分为多个文件 [#391](https://github.com/qarmin/czkawka/pull/391)
- 更新到 gtk-rs 0.14 [#383](https://github.com/qarmin/czkawka/pull/383)
- 修复移动窗口时的 Bug [#361](https://github.com/qarmin/czkawka/pull/361)
- 生成最小 Appimage [#339](https://github.com/qarmin/czkawka/pull/339)

## Version 3.1.0 - 09.05.2021r

- 清理 README，将说明移到不同的文件 - [9aea6e9b](https://github.com/qarmin/czkawka/commit/9aea6e9b1ef5ac1e56ccd008e7456b80401179d0)
- 修复 Windows 上的排除项目 - [#324](https://github.com/qarmin/czkawka/pull/324)
- 居中窗口并添加缺失的设置图标 - [#323](https://github.com/qarmin/czkawka/pull/323)
- 排序缓存 - [#322](https://github.com/qarmin/czkawka/pull/322)
- 添加 Snap 的桌面文件 - [018d5bebb](https://github.com/qarmin/czkawka/commit/018d5bebb0b297ba35529b03b8e2e68eb0a9b474), [ade2a756e2](https://github.com/qarmin/czkawka/commit/ade2a756e29c5ce5739d6268fcab7e76f59ed5f6)
- 自定义缓存记录的最小文件大小 - [#321](https://github.com/qarmin/czkawka/pull/321)
- 更新基准测试 - [2044b9185](https://github.com/qarmin/czkawka/commit/2044b91852fea89dfaf10dc1ab79c1d00e9e0c12)
- 重新排列说明 - [8e7ac4a2d7f5b0](https://github.com/qarmin/czkawka/commit/8e7ac4a2d7f5b0beba2552581fb3a0d19c2efeb5)
- 添加 Czkawka 和 Bleachbit 不是彼此替代品的信息 - [30602a486](https://github.com/qarmin/czkawka/commit/30602a486f6ade6f9b7b91a73708225b4f4c2a7d)
- 修复消息队列过小时的崩溃 - [#316](https://github.com/qarmin/czkawka/pull/316)
- 修复结果略微未排序的问题 - [#304](https://github.com/qarmin/czkawka/pull/304)
- 修复 Appimage（外部 Bug） - [#299](https://github.com/qarmin/czkawka/issues/299)
- 修复保存名称重复结果时的错误 - [#307](https://github.com/qarmin/czkawka/pull/307)
- 更新到 Rust 1.5.1 - [#302](https://github.com/qarmin/czkawka/pull/302)

## Version 3.0.0 - 11.03.2021r

- 新增不忽略硬链接的选项 - [#273](https://github.com/qarmin/czkawka/pull/273)
- GUI 的硬链接支持 - [#276](https://github.com/qarmin/czkawka/pull/276)
- 新的设置窗口 - [#262](https://github.com/qarmin/czkawka/pull/262)
- 统一文件移除 - [#278](https://github.com/qarmin/czkawka/pull/278)
- 重复 CLI 中的试运行 - [#277](https://github.com/qarmin/czkawka/pull/277)
- 新增关闭缓存的选项 - [#263](https://github.com/qarmin/czkawka/pull/263)
- 更新 Image 依赖并修复崩溃 - [#270](https://github.com/qarmin/czkawka/pull/270), [e3aca69](https://github.com/qarmin/czkawka/commit/e3aca69499966499413e4b7cd4d1037bec6a5d68)
- 尝试移除组中所有文件时新增确认对话框 - [#281](https://github.com/qarmin/czkawka/pull/281)
- 按删除键移除文件时新增确认对话框 - [#282](https://github.com/qarmin/czkawka/pull/282)
- 点击 Enter 键时打开文件 - [#285](https://github.com/qarmin/czkawka/pull/285)
- 允许将文件放入垃圾桶而不是完全移除它们 - [#284](https://github.com/qarmin/czkawka/pull/284)

## Version 2.4.0 - 22.02.2021r

- 新增关于对话框 - [#226](https://github.com/qarmin/czkawka/pull/226)
- 移除相似图像中对 ico 的检查 - [#227](https://github.com/qarmin/czkawka/pull/227)
- 将进度对话框更改为进度窗口 - [#229](https://github.com/qarmin/czkawka/pull/229)
- 恢复 Snap 限制 - [#218](https://github.com/qarmin/czkawka/pull/218), [8dcb718](https://github.com/qarmin/czkawka/commit/8dcb7188434e1c1728368642e17ccec29a4b372d)
- 新增对 CRC32 和 XXH3 哈希的支持 - [#243](https://github.com/qarmin/czkawka/pull/243)
- 新增将重复文件替换为硬链接的删除方法 - [#236](https://github.com/qarmin/czkawka/pull/236)
- 新增对损坏音乐的选择性检查 - [#249](https://github.com/qarmin/czkawka/pull/249)
- 允许将相似图像结果保存到文件 - [10156ccfd3](https://github.com/qarmin/czkawka/commit/10156ccfd3ba880d26d4bbad1e025b0050d7753b)
- 如果替换重复文件为硬链接失败，则保留原始文件 - [#256](https://github.com/qarmin/czkawka/pull/256)
- 修复 Windows 主题 - [#265](https://github.com/qarmin/czkawka/pull/265)
- Windows 任务栏进度支持 - [#264](https://github.com/qarmin/czkawka/pull/264)
- 如果重复文件是硬链接，则忽略它们 - [#234](https://github.com/qarmin/czkawka/pull/234)
- 在 CLI 中支持哈希类型参数 - [#267](https://github.com/qarmin/czkawka/pull/267)
- 为所有哈希计算使用一个实现 - [#268](https://github.com/qarmin/czkawka/pull/268)
- 暂时禁用已损坏的 tga 和 gif 文件 - [#270](https://github.com/qarmin/czkawka/pull/270)

## Version 2.3.2 - 21.01.2021r

- 新增使用键盘移动选择以更新相似图像预览 [#223](https://github.com/qarmin/czkawka/pull/223)

此版本仅用于测试 flatpak 构建

## Version 2.3.1 - 20.01.2021r

- 新增 flatpak 支持 - [#203](https://github.com/qarmin/czkawka/pull/203)
- 拼写修复 - [#222](https://github.com/qarmin/czkawka/pull/222), [#219](https://github.com/qarmin/czkawka/pull/219)

## Version 2.3.0 - 15.01.2021r

- 新增重复查找器的缓存 - [#205](https://github.com/qarmin/czkawka/pull/205)
- 新增损坏文件的缓存 - [#204](https://github.com/qarmin/czkawka/pull/204)
- 减少 RAM 使用 - [#212](https://github.com/qarmin/czkawka/pull/212)
- 新增查找损坏的 zip 和音频文件的支持 - [#210](https://github.com/qarmin/czkawka/pull/210)
- 按路径对结果排序，在可能的情况下 - [#211](https://github.com/qarmin/czkawka/pull/211)
- 新增无效符号链接的缺少 popover 信息 - [#209](https://github.com/qarmin/czkawka/pull/209)
- 在 Linux 和 Mac CI 中使用最旧可用的操作系统，在 Windows 上使用最新 - [#206](https://github.com/qarmin/czkawka/pull/206)
- 新增损坏文件支持 - [#202](https://github.com/qarmin/czkawka/pull/202)
- 移除保存变通方法并修复加载/保存缓存时的崩溃 - [#200](https://github.com/qarmin/czkawka/pull/200)
- 修复通过 X 关闭进度对话框时的错误 - [#199](https://github.com/qarmin/czkawka/pull/199)

## Version 2.2.0 - 11.01.2021r

- 新增 Mac GUI - [#160](https://github.com/qarmin/czkawka/pull/160)
- 重新使用 master gtk 插件 - [#179](https://github.com/qarmin/czkawka/pull/179)
- 仅在选中 1 个图像时显示预览 - [#183](https://github.com/qarmin/czkawka/pull/183)
- 新增缓冲写入/读取 - [#186](https://github.com/qarmin/czkawka/pull/186)
- 修复包含逗号的包含/排除文件 - [#195](https://github.com/qarmin/czkawka/pull/195)
- 将图像缓存移动到配置目录中的缓存 - [#197](https://github.com/qarmin/czkawka/pull/197)
- 重新组织 GUI 代码（无可见变化） - [#184](https://github.com/qarmin/czkawka/pull/184), [#184](https://github.com/qarmin/czkawka/pull/184), [#189](https://github.com/qarmin/czkawka/pull/189), [#190](https://github.com/qarmin/czkawka/pull/190), [#194](https://github.com/qarmin/czkawka/pull/194)

## Version 2.1.0 - 31.12.2020r

- 隐藏删除图像或符号链接时的预览 - [#167](https://github.com/qarmin/czkawka/pull/167)
- 新增手动添加目录 - [#165](https://github.com/qarmin/czkawka/pull/165), [#168](https://github.com/qarmin/czkawka/pull/168)
- 新增可调整大小的顶部面板 - [#164](https://github.com/qarmin/czkawka/pull/164)
- 新增删除按钮的支持 - [#159](https://github.com/qarmin/czkawka/pull/159)
- 允许在文件选择器中选择多个条目 - [#154](https://github.com/qarmin/czkawka/pull/154)
- 新增相似图像的缓存支持 - [#139](https://github.com/qarmin/czkawka/pull/139)
- 新增按大小选择图像 - [#138](https://github.com/qarmin/czkawka/pull/138)
- 现代化 popovers 代码并简化后续更改 - [#137](https://github.com/qarmin/czkawka/pull/137)

## Version 2.0.0 - 23.12.2020r

- 新增 Snap 支持 - [ee3d4](https://github.com/qarmin/czkawka/commit/ee3d450552cd0c37a114b05c557ff9381ef92466)
- 默认选择较长名称 - [#113](https://github.com/qarmin/czkawka/pull/113)
- 新增删除确认对话框的设置 - [#114](https://github.com/qarmin/czkawka/pull/114)
- 新增隐藏/显示文本视图错误的按钮 - [#115](https://github.com/qarmin/czkawka/pull/115)
- 移除 Windows 中的控制台窗口 - [#116](https://github.com/qarmin/czkawka/pull/116)
- 新增自定义选择/取消选择 - [#117](https://github.com/qarmin/czkawka/pull/117)
- 为相似图像新增图像预览 - [#118](https://github.com/qarmin/czkawka/pull/118)
- 移除 orbtk 前端 - [#119](https://github.com/qarmin/czkawka/pull/119)
- 更新图标 - [#120](https://github.com/qarmin/czkawka/pull/120)
- 新增设置按钮以启用/禁用预览（默认启用） - [#121](https://github.com/qarmin/czkawka/pull/121)
- 新增在设置中启用/禁用文本视图错误的按钮 - [#122](https://github.com/qarmin/czkawka/pull/122)
- 新增对符号链接的支持 - [#123](https://github.com/qarmin/czkawka/pull/123)
- 新增对检查无效符号链接的支持 - [#124](https://github.com/qarmin/czkawka/pull/124)
- 新增新的 Windows 深色主题 - [#125](https://github.com/qarmin/czkawka/pull/125)
- 修复 Appimage 崩溃，通过添加 PNG 版本的图标 - [#126](https://github.com/qarmin/czkawka/pull/126)
- 将符号链接路径拆分为两个路径和文件名 - [#127](https://github.com/qarmin/czkawka/pull/127)
- 新增通过双击右键打开文件夹的选项 - [#128](https://github.com/qarmin/czkawka/pull/128)
- 新增最小相似度级别 - [#129](https://github.com/qarmin/czkawka/pull/129)
- 当图像预览生成失败时显示错误 - [#130](https://github.com/qarmin/czkawka/pull/130)
- 添加说明 - [58e6221a](https://github.com/qarmin/czkawka/commit/58e6221a0e02d17d07c71152f56b948f616751a8), [598aec345e](https://github.com/qarmin/czkawka/commit/598aec345e9f5ac199fc3d642c0699d5228100a6), [afaa402b](https://github.com/qarmin/czkawka/commit/afaa402b31526aa8e6b47f3670bc62b26ad9f60f)

## Version 1.5.1 - 08.12.2020r

- 修复由除以 0 导致的进度条错误 - [#109](https://github.com/qarmin/czkawka/pull/109)
- 新增保存文件、存储设置并加载它们的选项 - [#108](https://github.com/qarmin/czkawka/pull/108)
- 将对话框居中到当前窗口 - [a04](https://github.com/qarmin/czkawka/commit/a047380dbe8aa4d04f9c482364469e21d231fab2)

## Version 1.5.0 - 02.12.2020r

- 新增进度条 - [#106](https://github.com/qarmin/czkawka/pull/106)
- 移除未使用的按钮 - [#107](https://github.com/qarmin/czkawka/pull/107)

## Version 1.4.0 - 09.11.2020r

- 大多数模块的多线程支持 - [#98](https://github.com/qarmin/czkawka/pull/98) [#99](https://github.com/qarmin/czkawka/pull/99) [#100](https://github.com/qarmin/czkawka/pull/100) [#101](https://github.com/qarmin/czkawka/pull/101)
- 简化 GUI 代码 [#96](https://github.com/qarmin/czkawka/pull/96)
- 对相似图像进行分组 - [#97](https://github.com/qarmin/czkawka/pull/97)
- 为每种模式添加选择按钮 - [#102](https://github.com/qarmin/czkawka/pull/102)
- 修复 GUI 在删除相似图像时的行为 - [#103](https://github.com/qarmin/czkawka/pull/103)
- 新增相似度级别 - [#104](https://github.com/qarmin/czkawka/pull/104)

## Version 1.3.0 - 02.11.2020r

- Appimage 支持 - [#77](https://github.com/qarmin/czkawka/pull/77)
- 移除关于不存在的排除目录的警告 - [#79](https://github.com/qarmin/czkawka/pull/79)
- 更新 README - [8ec](https://github.com/qarmin/czkawka/commit/8ecde0fc9adb3e6cedf432c4ba749e698b645a7a)
- 新增预哈希支持（加速查找大型重复文件） - [#83](https://github.com/qarmin/czkawka/pull/83)
- 新增按文件名查找重复文件的支持 - [#84](https://github.com/qarmin/czkawka/pull/84)
- 新增对检查零填充文件的支持 - [#88](https://github.com/qarmin/czkawka/pull/88)
- 重构 GUI 代码以实现更快、更安全的更改/添加代码 - [#89](https://github.com/qarmin/czkawka/pull/89)
- 在某些模式中为 CLI 添加缺失的选项 - [#90](https://github.com/qarmin/czkawka/pull/90)
- 实现按音乐标签查找重复文件 - [#95](https://github.com/qarmin/czkawka/pull/95)

## Version 1.2.1 - 17.10.2020r

- 显著加快图像相似性搜索。[#72](https://github.com/qarmin/czkawka/pull/72)
- 稍微改进相似图像 GUI 并为 Similarity 枚举添加排序 [#73](https://github.com/qarmin/czkawka/pull/73)
- 改进类似文件的 GUI 中的文件删除 [#75](https://github.com/qarmin/czkawka/pull/75)

## Version 1.2.0 - 15.10.2020r

- 将 String 替换为 PathBuf 用于路径 [#59](https://github.com/qarmin/czkawka/pull/59)
- 向 PR 添加测试套件 [#65](https://github.com/qarmin/czkawka/pull/65)
- 为 CLI 添加查找相似图像的支持 [#66](https://github.com/qarmin/czkawka/pull/66)
- 修复语法相关的错误和 Ponglish 表达式 [#62](https://github.com/qarmin/czkawka/pull/62), [#63](https://github.com/qarmin/czkawka/pull/63)
- CLI 中的重复查找器不默认删除文件 - [23f203](https://github.com/qarmin/czkawka/commit/23f203a061e254275c95ca23ca4f1a78bd941f02)
- 为 GUI 添加查找相似图像的支持 [#69](https://github.com/qarmin/czkawka/pull/69)
- 新增从 GUI 通过双击打开文件/文件夹的支持 [#70](https://github.com/qarmin/czkawka/pull/70)

## Version 1.1.0 - 10.10.2020r

- Windows 支持 [#58](https://github.com/qarmin/czkawka/pull/58)
- 改进代码质量/简化代码库 [#52](https://github.com/qarmin/czkawka/pull/52)
- 修复在特定情况下跳过某些正确结果 [#52](https://github.com/qarmin/czkawka/pull/52#discussion_r502613895)
- 新增在其他线程中搜索的支持 [#51](https://github.com/qarmin/czkawka/pull/51)
- 将 CI 拆分为多个文件 [#48](https://github.com/qarmin/czkawka/pull/48)
- 新增从 GUI 停止任务的功能 [#55](https://github.com/qarmin/czkawka/pull/55)
- 修复从 GUI 中移除仅包含空目录的目录的问题 [#57](https://github.com/qarmin/czkawka/pull/57)

## Version 1.0.1 - 06.10.2020r

- 用 StructOpt 替换默认参数解析器 [#37](https://github.com/qarmin/czkawka/pull/37)
- 将所有（除 macOS GTK 构建外）构建添加到 CI，可在其中免费下载 [#41](https://github.com/qarmin/czkawka/pull/41) [#39](https://github.com/qarmin/czkawka/pull/39)
- 应用程序也可从 Arch AUR 和 Cargo 下载 [#36](https://github.com/qarmin/czkawka/pull/36)
- 修复无效文件修改日期导致的崩溃 [#33](https://github.com/qarmin/czkawka/issues/33)
- 当需要时，上部选项卡可以隐藏和显示 [#38](https://github.com/qarmin/czkawka/pull/38)
- 修复文件/文件夹名称包含非 Unicode 字符时的崩溃 [#44](https://github.com/qarmin/czkawka/issues/44)
- 为 GUI 添加查找相似图片的支持 [#69](https://github.com/qarmin/czkawka/issues/69)

## Version 1.0.0 - 02.10.2020r

- 为删除按钮添加确认对话框
- 更新 Readme
- 大量测试了应用，我认为版本 1.0.0 可以自由发布

## Version 0.1.4 - 01.10.2020r

- 修复 -f 默认参数
- 为 GUI 添加保存按钮
- 稍微清理了一些代码
- GUI 中删除文件和文件夹
- GUI 中支持所有笔记本项
- GUI 中支持添加和删除搜索及排除的目录
- GUI 中支持浅色主题
- 将 SystemTime 更改为从 EPOCH_TIME 的 u64
- GUI 中重复查找器的行选择性选择
- 将 GTK 最低版本更改为 3.22
- 为 GUI 添加保存系统
- 为 GUI 添加大文件、临时文件和空文件夹查找器

## Version 0.1.3 - 27.09.2020r

- 大规模代码重构 - 现在创建新模块和维护旧模块容易得多
- 新增查找空文件的功能
- 新增通过检查最多 1MB 文件哈希来查找重复文件的新选项
- 新增查找临时文件夹的支持
- 改进 README
- 简化 CLI 帮助并改进它

## Version 0.1.2 - 26.09.2020r

- 在 GTK GUI 中添加基本空文件夹搜索
- 记住按钮放置的位置
- 从 GUI 读取和解析更多值
- 将错误/警告/消息打印到 GUI 中的文本字段
- 向 GUI 中的上部笔记本添加包含、排除的目录、项目和扩展名
- 稍微改进 GUI
- 新增打印版本的参数，例如 `czkawka_gui --version`
- GUI 中的简单空文件夹支持
- CLI 中的最大文件支持

## Version 0.1.1 - 20.09.2020r

- 向 readme 添加图像
- 更好的 GTK 按钮和 glade 文件
- GTK 中的基本搜索
- 从 core 中清理 println
- Core 函数不再使用 process::exit（所有操作均通过消息/错误/警告完成）
- 新增非递归搜索支持
- 改进重复文件的数量和大小查找
- 将结果保存到文件
- 打印重复查找器读取的数据量（仅调试）
- 新增 GitHub CI
- 仅调试构建打印调试信息
- 清理代码
- 向 misc 文件夹添加基本想法配置

## Version 0.1.0 - 07.09.2020r

- 初始版本
- 重复文件查找器
- 空文件夹查找器
- 非常 WIP 的 Orbtk GUI 前端
- 基本 GTK 前端（没有任何逻辑）
- CLI

## 初始提交 - 26.08.2020r
