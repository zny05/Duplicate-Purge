# cedinia – Architecture Guide

## Overview

Android（以及次要的桌面端）GUI。架构参考 krokiet，但针对移动端限制进行了调整：触控优化的布局、JNI 文件选择器、运行时权限、系统内置区域（system insets），且没有 `VideoOptimizer`（基于 FFmpeg 的转码在 Android 上不可用）。`SimilarVideos` 仍然存在，仅使用音频指纹匹配（`rusty-chromaprint`），不使用帧哈希。

---

## Entry Points

**Android** (`src/lib.rs`):
```rust
#[unsafe(no_mangle)]
fn android_main(android_app: AndroidApp) {
    setup_android_paths(&android_app);   // JNI: get /data and /cache paths (sets DATA_DIR)
    app::setup_logger_cache();           // installs DualLogger: logcat + cedinia.log file
    asan_smoketest_if_requested();       // no-op unless CEDINIA_ASAN_SMOKETEST is set
    file_picker_android::init(&android_app); // Load DEX + init JNI
    slint::android::init(android_app.clone()).expect(…);
    file_picker_android::setup_nav_bar(); // pin/style the Android nav bar
    app::run_app_with_insets(inset_bottom_px, scale, android_app);
}
```

Logging：在 Android 上，`android_logger` 会占用唯一的全局 `log` 插槽，因此 czkawka_core 的文件 `WriteLogger` 永远不会安装（cedinia.log 始终为 0 字节）。`app.rs::setup_android_logger` 安装了一个 `DualLogger`，将日志分发到 `AndroidLogger`（logcat）和缓存文件夹中追加的 `cedinia.log` 两个目标，因此日志导出有真实内容。桌面端保留 `czkawka_core::setup_logger`。

**Desktop** (`src/app.rs`):
```rust
pub fn run_app() {
    setup_logger_cache();
    run_app_with_insets(0.0, 1.0, ());
}
```

两者均汇聚于 `run_app_inner()`：加载设置 → 创建 `MainWindow` → 连接回调 → 启动工作线程 → 运行事件循环。

---

## Source Layout

```
cedinia/src/
├── lib.rs                         # Android entry (#[unsafe(no_mangle)] android_main)
├── app.rs                         # Desktop entry + shared run_app_inner()
├── bin/cedinia.rs                 # Desktop binary wrapper
├── common.rs                      # Column index enums (StrData*, IntData*)
├── model.rs                       # FileEntry toggle/count logic
├── compare.rs                     # Image comparison overlay (cancel token, resize, diff)
├── file_actions.rs                # delete_path() (trash on desktop, permanent on Android) + DeleteEvent
├── scan_runner.rs                 # Worker thread + ScanRequest/ScanResult
├── scanners.rs                    # Tool-specific scan builders
├── notifications.rs               # Desktop notifications
├── set_initial_gui_infos.rs       # Initial GUI state
├── thumbnail_loader.rs            # Async image thumbnail loading
├── translations.rs                # translate_items() – populates Translations global
├── volumes.rs                     # Storage volume detection
├── localizer_cedinia.rs           # flc! macro, LANGUAGE_LIST, apply_language_preference()
├── file_picker_android.rs         # JNI + embedded DEX file picker
├── callbacks/
│   ├── callbacks.rs               # Module re-exports
│   ├── scan.rs                    # wire_scan() – scan/stop/tool-change callbacks
│   ├── selection.rs               # wire_selection() – delete + model access
│   ├── selection_ops.rs           # Shared FileEntry helpers: vm_of, get_val_str/int, full_path_of, size_from_entry
│   ├── directories.rs             # wire_directories() – add/remove include/exclude dirs
│   └── misc.rs                    # 10 wire_* fns: cache_info, collect_test, export_logs,
│                                   #   language_change, licenses_popup, notification_settings,
│                                   #   open_path, open_url, permission, save_settings_now
├── settings/
│   ├── mod.rs                     # CediniaSettings struct; load/save JSON
│   └── gui_settings_values.rs     # StringComboBoxItems – combo box option arrays
└── ui/
    ├── main_window.slint          # Root component
    ├── globals/
    │   ├── app_state.slint        # Global AppState, GeneralSettings, tool-specific globals
    │   ├── common.slint           # Enums: ActiveTool, ScanState, ConfirmPopupAction
    │   ├── colors.slint           # CediniaColors theme
    │   └── fonts.slint
    ├── screens/
    │   ├── home_screen.slint      # Tool cards
    │   ├── settings_screen.slint  # Settings screen layout
    │   ├── results_list.slint     # Generic results table
    │   ├── similar_images_gallery.slint
    │   ├── directories_screen.slint # Add/remove directory paths
    │   ├── image_compare.slint
    │   ├── scan_progress.slint
    │   ├── bottom_nav.slint
    │   └── top_bar.slint
    └── components/
        ├── settings/
        │   ├── toggle_row.slint
        │   ├── segment_row.slint
        │   ├── dropdown_row.slint
        │   ├── text_input_row.slint
        │   ├── tool_group_header.slint
        │   └── category_label.slint
        ├── buttons/
        │   ├── touch_button.slint
        │   ├── icon_button.slint
        │   └── circle_icon_button.slint
        ├── file_row.slint
        ├── section_header.slint
        ├── status_chip.slint
        ├── divider.slint
        ├── empty_state.slint
        ├── scan_fab.slint
        ├── scrim_dialog.slint
        ├── popup_title_bar.slint
        ├── context_menu_sheet.slint
        ├── deselection_menu_sheet.slint
        └── selection_menu_sheet.slint
```

---

## Slint Performance: ListView vs. for-in / ScrollView

当显示数十个以上项目时，**始终使用 `ListView`**（来自 `std-widgets.slint`），而不是在 `VerticalLayout` 内使用裸的 `ScrollView` / `for` 循环。

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

`ListView` 使用 Slint 的 Flickable 内 Repeater 优化：任意时刻仅实例化可见行（加上小缓冲区）。使用普通的 `ScrollView` + `VerticalLayout`，所有 N 个项目在每一帧都会被创建和遍历。

参考：Slint 问题 [#11021](https://github.com/slint-ui/slint/issues/11021)。

---

## Scan Data Flow

```
1. User selects tool + taps Scan → AppState.on_scan_requested()
2. scan.rs: collect settings from globals → build ScanRequest
3. ScanRequest sent to worker thread via channel
4. Worker: configure tool struct → tool.search(stop_flag, progress_sender)
5. Results stored; ScanResult sent back to main thread
6. invoke_from_event_loop: populate model, update AppState.scan_state
```

---

## Slint UI Architecture

设置存储在 Slint 全局中（不是在启动时从 Rust 设置）：

- `GeneralSettings` – 语言、文件大小、缓存、扩展名过滤器
- `DuplicateSettings`、`SimilarImagesSettings`、`SameMusicSettings` 等
- `AppState` – 扫描状态、活跃工具、结果模型、所有回调

`apply_settings_to_gui()`（`settings/mod.rs`）从 JSON 读取 `CediniaSettings` 并填充这些全局变量。`collect_settings_from_gui()` 将它们读回以供保存。

### DropdownRow (`ui/components/settings/dropdown_row.slint`)

内联手风琴，**不是** `PopupWindow`：

- 轻触该行会切换 `expanded`，在同一 `VerticalLayout` 内直接将选项列表插入到该行下方。
- 滚动由父级 `Flickable`/`ListView` 处理，而不是嵌套的 `ScrollView` —— 这样可以避免当行位于已可滚动的设置列表中时，出现“点击外部区域即关闭”的弹窗消失问题。
- 每个选项行都会跟踪指针移动（`_opt_moved`），因此在选项上结束的滚动拖动不会被注册为选择轻触。

## Translation System

与 krokiet 相同的变通方案：

- 所有 UI 文本均绑定到 `Translations` 全局属性。
- `src/translations.rs` 中的 `translate_items()` 通过 `flc!("key")` 填充它们。
- `localizer_cedinia.rs` 中的 `LANGUAGE_LIST` 定义了支持的 27 种语言。
- `ui/app_state.slint` 中的 `GeneralSettings.language_options` 是硬编码的，且必须与 `LANGUAGE_LIST` 完全匹配。
- 语言索引存储在 `GeneralSettings.language_idx` 中；代码存储在 `CediniaSettings.language` 中。

---

## Settings (`src/settings/mod.rs`)

JSON 文件（路径由 `czkawka_core::common::config_cache_path::get_config_cache_path()` 解析，通过 `set_config_cache_path("cedinia", "cedinia")` 配置）：

- 桌面端：`~/.config/cedinia/cedinia_settings.json`（directories-next 在 Linux 上会忽略限定符/组织名并将应用名小写化，没有 `Czkawka` 路径片段）
- Android：应用私有存储，`$DATA_DIR/files/cedinia/cedinia_settings.json`

包含/排除的目录单独持久化在同一文件夹中的同级 `cedinia_dirs.json` 文件。

`CediniaSettings`（带有 serde Serialize/Deserialize）涵盖所有工具参数。`Default` 实现委托给 `serde_json::from_str("{}")`，因此会使用所有 `#[serde(default)]` 值。

---

## Android-Specific Code

### File Picker (`src/file_picker_android.rs`)

Kotlin 辅助类在构建时（通过 `android-build` crate）编译，并嵌入为 DEX 字节码：

```rust
include_bytes!(concat!(env!("OUT_DIR"), "/classes.dex"))
```

运行时：

1. DEX 被加载到 `InMemoryDexClassLoader` 中。
2. 通过 JNI 创建 `CediniaFilePicker` 实例。
3. `launch_pick_directory(is_include, start_path)` 调用 Java `ACTION_OPEN_DOCUMENT_TREE` intent，提示选择器在 `start_path` 处打开。
4. 结果通过 `Java_CediniaFilePicker_onDirectoryPicked()` JNI 回调到达 → 通过 `invoke_from_event_loop()` 分发到 Rust。

### Storage Permissions

通过 JNI 进行运行时权限检查/请求。`AppState.storage_permission_granted` 控制扫描发起。

### System Insets

Android 边缘到边缘布局需要为导航栏留出内边距。内置区域大小通过 `android_app.content_rect()` 从 Kotlin 传递，并作为布局属性传递给 Slint。

### Android Paths via JNI

`setup_android_paths()` 在 Activity 上调用 `getFilesDir()` 和 `getCacheDir()` 以查找私有存储路径；这些路径被设置为环境变量，并被 `czkawka_core` 的配置路径逻辑使用。

---

## Differences from krokiet

| | cedinia | krokiet |
|---|---|---|
| `SimilarVideos` | 是（仅音频指纹，`rusty-chromaprint`） | 是（帧哈希） |
| `VideoOptimizer` | 否（基于 ffmpeg 的转码在 Android 上不可用） | 是 |
| `BadNames` | 是 | 是 |
| 文件选择器 | JNI（Android）/ rfd（桌面端） | rfd |
| 设置 | JSON，无预设 | JSON，11 个预设 |
| 列索引 | `common.rs`（独立集合） | `common.rs`（独立集合） |
| 构建目标 | `cdylib`（Android）+ `bin`（桌面端） | `bin` |

---

## Key Dependencies

### Always

| Crate | 用途 |
|-------|---------|
| `slint` 1.15 | UI 框架 |
| `czkawka_core` | 扫描引擎 |
| `crossbeam-channel` | 工作线程通信 |
| `i18n-embed` + `rust-embed` | Fluent 翻译 |
| `serde_json` | 设置持久化 |
| `image` | 缩略图加载 |

### Android only

| Crate | 用途 |
|-------|---------|
| `android-activity` 0.6 | Android 生命周期 |
| `jni` 0.22 | Java FFI |
| `android_logger` 0.15 | Logcat 输出 |

### Desktop only

| Crate | 用途 |
|-------|---------|
| `rfd` 0.17 | 原生文件选择器 |
| `trash` 5.2 | 移至废纸篓 |
| `notify-rust` 4 | 桌面通知 |

### Build

```toml
[build-dependencies]
slint-build = "1.15"
android-build = "0.1.2"   # Compiles CediniaFilePicker.java → classes.dex
```

### Android Manifest Permissions

`READ_EXTERNAL_STORAGE`、`WRITE_EXTERNAL_STORAGE`、`MANAGE_EXTERNAL_STORAGE`、`POST_NOTIFICATIONS`

`Cargo.toml` 的 `[package.metadata.android.uses_permission]` 还列出了 `WAKE_LOCK`，但通过 gradle 构建的 `android/app/src/main/AndroidManifest.xml` 未包含它 —— 这是仓库中预先存在的不一致，而非文档错误。

---

## Optional Features (forwarded to czkawka_core)

`heif`、`libraw`、`libavif`、`xdg_portal_trash`

---

## Comments

简短精炼 —— 参见根目录 `AGENTS.md`。仅在代码行为无法通过阅读推断时添加注释（非显而易见的约束、变通方案、跨模块耦合）；切勿重述代码本身已表达的内容。

---

## Slint model `row_data()` - panic, don't silently no-op

`ModelRc::row_data(index)` 返回 `Option<T>`。当 `index` 来自同步的用户触发回调（该索引刚由拥有它的模型产生——点击处理程序、切换、重命名）时，越界结果意味着索引与模型已经彼此不同步 —— 这是程序员错误，而非合法竞态。应当响亮 panic，而非用 `if let Some(...) = ... { }` 或 `let Some(...) = ... else { return }` 吞掉它：那里的静默无操作会隐藏不同步，并可能损坏依赖该行的任何状态（参见 `model.rs::toggle_row`、`compare.rs::wire_compare_toggle_checkbox`）。

```rust
let mut entry = model
    .row_data(index)
    .unwrap_or_else(|| panic!("toggle_row: index {index} out of bounds (row_count={})", model.row_count()));
```

以下两种情况仍然是合法的 `if let Some(...)` / 静默跳过：

- 索引来自 `0..model.row_count()` 循环上限 —— 按构造不可能越界。
- 查找发生在后台/定时任务中，且该任务已通过显式过期检查（例如代数/扫描 ID 比较）保护 —— 数据可能合法地已不存在，因为用户在操作途中导航离开；这是真实的竞态，而非 bug。
