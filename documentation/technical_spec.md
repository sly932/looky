
# Looky App 技术方案文档

## 1. 技术选型 (Technical Stack)

- **开发语言 (Language)**: Swift
- **UI 框架 (UI Framework)**: SwiftUI
- **最低系统版本 (Minimum OS)**: iOS 16.0
  - *原因：为了更好地支持锁屏小组件 (Lock Screen Widgets) 和 App Intents。*
- **核心数据存储 (Core Data Storage)**:
  - **Core Data**: 用于存储核心业务数据，如每一条“照片+文字”的记录。它能很好地处理结构化数据，并为未来的复杂查询和数据迁移做准备。
  - **UserDefaults / AppStorage**: 用于存储用户偏好和简单的应用配置，如主题设置、是否首次启动等。
- **拍照功能 (Camera)**: `AVFoundation`
  - *原因：相比 `UIImagePickerController`，`AVFoundation` 提供了更高的定制化能力，便于实现“快速拍照”的沉浸式体验。*
- **小组件 (Widgets)**: `WidgetKit`
  - *原因：原生支持主屏幕和锁屏小组件。*
- **快捷启动 (Shortcuts & Quick Launch)**: `App Intents`
  - *原因：为 Siri、捷径以及小组件的交互提供统一的编程模型。*

## 2. 关键功能实现方案

### 2.1 锁屏/主屏幕快捷启动

此功能是 Looky “快”的核心。我们将通过以下方式实现：

1.  **锁屏小组件 (Lock Screen Widget)**:
    -   **类型**: 使用 `WidgetKit` 创建一个 `.accessoryRectangular` 或 `.accessoryCircular` 类型的小组件。
    -   **功能**: 小组件上会有一个明显的“拍照”图标和文字。
    -   **交互**: 用户点击锁屏小组件后，通过 `App Intents` 直接触发 App 内的拍照流程，绕过主界面，直接打开相机。

2.  **主屏幕小组件 (Home Screen Widget)**:
    -   **类型**: 提供小、中、大三种尺寸的 `WidgetKit` 小组件。
    -   **功能**:
        -   **小尺寸**: 显示一个大的“快速拍照”按钮。
        -   **中/大尺寸**: 除了拍照按钮，还可以显示最近的一张或几张照片缩略图。
    -   **交互**: 点击按钮同样通过 `App Intents` 启动拍照。

3.  **Siri 与捷径 (Siri & Shortcuts)**:
    -   **实现**: 使用 `App Intents` 定义一个名为 `Take Looky Photo` 的意图。
    -   **功能**: 用户可以说“嘿 Siri，用 Looky 拍一张”或在捷径 App 中创建自动化流程，直接调用该意图启动拍照。

### 2.2 核心数据流：拍照与记录

1.  **触发**: 用户通过 App 图标、小组件或 Siri 启动拍照意图。
2.  **拍照**: App 启动后立即展示一个精简的、使用 `AVFoundation` 构建的自定义相机界面。
3.  **记录**: 拍照完成后，跳转到一个简单的文本输入界面，允许用户添加文字描述。
4.  **保存**:
    -   图片数据和文字描述将作为一个实体 (Entity) 保存到 `Core Data` 数据库中。
    -   该实体将包含 `imageID`, `textDescription`, `creationDate` 等字段。
    -   图片本身可以存储为二进制数据（如果较小）或存储文件路径（推荐）。
5.  **展示**: App 的主界面是一个用 `FetchRequest` 从 `Core Data` 读取数据并展示的类朋友圈信息流。

## 3. 项目目录结构 (Proposed)

```
looky/
├── looky/
│   ├── Assets.xcassets/         # App 图标、颜色等资源
│   │
│   ├── Application/             # App 生命周期管理
│   │   └── lookyApp.swift       # App 入口
│   │
│   ├── Core/                    # 核心模块
│   │   ├── Data/                # 数据持久化
│   │   │   └── Persistence.swift  # Core Data 堆栈设置
│   │   ├── Camera/              # 自定义相机
│   │   │   └── CameraView.swift
│   │   └── Intents/             # App Intents 定义
│   │       └── PhotoIntents.swift
│   │
│   ├── Features/                # 主要功能 UI
│   │   ├── Home/                # 主页信息流
│   │   │   └── ContentView.swift
│   │   ├── Creation/              # 拍照和记录视图
│   │   │   └── CreationView.swift
│   │   └── Settings/            # 设置页面
│   │       └── SettingsView.swift
│   │
│   └── Preview Content/         # SwiftUI 预览资源
│
├── lookyWidget/                 # Widget 扩展
│   ├── lookyWidget.swift
│   └── lookyWidgetBundle.swift
│
└── looky.xcodeproj/
``` 