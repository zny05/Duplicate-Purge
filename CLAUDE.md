# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is **Czkawka / Duplicate-Purge**, a fast, cross-platform duplicate-file finder written in Rust (edition 2024, minimum Rust 1.94.1, Cargo workspace resolver v3). It consists of a shared scanning engine (`czkawka_core`) plus several frontends:

- `czkawka_core` — shared scanning library, no UI dependency, used by every frontend
- `czkawka_cli` — command-line frontend (clap + indicatif)
- `czkawka_gui` — legacy GTK 4 GUI, maintenance mode only (no new features)
- `krokiet` — primary desktop GUI (Slint, GPL-3.0), cross-platform
- `cedinia` — Android/mobile GUI (Slint, `cdylib` for Android)

The two non-negotiable project properties are **performance first** (rayon parallelism, blake3 hashing, minimal allocations) and **minimal non-Rust dependencies** (native libraries like libheif/libraw are gated behind optional Cargo features).

The root `AGENTS.md` is the authoritative style guide and applies to every crate. The most important rules it sets:

- All code, comments, commit messages, and docs must be **English**.
- Every AI-authored commit/PR title must start with `[AI] `.
- Never use em/en/horizontal-dash characters (`—`, `–`, `─`, `…`) in code, comments, or commit messages — plain `-` only (ASCII box drawings excepted). `just fix` enforces this automatically.
- `unwrap()` only in tests; `expect()` in production only when no recovery is possible.
- Prefer `?`, iterators, `Cow`, and `#[derive(...)]`; avoid unnecessary copies.
- Keep source files at or below 500 lines; split large files into modules.
- Log via `log` (`handsome_logger`), not `tracing`.

## Commonly used commands

The project provides a `justfile` with recipe shortcuts, but everything can also be run with plain `cargo`.

### Build

| Command | What it does |
|---|---|
| `cargo build` | Debug build of the whole workspace |
| `cargo build --release` | Optimized release build |
| `cargo build --bin krokiet --release` | Build the krokiet binary |
| `just run krokiet` | Debug run (`cargo run --bin krokiet`) |
| `just runr krokiet` | fast_release run (`cargo run --profile fast_release --bin krokiet`) |
| `cargo install --path czkawka_cli --locked` | Install the CLI |

Optional features (gated native deps): `heif`, `libraw`, `libavif`. Krokiet renderer backends: `winit_skia_opengl`, `winit_skia_vulkan`, `winit_femtovg`, `femtovg_wgpu`, `winit_software`. Example:

```
cargo build --release --bin krokiet --features "heif,libraw,libavif"
cargo run --release --bin krokiet --no-default-features --features "winit_skia_opengl,winit_software"
```

### Lint / format (the quality gate)

**Mandatory after any coding task: run `just fix` and resolve everything it reports.** It runs, in order:

1. Auto-fix of `—`/`–`/`─`/`…` → plain `-`/`.` (excludes `AGENTS.md` and `justfile`)
2. `uv run ruff format --line-length 120` (Python in `misc/`)
3. `uv run mypy misc --strict`
4. `bash misc/run_checks.sh` (dead-code checks: unused fluent/slint translations, callbacks, settings properties, dead slint imports)
5. `cargo +nightly fmt`
6. `cargo clippy --fix --all-features --all-targets`
7. `cargo +nightly fmt` + `cargo fmt`

For clippy covering both feature builds, run `just clip` separately (`--all-features` and `--no-default-features --features winit_software`).

CI-equivalent checks you can run locally:

```
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo clippy --all-targets -- -D warnings
```

### Tests

| Command | What it does |
|---|---|
| `just test` | Run all normal (non-ignored) workspace tests: `cargo test --workspace` |
| `just ignored` | Run only `#[ignore]`-marked tests: `cargo test --workspace -- --ignored` |
| `cargo test -p czkawka_core` | Tests for one crate only |
| `cargo test -p czkawka_core duplicate::tests::test_name -- --exact` | Run a single test by path |
| `cargo test test_name` | Run a single test by name (workspace-wide) |

CI runs tests on Linux with `xvfb-run cargo test --all-features` and on Windows with `cargo test -p czkawka_core -p krokiet` (GTK GUI and extra features are not testable on Windows due to environment setup).

### Regression / integration tests

The `ci_tester` crate runs end-to-end regression tests against the built CLI using a downloaded `TestFiles.zip`:

```
cargo build --release --bin czkawka_cli
cd ci_tester && cargo build --release && cd ..
ci_tester/target/release/ci_tester target/release/czkawka_cli
```

### Other useful justfile recipes

`just fixn` — format + clippy fix + format (nightly, no Python steps).  
`just bench` — run criterion benchmarks in `czkawka_core`.  
`just validate_translations [--fix]` — validate Fluent placeholder consistency.  
`just translate` — AI-translate all projects (requires `ollama` + `uv`).

## High-level architecture

### The core engine (`czkawka_core`)

This is the shared scanning library; frontends only configure tool structs and drive them. There are `TOOLS_NUMBER = 14` tools (duplicate, empty folders, empty files, invalid symlinks, broken files, bad extensions, bad names, big file, same music, similar images, similar videos, temporary files, exif remover, video optimizer), plus `None`.

Each tool lives in `src/tools/<name>/` with a consistent layout:

- `mod.rs` — tool struct, `Info`, `Parameters`
- `core.rs` — internal scanning functions
- `traits.rs` — `Search`, `CommonData`, `DeletingItems`, `PrintResults`, `FixingItems` impls
- `tests.rs` — unit tests

Key traits (in `src/common/traits.rs`, except `CommonData` which is in `src/common/tool_data.rs`):

- `Search::search(...)` — the main scan entry point, takes a stop flag and optional progress sender
- `CommonData` — settings access (directories, extensions, delete method, cache flags, …)
- `PrintResults` — CSV/JSON export
- `DeletingItems` / `FixingItems` — file operations
- `AllTraits` — umbrella trait combining all of the above

`CommonToolData` holds shared settings: `tool_type`, `text_messages` (warnings/errors), `directories`, `extensions`, `excluded_items`, `recursive_search`, `delete_method`, size limits, `stopped_search`, `use_cache`, `dry_run`, `move_to_trash`, etc.

`DirTraversal` (`src/common/dir_traversal.rs`) is the builder-pattern filesystem walker used by all tools: it groups entries by a key (e.g. file size), applies extension/exclusion/size filters during traversal, uses rayon `into_par_iter().with_max_len(2)` for parallel folder processing, and reports progress via a background `ProgressThreadHandler` (~200 ms interval).

Progress is reported as `ProgressData` with a nested, tool-specific `ToolStage` enum (so a stage can't be mismatched with the wrong tool). Cancellation uses an `Arc<AtomicBool>` stop flag polled via `check_if_stop_received()` with `Relaxed` ordering.

Caching (`src/common/cache.rs`): `bincode` serialization of `BTreeMap<String, T>` (keyed by canonical path), optionally also as JSON; entries validated by path + size + mtime on load; 8 GB serialization limit; each tool has its own version constant.

### Frontends

**krokiet** (primary GUI): Slint UI declared in `ui/*.slint`, compiled at build time by `slint_build`, exposed via `slint::include_modules!()`. Entry point `src/main.rs`. Callbacks follow the weak-reference pattern:

```rust
let weak = app.as_weak();
app.global::<Callabler>().on_some_action(move || {
    let app = weak.upgrade().expect("MainWindow dropped while callback is still live");
    // ...
});
```

Feature areas live in dedicated `connect_*.rs` files (e.g. `connect_scan.rs`, `connect_compare.rs`, `connect_delete_button.rs`). `SharedModels` (`src/shared_models.rs`, `Arc<Mutex<SharedModels>>`) holds the last scan result and parameters per tool, shared between UI and background threads. The UI model is `ModelRc<VecModel<SingleMainListModel>>` with flat `[string]` / `[int]` row vectors; column indices per tool are constants in `src/common.rs`. Translations use the `flk!` macro with `i18n/<lang>/krokiet.ftl`.

**cedinia** (Android/mobile GUI): mirrors krokiet but adapts to mobile. Android entry: `#[unsafe(no_mangle)] fn android_main(android_app: AndroidApp)` in `src/lib.rs`; desktop entry: `fn run_app()` in `src/app.rs`. Uses JNI (embedded Kotlin DEX via `include_bytes!`) for the file picker, `android_logger` for logcat, and `AppState.storage_permission_granted` to gate scanning. Uses `flc!` macro and `cedinia/i18n/<lang>/cedinia.ftl`. Notable difference: has `SimilarVideos` (audio fingerprint via rusty-chromaprint) but not `VideoOptimizer` (no ffmpeg on Android).

**czkawka_cli**: thin wrapper around `czkawka_core`, clap derive API, `indicatif` progress bars, results via `PrintResults`. No GUI code.

**czkawka_gui**: GTK 4, maintenance mode only — bug fixes to keep it compatible with core API changes are accepted, no new features.

### i18n

All user-visible strings use Fluent (`.ftl` files). English is the source/fallback; other locales are AI-translated via Crowdin and **must not be edited directly** — they are overwritten on `just unpack_translations`. Only `i18n/en/` files are edited in this repo.

| Project | Macro | File pattern |
|---|---|---|
| krokiet | `flk!` | `krokiet/i18n/<lang>/krokiet.ftl` |
| cedinia | `flc!` | `cedinia/i18n/<lang>/cedinia.ftl` |
| czkawka_core | `flc!` | `czkawka_core/i18n/<lang>/czkawka_core.ftl` |
| czkawka_gui | `flg!` | `czkawka_gui/i18n/<lang>/czkawka_gui.ftl` |

### Build profiles (`Cargo.toml`)

`release`, `fast_release` (incremental, stripped), `rdebug` (release + full debug symbols), `fastest` (max opt + LTO + panic=abort), `fastci` (small binary, fast CI), `test` (debug-assertions + opt-level 3). The workspace sets `overflow-checks = true` and `panic = "unwind"` in release because parsing many file types can trigger library panics.

Key dependencies: `rayon`, `crossbeam-channel`, `blake3`, `image`/`image_hasher`, `lofty`, `symphonia`, `rusty-chromaprint`, `bincode`, `zip`, `trash`, `directories-next`, `fun_time`, `similario_core` (video similarity). Slint frontends additionally depend on Slint and a renderer backend.

### Key files to know first

- `Cargo.toml` — workspace definition, profiles, workspace lints
- `justfile` — build/test/fix recipes
- `AGENTS.md` — mandatory style guide (read this before writing code)
- `czkawka_core/AGENTS.md` — core-specific architecture guide
- `.github/workflows/quality.yml` — CI format + clippy gate
- `.github/workflows/linux.yml`, `windows.yml`, `mac.yml`, `android.yml` — platform CI
- `misc/run_checks.sh` — dead-code detection invoked by `just fix`

## Conventions to remember

- Run `just fix` after every coding task; it must produce no stderr output and exit zero before a change is ready for review.
- Commit/PR titles from AI must start with `[AI] `.
- Translations: edit only `i18n/en/` `.ftl` files; never hand-edit other locales.
- Keep functions focused (~30–50 lines max); extract logical steps into named functions instead of comment-headed sections.
- Pre-allocate with `Vec::with_capacity`/`HashMap::with_capacity` when the count is roughly known; reuse buffers with `buf.clear()`.
- Use the smallest enum discriminant that fits (`#[repr(u8)]`) for hot-path enums.