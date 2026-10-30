# czkawka_cli - 架构指南

## 概览

`czkawka_cli` 是围绕 `czkawka_core` 的轻量 CLI 封装。它处理参数解析、线程编排、进度渲染和结果输出。所有扫描逻辑都位于 `czkawka_core`；本 crate 仅将其连接到终端。

---

## 源码布局

```
czkawka_cli/src/
├── main.rs       # Entry point, thread spawning, tool dispatchers
├── commands.rs   # All clap CLI argument definitions
├── parsers.rs    # parse_* clap value-parser functions used by commands.rs
└── progress.rs   # indicatif progress bar rendering
```

---

## 执行模型

```
main()
 ├─ Parse args (clap)
 ├─ Create crossbeam channel  (Sender<ProgressData>, Receiver<ProgressData>)
 ├─ Create Arc<AtomicBool> stop_flag
 ├─ spawn calculation_thread → dispatches to one of 14 tool functions
 ├─ Register Ctrl+C handler → sets stop_flag = true
 ├─ connect_progress(&progress_receiver)   [blocks, renders progress bar]
 └─ join calculation_thread → print output → exit(11) if items found
```

**主线程** 渲染进度。**计算线程** 运行扫描。当发送方丢弃（扫描结束）时，`progress_receiver.recv()` 会自然退出。

---

## CLI 子命令

通过 `clap` 派生在 `commands.rs` 中定义。顶级枚举 `Commands` 有 14 个变体：

| 子命令 | 别名 | 用途 |
|--------|------|------|
| `Duplicates` | `dup` | 查找重复文件（哈希/名称/大小） |
| `EmptyFolders` | `empty-folders` | 查找空目录 |
| `BiggestFiles` | `big` | 查找最大或最小的文件 |
| `EmptyFiles` | `empty-files` | 查找零字节文件 |
| `Temporary` | `temp` | 查找临时文件 |
| `SimilarImages` | `image` | 查找相似图像（感知哈希） |
| `SameMusic` | `music` | 查找重复音乐（标签/指纹） |
| `InvalidSymlinks` | `symlinks` | 查找损坏的符号链接 |
| `BrokenFiles` | `broken` | 查找损坏的 PDF/音频/图像/归档 |
| `SimilarVideos` | `video` | 查找相似视频（帧哈希） |
| `BadExtensions` | `ext` | 查找扩展名错误的文件 |
| `BadNames` | `bad-names` | 查找有问题的文件名 |
| `VideoOptimizer` | `video-optimizer` | 转码或裁剪视频 |
| `ExifRemover` | `exif-remover` | 从图像中删除 EXIF 元数据 |

### `CommonCliItems`（每个子命令共用）

- `-d` 目录（必需）
- `-e` 排除的目录
- `-E` 排除的项（glob 模式，例如 `*/.*`）
- `-x` 允许的扩展名（支持宏：`IMAGE`、`VIDEO`、`MUSIC`、`TEXT`）
- `-P` 排除的扩展名
- `-R` 禁用递归搜索
- `-X`（仅 Unix）排除其他文件系统
- `-f` 将文本结果保存到文件
- `-C` 将紧凑 JSON 结果保存到文件
- `--pretty-file-to-save`（`-p`）将美化 JSON 结果保存到文件
- `-N` / `-M` 抑制结果/消息输出
- `-W` 找到项目时抑制非零退出码
- `-T` 线程数（0 = 所有 CPU）
- `-H` 禁用缓存

### 删除方法

**`DMethod`**（相似性分组工具用）：`-D NONE|AEN|AEO|ON|OO|AEB|AES|OB|OS|HARD`
**`SDMethod`**（简单工具用）：`-D` 删除标志，`-Q` 试运行，`-y` 移至废纸篓

---

## 工具分派模式

14 个分派函数都遵循相同的结构：

```rust
fn tool_name(args: ToolArgs, stop_flag: &Arc<AtomicBool>, progress_sender: &Sender<ProgressData>) -> CliOutput {
    // 1. Destructure args
    // 2. Build tool-specific parameter struct
    let mut tool = ToolType::new(params);
    // 3. Apply common settings (paths, extensions, cache, threads)
    set_common_settings(&mut tool, &common_cli_items, reference_directories);
    // 4. Apply tool-specific settings (file sizes, delete method, etc.)
    // 5. Run scan
    tool.search(stop_flag, Some(progress_sender));
    // 6. Optionally run fix (rename/delete/etc.)
    // 7. Collect and return output
    save_and_write_results_to_writer(&tool, &common_cli_items)
}
```

`set_common_settings` 通过 `AllTraits` 约束应用路径、递归、扩展名、缓存标志和线程数。

---

## 进度渲染 (`progress.rs`)

`connect_progress(&progress_receiver)` 在 `progress_receiver.recv()` 上循环，并通过 indicatif 渲染：

- 在收集文件或加载/保存缓存时显示 **Spinner**。
- 一旦已知总条目数或字节数，显示 **Linear bar** `[=>  ]`。

阶段标签（例如 "Calculating hashes"、"Reading tags"）派生自每条 `ProgressData` 消息上的 `CurrentStage` 枚举。

---

## 结果输出

`save_and_write_results_to_writer` 写入三种可选文件格式（文本、紧凑 JSON、美化 JSON），并缓冲 stdout 输出，在线程合并后打印。`CliOutput.found_any_files` 标志驱动退出码：

- 找到项目（且未设置 `-W`）时 `exit(11)` - 在脚本中有用。
- 否则 `exit(0)`。

---

## 取消

`Arc<AtomicBool>`（SeqCst 顺序）在 Ctrl+C 信号处理器和计算线程之间共享。`czkawka_core` 中的工具在扫描期间轮询它，并在其为 `true` 时优雅停止。

---

## 关键依赖

| Crate | 用途 |
|-------|------|
| `clap` 4.5 | CLI 解析（派生 API） |
| `indicatif` 0.18 | 进度条 |
| `crossbeam-channel` | 进度的无界通道 |
| `ctrlc` 3.4 | SIGINT / Ctrl+C 处理 |
| `humansize` 2.1 | 可读性字节大小 |
| `czkawka_core` | 所有扫描逻辑 |

### 可选 feature（转发到 `czkawka_core`）

- `heif` - HEIF/HEIC 图像支持（需要 libheif）
- `libraw` - RAW 图像支持（需要 libraw）
- `libavif` - AVIF 图像支持（需要 libavif）
- `xdg_portal_trash` - FlatPak 兼容的废纸篓（XDG 门户）

---

## 注释

简短、最小 - 参见根 `AGENTS.md`。仅在代码行为无法从阅读中推断时才添加注释（非明显约束、变通方案、跨模块耦合）；永远不要重复代码已表达的内容。
