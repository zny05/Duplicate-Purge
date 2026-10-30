<div align="center"><img src="../icon.jpeg" alt="cedinia_logo" width="600" /></div>

Cedinia 是一个新的 Android 触控友好型 GUI 前端，基于 Slint 构建，用于 Czkawka Core。

支持与 Krokiet 相同的扫描工具（重复文件、相似图片和视频、空文件和文件夹、大文件、无效扩展名、重复音乐等）。唯一缺失的功能是基于帧的相似视频检测、损坏视频文件检测以及视频优化，所有这些都需要 FFmpeg。

该名称指 972 年的 Cedynia 战役，这是一场对早期波兰国家具有重要意义的胜利。

<div align="center"><img src="../icon.jpeg" alt="cedinia_logo" width="1000" /></div>

## Installation

目前最简单的安装方式是从 Releases 页面下载最新的发布版 APK：https://github.com/qarmin/czkawka/releases

或者，也可以在此处下载最新的夜间构建版：https://github.com/qarmin/czkawka/releases/download/Nightly/cedinia.apk

目前尚未通过 F-Droid、Google Play 商店或其他应用商店分发，但我欢迎就此领域提出建议和贡献。

目前不计划支持其他操作系统（如 iOS）（虽然手动移植应该是可行的）

## Compilation / Setup

构建过程相对复杂且文档有限。可以参考 Android GitHub 工作流获取更多细节，但完整且最新的说明仍缺失。

## Known issues and missing features

- 键盘支持目前存在多个问题，原因是 Slint 中的 Bug
- 仅支持带特定宽高比的竖屏模式，可能在某些设备上（尤其是平板电脑）造成问题  

## AI usage

由于本项目涉及我不太熟悉的 Android 部分，我在开发中使用了 AI 辅助，主要用于通过 `jni-rs` 将本应用与 Android 桥接的代码。该代码已经过仔细测试。

## License

代码采用 MIT 许可证，但受 Slint 许可限制，整体项目按照 GPL-3.0 发布。

所有图标和图像均根据 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 许可证授权。
