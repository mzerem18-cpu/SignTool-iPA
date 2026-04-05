# PRD — iOS SignTool

## Original Problem Statement
Generate a full Xcode project (iOS wrapper) for https://signipa.vercel.app using Swift + UIKit + WKWebView. Buildable on GitHub Actions producing an unsigned IPA without any Apple Developer Team ID.

## Architecture
- **Language:** Swift 5.9, UIKit
- **WebView:** WKWebView (WebKit framework)
- **Navigation:** Scene-based (AppDelegate + SceneDelegate)
- **Min iOS:** 15.0
- **Bundle ID:** com.astear17.signtool
- **Xcode:** 15+

## What's Been Implemented (2026-02)

### iOS Source Files (`iOSSignTool/`)
- `AppDelegate.swift` — standard UIKit entry point with scene support
- `SceneDelegate.swift` — creates UIWindow programmatically, sets root ViewController
- `ViewController.swift` — full WKWebView wrapper:
  - Loads https://signipa.vercel.app
  - Pull-to-refresh (UIRefreshControl)
  - Loading progress bar (UIProgressView + KVO)
  - Offline/error screen with Retry button
  - Camera & microphone permission grant (iOS 15+ WKUIDelegate)
  - External links → Safari; internal links stay in WebView
  - window.open() → Safari
  - JS alert / confirm / prompt dialogs fully handled
  - Cookies, localStorage, IndexedDB via default WKWebsiteDataStore
- `Info.plist` — NSCamera/Microphone/PhotoLibrary usage descriptions, ATS, Scene manifest
- `LaunchScreen.storyboard` — app icon + "iOS SignTool" label centred
- `Assets.xcassets/AppIcon.appiconset/icon.png` — downloaded from Astear17/SignTool GitHub repo

### Xcode Project (`iOSSignTool.xcodeproj/`)
- `project.pbxproj` — full PBX project with Debug/Release configs, iOS 15 deployment target
- `project.xcworkspace/contents.xcworkspacedata`
- `xcshareddata/xcschemes/iOSSignTool.xcscheme` — shared scheme (required for CI)

### GitHub Actions (`.github/workflows/ios-build.yml`)
- Runs on `macos-14` (Xcode 15.x)
- Archives with `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO`
- Packages `iOSSignTool.app` → `Payload/` → `iOSSignTool-unsigned.ipa`
- Uploads IPA as downloadable artifact (30-day retention)
- Triggers on push to main/master and manual `workflow_dispatch`

### Docs
- `README.md` — project overview, local build, CI/CD instructions, unsigned IPA install notes
- `LICENSE` — MIT

## Next Action Items / Backlog
- P0: Push to GitHub and verify Actions build passes
- P1: Add custom splash animation / branded loading indicator
- P1: Universal links / deep-link support if signipa.vercel.app adds them
- P2: Signed IPA via GitHub Actions (requires Apple Dev account secrets)
