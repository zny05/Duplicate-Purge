![czkawka_logo](https://user-images.githubusercontent.com/41945903/102616149-66490400-4137-11eb-9cd6-813b2b070834.png)

Czkawka GUI 是 Czkawka Core 的图形用户界面，基于 GTK 4 构建。

![Screenshot from 2023-11-26 12-43-32](https://github.com/qarmin/czkawka/assets/41945903/722ed490-0be1-4dac-bcfc-182a4d0787dc)

## 废弃通知 - 12.0 是最后一个版本

**版本 12.0 是 Czkawka GTK 的最后一个发布版本。** 不会再提供新的二进制文件。鼓励所有用户迁移到 [Krokiet](../krokiet/README.md)，即新的基于 Slint 的 GUI。

源代码仍保留在仓库中，且与 `czkawka_core` 的兼容性将维持一段时间，因此应用程序仍可手动构建。但是，所有特定于 Czkawka GTK 的问题和功能请求将被关闭，除非是影响 Debian 或 Docker 等广泛使用的非官方构建的关键问题。

## 要求

要求取决于您的平台。

预构建二进制文件可在此处下载：https://github.com/qarmin/czkawka/releases/

诸如 HEIF、libraw 和 libavif 等附加功能需要安装额外的库，这可能会增加依赖数量。

### Linux

#### 预构建二进制 / 自行编译

Ubuntu:  
`sudo apt install libgtk-4-bin libheif1 libraw-bin ffmpeg -y`

### macOS

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gtk4 ffmpeg librsvg libheif libraw dav1d
```

### Windows

#### 预构建二进制

所有必需的库都已打包在 zip 中（ffmpeg 除外，您可以手动安装并将 `ffmpeg.exe` 放在系统 PATH 包含的目录中）。

## 安装

### 预构建二进制（所有操作系统）

安装所需的依赖后，从 [发布页面](https://github.com/qarmin/czkawka/releases) 下载适用于您平台的预构建二进制文件。

### Linux

#### Flatpak

```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.qarmin.czkawka
```

#### Debian 软件包（非官方）

需要 Debian 13（或衍生版本）或更高版本。
```
sudo apt install czkawka_gui
```

#### PPA（非官方） - 基于 Debian 的发行版（Ubuntu、Linux Mint 等）

```
sudo add-apt-repository ppa:xtradeb/apps
sudo apt update
sudo apt install czkawka
```

[PPA 页面](https://launchpad.net/~xtradeb/+archive/ubuntu/apps)

### macOS

#### Homebrew（非官方）

```
brew install czkawka
```

[Formula 页面](https://formulae.brew.sh/formula/czkawka)

### Windows

#### MSYS2（非官方）

```
pacman -S mingw-w64-x86_64-czkawka-gui
```

[Package 链接](https://packages.msys2.org/base/mingw-w64-czkawka)

该文件应安装到 `C:\msys64\mingw64\bin\czkawka_gui.exe`，并可从那里运行。  
此版本在 Windows 上可能功能最完整，因为它启用了可选功能进行编译。

## 编译

编译 GUI 比编译 CLI、core 或 Krokiet 更复杂，因为它使用 GTK4（用 C 编写）并需要许多构建和运行时依赖项。

### 要求

| Program | Minimal version |
|:-------:|:---------------:|
|  Rust   |     1.94.1      | 
|   GTK   |       4.6       |

Rust 版本对应 Debian Sid 中可用的最新 rustc：https://packages.debian.org/sid/rustc

### Linux（Ubuntu；类似步骤适用于其他发行版）

```shell
sudo apt install libgtk-4-dev -y # Base
sudo apt install libgtk-4-dev libheif-dev libraw-dev libavif-dev libdav1d-dev -y # With features
cargo run --release --bin czkawka_gui
# Or with support for heif, libraw, libavif
cargo run --release --bin czkawka_gui --features "heif,libraw,libavif"
```

### macOS

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install rustup gtk4 adwaita-icon-theme ffmpeg librsvg libheif libraw dav1d pkg-config
rustup-init
cargo run --release --bin czkawka_gui
# Or with support for heif, libraw, libavif
cargo run --release --bin czkawka_gui --features "heif,libraw,libavif"
```

### Windows

目前，没有在 Windows 上原生编译该应用程序的说明。</br>
您可以查看 CI 以了解如何从 Linux 到 Windows 交叉编译该应用程序（使用预构建的 Docker 镜像）：[CI 说明](../.github/workflows/windows.yml)</br>
还有一个 mingw 配方，您可以尝试根据需要进行调整：https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-czkawka/PKGBUILD

## 限制

并非所有功能和组件都在此实现。主要限制如下：

- Windows 版本的预构建二进制文件不支持 HEIF 和 WebP 文件（MSYS2 版本支持）。
- 在 Windows 上，高分辨率显示器上的文本可能显得非常小。您可以手动更改此应用的 DPI 缩放：
    - [推荐修复](https://github.com/qarmin/czkawka/issues/787#issuecomment-1292253437)（修改 gtk.css）
    - [替代变通方案](https://github.com/qarmin/czkawka/issues/863#issuecomment-1416761308)（修改此应用的 Windows DPI 设置；此方法也有效，但文本可能会模糊一些）。

## 许可证

代码根据 MIT 许可证分发。

图标由 [jannuary](https://github.com/jannuary) 创建，并根据 CC-BY-4.0 许可。

Windows 深色主题来自 [WhiteSur](https://github.com/slypy/whitesur-gtk4-theme) 项目，根据 MIT 许可。

该程序完全免费使用。

"Gratis to uczciwa cena" - "免费是公平的价格"

## 名称

Czkawka 是一个波兰语单词，意为“打嗝”（hiccup）。

我选择这个名字是因为我想听听其他语言的人如何发音它，所以请随心所欲地发音。

这个名字并不像看起来那么难；我还考虑过 _żółć_、_gżegżółka_ 或 _żołądź_ 等单词，但决定不选，因为它们包含波兰语字符，这会使搜索项目更加困难。

项目初期，如果对名称的反应一致是负面的，我准备更改它，但意见极不一致。
