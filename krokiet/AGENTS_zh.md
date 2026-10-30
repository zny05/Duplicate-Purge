# krokiet – 架构指南

## 概述

主要的桌面 GUI。基于 [Slint](https://slint.dev/)（GPL-3.0）构建。UI 在 `ui/*.slint` 中声明；Rust 连接所有回调并驱动 Slint 数据模型。所有扫描逻辑都位于 `czkawka_core`。

---

## 源代码布局

```
krokiet/
├── build.rs                          # slint_build::compile("ui/main_window.slint")
├── src/
│   ├── main.rs                       # Entry point: load settings, create MainWindow,
│   │                                  #   wire all callbacks, run event loop
│   ├── shared_models.rs              # SharedModels – Arc<Mutex<…>> of all tool results
│   ├── common.rs                     # Column index enums (IntDataDuplicateFiles, …)
│   │                                  #   and sort index helpers
│   ├── localizer_krokiet.rs          # flk! macro, LANGUAGE_LOADER_KROKIET
│   ├── set_initial_gui_info.rs       # Asserts Slint combo lists == Rust enums
│   ├── set_initial_scroll_list_data_indexes.rs
│   ├── simpler_model.rs              # Minimal serializable row struct for threading
│   ├── audio_player.rs               # Play sound on scan completion
│   ├── notification_manager.rs       # Desktop notifications
│   ├── create_calculate_task_size.rs # Background total-size calculator
│   ├── clear_outdated_video_thumbnails.rs
│   ├── connect_scan.rs               # Routes scan to per-tool functions
│   ├── connect_scan/                 # One file per tool (duplicate.rs, …)
│   ├── connect_progress_receiver.rs  # Receives ProgressData → updates UI bar
│   ├── connect_row_selection/        # Row checkbox logic, group handling
│   │   ├── mod.rs
│   │   ├── checker.rs
│   │   ├── clipboard.rs
│   │   ├── context_menu.rs
│   │   ├── opener.rs
│   │   └── selection.rs
│   ├── connect_sort.rs               # Column-header sort (string + int indices)
│   ├── connect_translation.rs        # LANGUAGE_LIST, change_language(), translate_items()
│   ├── connect_compare.rs            # Image comparison overlay
│   ├── connect_show_preview.rs       # File preview / thumbnail
│   ├── connect_open.rs               # Open file/folder in system app
│   ├── connect_save.rs               # Export results via PrintResults
│   ├── connect_show_confirmation.rs  # Confirmation popup before destructive action
│   ├── connect_directories_changes.rs
│   ├── connect_clean_cache.rs
│   ├── connect_tab_changed.rs
│   ├── connect_stop.rs               # Sets stop_flag = true
│   ├── connect_rfd.rs                # File picker (rfd)
│   ├── connect_select/
│   │   ├── mod.rs
│   │   └── custom_select.rs          # Advanced filter popup
│   ├── file_actions/
│   │   ├── connect_delete.rs
│   │   ├── connect_move.rs
│   │   ├── connect_rename.rs
│   │   ├── connect_hardlink.rs
│   │   ├── connect_symlink.rs
│   │   ├── connect_optimize_video.rs
│   │   └── connect_clean_exif.rs
│   ├── model_operations/
│   │   ├── mod.rs                    # Slint model ↔ thread-safe model conversion
│   │   └── model_processor.rs        # Parallel item processing framework
│   └── settings/
│       ├── mod.rs                    # Load/save JSON settings (11 presets)
│       ├── model.rs                  # BasicSettings, SettingsCustom structs
│       └── combo_box.rs              # StringComboBoxItems + regenerate_items()
└── ui/
    ├── main_window.slint             # Root component; imports everything; exports globals
    ├── globals/
    │   ├── common.slint              # Enums + structs: ActiveTab, SingleMainListModel, …
    │   ├── gui_state.slint           # Global GuiState (transient runtime state)
    │   ├── settings.slint            # Global Settings (persisted)
    │   ├── translations.slint        # Global Translations (all UI strings)
    │   ├── callabler.slint           # Global Callabler (all Rust to UI callbacks)
    │   ├── fonts.slint               # FontSizes global
    │   ├── color_palette.slint       # Dark-theme color definitions
    │   └── text_size.slint
    ├── screens/
    │   ├── left_side_panel.slint     # Tool selector + tool settings sub-panel
    │   ├── main_lists.slint          # Results table (bound to model)
    │   ├── action_buttons.slint      # Scan / Stop / Select / Delete / … buttons
    │   ├── bottom_panel.slint        # Progress bar + error text + status
    │   ├── progress.slint            # Real-time scan progress widget
    │   ├── image_compare.slint       # Side-by-side image diff overlay
    │   ├── settings_list.slint       # Settings tab form
    │   ├── tool_settings.slint       # Per-tool options (hash alg, threshold, …)
    │   ├── about.slint                # About tab
    │   └── included_paths.slint
    ├── components/
    │   ├── preview.slint             # File preview / thumbnail side panel
    │   ├── selectable_tree_view.slint # Custom tree widget for path lists
    │   ├── hint_text.slint
    │   ├── popup_base.slint
    │   ├── popup_centered_text.slint
    │   └── popup_context_menu.slint
    └── popups/                       # 18 modal dialogs: popup_delete, popup_save,
                                       #   popup_optimize, popup_crop_video,
                                       #   popup_custom_select, popup_rename_*, …
```

---

## Slint 性能：ListView 与 for-in / ScrollView

当显示数十个以上项目时，**始终使用 `ListView`**（来自 `std-widgets.slint`），而不是在 `VerticalLayout` 内部使用裸露的 `ScrollView` / `for` 循环。

```slint
// SLOW – instantiates every item upfront, O(n) per frame
ScrollView {
    VerticalLayout {
        for item in model : Row { ... }
    }
}

// SLOW - same as above
VerticalLayout {
    for item in model : Row { ... }
}

// FAST – virtual scroll via Flickable's Repeater optimization
ListView {
    for item in model : Row { ... }
}
```

`ListView` 使用 Slint 的 Flickable 内 Repeater 优化：在任何给定时间，仅实例化可见行（加上一个小缓冲区）。而使用普通的 `ScrollView` + `VerticalLayout`，所有 N 个项目都会在每帧被创建和遍历。

引用：Slint 问题 [#11021](https://github.com/slint-ui/slint/issues/11021)。

---

## SharedModels (`src/shared_models.rs`)

```rust
pub struct SharedModels {
    pub shared_duplication_state:       Option<DuplicateFinder>,
    pub shared_empty_folders_state:     Option<EmptyFolder>,
    // … one field per tool (14 total)
}
```

在 `main.rs` 中创建一次，作为 `Arc<Mutex<SharedModels>>`，克隆并传递给需要扫描结果的每个回调（预览、比较、保存、删除……）。

扫描完成后，worker 线程独占锁以**写入**结果。UI 回调短暂加锁以**读取**结果用于预览/导出。

`VideoOptimizer` 是 14 个工具之一，但不符合其他工具的扫描/选择/删除形状：它有自己的 `connect_scan/video_optimizer.rs` 入口点，以及专用的 `file_actions/connect_optimize_video.rs` 操作，还有两个弹出窗口（`popup_optimize.slint` 用于转码选项，`popup_crop_video.slint` 用于裁剪区域预览），而不是复用通用的删除/保存弹出窗口。

---

## 扫描数据流

```
1. 用户点击 Scan → on_scan_starting(active_tab)
2. connect_scan.rs: collect_settings() → ScanData → route to scan_<tool>()
3. scan_<tool>(): spawn worker thread
       → create and configure tool struct
       → tool.search(stop_flag, progress_sender)
       → store tool in shared_models.lock()
       → populate Slint VecModel<SingleMainListModel>
       → app.upgrade_in_event_loop(|app| app.set_<tool>_model(model))
4. UI re-renders with new model
```

---

## Slint 数据模型

```rust
// ui/common.slint
export struct SingleMainListModel {
    checked: bool,           // row selected by user
    header_row: bool,        // group header
    filled_header_row: bool, // header with formatted summary
    focused_row: bool,      // UI highlight
    val_str: [string],       // text columns
    val_int: [int],          // numeric columns (raw values for sorting)
}
```

列索引在 `src/common.rs` 中定义为常量：

```rust
pub enum StrDataDuplicateFiles { Size, Name, Path, ModificationDate }
pub enum IntDataDuplicateFiles { ModificationDatePart1, ModificationDatePart2,
                                  SizePart1, SizePart2 }
```

Slint 无法存储 `i64`，因此日期和文件大小被拆分为两个 `i32` 字段。

---

## 翻译系统

Slint 没有原生的 Fluent 支持。变通方案：
1. 所有 UI 文本都绑定到 `Translations` 全局中的属性（`ui/translations.slint`），而非硬编码在 `.slint` 中。
2. `connect_translation.rs` 中的 `translate_items()`（约 440 行，文件总计约 750 行）在语言更改后通过 `flk!("key")` 设置每个属性。
3. 语言列表在 `connect_translation.rs` 中定义为 `LANGUAGE_LIST: &[Language]`。
4. `.slint` 文件中硬编码的组合框列表（例如 `Settings.languages_list`）在启动时通过 `set_initial_gui_info.rs` 中的 `assert_eq!` 针对 Rust 枚举进行验证（这是针对 [slint#7632](https://github.com/slint-ui/slint/issues/7632) 的变通方案）。

---

## 设置 (`src/settings/`)

双层 JSON 系统：

| 文件 | 内容 |
|------|------|
| `~/.config/krokiet/config_general.json` | `BasicSettings` – 默认预设索引，预设名称，主题，窗口大小 |
| `~/.config/krokiet/config_preset_N.json` | `SettingsCustom` – 路径，扩展名，工具参数 |

（`directories-next` 仅从小写的应用名称解析配置目录 - 传递给 `set_config_cache_path` 的限定符/组织在 Linux 上被忽略。）

11 个预设槽位（索引 0–10）。槽位 10 保留用于 CLI 模式覆盖。
`StringComboBoxItems::regenerate_items()` 从 Rust 枚举构建所有组合框选项数组；既用于设置序列化，也用于 UI 初始化。

---

## 回调注册模式

```rust
let weak = app.as_weak();
app.global::<Callabler>().on_some_action(move || {
    let app = weak.upgrade().expect("MainWindow dropped while callback is still live");
    // use app …
});
```

这里使用 `expect()` 是正确的：如果窗口已关闭，则不应触发任何回调。跨线程更新使用 `weak.upgrade_in_event_loop(|app| { … })`。

---

## 关键依赖

| Crate | 用途 |
|-------|------|
| `slint` 1.15 | UI 框架（GPL-3.0） |
| `czkawka_core` | 扫描引擎 |
| `i18n-embed` + `rust-embed` | Fluent 翻译 |
| `crossbeam-channel` | 进度 + 结果通道 |
| `rayon` | 结果并行排序 |
| `serde_json` | 设置持久化 |
| `image` | 缩略图加载 |
| `rfd` 0.17 | 文件选择器（xdg-portal 后端） |
| `notify-rust` | 桌面通知 |
| `rodio` | 扫描完成声音（可选 `audio` 功能） |
| `fontique` | 字体发现（dlopen，避免 C 依赖） |

### 可选功能

- `audio` – 通过 `rodio` 发出扫描完成声音
- 渲染器功能：`winit_femtovg`（默认）、`winit_software`（默认）、`skia_opengl`、`skia_vulkan` 等 – 在编译时选择 GPU 后端
- `heif`、`libraw`、`libavif`、`xdg_portal_trash` – 转发到 `czkawka_core`

### 构建

`build.rs` 使用 `fluent-dark` 样式编译 `ui/main_window.slint`（可通过 `SLINT_STYLE` 环境变量覆盖）。

---

## 注释

简短且极简 - 参见根目录的 `AGENTS.md`。仅在代码行为无法通过阅读推断时添加注释（非显而易见的约束、变通方案、跨模块耦合）；永远不要重复代码已经表达的内容。

---

## Slint 模型 `row_data()` - 应 panic，不要静默无操作

`ModelRc::row_data(index)` 返回 `Option<T>`。当 `index` 来自同步的用户触发回调（索引刚由拥有它的模型生成 - 点击处理程序、切换、重命名），超出范围的结果意味着索引和模型已经彼此不同步 - 这是程序员错误，而非合法的竞态。应大声 panic，而不是用 `if let Some(...) = ... { }` 或 `let Some(...) = ... else { return };` 吞掉它：那里的静默无操作会隐藏不同步，并有损坏依赖于该行的任何状态。

```rust
let mut entry = model
    .row_data(index)
    .unwrap_or_else(|| panic!("toggle_row: index {index} out of bounds (row_count={})", model.row_count()));
```

有两种情况仍属于合法的 `if let Some(...)` / 静默跳过：
- 索引来自 `0..model.row_count()` 循环边界 - 按构造它不可能超出范围。
- 查找发生在已通过显式新鲜度检查（例如，生成/扫描 ID 比较）保护的后台/定时器任务中 - 数据可能合法地不存在，因为用户在飞行途中导航走了；这是真正的竞态，而非 bug。
