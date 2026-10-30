# Czkawka – 代码库指南

## 语言

所有代码、注释、提交信息和文档必须使用 **英语** 编写。

---

## AI 编写的提交与合并/拉取请求

始终，不例外：AI 助手创建的每个提交，其标题（提交信息的第一行）必须以 `[AI] ` 开头，例如 `[AI] Fix crash when scanning empty directories`。如果提交信息有正文，正文不需要再次加前缀——仅标题即可标记。

同样适用于 AI 助手打开的任何合并请求（GitLab）或拉取请求（GitHub）：标题和正文/描述都必须以 `[AI] ` 开头，例如标题 `[AI] Add duplicate detection for symlinked folders` 以及正文以 `[AI] This MR adds ...` 开头。这在 GitLab 和 GitHub 中都必须让审阅者一目了然——即使是小的或自动的更改也绝不能省略。

---

## Rust 风格

适用于工作区中的每个 Rust crate（`czkawka_core`、`czkawka_cli`、`czkawka_gui`、`krokiet`、`cedinia`）。特定于程序的偏差或详细说明位于该程序自己的 `AGENTS.md` 中。

**格式化与 lint**

- 先用 `cargo +nightly fmt` 格式化，再用 `cargo fmt` 保持稳定版兼容（`.rustfmt.toml`：`max_width = 120`，粒度导入分组 `group_imports = "StdExternalCrate"`）。
- 代码编译时不能有 clippy 警告。仅用注释本地抑制 lint，并说明原因。

**错误与 panic**

- 优先使用 `?`、`ok_or_else`、`map_err`，而非基于 panic 的流程。
- `unwrap()` 仅用于测试。
- `expect()` 仅在生产环境中且同时满足以下两点时使用：没有正确的恢复路径，且继续执行可能会掩盖严重错误——始终附带精确且可操作的消息。这在 Krokiet/Cedinia 回调代码中可见：Slint 弱引用使用 `expect()` 升级，因为如果窗口已不存在，除了崩溃外无其他有意义的操作。
- 除非失败确实无关紧要，否则永远不要用 `let _ = ...` 静默吞掉错误。
- 用显式类型（`thiserror`/枚举）建模域错误，而非原始字符串。
- 用上下文（如文件路径）包装 I/O 错误，而不是让 std 的光秃秃 "Permission denied" 传播——没有路径就难以定位来源。
- 不要忽略 `Result`；显式处理。

**代码形状**

- 保持函数精简；当函数超过 ~30-50 行时，将其逻辑步骤提取为命名良好的独立函数。绝不要用注释标题或光秃秃的 `{ ... }` 作用域块将长函数分节——`// validate input` 注释在块上方是将其提取为 `validate_input(...)` 的信号，而不是将其围起来。
- 按意图命名事物，而非按容器/类型（`user_count`，而非 `vec_users_len`）。
- 使非法状态不可表示：用枚举而非字符串，用 `Option<T>` 而非哨兵值（`-1`、空字符串）。
- 优先使用迭代器和集合方法，而非手动索引循环。
- 当行为标准时，优先使用 `#[derive(...)]` 而非手动实现。
- 避免不必要的复制和分配；尽可能优先使用引用和 `Cow`。
- 优先使用外部 crate，而非重新实现它们。

**注释**

- 保持注释简短、最少——一行简洁，而非一段。代码应通过清晰的命名自我文档化。仅当代码本身难以推断出 _why_ 时才添加注释——算法选择、非显而易见的约束、对外部库缺陷的变通方案等。不要重复代码已经表达的内容。绝不要在代码、注释或提交信息中使用 `—`/`–` 破折号字符——仅用普通 `-`（ASCII 盒图是唯一例外）。

例外：`czkawka_core` 是一个库——工作区中的每个前端都依赖它，外部消费者只读其公共 API，不读其内部。其 `pub fn`/`pub struct` 表面比工作区其他部分更需要说明；参见 `czkawka_core/AGENTS.md`。

**测试、模糊测试、基准测试**

- 尽可能用测试覆盖代码；使用显式 `assert_eq!` 保持可读性，输入数据靠近断言。
- 在有助于展示用法、发现错误或衡量更改性能影响的地方，添加模糊测试/示例/基准测试。

**`unsafe`**

- 尽可能避免。每个 `unsafe` 块都要记录其不变量以及为什么安全要求成立（参见 cedinia 的 `#[unsafe(no_mangle)] android_main`）。

**文件与日志**

- 保持源文件在 500 行或以下；将大文件拆分为模块。
- 始终通过 `log`（`handsome_logger`）记录日志；只有在实际需要时才使用 `tracing`。

**自动向量化**

当 LLVM 能证明：无循环携带依赖、无别名、无边界检查、且成本模型有利时，它会向量化循环。

- 启用：使用 `.iter()`/`.iter_mut()` + `.zip()` 而非索引循环（消除边界检查）；使用 `.chunks_exact(N)`/`.chunks_exact_mut(N)` + `.remainder()` 进行对齐 SIMD 块处理；使用 `(&[T], &mut [T])` 而非 `(&mut [T], &mut [T])`，以便 LLVM 可假设无别名；保持循环体统一（无按元素的 `if`/`match`，无提前返回）；使用归约（`.sum()`/`.fold()`）而非依赖自身前一个值的运行累加器。
- 会破坏向量化：`slice[i]` 索引循环、元素循环内基于值的 `continue`、跨迭代共享的可变状态。
- 验证：在 godbolt.org 上检查汇编是否有 `vmulps`/`vpaddb`/`vpsubusb`，而非标量 `mulss`/`movss`；使用 `RUSTFLAGS="-C opt-level=3 -C no-vectorize-loops -C no-vectorize-slp"` 测量差异；使用 `RUSTFLAGS="-C target-cpu=native"` 构建以在主机 CPU 上解锁 AVX2/AVX-512。
- 当 LLVM 不会向量化时，使用显式 SIMD：`std::arch`（稳定，特定架构）、`std::simd`/`portable_simd`（夜间版，可移植），或稳定的 `wide`/`pulp` crate。

**性能微提示**

- 当数量大致已知时，使用 `Vec::with_capacity(n)` / `HashMap::with_capacity(n)` 预分配——避免重新分配阶梯。
- 跨调用重用缓冲区（`buf.clear()`），而非重新分配。
- 对几乎总是短的集合，考虑 `SmallVec`/`ArrayVec`（溢出前在栈上分配）。
- 对热路径枚举，使用尽可能小的枚举判别式（`#[repr(u8)]`/`#[repr(u16)]`），以便更紧凑打包和更好的缓存密度。
- 将 Criterion 基准输入/输出包裹在 `std::hint::black_box(...)` 中，防止死代码消除使测量失效。
- 使用 `RUSTFLAGS="-C target-cpu=native"` 构建，以在主机 CPU 上解锁 AVX2/AVX-512。

---

## 项目目标

以下两个属性在每个子项目中都是不可协商的：

1. **性能优先** – 扫描和文件操作必须快速。通过 `rayon` 实现并行，使用高效算法（例如感知哈希、blake3），并小心使用内存，是常态。在热路径中避免不必要的分配或复制。

2. **最小非 Rust 依赖** – 每个额外的 C/C++ 库（或任何其他非 Rust 语言）都会让交叉编译更困难，缩小受支持目标集，并增加贡献者的构建复杂性。优先使用纯 Rust crate。如果原生库确有必要（例如 `libheif`、`libraw`），将其置于可选 Cargo 特性后面，使默认构建保持完全为 Rust。

---

## `just fix` – 基准质量门

**强制：完成任何编码任务后，运行 `just fix` 并解决其报告的所有问题，然后再视任务完成。** 这始终适用，不例外——不仅在开启合并请求之前。

运行 `just fix` 必须在任何合并请求之前通过。它按顺序运行：

1. 仓库范围内自动修复 `—`/`–`/`—` 破折号字符回为普通 `-`（`.rs`、`.slint`、`.md`、`.ftl`；`AGENTS.md` 和 `justfile` 本身除外）——这是 "永不使用 em/en 破折号" 样式规则背后的执行机制。
2. `uv run ruff format --line-length 120` – Python 代码格式化。
3. `uv run mypy misc --strict` – 对 `misc/` 中的所有脚本进行静态类型检查。
4. `bash misc/run_checks.sh` – 项目特定检查：
   - `delete_unused_krokiet_slint_imports.py` 用于 krokiet 和 cedinia
   - `find_unused_fluent_translations.py` 用于所有四个项目
   - `find_unused_slint_translations.py` 用于 krokiet 和 cedinia
   - `find_unused_callbacks.py` 用于 krokiet 和 cedinia
   - `find_unused_settings_properties.py` 用于 krokiet 和 cedinia
5. `cargo +nightly fmt` – Rust 格式化。
6. `cargo clippy --fix --all-features --all-targets` – Rust lint（单次遍历）。
7. `cargo +nightly fmt` + `cargo fmt` – 再次重新格式化 clippy 的修改所触及的部分。

若要对 `--no-default-features` 构建进行 clippy 检查，请分别运行 `just clip`（两遍：`--all-features` 和 `--no-default-features --features winit_software`）。

如果 `just fix` 在 stderr 上产生任何输出或以非零退出，则代码尚未准备好供审阅。

---

## 工作区结构

```
czkawka/
├── czkawka_core/   # 扫描逻辑 – 所有前端共用的库
├── czkawka_cli/    # 命令行界面
├── czkawka_gui/    # 旧版 GTK 4 GUI（仅维护模式）
├── krokiet/        # 主要桌面 GUI – Slint 基础
├── cedinia/        # Android / 移动 GUI – Slint 基础
└── misc/           # 脚本：AI 翻译、验证、基准、CI 帮助程序
```

Cargo 工作区解析器 v3，最低 Rust 1.94.1，全版本 2024。

---

## czkawka_core

共享扫描引擎。每个前端都依赖它；它没有 UI 依赖项。

**关键模块：**

- `common/` – `CommonToolData`（设置、停止标志、进度发送器）、`DirTraversal`、缓存、扩展过滤、路径帮助程序、进度类型。
- `tools/` – 每个扫描工具一个子模块：`duplicate`、`empty_folder`、`empty_files`、`big_file`、`similar_images`、`similar_videos`、`same_music`、`broken_files`、`bad_extensions`、`bad_names`、`invalid_symlinks`、`temporary`、`exif_remover`、`video_optimizer`。
- `localizer_core.rs` – Rust 端消息的 Fluent 翻译加载器。

每个工具实现 `CommonData` 特性（共享设置访问）和 `PrintResults`（CSV/JSON 导出）。工具结构被构建、配置，然后在工作线程中调用其 `find_*()` 方法。进度通过 `crossbeam` 通道报告；停止 `AtomicBool` 被轮询以支持取消。

---

## krokiet

主要桌面 GUI。使用 [Slint](https://slint.dev/)（GPL-3.0）构建。UI 在 `ui/*.slint` 中声明；Rust 连接回调并驱动 Slint 模型。

**构建：** `slint_build` 在构建时编译 `.slint` 源文件；`slint::include_modules!()` 公开生成的类型。

**入口点：** `src/main.rs`

- 加载设置，创建 `MainWindow`，连接所有回调，启动事件循环。

**回调模式：**

```rust
let weak = app.as_weak();
app.global::<Callabler>().on_some_action(move || {
    let app = weak.upgrade().expect("MainWindow dropped while callback is still live");
    // ...
});
```

每个功能区域都位于专用的 `connect_*.rs` 文件中（例如 `connect_scan.rs`、`connect_compare.rs`、`connect_delete_button.rs`）。

**`SharedModels`** (`src/shared_models.rs`)：

一个 `Arc<Mutex<SharedModels>>` 保存每个工具的最后一次扫描结果和扫描参数。它传递给每个需要从后台线程访问或修改扫描状态的 `connect_*` 函数。

**模型层：**

- Slint UI 由 `ModelRc<VecModel<SingleMainListModel>>` 驱动。
- `SingleMainListModel` 承载 `val_str: [string]` 和 `val_int: [int]` 向量——一种基于索引的扁平行表示。
- 每个工具的列索引定义为 `src/common.rs` 中的常量（`StrDataSimilarImages`、`StrDataDuplicates` 等）。

**翻译：** 在 `src/localizer_krokiet.rs` 中定义的 `flk!("key")` / `flk!("key", var = value)` 宏。语言文件在 `i18n/<lang-code>/krokiet.ftl` 中。

---

## cedinia

Android（以及次要桌面）GUI。架构与 Krokiet 镜像，但适应移动约束。为 Android 编译为 `cdylib`（通过 `android-activity` 加载）。

**入口点：**

- Android：`src/lib.rs` 中的 `#[unsafe(no_mangle)] fn android_main(android_app: AndroidApp)`
- 桌面：`src/app.rs` 中的 `fn run_app()`

**Android 特定：**

- 文件选择器使用 JNI 调用嵌入的 Kotlin/Java 辅助程序（通过 `include_bytes!` 为 DEX）。
- 运行时请求存储权限；`AppState.storage_permission_granted` 控制扫描。
- 系统内置（`inset_top`、`inset_bottom`）传递给 Slint 以实现边缘到边缘布局。
- `android_logger` 将 Rust 日志输出路由到 logcat。

**与 Krokiet 的区别：**

- 具有 `SimilarVideos`（仅音频指纹匹配，通过 `rusty-chromaprint`），但没有 `VideoOptimizer` —— ffmpeg 基于的转码/裁剪检测在 Android 上不可用。
- 触摸优化的 UI（`cedinia/ui/`）；动量滚动视图、底部表单、FAB。
- `flc!` 宏（cedinia 特定），在 `src/localizer_cedinia.rs` 中。
- 有关完整对比表，参见 `cedinia/AGENTS.md`（"Differences from krokiet"）。

**翻译：** `flc!("key")` 宏；语言文件在 `cedinia/i18n/<lang-code>/cedinia.ftl` 中。

---

## czkawka_cli

围绕 `czkawka_core` 的薄包装器。使用 `clap`（派生 API）进行参数解析，使用 `indicatif` 进行进度条。无 GUI 代码。通过工具的 `PrintResults` 特性打印结果。

---

## czkawka_gui

旧版 GTK 4 GUI。**仅维护模式** – 不添加新功能。接受保持其与核心 API 变化兼容的错误修复。

---

## misc/

**翻译工具** (`ai_translate/`)：

- `translate.py` – 批量 AI 翻译为所有支持的语言。
- `validate_translations.py` – 检查翻译间占位符一致性。传递 `--fix` 以自动删除无效条目。

**死代码检测**（由 `run_checks.sh` 运行，参见上面的 `just fix`）：

- `find_unused_fluent_translations.py` / `find_unused_slint_translations.py` – 未使用的翻译键。
- `find_unused_callbacks.py` – 从未从 Rust 调用的 Slint 回调。
- `find_unused_settings_properties.py` – 从未由 UI 读取的设置结构体字段。
- `delete_unused_krokiet_slint_imports.py` – 从 `.slint` 文件中删除死的 `import` 行。

**打包/发布：**

- `gen_cedinia_licenses.py` – 从 Cargo 元数据生成 `THIRD_PARTY_LICENSES.txt`。
- `gen_android_icons.py` – 从 SVG 徽标生成 cedinia 的 Android 自适应图标资产。
- `simplify_and_minify_svg.py` – 通过 Inkscape 最小化 SVG 图标。
- `pack_all_backends.sh` / `.ps1` – 将带有每个后端启动脚本的全后端 krokiet 二进制打包成发布 zip。
- `flathub.sh` – 为 Flathub 清单生成 Flatpak cargo-sources 元数据。
- `add_icon_exe/` – Cargo 助手 crate，在构建时将 `.ico` 嵌入 Windows 二进制。
- `docker/` – 用于容器化构建的 `Dockerfile`。
- `nix/` – 用于 Nix 构建的 Nix flake（`flake.nix`、`packages.nix`）。
- `install_scripts/` – 终端用户安装程序：`install_linux.sh`、`install_macos.sh`、`install_windows.bat`。

**开发实用工具：**

- `remove_comments.py` – 从源文件中删除注释（一次性清理工具）。
- `compare_files.sh` – 对 CI 构建工件的 MD5 哈希进行差异比较，以检查确定性。
- `run_checks.sh` – 运行上述所有死代码检测脚本；由 `just fix` 调用。

**基准测试**（独立的 Cargo crate）：

- `test_image_perf/`、`test_read_perf/` – 图像哈希/文件读取的微基准测试。
- `test_compilation_speed_size/` – 跟踪更改的构建时间和二进制大小。

---

## i18n

所有用户可见字符串都使用 [Fluent](https://projectfluent.org/)（`.ftl` 文件）。

| 项目      | 宏    | 文件模式                                |
|-----------|-------|-----------------------------------------|
| krokiet   | `flk!` | `krokiet/i18n/<lang>/krokiet.ftl`       |
| cedinia   | `flc!` | `cedinia/i18n/<lang>/cedinia.ftl`       |
| czkawka_core | `flc!` | `czkawka_core/i18n/<lang>/czkawka_core.ftl` |
| czkawka_gui  | `flg!` | `czkawka_gui/i18n/<lang>/czkawka_gui.ftl`   |

英语是源/回退语言。所有其他语言环境均经 AI 翻译，然后经过验证。

**重要：** 仅直接在此仓库中编辑英语 `.ftl` 文件（`i18n/en/`）。所有其他语言文件通过 [Crowdin](https://crowdin.com/) 管理，在从 Crowdin 拉取翻译时将被 **覆盖**。对非英语 `.ftl` 文件的任何手动编辑在下次运行 `just unpack_translations` 时都将丢失。

---

## Slint UI 约定

- **用于宽度测量的隐藏 Text 元素** – 当布局元素必须根据翻译的标签文本调整其宽度时，添加屏幕外的 `Text` 实例（`x: -10000px; y: -10000px; height: 0`），并在运行时计算 `preferred-width`（见 `LeftSidePanel`、`CompareInfoBar`）。
- **枚举优于字符串** – 采用固定值集合的 UI 状态应使用 Slint `enum`，而非 `string`（例如 `ConfirmPopupAction`、`ActiveTool`、`ScanState`）。
- **全局状态** – 应用程序范围的状态位于 Slint `global` 块中（`GuiState`、`AppState`、`Settings`、`Translations` 等）。Rust 通过 `app.global::<GlobalName>()` 读取/写入。

---

## 构建配置（Cargo.toml）

| 配置文件 | 目的 |
|----------|------|
| `release` | 标准发布 |
| `fast_release` | 增量，已剥离 – 快速迭代 |
| `rdebug` | 发布 + 完整调试符号（分析） |
| `fastest` | 最大优化，LTO，panic=abort – 主要用于基准/POC 展示其能有多快 |
| `fastci` | 小二进制，快速 CI 构建 |

---

## justfile 快速参考

```
just run krokiet          # 调试运行
just runr krokiet         # fast_release 运行
just fix                  # 格式化 + clippy + Python 检查
just translate            # AI 翻译所有项目
just validate_translations [--fix]
just pack_translations    # 为 Crowdin 创建 i18n_translations.zip
just unpack_translations <path>
just android              # 构建 + 安装 + 在设备上启动
just androidr             # 发布变体
```
