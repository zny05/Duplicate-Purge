# 测试编译速度与大小
本项目用于获取不同配置下生成的 rust 二进制文件的编译速度和大小。

## 如何使用？
- 安装应用 `cargo install --path .`
- 配置 json 配置文件，如 `test.json` 或 `krokiet.json` - 允许的值可在 `src/model.rs` 中找到
- 进入你的项目根目录（如果项目在工作区中，则需要进入工作区根目录）
- 运行 `test_compilation_speed_size config.json`
- 修复可能出现的编译错误（混合某些编译标志可能导致编译错误）
- 使用 `sudo apt install python3-matplotlib python3-pandas python3-tabulate` 或类似命令安装 python 依赖
- 使用 `python3 generate_md_and_plots.py` 生成图表
- 生成的 md 和 png 文件将在 `charts` 文件夹中
