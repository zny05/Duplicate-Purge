
![krokiet_logo](../icon.jpeg)

Krokiet 是一个用 Slint 编写的新 Czkawka 前端。

![Krokiet](../icon.jpeg)

与之前的 GTK 4 前端相比，它旨在跨所有平台（Linux、Windows、macOS）提供更一致的体验。

## 如何安装？

预构建二进制文件适用于 Windows 10/11、Mac 和 Ubuntu 22.04（基础版）/24.04（带附加库），或具有相同/更新的 glibc/库版本的发行版。

您可以从 https://github.com/qarmin/czkawka/releases/ 下载，其中包含根据您的需求选择变体的建议。

## 要求

预构建二进制文件没有强制运行时依赖项。

可选功能需要在编译前安装原生库：

| 功能   | 库               | 用途                  |
|--------|------------------|-----------------------|
| `heif` | `libheif`        | HEIF/HEIC 图像支持    |
| `libraw` | `libraw`      | RAW 相机图像支持      |
| `libavif` | `libavif`, `libdav1d` | AVIF 图像支持      |

相似视频工具在运行时需要 **ffmpeg**。

### Linux（Ubuntu / Debian）

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

- ffmpeg：`choco install ffmpeg` 或从 [ffmpeg.org](https://ffmpeg.org/download.html#build-windows) 下载，并将 `ffmpeg.exe` 放在您的 `PATH` 中。
- `heif` 和 `libraw` 功能在 Windows 上很难设置，且在预构建二进制文件中不可用（有一些非官方构建启用了这些功能）。

## 编译

另一种选择是自行编译。

编译最新版 Krokiet 最简单的方法是运行

```
cargo install krokiet --locked
```

它将安装最新的优化版 Krokiet。

使用 `cargo build --release` 编译应生成一个可用的二进制文件，无需任何额外依赖即可在用户操作系统上运行。

要启用对额外图像格式的支持，请使用可选功能编译：

```shell
cargo build --release --bin krokiet --features "heif,libraw,libavif"
```

如果您已安装新版 `cargo`，可以通过 `cargo install krokiet` 轻松编译并安装它。

## 其他渲染器

默认情况下，仅启用 femtovg（OpenGL）和软件渲染器，但您可以通过编译应用并添加额外功能来启用更多渲染器。

大多数用户希望在窗口系统/合成器上使用该应用，因此建议启用名称以 `winit` 开头的功能。

例如：

```
cargo build --release --features "winit_skia_opengl"
cargo build --release --features "winit_software"
```

要使用不同的渲染器运行应用，请设置 `SLINT_BACKEND` 环境变量（但应用必须已编译相应功能）：

```
SLINT_BACKEND=winit-femtovg ./target/release/krokiet
SLINT_BACKEND=software ./target/release/krokiet
SLINT_BACKEND=skia ./target/release/krokiet
```

如果使用无效或不存在的后端，应用会显示警告：

```
slint winit: unrecognized renderer skia, falling back to FemtoVG
```

要检查实际使用的后端，请添加 `SLINT_DEBUG_PERFORMANCE=refresh_lazy,console,overlay` 环境变量：

```
SLINT_DEBUG_PERFORMANCE=refresh_lazy,console,overlay cargo run
```

您应该看到类似的输出：

```
Slint: Build config: debug; Backend: software
```

## 为何创建新前端而非改进现有的 Czkawka GTK 4 应用？

对许多人来说，放弃 Czkawka 现有的 GTK 4 前端并替换为基于相对不那么知名的 Slint 的新前端，似乎令人惊讶，尤其是考虑到 GTK 是最流行的 GUI 框架之一。

此决定由几个关键因素驱动：

- **GTK 在 Windows 和 macOS 上性能较差** - 存在随机 bug，这些 bug 在 Linux 或类似环境的其他系统上不会出现。另一方面，Slint 在所有平台上表现一致且可靠。
- **编译和交叉编译复杂** - 由于 GTK 在 Windows 上的复杂性，编译该应用程序的最简单方法是使用带有 Linux 的 Docker 镜像。这使得在 Windows 上进行测试和调试要困难得多。
- **外部依赖** - 我喜欢下载后即可运行、无需安装的应用程序。使用 GTK 时，这种情况很少见。在 Linux 和 macOS 上，必须先安装几个动态链接库，并且它们在不同系统上可能存在不同版本。在 Windows 上，您通常需要手动包含 DLL。如果 GTK 团队正式分发这些库并维护所需文件列表，这本来不成问题，但他们并没有这样做，因此您只能自己编译一切，或者像我一样依赖外部 Docker 镜像。使用 Slint，我只需要一个单一的二进制文件，它几乎可以在任何系统上开箱即用。
- **跨平台 GTK 版本碎片化** - 在 Linux 上，GTK 是动态链接的，不同版本可能引入独特的 bug 或不一致性。在 Windows 上，库是打包的，但在我的应用中过时了，因为我使用的 Docker 镜像中没有更新版本，并且某些版本在某些操作系统上会崩溃。macOS（使用 Homebrew）处境最好，因为它通常保持 GTK 更新。使用 Slint，每个 Krokiet 版本都打包了最新的 Slint 版本，确保所有系统的一致性并减少平台特定问题。
- **Cambalache 是唯一的无代码 GUI 工具** - 虽然 Cambalache 本身工作得相当不错，但它不是由 GTK 团队官方支持或维护，而是由独立开发者维护。相比之下，虽然 Slint GUI 大多是通过代码创建的，但它提供 VS Code/VSCodium 中的实时预览，这非常方便。
- **难以修改内置小部件** - GTK 强制执行特定的视觉样式，这可能非常限制。就我而言，我不得不调整内置小部件参数才能达到想要的外观，这将来可能会造成很多问题。Slint 采取相反的方法：其内置小部件相当有限，这通常使从头构建完全自定义组件更容易。
- **GTK 仍然是 C 代码** - 尽管该库被包装并提供了相对安全的 Rust 接口，但您仍然偶尔需要处理低级结构，这在过去曾给我带来问题和崩溃。另一个缺点是，即使代码正确，也会因内部 GTK 问题向控制台打印大量警告。这些警告通常无帮助，很少帮助识别实际 bug。

## 许可证

代码根据 MIT 许可证授权，但由于 Slint 许可证限制，整个项目根据 GPL-3.0 许可。

所有图标和图片均根据 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可。

## 名称

为什么是 Krokiet（英语：Croquette）？
因为我喜欢炸薯饼（波兰版），那种用面包屑裹着肉和蘑菇的……让人垂涎欲滴。
我还考虑过其他我喜欢的菜肴，例如 pierogi、żurek、pączek、schabowy 或 zapiekanka。
这个名字应该比 czkawka 或 szyszka 容易记住得多。
