# 云洞酒馆 iOS

这是一个 SwiftUI + WKWebView 的 iPhone/iPad 壳应用，内置三个可切换入口：

- `https://aaa.sillytavern.top:8000`
- `https://aaa.sillytavern.top:8443`
- `https://aaa.sillytavern.top:8888`

## 用 GitHub 自动生成 IPA

1. 新建一个 GitHub 仓库，把本项目的全部文件上传到仓库根目录。
2. 打开仓库的 **Actions** 页面。
3. 选择 **Build iOS IPA**，点击 **Run workflow**。
4. 构建完成后，在该次运行底部下载 `TavernSwitcher-unsigned-IPA`。
5. 解压后得到 `TavernSwitcher-unsigned.ipa`。

该 IPA 是未签名安装包，需要用你自己的证书通过 AltStore、SideStore、Sideloadly、爱思助手签名，或在签名工具中重签后安装。GitHub 本身没有你的 Apple 签名证书，因此不能直接生成所有 iPhone 都能安装的已签名 IPA。普通免费的 Apple ID 签名通常需要定期续签。

## 本地开发

需要 macOS、Xcode 和 XcodeGen：

```bash
brew install xcodegen
xcodegen generate
open TavernSwitcher.xcodeproj
```

## 修改名称或网址

- 三个网址和显示名称：`TavernSwitcher/AppState.swift`
- App 显示名称：`TavernSwitcher/Info.plist`
- Bundle ID：`project.yml`

## 已实现

- 三入口玻璃卡片启动页
- 自动记录上次使用入口
- 网页内悬浮按钮切换入口
- 后退、刷新、返回首页
- 清除 Cookie、缓存和网页数据
- 支持网页弹窗、新窗口链接、视频内联播放
- GitHub Actions 自动打包 unsigned IPA
