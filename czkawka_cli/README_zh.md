# Czkawka CLI

允许你从终端使用 Czkawka 的 CLI 前端。

## 要求

预构建二进制文件应在 Linux（Ubuntu 22.04+）、Windows（10+）和 macOS（10.15+）上无需任何额外依赖即可工作。

在 Linux 上，甚至可以（使用 eyra）完全避免 libc 并使用完全静态的 Rust 二进制文件，或者你也可以使用 musl 完成此任务。

如果你想使用 similar videos 工具，需要安装 ffmpeg（运行时依赖）。
如果你想使用 heif/libraw/libavif（构建/运行时依赖），需要安装所需的软件包。

- macOS: `brew install ffmpeg libraw libheif libavif dav1d` - [ffmpeg formula](https://formulae.brew.sh/formula/ffmpeg)
- Linux: `sudo apt install ffmpeg libraw-dev libheif-dev libavif-dev libdav1d-dev`
- Windows: `choco install ffmpeg` - 如果不起作用，请从 [ffmpeg.org](https://ffmpeg.org/download.html#build-windows) 下载并解压到 `czkawka_cli.exe` 所在位置。`heif` 和 `libraw` feature 在 Windows 上很难设置，且预构建二进制文件中不可用（有一些非官方构建启用了此功能）。

## 编译

要编译，你需要通过 [rustup](https://rustup.rs/) 安装 Rust。然后构建：

```shell
cargo run --release --bin czkawka_cli
```

你可以启用额外的 feature：

```shell
cargo run --release --bin czkawka_cli --features "heif,libraw,libavif"
```

## 使用方法

应用程序为每个工具包含简洁的帮助，你可以运行以下命令查看：
```
czkawka_cli --help
```
你也可以运行以下命令获取特定工具参数的详细信息，例如：
```
czkawka_cli dup --help
```

示例用法：
```shell
czkawka dup -d /home/rafal -e /home/rafal/Obrazy  -m 25 -x 7z rar IMAGE -s hash -f results.txt -D aeo
czkawka empty-folders -d /home/rafal/rr /home/gateway -f results.txt
czkawka big -d /home/rafal/ /home/piszczal -e /home/rafal/Roman -n 25 -x VIDEO -f results.txt
czkawka empty-files -d /home/rafal /home/szczekacz -e /home/rafal/Pulpit -R -f results.txt
czkawka temp -d /home/rafal/ -E */.git */tmp* *Pulpit -f results.txt -D
czkawka music -d /home/rafal -e /home/rafal/Pulpit -z "artist,year, ARTISTALBUM, ALBUM___tiTlE"  -f results.txt
czkawka symlinks -d /home/kicikici/ /home/szczek -e /home/kicikici/jestempsem -x jpg -f results.txt
```

## 许可证

MIT
