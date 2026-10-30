# Czkawka Core

`czkawka_core` 实现了所有扫描工具（重复文件、空文件夹、相似图像、相似视频、损坏文件等）。它没有 UI 依赖，并设计为可嵌入到任何前端。

## 要求

基础构建没有强制性的原生依赖 - 它是纯 Rust。

可选 feature 需要额外的原生库：

| Feature | 库 | 用途 |
|---------|-----|------|
| `heif` | `libheif` | HEIF/HEIC 图像支持 |
| `libraw` | `libraw` | RAW 相机图像支持 |
| `libavif` | `libavif`, `libdav1d` | AVIF 图像支持 |

`similar_videos` 工具在运行时需要 **ffmpeg**（不是构建依赖）。

### Linux (Ubuntu / Debian)

```shell
# Runtime: similar videos
sudo apt install ffmpeg 

# Optional build + runtime: extra image formats
sudo apt install libheif-dev libraw-dev libavif-dev libdav1d-dev
```

### macOS

```shell
brew install ffmpeg libraw libheif libavif dav1d
```

### Windows

- ffmpeg: `choco install ffmpeg` 或从 [ffmpeg.org](https://ffmpeg.org/download.html#build-windows) 下载并将 `ffmpeg.exe` 放置在你的 `PATH` 中。
- `heif` 和 `libraw` feature 在 Windows 上很难设置，且预构建二进制文件中不可用（有一些非官方构建启用了此功能）。

## 编译

```shell
# Base (no optional features)
cargo build --release -p czkawka_core

# With all optional image format features
cargo build --release -p czkawka_core --features "heif,libraw,libavif"
```

## 许可证

MIT
