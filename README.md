# iOS SignTool

A native iOS wrapper for [signipa.vercel.app](https://signipa.vercel.app) built with Swift and UIKit using WKWebView.

## Features

- Full-screen WKWebView wrapping `https://signipa.vercel.app`
- Pull-to-refresh
- Loading progress bar
- Offline / error screen with retry
- Camera & microphone permission handling (iOS 15+)
- File uploads via system document picker
- Cookies, localStorage, and IndexedDB persistence
- External links open in Safari
- Internal navigation stays inside the app
- JavaScript dialogs (alert / confirm / prompt) fully supported
- Launch screen with app icon and name
- Supports iOS 15+ · iPhone & iPad · Portrait & Landscape

## Project Structure

```
.
├── iOSSignTool.xcodeproj/          Xcode project
│   ├── project.pbxproj
│   ├── project.xcworkspace/
│   └── xcshareddata/xcschemes/
│       └── iOSSignTool.xcscheme
├── iOSSignTool/                    Swift source files
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── ViewController.swift
│   ├── Info.plist
│   ├── LaunchScreen.storyboard
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
├── .github/
│   └── workflows/
│       └── ios-build.yml           GitHub Actions (unsigned IPA)
├── README.md
└── LICENSE
```

## Build Locally (Xcode)

1. Open `iOSSignTool.xcodeproj` in Xcode 15+
2. Select an iPhone simulator or device
3. Press **⌘R** to build and run

> No signing required for simulator builds.  
> For device deployment, set your Apple Developer Team in **Signing & Capabilities**.

## Build via GitHub Actions (Unsigned IPA)

Push to `main` or `master` — the workflow in `.github/workflows/ios-build.yml` will:

1. Archive the app without code signing
2. Package it into `iOSSignTool-unsigned.ipa`
3. Upload the IPA as a downloadable artifact (kept for 30 days)

The workflow runs automatically on every push. You can also trigger it manually from the **Actions** tab → **Build Unsigned IPA** → **Run workflow**.

### Download the IPA

1. Go to your repository on GitHub
2. Click **Actions**
3. Select the latest **Build Unsigned IPA** run
4. Download the `iOSSignTool-unsigned` artifact

> **Note:** Unsigned IPAs can be installed with tools such as **AltStore**, **Sideloadly**, or **TrollStore** on non-jailbroken devices, or via **Xcode Devices** window for development devices.

## Requirements

| Tool    | Version |
|---------|---------|
| Xcode   | 15.0+   |
| Swift   | 5.9+    |
| iOS     | 15.0+   |
| macOS   | 13.0+ (for building) |

## Bundle Identifier

`com.astear17.signtool`

## License

MIT — see [LICENSE](LICENSE)
