# Czkawka Core - 库指南

`czkawka_core` 是一个纯 Rust 库，实现了所有扫描工具。它没有 UI 依赖，设计用于嵌入任何前端。

## 目录

- [工具](#工具)
  - [重复查找器](#重复查找器)
  - [空文件](#空文件)
  - [空文件夹](#空文件夹)
  - [大文件](#大文件)
  - [临时文件](#临时文件)
  - [无效符号链接](#无效符号链接)
  - [同类音乐](#同类音乐)
  - [相似图像](#相似图像)
  - [相似视频](#相似视频)
  - [损坏文件](#损坏文件)
  - [错误扩展名](#错误扩展名)
  - [错误名称](#错误名称)
  - [Exif 移除器](#exif-移除器)
  - [视频优化器](#视频优化器)
- [缓存](#缓存)
- [添加为依赖](#添加为依赖)
- [集成模式](#集成模式)
  - [通用配置（所有工具）](#通用配置所有工具)
  - [运行扫描](#运行扫描)
  - [进度报告](#进度报告)
  - [停止标志](#停止标志)
  - [读取结果](#读取结果)
  - [删除文件](#删除文件)
- [配置和缓存路径](#配置和缓存路径)

---

## 工具

### 重复查找器

查找内容相同（或名称/大小匹配，取决于方法）的文件。

**工作原理**：文件首先按大小分组（大小唯一的文件不可能有重复项）。在每个大小组中，计算开头和结尾 4 KB 的预哈希值 - 具有唯一预哈希值的文件被排除。最后，其余文件被完全哈希并按哈希值分组。

**检查方法：**
- **Name** - 按相同文件名分组。非常快，但会产生许多误报。
- **Size** - 按完全相同的字节大小分组。快但不可靠；几乎总是产生误报。
- **Size + Name** - 同时按大小和名称分组。仍然不可靠。
- **Hash** - 整个文件内容的加密哈希。最慢，但在实际中几乎 100% 可靠。

**集成：**

```rust
use czkawka_core::tools::duplicate::{DuplicateFinder, DuplicateFinderParameters};
use czkawka_core::common::model::{CheckingMethod, HashType};

let params = DuplicateFinderParameters::new(
    CheckingMethod::Hash,
    HashType::Blake3,
    false,   // use_prehash_cache
    257_144, // minimal_cache_file_size (bytes)
    257_144, // minimal_prehash_cache_file_size (bytes)
    false,   // case_sensitive_name_comparison
);
let mut finder = DuplicateFinder::new(params);
// 使用 CommonData 设置器配置，然后：
finder.search(&stop_flag, progress_sender);
```

**结果：**

```rust
// 哈希模式（最常见）
// BTreeMap<file_size: u64, Vec<group: Vec<DuplicateEntry>>>
for (size, groups) in finder.get_files_sorted_by_hash() {
    for group in groups {
        for entry in group {
            // entry.path, entry.size, entry.modified_date, entry.hash
        }
    }
}

// 带参考文件夹：
// BTreeMap<size, Vec<(reference: DuplicateEntry, duplicates: Vec<DuplicateEntry>)>>
for (size, pairs) in finder.get_files_with_identical_hashes_referenced() { }

// 名称模式：finder.get_files_sorted_by_names()  -> BTreeMap<String, Vec<DuplicateEntry>>
// 大小模式：finder.get_files_sorted_by_size()   -> BTreeMap<u64,    Vec<DuplicateEntry>>
// SizeName:    finder.get_files_sorted_by_size_name()
```

`DuplicateEntry`: `path: PathBuf`, `size: u64`, `modified_date: u64`, `hash: String`。

**信息结构**（搜索后）：`finder.get_information()` 返回 `Info`，包含 `number_of_groups_by_hash`、`number_of_duplicated_files_by_hash`、`lost_space_by_hash`、`scanning_time` 等。

**哈希类型：** `HashType::Blake3`（推荐，加密哈希），`HashType::Xxh3`（最快，非加密），`HashType::Crc32`。

---

### 空文件

查找不包含有意义数据的文件。

**工作原理**：扫描所有文件并检查元数据大小。可选内容模式检查实际字节。

**模式：**
- **基本**（默认）- 大小正好为 0 字节的文件。
- **零字节内容** - 还包括非空文件且整个内容为空字节 (`\0`) 的文件。用于查找占用磁盘空间但不包含数据的占位符文件。
- **不可打印内容** - 还包括仅包含不可打印 ASCII 的文件：`\0`, `\t`, `\n`, `\v`, `\f`, `\r`, 空格。隐含零字节内容。

**集成：**

```rust
use czkawka_core::tools::empty_files::{EmptyFiles, EmptyFilesParameters};
use czkawka_core::common::model::CheckingMethod;

let params = EmptyFilesParameters::new(
    CheckingMethod::EmptyFilesContent, // 或 CheckingMethod::None 代表基本模式
);
let mut tool = EmptyFiles::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<FileEntry>
for entry in tool.get_empty_files() { }
```

---

### 空文件夹

查找不包含文件或子目录的目录。

**工作原理**：为每个目录创建条目并将其标记为潜在空目录。在检查目录内容时，任何具有文件或非空子目录的目录都会递归地向上传播“非空”状态到所有父目录。在完整遍历后仍被标记为空的目录会被报告。

**集成：**

```rust
use czkawka_core::tools::empty_folder::EmptyFolder;

let mut tool = EmptyFolder::new();
tool.search(&stop_flag, progress_sender);

// 结果：HashMap<PathBuf, FolderEntry>
for (path, entry) in tool.get_empty_folder_list() { }
```

`FolderEntry` 包含路径和文件夹元数据。

---

### 大文件

查找指定目录中 N 个最大（或 N 个最小）文件。

**集成：**

```rust
use czkawka_core::tools::big_file::{BigFile, BigFileParameters, SearchMode};

let params = BigFileParameters::new(50, SearchMode::BiggestFiles); // 或 SmallestFiles
let mut tool = BigFile::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<FileEntry>，已按最大优先（或最小优先）排序
for entry in tool.get_big_files() { }
```

---

### 临时文件

查找匹配预定义临时文件模式列表的文件。

**工作原理**：检查每个文件的小写名称，与一组扩展名和后缀进行匹配。默认列表包括：`.tmp`, `.bak`, `.part`, `.crdownload`, `.temp`, `.cache`, `.dmp`, `.download`, `.partial`, `thumbs.db`, `~`, `#`。通过提供自定义列表，可以完全替换该列表。

**集成：**

```rust
use czkawka_core::tools::temporary::{Temporary, TemporaryParameters};

let params = TemporaryParameters::new(
    Vec::new(),  // 空 = 使用内置默认值；提供字符串可完全替换
);
let mut tool = Temporary::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<FileEntry>
for entry in tool.get_temporary_files() { }
```

---

### 无效符号链接

查找目标不存在或形成循环链的符号链接。

**工作原理**：对于每个符号链接，工具检查其目标路径是否存在。如果不存在，则标记该符号链接。超过 20 跳的链被标记为循环引用。

**集成：**

```rust
use czkawka_core::tools::invalid_symlinks::InvalidSymlinks;

let mut tool = InvalidSymlinks::new();
tool.search(&stop_flag, progress_sender);

// 结果：Vec<SymlinkEntry>
for entry in tool.get_invalid_symlinks() { }
```

`SymlinkEntry` 包含 `path`、`destination_path` 和 `type_of_error`（`InfiniteRecursion` 或 `NonExistentFile`）。

---

### 同类音乐

查找重复或相似的音乐文件。

**工作原理：**

**标签模式** - 从每个文件中读取元数据标签。用户选择要比较的标签字段（艺术家、标题、专辑、年份、比特率、流派、长度）。标签会被标准化（小写、去除非字母数字、可选近似比较）。只有在所选字段中具有非空标签的文件才会被比较。

**内容模式** - 为每个文件计算音频指纹。可选按标题相似度预筛选，以减少成对比较。使用可配置相似度阈值和最小匹配段长度比较指纹。

**集成：**

```rust
use czkawka_core::tools::same_music::{SameMusic, SameMusicParameters, MusicSimilarity};
use czkawka_core::common::model::CheckingMethod;

let params = SameMusicParameters::new(
    MusicSimilarity::TRACK_TITLE | MusicSimilarity::TRACK_ARTIST, // 要比较的字段
    false,                       // approximate_comparison
    CheckingMethod::AudioTags,   // AudioTags 或 AudioContent
    10.0,                        // minimum_segment_duration (秒，AudioContent 模式)
    2.0,                         // maximum_difference (0.0-10.0，AudioContent 模式)
    false,                       // compare_fingerprints_only_with_similar_titles
);
let mut tool = SameMusic::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<Vec<MusicEntry>>
for group in tool.get_similar_music_entries() { }

// 带参考文件夹：Vec<(MusicEntry, Vec<MusicEntry>)>
for (reference, duplicates) in tool.get_similar_music_referenced() { }
```

`MusicEntry` 包含 `path`、`size`、`modified_date` 和标签字段（`track_title`、`track_artist`、`year`、`bitrate`、`genre`、`length`）。

`MusicSimilarity` 是一个位标志 - 使用 `|` 组合字段：`TRACK_TITLE | TRACK_ARTIST | YEAR | BITRATE | GENRE | LENGTH`。

---

### 相似图像

查找看起来相似但非逐字节相同的图像（不同分辨率、水印、压缩重新保存等）。

**工作原理：**
1. 按扩展名收集图像。
2. 从缓存加载先前计算的哈希值。
3. 每个未缓存的图像被调整为选定的哈希大小（8×8、16×16、32×32 或 64×64 像素），使用选定的调整大小滤波器，然后计算感知哈希。
4. 哈希值存储在 BK-tree 中，用于高效的汉明距离搜索。
5. 比较所有哈希值；汉明距离低于 `max_difference` 的配对被归为相似组。

与加密哈希不同，感知哈希设计为视觉相似的图像产生相似（接近）的哈希值。

**几何不变性** - 启用后，会为每个图像计算额外的镜像、翻转和/或旋转（90 度）变体的哈希值。这允许匹配镜像/旋转的副本，代价是更多哈希计算。

**哈希算法：** `Gradient`（CLI 默认，适用于大多数照片），`Mean`（Krokiet 默认），`Blockhash`（不调整大小即哈希），`VertGradient`，`DoubleGradient`，`Median`。

**调整大小滤波器：** `Nearest`（最快，CLI 默认），`Lanczos3`（质量最佳，Krokiet 默认），`Triangle`，`Gaussian`，`CatmullRom`。

**SIMILAR_VALUES** 常量 - 每个哈希大小和相似度级别的 `max_difference` 预设值：

```rust
use czkawka_core::tools::similar_images::SIMILAR_VALUES;
// SIMILAR_VALUES[hash_size_idx][preset_idx]
// hash_size_idx: 0=8, 1=16, 2=32, 3=64
// preset_idx: 0=Original..5=Minimal
let recommended = SIMILAR_VALUES[1][2]; // 哈希大小 16，中等预设
```

**集成：**

```rust
use czkawka_core::tools::similar_images::{SimilarImages, SimilarImagesParameters, GeometricInvariance};
use czkawka_core::re_exported::{HashAlg, FilterType};

let params = SimilarImagesParameters::new(
    10,                         // max_difference (0-40)
    16,                         // hash_size (8, 16, 32 或 64)
    HashAlg::Gradient,
    FilterType::Nearest,
    false,                      // exclude_images_with_same_size
    false,                      // exclude_images_with_same_resolution
    GeometricInvariance::Off,   // Off | MirrorFlip | MirrorFlipRotate90
);
let mut tool = SimilarImages::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<Vec<ImagesEntry>>
for group in tool.get_similar_images() { }

// 带参考文件夹：Vec<(ImagesEntry, Vec<ImagesEntry>)>
for (reference, similars) in tool.get_similar_images_referenced() { }
```

`ImagesEntry`: `path`, `size`, `modified_date`, `width: u32`, `height: u32`, `hashes: Vec<Vec<u8>>`, `difference: u32`。

---

### 相似视频

使用感知帧哈希查找视觉相似的视频。运行时需要 **ffmpeg**。

**工作原理**：视频按持续时间（在可配置容差范围内）分组。对于每个视频，在规则间隔处提取多个帧（时间窗口）并计算感知哈希。如果足够比例的窗口哈希在给定容差内匹配，则两个视频被视为相似。子片段检测识别较短视频包含在较长视频中的情况。

可选音频模式计算音频指纹并独立于视觉匹配进行比较。

**集成：**

```rust
use czkawka_core::tools::similar_videos::{
    SimilarVideos, SimilarVideosParameters,
    DEFAULT_WINDOW_COUNT, DEFAULT_DURATION_TOLERANCE_PCT,
    DEFAULT_MIN_MATCHING_WINDOWS, DEFAULT_SUBCLIP_MIN_MATCH,
    DEFAULT_SKIP_FORWARD_AMOUNT, DEFAULT_CROP_DETECT,
    DEFAULT_VIDEO_PERCENTAGE_FOR_THUMBNAIL, DEFAULT_THUMBNAIL_GRID_TILES_PER_SIDE,
    DEFAULT_AUDIO_SIMILARITY_PERCENT, DEFAULT_AUDIO_LENGTH_RATIO,
    DEFAULT_AUDIO_MAXIMUM_DIFFERENCE, DEFAULT_AUDIO_MIN_DURATION_SECONDS,
};

let params = SimilarVideosParameters::new(
    10,                                    // tolerance (0-20)
    false,                                 // exclude_videos_with_same_size
    false,                                 // exclude_videos_with_same_resolution
    DEFAULT_SKIP_FORWARD_AMOUNT,           // 跳过视频开头的秒数
    10,                                    // 每个视频扫描持续时间（秒）
    DEFAULT_CROP_DETECT,                   // 检测/移除信箱黑边
    DEFAULT_WINDOW_COUNT,                  // 每个视频的时间窗口数
    DEFAULT_DURATION_TOLERANCE_PCT,        // 最大持续时间差异百分比
    DEFAULT_MIN_MATCHING_WINDOWS,          // 匹配窗口的最小分数
    DEFAULT_SUBCLIP_MIN_MATCH,             // 子片段检测的最小分数
    false,                                 // generate_thumbnails
    DEFAULT_VIDEO_PERCENTAGE_FOR_THUMBNAIL,// 缩略图位置百分比
    false,                                 // generate_thumbnail_grid_instead_of_single
    DEFAULT_THUMBNAIL_GRID_TILES_PER_SIDE, // 网格缩略图每边的瓦片数
    false,                                 // check_audio_content（设置为 true 以进行音频比较）
    DEFAULT_AUDIO_SIMILARITY_PERCENT,      // 匹配音频的最小百分比
    DEFAULT_AUDIO_MAXIMUM_DIFFERENCE,      // 最大音频段差异
    DEFAULT_AUDIO_LENGTH_RATIO,            // 较短/较长音频的最小比率
    DEFAULT_AUDIO_MIN_DURATION_SECONDS,    // 音频比较的最小持续时间
);
let mut tool = SimilarVideos::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<Vec<VideosEntry>>
for group in tool.get_similar_videos() { }

// 带参考文件夹：Vec<(VideosEntry, Vec<VideosEntry>)>
for (reference, similars) in tool.get_similar_videos_referenced() { }
```

`VideosEntry`: `path`, `size`, `modified_date`, `duration: f64`。

---

### 损坏文件

查找无法使用其预期库正确打开或验证的文件。

**工作原理**：按扩展名收集文件。使用相应的库打开和解析每个文件。如果解析返回错误，则将文件标记为损坏。某些常见产生误报的错误会被抑制。

**支持的检查器：**

| 检查器 | 文件类型 | 默认 |
|---------|-----------|---------|
| `IMAGE` | jpg, jpeg, png, tiff, gif, bmp, ico, webp, exr, avif, 其他 | 开启 |
| `AUDIO` | mp3, flac, wav, ogg, m4a, aac, 其他 | 开启 |
| `PDF` | pdf | 开启 |
| `ARCHIVE` | zip, 7z, gz/tgz, tar, zst, bz2, xz | 开启 |
| `FONT` | ttf, otf, ttc | 开启 |
| `MARKUP` | JSON, XML, TOML, YAML, SVG | 开启 |
| `VIDEO_FFPROBE` | mp4, mkv, avi, mov, webm, 其他 - 快速仅头部检查 | 关闭（需要 ffmpeg） |
| `VIDEO_FFMPEG` | 同上 - 慢速完整解码 | 关闭（需要 ffmpeg） |

**集成：**

```rust
use czkawka_core::tools::broken_files::{BrokenFiles, BrokenFilesParameters, CheckedTypes};

let checked_types = CheckedTypes::IMAGE | CheckedTypes::AUDIO | CheckedTypes::PDF
    | CheckedTypes::ARCHIVE | CheckedTypes::FONT | CheckedTypes::MARKUP;
// 如果可用 ffmpeg，添加视频类型：
// | CheckedTypes::VIDEO_FFPROBE | CheckedTypes::VIDEO_FFMPEG

let params = BrokenFilesParameters::new(checked_types);
let mut tool = BrokenFiles::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<BrokenEntry>
for entry in tool.get_broken_files() {
    // entry.path, entry.size, entry.modified_date
    // entry.get_error_string() -> 人类可读的原因
}
```

注意：可能出现误报。删除前请手动验证文件。

---

### 错误扩展名

查找其实际内容（从魔数检测）与当前扩展名不匹配的文件。

**工作原理**：读取每个文件的前几个字节，并将其与已知魔数签名匹配以确定可能的文件类型。检测到的 MIME 类型被扩展到该类型的所有有效扩展名。如果文件的当前扩展名不在其中，则文件被标记。

**集成：**

```rust
use czkawka_core::tools::bad_extensions::{BadExtensions, BadExtensionsParameters};

let params = BadExtensionsParameters::new();
let mut tool = BadExtensions::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<BadFileEntry>
for entry in tool.get_bad_extensions_files() {
    // entry.path - 当前路径
    // entry.proper_extensions - 建议的扩展名
}
```

使用 `FixingItems` 自动重命名文件：

```rust
use czkawka_core::common::traits::FixingItems;
tool.fix_items(&stop_flag, progress_sender, ());
```

---

### 错误名称

查找在某些文件系统或操作系统上可能引起问题的名称的文件。

**工作原理**：根据启用的规则检查每个文件名。任何匹配的规则都会将文件添加到结果中。为每个标记的文件计算建议的修正名称。

**检查（每个独立可配置）：**
- **大写扩展名** - 例如 `photo.JPG` 而不是 `photo.jpg`
- **表情符号** - 文件名中的表情符号字符
- **开头或结尾空格** - 开头或结尾空格
- **非 ASCII 图形字符** - 超出 ASCII 可打印范围的字符
- **受限字符集** - 不在用户定义允许集中的字符（例如仅 `a-z`、`0-9`、`_`、`-`、`.`）
- **重复非字母数字字符** - 重复的特殊字符（例如 `file__name`、`doc---v2`）

**集成：**

```rust
use czkawka_core::tools::bad_names::{BadNames, BadNamesParameters};

let params = BadNamesParameters::new(
    true,         // uppercase_extension
    true,         // emoji_used
    true,         // space_at_start_or_end
    true,         // non_ascii_graphical
    None,         // restricted_charset: Option<String> (例如 Some("_- .".to_string()))
    false,        // remove_duplicated_non_alphanumeric
);
let mut tool = BadNames::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<BadFileEntry>
for entry in tool.get_bad_names() {
    // entry.path - 当前路径
    // entry.proper_name - 建议的修正名称
}
```

使用 `FixingItems` 自动重命名：

```rust
tool.fix_items(&stop_flag, progress_sender, ());
```

---

### Exif 移除器

查找包含 EXIF 元数据（GPS、相机型号、创建时间戳等）的图像文件。

**工作原理**：使用 `little_exif` 读取每个图像的 EXIF 标签。具有非忽略标签的文件会被报告。缓存存储已扫描文件的信息（按路径、大小和修改日期键入）。

**支持的格式**：jpg, jpeg, jfif, png, tiff, tif, avif, jxl, webp, heic, heif。

**集成：**

```rust
use czkawka_core::tools::exif_remover::{ExifRemover, ExifRemoverParameters};

let params = ExifRemoverParameters::new(
    vec!["Orientation".to_string(), "ColorSpace".to_string()], // 要忽略（保留）的标签
);
let mut tool = ExifRemover::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<ExifEntry>
for entry in tool.get_exif_files() {
    // entry.path, entry.size, entry.modified_date
    // entry.exif_tags: Vec<ExifTag>  (仅忽略列表之外的标签)
}
```

使用 `FixingItems` 删除标签：

```rust
use czkawka_core::common::traits::FixingItems;
// FixParams: (override_original: bool)
tool.fix_items(&stop_flag, progress_sender, false); // false = 写入 _cleaned 副本
tool.fix_items(&stop_flag, progress_sender, true);  // true = 覆盖原始文件
```

---

### 视频优化器

识别适合优化的视频。两种模式：

**转码模式** - 查找尚未使用高效编解码器的视频。用户提供一个“排除”编解码器列表（例如 `["h265", "av1"]`）；任何不在该列表中的编解码器的视频都会被标记为转码候选项。使用 `-F`/`fix_items`，工具会实际使用 ffmpeg 重新编码文件。

**裁剪模式** - 分析视频帧以检测黑边（letterbox/pillarbox）或静态边缘内容。为每个视频报告最佳裁剪矩形。使用 `-F`/`fix_items`，工具会使用 ffmpeg 应用裁剪。

可选功能：降噪（`hqdn3d`）、硬件加速编码、自定义 ffmpeg 命令覆盖、缩略图生成。

**集成：**

```rust
use czkawka_core::tools::video_optimizer::{VideoOptimizer, VideoOptimizerParameters, VideoOptimizerMode};

let params = VideoOptimizerParameters::new(VideoOptimizerMode::Transcode {
    excluded_codecs: vec!["h265".to_string(), "av1".to_string()],
    generate_thumbnails: false,
    thumbnail_percentage: 10,
    generate_thumbnail_grid: false,
    thumbnail_grid_tiles_per_side: 3,
});
let mut tool = VideoOptimizer::new(params);
tool.search(&stop_flag, progress_sender);

// 结果：Vec<VideoEntry>
for entry in tool.get_video_optimizer_entries() {
    // entry.path, entry.size, entry.codec, entry.width, entry.height
}
```

---

## 缓存

缓存文件存储在共享的 czkawka 缓存目录中。所有前端（CLI、Krokiet、GTK）读写相同的缓存。

重要文件：
- `cache_duplicates_<HASH>.bin/.json` - 按哈希类型分类的重复文件缓存
- `cache_similar_image_<SIZE>_<HASH>_<FILTER>_<INVARIANCE>.bin/.json` - 感知图像哈希（每个唯一参数集一个文件）
- `cache_similar_videos.bin/.json` - 视频签名
- `cache_music_tags.bin/.json`、`cache_music_fingerprints.bin/.json` - 音乐元数据/指纹
- `cache_exif.bin/.json` - EXIF 扫描结果
- `cache_broken_files.txt` - 损坏文件检查结果

默认加载 `.bin`（二进制/bincode 格式）；如果 `.bin` 文件缺失，则使用 `.json` 回退。调用 `set_save_also_as_json(true)` 可同时写入两种格式。

JSON 文件可以手动编辑（例如，在将集合移动到另一台机器时更新路径）。

---

## 添加为依赖

```toml
# Cargo.toml
[dependencies]
czkawka_core = { path = "../czkawka_core" }
# 或者来自 git：
# czkawka_core = { git = "https://github.com/qarmin/czkawka" }
```

可选功能（需要在构建和运行时安装原生库）：

| 功能 | 库 | 用途 |
|---------|---------|---------|
| `heif` | `libheif` | HEIF/HEIC 图像支持 |
| `libraw` | `libraw` | RAW 相机图像支持 |
| `libavif` | `libavif`, `libdav1d` | AVIF 图像支持 |

`similar_videos` 工具仅在运行时需要 **ffmpeg**（不是构建依赖）。

---

## 集成模式

所有工具遵循相同模式：使用参数创建，使用 `CommonData` 特性设置器配置，调用 `.search()`，然后读取结果。

### 通用配置（所有工具）

每个工具结构体实现 `CommonData`，公开所有工具共享的设置器：

```rust
use czkawka_core::common::tool_data::CommonData;

// 必需：要扫描的目录
tool.set_included_paths(vec![PathBuf::from("/home/user/Documents")]);

// 可选过滤器
tool.set_excluded_paths(vec![PathBuf::from("/home/user/.cache")]);
tool.set_excluded_items(vec!["*/tmp*".to_string(), "*/.git".to_string()]);
tool.set_allowed_extensions(vec!["jpg".to_string(), "png".to_string()]);
tool.set_excluded_extensions(vec!["db".to_string()]);

// 文件大小限制（字节）
tool.set_minimal_file_size(8_192);
tool.set_maximal_file_size(u64::MAX);

// 遍历
tool.set_recursive_search(true);          // 默认：true
tool.set_exclude_other_filesystems(false); // 仅 Unix

// 缓存行为
tool.set_use_cache(true);                  // 默认：true
tool.set_delete_outdated_cache(true);      // 默认：true
tool.set_save_also_as_json(false);         // 与 .bin 缓存一起写入 .json

// 参考路径（支持：重复查找器、相似图像、相似视频、同类音乐）
tool.set_reference_paths(vec![PathBuf::from("/home/user/Archive")]);
tool.set_use_reference_folders(true);

// 删除（调用 delete_files() 后搜索时使用）
use czkawka_core::common::tool_data::DeleteMethod;
tool.set_delete_method(DeleteMethod::AllExceptNewest);
tool.set_dry_run(false);
tool.set_move_to_trash(false);
```

`DeleteMethod` 值：`None`, `Delete`, `AllExceptNewest`, `AllExceptOldest`, `OneNewest`, `OneOldest`, `AllExceptBiggest`, `AllExceptSmallest`, `OneBiggest`, `OneSmallest`, `HardLink`。

### 运行扫描

所有工具实现 `Search` 特性：

```rust
use std::sync::Arc;
use std::sync::atomic::AtomicBool;
use czkawka_core::common::traits::Search;

let stop_flag = Arc::new(AtomicBool::new(false));

// 阻塞调用 - 扫描完成或停止时返回
tool.search(&stop_flag, None);               // 不报告进度
tool.search(&stop_flag, Some(&progress_tx)); // 带进度通道
```

### 进度报告

进度通过 `crossbeam_channel::Sender<ProgressData>` 发送：

```rust
use crossbeam_channel::unbounded;
use czkawka_core::common::progress_data::ProgressData;

let (progress_tx, progress_rx) = unbounded::<ProgressData>();

// 在调用 search 之前生成接收器
std::thread::spawn(move || {
    for progress in progress_rx {
        // `to_display()` 返回前端渲染此更新所需的一切 -
        // 完全翻译的标签和可直接显示的百分比 - 无需前端
        // 自行根据阶段进行分支。
        let display = progress.to_display();
        println!(
            "{} (overall: {}%, current stage: {:?}%)",
            display.label, display.all_progress, display.current_progress,
        );
    }
});

tool.search(&stop_flag, Some(&progress_tx));
```

`ProgressData` 字段：
- `stage: ToolStage` - 正在运行的子步骤（例如 `ToolStage::Duplicate(DuplicateStage::FullHashing)`、`ToolStage::SimilarImages(SimilarImagesStage::CalculatingHashes)`）
- `entries_checked / entries_to_check: usize` - 当前阶段内的项目级进度
- `bytes_checked / bytes_to_check: u64` - 字节级进度（哈希阶段设置）

`ToolStage` 是嵌套枚举 - 顶级变体如 `ToolStage::Duplicate`/`ToolStage::SimilarImages` 携带工具特定的子阶段枚举（`DuplicateStage`、`SimilarImagesStage` 等），因此阶段不能与不属于它的工具配对。有用的查询：`ToolStage::is_cache_loading_saving()`（缓存阶段，其中 `entries_to_check` 为 0，无法显示进度条）、`ToolStage::is_indeterminate()`、`ToolStage::current_stage_idx()` / `max_stage_idx()`。

如果你需要比 `to_display()` 更低级别的访问（例如自定义 UI），请调用 `ProgressData::label()` 获取仅翻译的字符串，或调用 `item_progress()` / `all_progress()` 获取原始百分比。

### 停止标志

要从另一个线程中断正在运行的扫描：

```rust
use std::sync::atomic::Ordering;

stop_flag.store(true, Ordering::Relaxed);
```

工具会定期检查标志并尽早从 `.search()` 返回。之后检查 `tool.get_stopped_search()` 以了解扫描是否被中断。

### 读取结果

每个工具公开其自己的 getter 方法（如上每个工具中所述）。搜索后，还要检查消息：

```rust
let messages = tool.get_text_messages();
// messages.errors   - Vec<String>
// messages.warnings - Vec<String>
// messages.messages - Vec<String>
```

### 删除文件

成功搜索后，调用 `delete_files()` 以应用配置的 `DeleteMethod`：

```rust
use czkawka_core::common::traits::DeletingItems;

tool.set_delete_method(DeleteMethod::AllExceptNewest);
tool.delete_files(&stop_flag, Some(&progress_tx));
```

对于支持修复（重命名、EXIF 移除、转码）的工具，使用 `FixingItems` 特性：

```rust
use czkawka_core::common::traits::FixingItems;
tool.fix_items(&stop_flag, Some(&progress_tx), fix_params);
```

---

## 配置和缓存路径

路径取决于传递给 `set_config_cache_path` 的 `cache_name` 和 `config_name` 字符串。现有前端使用：

| 前端 | `cache_name` | `config_name` |
|----------|-------------|---------------|
| Krokiet | `"Czkawka"` | `"Krokiet"` |
| GTK / CLI | `"Czkawka"` | `"Czkawka"` |
| Cedinia | `"cedinia"` | `"cedinia"` |

结果路径（Linux 示例，使用 `directories_next::ProjectDirs`）：
- 缓存 `"Czkawka"` → `~/.cache/czkawka/`
- 配置 `"Krokiet"` → `~/.config/krokiet/`
- 配置 `"Czkawka"` → `~/.config/czkawka/`

`set_config_cache_path` **必须在任何缓存或配置访问之前调用一次**：

```rust
use czkawka_core::common::config_cache_path::{set_config_cache_path, get_config_cache_path};

// 启动时调用一次 - 为你的应用选择适当的名称
let result = set_config_cache_path("MyApp", "MyApp");
// result.infos / result.warnings 包含诊断消息

if let Some(paths) = get_config_cache_path() {
    println!("Cache: {}", paths.cache_folder.display());
    println!("Config: {}", paths.config_folder.display());
}
```

使用环境变量覆盖（在默认路径之前检查）：

```shell
CZKAWKA_CONFIG_PATH="/custom/config" CZKAWKA_CACHE_PATH="/custom/cache" ./my_app
```
