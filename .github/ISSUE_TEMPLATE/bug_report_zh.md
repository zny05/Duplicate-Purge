---
name: Bug 报告
about: 创建报告以帮助改进应用
title: ''
labels: bug
assignees: ''

---

<!-- Czkawka GTK GUI 不再受支持 - 版本 12.0 是最后一个发行版本，不会再提供新的二进制文件或修复。仅针对 Czkawka GTK GUI 报告的问题（在 Krokiet、Cedinia、CLI 或 czkawka_core 中无法复现）将被关闭。请改用 Krokiet：https://github.com/qarmin/czkawka/tree/master/krokiet -->

**Bug 描述**

**复现步骤：**
<!-- 请描述你期望看到的和实际看到的情况。如有需要，请附上截屏或录屏。 -->

**终端输出**（可选）：

```
<!--
Add terminal output only if needed - if there are some errors or warnings or you have performance/freeze issues.  
Very helpful in this situation will be logs from czkawka run with RUST_LOG environment variable set e.g. 
`RUST_LOG=debug ./czkawka` or `flatpak run --env=RUST_LOG=debug com.github.qarmin.czkawka` if you use flatpak, which will print more detailed info about executed function.
-->

<details>
<summary>Debug log</summary>

# UNCOMMENT DETAILS AND PUT LOGS HERE

</details>
```

**系统**

<!-- OS 和 Czkawka/Krokiet 版本以及其他操作系统信息 - 你可以从日志中复制（在终端运行应用或手动查找日志文件）
(Linux: `/home/username/.cache/czkawka`,
macOS: `/Users/Username/Library/Caches/pl.Qarmin.Czkawka`,
Windows: `C:\Users\Username\AppData\Local\Qarmin\Czkawka\cache`).
注意：确切路径取决于安装方式（可从 GUI 打开配置/缓存路径）。 -->
<!-- 日志示例：-->
<!-- Krokiet 版本: 12.0.2, 调试模式, rust 1.94.1 (2025-06-23), 操作系统 Ubuntu 25.4.0 (x86_64 64-bit), 24 个 cpu/线程, features(1): [fast_image_resize], 应用 cpu 版本: x86-64-v3 (AVX2) 或 x86-64-v4 (AVX-512), 操作系统 cpu 版本: x86-64-v4 (AVX-512) -->
<!-- 配置文件夹设置为 "/home/rafal/.config/czkawka"，缓存文件夹设置为 "/home/rafal/.cache/czkawka" -->

- Czkawka/Krokiet 版本：<!-- 例如：12.0.2 cli/gui -->
- 操作系统版本：<!-- 例如：Ubuntu 22.04, Windows 11, Mac 15.1 ARM -->
- 安装方式：<!-- 例如：github binaries, flatpak, msys2 -->

<!-- 如果你使用 flatpak，请包含 `flatpak info com.github.qarmin.czkawka` 的输出结果。 -->
