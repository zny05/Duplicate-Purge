# czkawka_gui – 架构指南

## 状态：仅维护模式

不添加新功能。接受能保持与 `czkawka_core` API 兼容的 Bug 修复。

---

## 概述

使用 Cambalache 撰写 XML UI 文件的 GTK4 前端。`czkawka_core` 中的所有扫描工具均通过基于标签页的 notebook 界面暴露。

---

## 源代码布局

```
czkawka_gui/src/
├── main.rs                          # GTK Application setup, GuiData construction
├── initialize_gui.rs                # Initial widget state
├── compute_results.rs               # Converts scan results → GTK ListStore rows
├── saving_loading.rs                # JSON settings load/save
├── language_functions.rs            # LANGUAGES_ALL constant (26 entries)
├── localizer_gui.rs                 # flg! macro, Fluent loader
├── gui_structs/
│   ├── gui_data.rs                  # GuiData – central struct for all UI components
│   ├── gui_main_notebook.rs         # 11-tool tab notebook
│   ├── gui_upper_notebook.rs        # Included/excluded directory tabs
│   ├── gui_settings.rs              # Settings dialog
│   ├── gui_header.rs                # Menu bar (About, Settings)
│   ├── gui_bottom_buttons.rs        # Action buttons (Search, Delete, etc.)
│   ├── gui_progress_dialog.rs       # Scan progress window
│   ├── gui_about.rs                 # About dialog
│   ├── gui_compare_images.rs        # Side-by-side image diff overlay
│   ├── common_tree_view.rs          # TreeView/ListStore rendering + SharedModelEnum
│   ├── common_upper_tree_view.rs    # Dir-list TreeViews
│   ├── gui_popovers_select.rs       # Selection filter popovers
│   └── gui_popovers_sort.rs         # Sort filter popovers
├── connect_things/                  # Callback wiring files
│   ├── connect_button_search.rs     # Scan thread spawn + progress forwarding
│   ├── connect_button_delete.rs     # File deletion with confirmation
│   ├── connect_button_save.rs       # Export results (CSV/JSON)
│   ├── connect_button_select.rs     # Row selection helpers
│   ├── connect_button_sort.rs       # Column-header sort
│   ├── connect_button_stop.rs       # Cancel scan (stop flag)
│   ├── connect_button_move.rs       # Move files to folder
│   ├── connect_button_hardlink.rs   # Hard-link/symlink creation
│   ├── connect_button_compare.rs    # Image comparison launcher
│   ├── connect_notebook_tabs.rs     # Tab-switch handler
│   ├── connect_selection_of_directories.rs  # Dir-picker dialogs
│   ├── connect_change_language.rs   # Language switch + full UI relabel
│   ├── connect_settings.rs          # Settings window callbacks
│   ├── connect_progress_window.rs   # Progress bar updates from channel
│   ├── connect_show_hide_ui.rs      # Error text visibility toggle
│   ├── connect_similar_image_size_change.rs
│   ├── connect_same_music_mode_changed.rs
│   ├── connect_popovers_select.rs
│   ├── connect_popovers_sort.rs
│   ├── connect_header_buttons.rs
│   ├── connect_about_buttons.rs
│   ├── connect_krokiet_info_dialog.rs  # One-time Krokiet deprecation notice (shown on first run)
│   ├── connect_krokiet_promo_dialog.rs # Krokiet promo dialog (shown from the header button)
│   └── file_chooser_helpers.rs
├── helpers/
│   ├── enums.rs                     # Column index enums for all tools
│   ├── list_store_operations.rs     # Append/read GTK ListStore rows
│   ├── image_operations.rs          # Image resize/preview for GTK
│   ├── model_iter.rs                # GTK TreeView iteration
│   └── mod.rs
├── help_functions.rs                # HEADER_ROW_COLOR, MAIN_ROW_COLOR, set_buttons
├── help_combo_box.rs                # Combo box option arrays (hash algs, etc.)
├── notebook_enums.rs                # NotebookMainEnum (per-tool tab index)
├── notebook_info.rs                 # Tab label + ListStore column definitions
├── opening_selecting_records.rs     # Double-click → open file/folder
├── taskbar_progress.rs              # Windows taskbar progress (real impl)
├── taskbar_progress_dummy.rs        # No-op stand-in for non-Windows targets
├── taskbar_progress_win.rs          # Windows-specific taskbar API calls
└── gtk_traits.rs                    # Custom GTK trait extensions

ui/
├── czkawka.cmb         # Cambalache project file (source of truth for the .ui files below)
├── main_window.ui      # Cambalache XML (65 KB) – entire main window layout
├── settings.ui         # Settings dialog
├── compare_images.ui   # Image comparison panel
├── popover_select.ui   # Selection filter popover
├── popover_sort.ui     # Sort popover
├── popover_right_click.ui # Right-click context menu popover
├── about_dialog.ui     # About window
└── progress.ui         # Scan progress dialog
```

---

## GuiData 结构体 (`gui_structs/gui_data.rs`)

每个回调通过克隆/引用传递的中心结构体：

```rust
pub struct GuiData {
    pub window_main: gtk4::Window,
    pub main_notebook: GuiMainNotebook,         // 11 tool tabs
    pub upper_notebook: GuiUpperNotebook,       // Dir configuration
    pub bottom_buttons: GuiBottomButtons,       // Action buttons
    pub progress_window: GuiProgressDialog,
    pub settings: GuiSettings,
    pub header: GuiHeader,
    pub compare_images: GuiCompareImages,
    pub about: GuiAbout,
    pub popovers_select: GuiSelectPopovers,
    pub popovers_sort: GuiSortPopovers,
    pub entry_info: gtk4::Entry,
    pub text_view_errors: gtk4::TextView,
    pub scrolled_window_errors: gtk4::ScrolledWindow,  // show/hide bottom error panel
    pub file_dialog_include_exclude_folder_selection: gtk4::FileChooserNative,
    pub file_dialog_move_to_folder: gtk4::FileChooserNative,
    pub taskbar_state: Rc<RefCell<TaskbarProgress>>,
    pub shared_buttons: Rc<RefCell<HashMap<NotebookMainEnum, …>>>,
    pub stop_flag: Arc<AtomicBool>,
}
```

由 `GuiData::new_with_application()` 构造，通过 `gtk4::Builder` 加载所有 `.ui` 文件。

---

## 扫描线程架构

```
用户点击 Search
→ connect_button_search.rs
→ 禁用 UI，显示进度窗口
→ 生成 worker 线程：
    - 从 GTK 小部件读取设置
    - 创建工具结构体（例如 DuplicateFinder）
    - 调用 tool.search(stop_flag, progress_sender)
    - 通过 result_sender 发送 Message::Duplicates(tool)
→ 主线程：接收进度更新 → 更新进度条
→ 收到结果后：
    - compute_results.rs 处理工具数据 → 追加到 ListStore
    - 重新启用 UI，隐藏进度
```

**通道类型：**
- `Sender<Message>` – 一站式结果通道（包含完整数据的工具枚举）
- `Sender<ProgressData>` – 来自核心的实时进度

---

## 结果填充 (`compute_results.rs`)

1. 从 worker 线程接收 `Message::Duplicates(DuplicateFinder)`。
2. 从工具提取已排序的文件组。
3. 对每个组：插入一个**标题行**（颜色为 `HEADER_ROW_COLOR`），然后每个文件插入一行（`MAIN_ROW_COLOR`）。
4. `append_row_to_list_store()` 将单个单元格写入 `gtk4::ListStore`。
5. `finalize_compute()` 将工具对象存储在 `SubView.shared_model_enum` 中（以供选择/排序回调稍后复用）。

---

## 语言切换 (`language_functions.rs`)

26 种语言定义为 `LANGUAGES_ALL: &[Language]`，包含 `combo_box_text`（显示名称）和 `short_text`（BCP-47 代码）。

语言更改时：
1. 从选定的组合框索引查找 `short_text`。
2. 对 `czkawka_core` 和 `czkawka_gui` 都调用 `localizer.select([lang_id])`。
3. 调用 `gui_data.update_language()` → 传播到所有子结构体，它们通过 `flg!("key")` 更新小部件标签。

---

## 设置存储 (`saving_loading.rs`)

JSON 文件位于 `~/.config/Czkawka/czkawka_gui_config.json`。结构体 `SettingsJson` 使用 `serde_json` 序列化。包含目录、工具参数、UI 状态、语言偏好。

---

## 关键依赖

| Crate | 用途 |
|-------|------|
| `gtk4` 0.11 | GTK4 GUI 框架 |
| `gdk4` 0.11 | 绘制/渲染 |
| `glib` 0.22 | 事件循环，`spawn_future_local` |
| `i18n-embed` + `rust-embed` | Fluent 翻译 |
| `open` 5.3 | 启动文件管理器 |
| `image` 0.25 | 预览缩略图 |
| `resvg` 0.47 | SVG 图标缩放 |
| `rayon` 1.10 | 结果并行排序 |
| `crossbeam-channel` | 结果 + 进度通道 |
| `czkawka_core` | 扫描引擎 |

可选功能（转发给核心）：`heif`、`libraw`、`libavif`、`xdg_portal_trash`。

---

## 注释

简短且极简 - 参见根目录的 `AGENTS.md`。仅在代码行为无法通过阅读推断时添加注释（非显而易见的约束、变通方案、跨模块耦合）；永远不要重复代码已经表达的内容。
