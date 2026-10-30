# Instruction

Czkawka 由几个共享共同核心库的独立前端组成。每个前端都有自己的专门指南：

- [Krokiet GUI (Slint 前端)](Instruction_Krokiet.md) - 所有平台推荐的 GUI
- [CLI (命令行前端)](Instruction_CLI.md) - 完整的标志参考和自动化示例
- [GTK GUI (旧版)](Instruction_GTK.md) - **12.0 是最后一个版本**，迁移到 Krokiet
- [核心库集成](Instruction_Core.md) - 工具描述、API、嵌入 czkawka_core
- [常见问题解答](FAQ.md) - 来自 1200 多个 GitHub 问题的常见问题（空白窗口、ffmpeg、最小文件大小等）
- [翻译](Translations.md) - 如何贡献或添加新语言

---

## 术语（所有前端共享）

- **参考路径**
  - 添加目录或文件后，可以在 UI 中通过勾选旁边的复选框，或在 CLI 中使用相应标志，将其标记为“参考路径”。
  - 参考路径用于比较，但受保护：任何自动操作在 UI 或 CLI 中都无法修改、移动或删除它们。
  - 支持的工具：重复文件、相似图像、相似视频、同类音乐。
  - 用例：将工作文件夹与主备份比较，在删除重复项时保护原始文件，将数据集用作只读基线。

- **包含/排除路径**
  - 包含路径是工具扫描的目录。排除路径在扫描期间被明确忽略。

- **排除项目**
  - 针对完整文件和目录路径匹配的通配符模式（例如 `*/tmp*`、`*/.git`）。比排除路径更灵活，但略慢一些。

- **配置与缓存**
  - 配置文件是每个前端特有的。配置在 GTK、Krokiet 和 CLI 之间不共享。
  - 缓存文件在所有前端之间共享。它们包含计算的数据（哈希值、缩略图、分析结果），存储在共享缓存目录中，以便所有前端都能重用计算结果。

---

## 配置/缓存文件

**配置文件（每个前端，不共享）：**

- GTK 在用户配置目录下存储 `czkawka_gui_config.txt`。
- Krokiet 在用户配置目录下存储 `config_general.json` 和 `config_preset_N.json`（Linux 上为 `~/.config/krokiet/`）。
- CLI 不存储配置文件。

**缓存文件（所有前端共享）：**

缓存包含计算结果（哈希值、缩略图、解析的元数据），并共享以避免重新计算。

重要文件：
- `cache_similar_image_SIZE_HASH_FILTER.bin/.json` - 图像哈希
- `cache_duplicates_HASH.txt` - 重复文件哈希
- `cache_similar_videos.bin/.json` - 视频签名
- `cache_broken_files.txt` - 损坏文件检查结果

JSON 格式的缓存文件可以手动编辑（在将集合移动到不同磁盘或机器时有用）。要生成它们，请在设置中启用“另保存为 JSON”。默认加载 `.bin` 文件；如果缺失，则使用 `.json` 回退。

**默认路径（GTK 和 CLI 对配置和缓存都使用“Czkawka”；Krokiet 对配置使用“Krokiet”，对缓存使用“Czkawka”）：**

| OS | GTK/CLI 配置 | Krokiet 配置 | 缓存（所有前端） |
|----|-------------|-------------|-----------------|
| Linux | `~/.config/czkawka/` | `~/.config/krokiet/` | `~/.cache/czkawka/` |
| macOS | `~/Library/Application Support/pl.Qarmin.Czkawka/` | `~/Library/Application Support/pl.Qarmin.Krokiet/` | `~/Library/Caches/pl.Qarmin.Czkawka/` |
| Windows | `%APPDATA%\Qarmin\Czkawka\config\` | `%APPDATA%\Qarmin\Krokiet\config\` | `%LOCALAPPDATA%\Qarmin\Czkawka\cache\` |

使用环境变量覆盖：

```shell
CZKAWKA_CONFIG_PATH="/media/rafal/Ventoy/config" CZKAWKA_CACHE_PATH="/media/rafal/Ventoy/cache" krokiet
```

便携式设置脚本（放在 USB 驱动器二进制文件旁边）：

```shell
#!/bin/bash
CZKAWKA_CONFIG_PATH="$(dirname "$(realpath "$0")")/config"
CZKAWKA_CACHE_PATH="$(dirname "$(realpath "$0")")/cache"
./krokiet
```

---

## 技巧、技巧和已知错误

- **LTO 加速**  
  添加到 `Cargo.toml` 以获得小幅性能提升和显著二进制文件大小减少：
  ```toml
  [profile.release]
  lto = "thin" # 或 "fat"
  ```

- **原生 CPU 指令加速**  
  使用原生 CPU 优化编译，可使 x86_64-v4 上的图像哈希提升 10-20%：
  ```shell
  RUSTFLAGS="-C target-cpu=native" cargo build --release
  ```
  或者在 `~/.cargo/config.toml` 中全局设置：
  ```toml
  [target.x86_64-unknown-linux-gnu]
  rustflags = ["-C", "target-cpu=native"]
  ```

- **缓存加载缓慢**  
  如果加载缓存很慢（之前扫描了一个非常大的集合），重命名或删除相关的缓存文件（例如 `cache_similar_image_*.bin`）。缓存将在下次扫描时，仅使用当前扫描的条目重新生成。

- **部分扫描**  
  你可以随时停止扫描。所有已计算的哈希值已经写入缓存，并将加速下一次完整扫描。

- **预哈希缓存**  
  缓存大文件的部分哈希（开头和结尾 4 KB），以便重新扫描时仅需对新文件或已更改的文件进行完整哈希。**默认在 Krokiet 中启用。** 在 CLI 中必须使用 `--use-prehash-cache` 显式启用。如果缓存文件大小是一个问题，请禁用它。

- **可移动驱动器的缓存**  
  当你定期取出外部驱动器时，禁用“自动删除过时的缓存条目”。改用“删除过时的结果”手动操作，以避免在断开连接时条目被驱逐。
