# SUUMO家探しアプリ - 詳細セットアップガイド

## 📋 目次
1. [環境構築](#環境構築)
2. [プロジェクトのセットアップ](#プロジェクトのセットアップ)
3. [Google Maps API設定](#google-maps-api設定)
4. [開発環境での実行](#開発環境での実行)
5. [トラブルシューティング](#トラブルシューティング)
6. [本番環境へのデプロイ](#本番環境へのデプロイ)

## 環境構築

### 1. Flutter SDKのインストール

#### macOS
```bash
# Homebrewを使用
brew install flutter

# または公式サイトからダウンロード
# https://docs.flutter.dev/get-started/install/macos
```

#### Windows
1. [Flutter公式サイト](https://docs.flutter.dev/get-started/install/windows)からダウンロード
2. ZIPファイルを展開
3. PATH環境変数に追加

#### Linux
```bash
# Snapを使用
sudo snap install flutter --classic
```

### 2. Flutter環境の確認
```bash
flutter doctor
```

以下の項目を確認:
- ✓ Flutter SDK
- ✓ Android toolchain (Android開発の場合)
- ✓ Xcode (iOS開発の場合)
- ✓ Chrome (Web開発の場合)
- ✓ Connected device

## プロジェクトのセットアップ

### 1. プロジェクトディレクトリへ移動
```bash
cd suumo_finder_app
```

### 2. 依存関係のインストール
```bash
flutter pub get
```

### 3. 依存関係の確認
```bash
flutter pub deps
```

## Google Maps API設定

### 1. Google Cloud Platformでプロジェクト作成

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成
3. プロジェクト名: 「SUUMO家探しアプリ」など

### 2. Maps SDK for Android/iOSの有効化

1. 「APIとサービス」→「ライブラリ」
2. 以下のAPIを検索して有効化:
   - Maps SDK for Android
   - Maps SDK for iOS

### 3. APIキーの作成

1. 「認証情報」→「認証情報を作成」→「APIキー」
2. APIキーをコピー
3. 必要に応じてAPIキーの制限を設定

### 4. Android用APIキー設定

`android/app/src/main/AndroidManifest.xml` を編集:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 5. iOS用APIキー設定

`ios/Runner/AppDelegate.swift` を編集:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## 開発環境での実行

### 1. エミュレーターの起動

#### Android
```bash
# 利用可能なエミュレーターを確認
flutter emulators

# エミュレーターを起動
flutter emulators --launch <emulator_id>
```

#### iOS (macOSのみ)
```bash
open -a Simulator
```

### 2. アプリの実行
```bash
# デバイスを確認
flutter devices

# アプリを実行
flutter run

# 特定のデバイスで実行
flutter run -d <device_id>

# デバッグモードで実行
flutter run --debug

# リリースモードで実行
flutter run --release
```

### 3. ホットリロード
アプリ実行中に:
- `r`: ホットリロード
- `R`: ホットリスタート
- `q`: 終了

## トラブルシューティング

### エラー: "Google Maps API key not found"
**解決策:**
1. APIキーが正しく設定されているか確認
2. AndroidManifest.xmlまたはAppDelegate.swiftを確認
3. アプリを完全に再起動

### エラー: "Location permissions not granted"
**解決策:**
1. AndroidManifest.xmlに位置情報パーミッションを追加
2. Info.plistに位置情報の説明文を追加
3. アプリから位置情報の許可を求める

### エラー: "Failed to load asset"
**解決策:**
1. pubspec.yamlのassetsセクションを確認
2. `flutter clean` を実行
3. `flutter pub get` を再実行

### エラー: "Gradle build failed"
**解決策:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### エラー: "CocoaPods not installed"
**解決策:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

## 本番環境へのデプロイ

### Android APKのビルド

#### 1. リリースビルドの作成
```bash
flutter build apk --release
```

#### 2. APKの場所
```
build/app/outputs/flutter-apk/app-release.apk
```

#### 3. Google Play Storeへの公開準備

**キーストアの生成:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**key.propertiesの作成:**
`android/key.properties`:
```
storePassword=<パスワード>
keyPassword=<パスワード>
keyAlias=upload
storeFile=<キーストアのパス>
```

**build.gradleの更新:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**App Bundleのビルド:**
```bash
flutter build appbundle --release
```

### iOSアプリのビルド

#### 1. Apple Developer Programへの登録
- [Apple Developer](https://developer.apple.com/)でアカウント作成
- 年間99ドルの登録料が必要

#### 2. Xcodeでの設定
```bash
open ios/Runner.xcworkspace
```

1. Runner → Signing & Capabilities
2. Team を選択
3. Bundle Identifier を設定

#### 3. リリースビルドの作成
```bash
flutter build ios --release
```

#### 4. App Store Connectへのアップロード
1. Xcode → Product → Archive
2. Organizer → Distribute App
3. App Store Connect へアップロード

### Webアプリのデプロイ

#### 1. Webビルドの作成
```bash
flutter build web --release
```

#### 2. ビルド成果物の場所
```
build/web/
```

#### 3. Firebase Hostingへのデプロイ例
```bash
# Firebase CLIのインストール
npm install -g firebase-tools

# Firebaseへログイン
firebase login

# プロジェクトの初期化
firebase init hosting

# デプロイ
firebase deploy
```

## パフォーマンス最適化

### 1. 画像の最適化
- 適切なサイズの画像を使用
- WebP形式の使用を検討

### 2. コードの最小化
```bash
flutter build apk --release --obfuscate --split-debug-info=/<directory>
```

### 3. アプリサイズの削減
```bash
# 未使用のリソースを削除
flutter build apk --release --target-platform android-arm,android-arm64
```

## 継続的インテグレーション

### GitHub Actionsの例

`.github/workflows/flutter.yml`:
```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk
```

## サポート

問題が発生した場合:
1. [Flutter公式ドキュメント](https://docs.flutter.dev/)を確認
2. [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)で検索
3. [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)を確認

## 次のステップ

- [ ] 実機でのテスト
- [ ] ユーザーテストの実施
- [ ] アプリストアへの申請準備
- [ ] プロモーション素材の作成
- [ ] アナリティクスの実装検討
