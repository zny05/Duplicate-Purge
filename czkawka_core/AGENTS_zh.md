# czkawka_core - 架构指南

## 概览

`czkawka_core` 是所有前端共用的扫描引擎。它没有 UI 依赖。所有扫描工具都在此实现；前端只需配置工具结构体，并通过 `Search` trait 驱动它们。

`TOOLS_NUMBER = 14`（定义在 `src/lib.rs` 中）。

---

## 源码布局

```
czkawka_core/src/
├── lib.rs                         # Crate root; TOOLS_NUMBER constant
├── localizer_core.rs              # Fluent i18n loader (flc! macro)
├── common/
│   ├── mod.rs                     # Module declarations + re-exports only (no logic of its own)
│   ├── traits.rs                  # Search, PrintResults, DeletingItems, FixingItems, ResultEntry, AllTraits
│   ├── tool_data.rs               # CommonToolData struct + the CommonData trait (defined here, not traits.rs)
│   ├── model.rs                   # ToolType, CheckingMethod, FileEntry, DeleteMethod
│   ├── progress_data.rs           # ProgressData, CurrentStage enum
│   ├── progress_stop_handler.rs   # ProgressThreadHandler, check_if_stop_received
│   ├── dir_traversal.rs           # DirTraversalBuilder, DirTraversalResult
│   ├── cache.rs                   # Generic load/save cache (bincode + JSON)
│   ├── cache/
│   │   └── cleaning.rs            # Outdated cache cleanup
│   ├── config_cache_path.rs       # Platform config/cache path lookup
│   ├── directories.rs             # Directories struct (included/excluded/reference)
│   ├── extensions.rs              # Extensions struct (allowed/excluded filtering)
│   ├── items.rs                   # ExcludedItems (glob pattern matching)
│   ├── consts.rs                  # Extension lists: IMAGE_RS_EXTENSIONS, …
│   ├── formatting.rs              # format_time and other display formatting helpers
│   ├── path_utils.rs              # split_path, regex_check, normalize_windows_path
│   ├── fs_ops.rs                  # make_hard_link, make_file_symlink, remove_single_file/folder
│   ├── threads.rs                 # get_number_of_threads, set_number_of_threads
│   ├── deletion.rs                # DeleteResult, DeleteItemType
│   ├── audio_fingerprint.rs       # Chromaprint fingerprint calculation (used by same_music)
│   ├── ffmpeg_utils.rs            # FFmpeg invocation helpers
│   ├── video_utils.rs             # Video metadata extraction
│   ├── image.rs                   # Image loading helpers
│   ├── process_utils.rs           # Child-process helpers
│   ├── logger.rs                  # Logging configuration
│   └── basic_gui_cli.rs           # Types shared with GUI/CLI boundaries
├── tools/
│   ├── mod.rs                     # Re-exports all tool modules
│   ├── duplicate/                 # Hash/name/size duplicate detection
│   ├── empty_files/
│   ├── empty_folder/
│   ├── big_file/
│   ├── similar_images/            # Perceptual hashing (image_hasher)
│   ├── similar_videos/            # Frame-based video similarity
│   ├── same_music/                # Audio tag + chromaprint fingerprint
│   ├── broken_files/              # ZIP/PDF/audio/image validation
│   ├── bad_extensions/            # Extension vs magic-number mismatch
│   ├── bad_names/                 # Naming policy checks
│   ├── invalid_symlinks/
│   ├── temporary/
│   ├── exif_remover/
│   └── video_optimizer/           # Crop detection + FFmpeg transcoding
└── helpers/
    ├── messages.rs                # Messages struct (errors, warnings, info)
    ├── delayed_sender.rs          # Rate-limited progress sender
    ├── audio_checker.rs           # Audio file validation
    ├── ffprobe.rs                 # ffprobe JSON output parsing
    └── debug_timer.rs             # Debug-build timing
```

---

## 工具模块布局

每个工具都有自己的目录，通常包含这些文件：

| 文件 | 内容 |
|------|------|
| `mod.rs` | 工具结构体 + `Info` 结构体 + `Parameters` 结构体（如需要） |
| `core.rs` | 内部扫描函数（`check_files_*`、`hash_calculation`，…） |
| `traits.rs` | trait 实现：`Search`、`CommonData`、`DeletingItems`、`PrintResults` |
| `tests.rs` | 工具的单元测试（每个工具都有，除了 `temporary/`） |

少数工具不符合上述 4 文件模式：`bad_extensions/` 增加了 `workarounds.rs`，而 `video_optimizer/` 增加了 `encoding.rs` 及其自己的 `core/` 子目录（`video_converter.rs`、`video_cropper.rs`）。

示例 - `EmptyFiles`:

```
src/tools/empty_files/
├── mod.rs      # pub struct EmptyFiles { common_data, information, files_to_check, params }
│               #   params: EmptyFilesParameters
├── core.rs     # fn check_files() → WorkContinueStatus
├── tests.rs    # Unit tests
└── traits.rs   # impl Search, CommonData, PrintResults, DeletingItems, AllTraits
```

---

## 核心 trait

`CommonData` 是个特例：它定义在 `src/common/tool_data.rs` 中，与 `CommonToolData` 相邻，而不是在 `traits.rs` 中。下面的其他 trait 都位于 `src/common/traits.rs`。签名仅作参考简化 - 两个文件都有比这里显示的更多方法（主要是 setter/getter 对和默认实现辅助函数）。

```rust
pub trait Search {
    fn search(&mut self, stop_flag: &Arc<AtomicBool>,
              progress_sender: Option<&Sender<ProgressData>>);
}

// src/common/tool_data.rs - NOT traits.rs
pub trait CommonData {
    type Info;
    type Parameters;
    fn get_cd(&self) -> &CommonToolData;
    fn get_cd_mut(&mut self) -> &mut CommonToolData;
    fn found_any_items(&self) -> bool;
    // ~30 more setters/getters for directories, extensions, delete method, cache flags, …
}

pub trait PrintResults: CommonData {
    fn write_results<T: Write>(&self, w: &mut T) -> io::Result<()>;
    fn print_results_to_writer<T: Write>(&self, w: &mut T) -> io::Result<()>;
    fn save_results_to_file_as_json(&self, file: &str, pretty: bool) -> io::Result<()>;
    // + write_base_search_paths, print_results_to_output/_to_file, save_all_in_one, …
}

pub trait DeletingItems {
    fn delete_files(&mut self, stop_flag: &Arc<AtomicBool>,
                    progress_sender: Option<&Sender<ProgressData>>) -> WorkContinueStatus;
}

pub trait FixingItems {
    type FixParams;
    fn fix_items(&mut self, stop_flag: &Arc<AtomicBool>,
                 progress_sender: Option<&Sender<ProgressData>>, fix_params: Self::FixParams);
}

pub trait ResultEntry {
    fn get_path(&self) -> &Path;
    fn get_modified_date(&self) -> u64;
    fn get_size(&self) -> u64;
}

pub trait AllTraits: DebugPrint + PrintResults + DeletingItems + CommonData + Search {}
```

---

## CommonToolData (`src/common/tool_data.rs`)

```rust
pub struct CommonToolData {
    pub(crate) tool_type: ToolType,
    pub(crate) text_messages: Messages,        // Accumulated warnings / errors
    pub(crate) directories: Directories,       // Included / excluded / reference paths
    pub(crate) extensions: Extensions,         // Allowed / excluded extensions
    pub(crate) excluded_items: ExcludedItems,  // Glob patterns (e.g. "*/.*")
    pub(crate) recursive_search: bool,
    pub(crate) delete_method: DeleteMethod,
    pub(crate) maximal_file_size: u64,
    pub(crate) minimal_file_size: u64,
    pub(crate) stopped_search: bool,
    pub(crate) use_cache: bool,
    pub(crate) delete_outdated_cache: bool,
    pub(crate) save_also_as_json: bool,
    pub(crate) use_reference_folders: bool,
    pub(crate) dry_run: bool,
    pub(crate) move_to_trash: bool,
    pub(crate) hide_hard_links: bool,
}
```

---

## DirTraversal (`src/common/dir_traversal.rs`)

Builder-pattern 文件系统遍历，所有工具均使用：

```rust
let result = DirTraversalBuilder::new()
    .common_data(&self.common_data)
    .group_by(|fe: &FileEntry| fe.size)   // Groups entries by this key
    .stop_flag(stop_flag)
    .progress_sender(progress_sender)
    .checking_method(CheckingMethod::Size)
    .build()
    .run();

match result {
    DirTraversalResult::SuccessFiles { grouped_file_entries, warnings } => { … }
    DirTraversalResult::Stopped => return WorkContinueStatus::Stop,
}
```

**内部实现：**
- Rayon `into_par_iter().with_max_len(2)` 用于并行文件夹处理。
- 两阶段：先访问根目录和文件，然后逐批递归。
- 遍历期间应用扩展名、排除项和大小过滤器。
- 在 Unix 上：可选的文件系统边界检查（`exclude_other_filesystems`）。
- 通过 `ProgressThreadHandler` 跟踪进度（专用线程，200 ms 间隔）。

---

## 进度报告 (`src/common/progress_data.rs` + `src/common/progress_stop_handler.rs`)

`ProgressData`/`ToolStage` 定义在 `progress_data.rs` 中；`ProgressThreadHandler` 和
`check_if_stop_received` 位于 `progress_stop_handler.rs` 中。

```rust
pub struct ProgressData {
    pub stage: ToolStage,           // Current operation
    pub entries_checked: usize,
    pub entries_to_check: usize,
    pub bytes_checked: u64,
    pub bytes_to_check: u64,
}
```

`ToolStage` 是嵌套枚举（`ToolStage::Duplicate(DuplicateStage)`、`ToolStage::SimilarImages(SimilarImagesStage)`，…），因此一个阶段不能与不属于它的工具配对 - 这取代了旧的扁平 `CurrentStage` 枚举及其运行时 `ProgressData::validate()` 断言。调用 `progress.to_display()` 即可获取完全翻译、可直接渲染的 `ProgressDisplay`（标签 + 百分比），而不是在前端代码中按阶段分支。

`ProgressThreadHandler` 会生成一个后台线程，每隔约 200 ms 轮询 `AtomicUsize`/`AtomicU64` 计数器，并将 `ProgressData` 发送到前端通道。

从 rayon 任务中调用 `handler.increase_items(n)` / `handler.increase_size(n)`（使用 `Relaxed` 顺序 - 快速，无同步开销）。

---

## 取消

```rust
// In hot paths:
if check_if_stop_received(stop_flag) {
    return WorkContinueStatus::Stop;  // or break / return None in rayon
}
```

`stop_flag` 是带 `Relaxed` 顺序的 `Arc<AtomicBool>` - 对于简单的“应该停止吗？”轮询已足够，无同步开销。前端将其设为 `true`；后端轮询并优雅停止。

---

## 缓存 (`src/common/cache.rs`)

```rust
// Save
save_cache_to_file_generalized::<T>(
    cache_file_name,    // e.g. "cache_duplicates.bin"
    &btree_map,         // BTreeMap<String, T> (String = canonical path)
    save_also_as_json,
    minimum_file_size,
);

// Load
let (messages, opt_cache) =
    load_cache_from_file_generalized_by_path::<T>(
        cache_file_name,
        delete_outdated_cache,
        &used_files,    // Current BTreeMap to validate against
    );
```

- 用 `bincode` 序列化（二进制）。可选也导出为 `.json`。
- 加载时按路径 + 大小 + mtime 验证缓存条目。
- 序列化内存限制为 8 GB。
- 每个工具都有自己的版本常量（`CACHE_DUPLICATE_VERSION`，…）。

---

## Rayon 用法模式

```rust
// Directory traversal
folders.into_par_iter().with_max_len(2).map(|dir| { … }).while_some().collect();

// Deletion with early exit
items.into_par_iter().map(|e| {
    if check_if_stop_received(stop_flag) { return None; }
    // … process e …
    Some(result)
}).while_some().flatten().collect()
```

线程数通过 `set_number_of_threads(n)` 全局控制，它将值存储到 `LazyLock<Mutex<Option<usize>>>`，并通过 rayon 的线程池应用。

---

## ToolType 枚举 (`src/common/model.rs`)

```rust
pub enum ToolType {
    Duplicate, EmptyFolders, EmptyFiles, InvalidSymlinks,
    BrokenFiles, BadExtensions, BadNames, BigFile, SameMusic,
    SimilarImages, SimilarVideos, TemporaryFiles, ExifRemover,
    VideoOptimizer,
    #[default]
    None,
}
```

支持参考目录的工具：`Duplicate`、`SameMusic`、`SimilarImages`、`SimilarVideos`（`may_use_reference_paths()`）。

---

## 关键依赖

| Crate | 用途 |
|-------|------|
| `rayon` | 并行迭代器 |
| `crossbeam-channel` | 进度通道 |
| `blake3` | 快速文件哈希 |
| `image` + `image_hasher` | 图像加载 + 感知哈希 |
| `lofty` | 音频标签读取 |
| `symphonia` | 音频解码 |
| `rusty-chromaprint` | 音频指纹 |
| `bincode` | 缓存序列化 |
| `zip` | ZIP 验证 |
| `i18n-embed` + `rust-embed` | Fluent 翻译 |
| `trash` | 移至废纸篓 |
| `directories-next` | 配置/缓存路径 |
| `fun_time` | `#[fun_time]` 计时属性 |
| `similario_core` | 视频相似性（同路径依赖；取代了 `vid_dup_finder_lib`） |

可选（在 feature 后面）：
- `heif` -> `libheif-rs` - HEIC/HEIF 图像支持
- `libraw` -> `rawler` / `libraw-rs` - RAW 照片支持
- `libavif` - AVIF 图像支持
- `xdg_portal_trash` - 通过 XDG 门户的 FlatPak 废纸篓
- `blake_pure` -> `blake3/pure` - 纯 Rust Blake3（无 SIMD 汇编），用于 asm 后端无法构建的目标

---

## 注释

简短、最小，与工作区其余部分相同的基线（根 `AGENTS.md`）。这个工作区中的一个例外是：`czkawka_core` 是每个前端都依赖的库，外部消费者通常只阅读其 `pub fn`/`pub struct` 公共表面，而非内部实现。该公共 API 可能比仓库其他地方的代码多一些说明 - 仍要简洁，没有段落，仅足以涵盖签名本身不明显的内容。
