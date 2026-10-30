<div align="center"><img src="icon.jpeg" alt="krokiet_logo" width="600" /></div>
	     
**Krokiet** ((IPA: [ˈkrɔcɛt]), "croquette" 在波兰语中) 新一代 GUI 前端，简单、跨平台、快速且免费的应用，用于从计算机中删除不必要的文件。


<div align="center"><img src="icon.jpeg" alt="czkawka_logo" width="600" /></div>

**Czkawka** (_tch•kav•ka_ (IPA: [ˈʧ̑kafka]), "hiccup" 在波兰语中) 旧版 GTK4 GUI 前端，已被 Krokiet 取代。**版本 12.0 是最后一个发布版本** - 不再提供新的二进制文件。鼓励新用户和现有用户切换到 Krokiet。

<div align="center"><img src="icon.jpeg" alt="cedinia_logo" width="600" /></div>

**Cedinia** - 基于 Slint 的面向 Android 触摸的 Czkawka Core GUI 前端。

## 特性

- **使用内存安全的 Rust 编写** - 几乎 100% 无 unsafe 代码
- **速度惊人** - 由于多线程和高效算法
- **免费、开源，无任何广告**
- **多平台** - 运行在 Linux、Windows、macOS、FreeBSD、x86、ARM、RISC-V，甚至 Android 上
- **缓存支持** - 第二次及后续扫描应比第一次快得多
- **易于运行，易于编译** - 最小的运行时和构建依赖，提供便携版
- **CLI 前端** - 用于轻松自动化
- **GUI 前端** - 使用 Slint 或 GTK 4 框架
- **核心库** - 允许在其他应用中复用功能
- **Android 应用** - 面向 Android 设备的触摸友好前端
- **无监视** - Czkawka 无法访问互联网，也不收集任何用户信息或统计数据
- **多语言** - 支持多种语言，如波兰语、英语或意大利语
- **多种工具**：
    - **重复文件** - 基于文件名、大小或哈希查找重复文件
    - **空文件夹** - 借助高级算法查找空文件夹
    - **大文件** - 在给定位置查找指定数量的最大文件
    - **空文件** - 在驱动器中查找空文件
    - **临时文件** - 查找临时文件
    - **相似图像** - 查找不完全相同的图像（不同分辨率、水印）
    - **相似视频** - 查找视觉相似的视频
    - **相同音乐** - 按标签或按读取内容并比较来搜索相似音乐
    - **无效符号链接** - 显示指向不存在的文件/目录的符号链接
    - **损坏文件** - 查找无效或损坏的文件
    - **错误扩展名** - 列出内容与扩展名不匹配的文件
    - **Exif 移除** - 从各种文件类型中移除 Exif 元数据
    - **视频优化器** - 裁剪静态部分并将视频转换为更高效的格式
    - **错误名称** - 查找可能不需要的文件名（例如，包含特殊字符）

![Krokiet](icon.jpeg)

![Czkawka](icon.jpeg)

各版本的更改日志可在 [CHANGELOG.md](Changelog.md) 中找到。

新版本可在 [Github releases](https://github.com/qarmin/czkawka/releases) 找到，每夜构建也可在 [Nightly releases](https://github.com/qarmin/czkawka/releases/tag/Nightly) 找到。

您可以在以下文章中阅读更多关于 12.0 版、其新功能以及修复的问题：
- 英文文章 - https://medium.com/@qarmin/krokiet-czkawka-12-0-6fa09c43c3b9
- 波兰文文章 - https://medium.com/@qarmin/krokiet-czkawka-12-0-c5dad2116793

## 使用、安装、编译、要求、许可

每个工具使用不同的技术，因此每个工具的说明可在相应的文件中找到：

- [Krokiet GUI (Slint 前端)](krokiet/README.md)</br>
- [Czkawka GUI (GTK 前端)](czkawka_gui/README.md)</br>
- [Czkawka CLI](czkawka_cli/README.md)</br>
- [Czkawka Core](czkawka_core/README.md)</br>
- [Cedinia](cedinia/README.md)</br>

## 与其他工具的对比

在这个对比中请记住，即使应用具有相同的特性，它们的工作方式也可能不同（例如，一个应用可能比另一个应用有更多可选选项）。

|                           |   Krokiet   |   Czkawka   | Cedinia | FSlint |     DupeGuru      |  Bleachbit  |
|:-------------------------:|:-----------:|:-----------:|:-------:|:------:|:-----------------:|:-----------:|
|         语言         |    Rust     |    Rust     |  Rust   | Python |   Python/Obj-C    |   Python    |
|  框架基础语言  |    Rust     |      C      |  Rust   |   C    | C/C++/Obj-C/Swift |      C      |
|         框架         |    Slint    |    GTK 4    |  Slint  | PyGTK2 | Qt 5 (PyQt)/Cocoa |   PyGTK3    |
|            OS             | Lin,Mac,Win | Lin,Mac,Win | Android |  Lin   |    Lin,Mac,Win    | Lin,Mac,Win |
|     查找重复文件      |      ✔      |      ✔      |    ✔    |   ✔    |         ✔         |             |
|        空文件        |      ✔      |      ✔      |    ✔    |   ✔    |                   |             |
|       空文件夹       |      ✔      |      ✔      |    ✔    |   ✔    |                   |             |
|      临时文件      |      ✔      |      ✔      |    ✔    |        |                   |      ✔      |
|         大文件         |      ✔      |      ✔      |    ✔    |        |                   |             |
|      相似图像       |      ✔      |      ✔      |    ✔    |        |         ✔         |             |
|   相似视频(音频)   |      ✔      |      ✔      |    ✔    |        |                   |             |
|  相似视频(帧)   |      ✔      |      ✔      |         |        |                   |             |
|  音乐重复(标签)   |      ✔      |      ✔      |    ✔    |        |         ✔         |             |
| 音乐重复(内容) |      ✔      |      ✔      |    ✔    |        |                   |             |
|     无效符号链接      |      ✔      |      ✔      |         |   ✔    |                   |             |
|       损坏文件        |      ✔      |      ✔      |    ✔    |        |                   |             |
| 无效名称/扩展名 |      ✔      |      ✔      |    ✔    |   ✔    |                   |             |
|       Exif 清理器        |      ✔      |             |    ✔    |        |                   |             |
|      视频优化器      |      ✔      |             |         |        |                   |             |
|         错误名称         |      ✔      |             |    ✔    |        |                   |             |
|      名称冲突       |             |             |         |   ✔    |                   |             |
|    已安装包     |             |             |         |   ✔    |                   |             |
|          错误 ID           |             |             |         |   ✔    |                   |             |
|   未剥离的二进制   |             |             |         |   ✔    |                   |             |
|   冗余空格    |             |             |         |   ✔    |                   |             |
|     覆盖文件     |             |             |         |   ✔    |                   |      ✔      |
|     便携版本      |      ✔      |      ✔      |         |        |                   |      ✔      |
|    多语言     |      ✔      |      ✔      |    ✔    |   ✔    |         ✔         |      ✔      |
|       缓存支持       |      ✔      |      ✔      |    ✔    |        |         ✔         |             |
|   正在积极开发   |     Yes     |    No**     | Yes***  |   No   |  No<sup>*</sup>   |     Yes     |

<p><sup>*</sup> 最近有几个小的提交，最后一个版本发布于 2023 年</p> 
<p><sup>**</sup> Czkawka GTK 12.0 是最后一个发布版本 - 不再提供新的二进制文件</p>
<p><sup>***</sup> Cedinia 是一个 Android 应用，由于 Android 缺少 ffmpeg，视频工具不可用</p>

## 其他应用

互联网上有许多类似 Czkawka 的应用程序，它们在某些方面更好，在某些方面更差：

### GUI

- [DupeGuru](https://github.com/arsenetar/dupeguru) - 有很多可自定义选项
- [FSlint](https://github.com/pixelb/fslint) - 有点过时，但仍有一些 Czkawka 没有的工具
- [AntiDupl.NET](https://github.com/ermig1979/AntiDupl) - 显示比较图像的许多元数据
- [Video Duplicate Finder](https://github.com/0x90d/videoduplicatefinder) - 查找相似视频(惊人，不是吗)

### CLI

由于时间有限，最大重点放在 GUI 版本上，如果您在寻找非常出色且功能丰富的控制台应用程序，请看这些：

- [Fclones](https://github.com/pkolaczk/fclones) - 最快的查找重复文件的工具之一；它也是用 Rust 编写的
- [Rmlint](https://github.com/sahib/rmlint) - 漂亮的控制台界面，功能也丰富
- [RdFind](https://github.com/pauldreik/rdfind) - 快速，但用 C++ 编写 ¯\\\_(ツ)\_/¯


## 使用 Czkawka 的项目

Czkawka 通过名为 **`czkawka_core`** 的 crate 暴露其常用功能，可被其他项目复用。

它用 Rust 编写，并被所有 Czkawka 前端（`czkawka_gui`、`czkawka_cli`、`krokiet`、`cedinia`）使用。

它也被外部项目使用，例如：

- **Czkawka Tauri** - https://github.com/shixinhuang99/czkawka-tauri - 基于 Tauri 的 Czkawka GUI 前端。
- **page-dewarp** - https://github.com/lmmx/page-dewarp - 用于使用三次方曲面模型去扭曲文档图像的库。

还提供以下绑定：

- **Python** - https://pypi.org/project/czkawka/

一些项目作为 `czkawka_cli` 的包装器，而不直接依赖 `czkawka_core`，它们允许简单扫描并以 JSON 格式获取结果：

- **Schluckauf** - https://github.com/fadykuzman/schluckauf

## 致谢

特别感谢 Pádraig Brady，FSlint 的出色创建者，没有他的工作我就不会创建这个工具。

也感谢所有以各种可能方式为项目做出贡献的人。

我非常感谢创建 Czkawka 所依赖的 crate 的人，并因此努力报告错误以使其更好。

## 如何帮助？

- **创建问题** - 主要与错误、行为异常的功能等相关。正如您从问题跟踪器中看到的，有很多新功能的想法，但其中大多数要么难以实现，要么不符合项目的愿景，而项目的愿景随时间略微演变。
- **创建拉取请求** - 错误修复当然非常受欢迎。关于新功能，最好在实现之前与我商讨以确认它们是否符合项目愿景。作为外部脚本/项目用 Rust 实现的 POC 会很有用，尤其是对于更复杂的功能，以确保没有技术限制。
- **更新翻译** - 项目使用 Crowdin 平台，翻译可以在那里创建和更新。在新版本中缺少翻译的情况下，我使用机器翻译，这通常不准确，因此更新翻译备受赞赏。
- **为各种平台创建软件包** - 由于为每个新平台添加和维护支持存在困难，例如学习 deb 或 rpm 等软件包格式、创建安装程序和软件包，我决定主要专注于提供预构建二进制文件。但是，将项目在发行版存储库或 Chocolatey、Homebrew 或 Winget 等项目中可用，对于喜欢集中式存储库的用户来说将是有益的。
- **创建文章、视频、教程等** - 任何帮助人们更好地了解该程序及其功能的材料都受欢迎。
- **向朋友、家人、同事等推荐它** - 这可能是让项目更受欢迎的最简单方式，这也激励我继续开发这个程序。以下是在日常对话中自然提及该程序的几个示例方式：

**S** - 某人  
**Y** - 你

### 情况 1：

- **S** - 嘿 Anon，我的磁盘上有很多垃圾，我该怎么办？
- **Y** - 下载 Krokiet/Czkawka。它们完全免费，几乎在所有系统上都能运行。
- **S** - 谢谢老兄！

### 情况 2：

- **S** - 我好渴啊...
- **Y** - 你听说过 Krokiet/Czkawka 吗？
- **S** - 等等，什么？
- **Y** - Krokiet 和 Czkawka，以防你不知道，可以让你从磁盘上清理不必要的文件。它们完全免费...
- **S** - 那很好，但我口渴...
- **Y** - ...它们适用于 Windows、Linux 和 macOS，有些人甚至将它们移植到 FreeBSD 和 Android...

## AI 政策

该项目中的绝大部分代码是由我（qarmin）在未使用 AI 的情况下编写的。但是，随着 AI 工具的改进，能够显著简化开发并减少样板代码，我没有理由禁止使用它们。我还添加了 AGENTS.md 文件到仓库，以便 AI 工具更容易了解项目的风格和代码结构。

话虽如此，每个拉取请求，无论是否使用 AI 创建，都必须满足适当的质量标准。作者必须能够清楚地解释代码的作用，而不依赖 AI 来做出解释。我手动审核每个 PR 并测试每个更改，因此不正确的代码滑进来的风险很低。但为了避免浪费时间，请不要提交 AI Slop PR。

## 官方支持的项目

只有此仓库，[prebuild-binaries](https://github.com/qarmin/czkawka/releases)，以及 [crates.io](https://crates.io/crates/czkawka_gui) 和 [flathub](https://flathub.org/apps/com.github.qarmin.czkawka) 上的项目由我直接维护。

Czkawka 没有官方网站，因此不要相信任何声称是官方网站的网站。

如果您使用非官方来源的软件包，请确保它们是安全的。

## 许可

本仓库中的所有代码均根据 [MIT](https://mit-license.org/) 许可证授权。

所有图像和音频文件均根据 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可证授权。

Czkawka GTK GUI 和 CLI 应用程序根据 [MIT](https://mit-license.org/) 许可证授权，而 Krokiet 和 Cedinia（由于 Slint 许可证要求）根据 [GPL-3.0-only](https://www.gnu.org/licenses/gpl-3.0.en.html) 许可证授权。

## 捐赠

如果您正在使用该应用程序，我很感激您能为其进一步开发捐款，可以 [在此](https://github.com/sponsors/qarmin) 捐赠。

