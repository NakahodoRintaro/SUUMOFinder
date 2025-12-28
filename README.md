# SUUMO家探しアプリ (suumo_finder_app)

SUUMOの物件データをスコアリングして最適な物件を見つけるFlutterアプリケーション

## 主要機能

### 物件一覧
- スコアリング済みの物件を美しいカードデザインで表示
- ランキング表示（1位〜）
- お気に入り機能
- リフレッシュによる再読み込み

### フィルター機能
- **賃料**: 最低〜最高賃料で絞り込み
- **間取り**: 1K、1DK、1LDK、2LDKなど
- **駅徒歩時間**: 最大徒歩時間で絞り込み
- **専有面積**: 最低面積で絞り込み
- **最寄駅**: 特定の駅でフィルター
- **お気に入りのみ**: お気に入り物件のみ表示

### ソート機能
- 総合スコア順（デフォルト）
- 賃料順
- 広さ順
- 駅徒歩時間順
- 川崎駅までの時間順
- 昇順/降順の切り替え

### 詳細画面
- 物件の詳細情報表示
- Google Maps統合（物件位置表示）
- スコアの詳細な内訳
  - 川崎駅へのアクセススコア (30%)
  - 渋谷駅へのアクセススコア (20%)
  - 新橋駅へのアクセススコア (10%)
  - 新宿駅へのアクセススコア (10%)
  - 駅からの近さスコア (10%)
  - 部屋の広さスコア (20%)
- SUUMOの物件詳細ページへのリンク

### 地図表示
- すべての物件を地図上に表示
- スコアに応じた色分けマーカー
  - 緑: 80点以上
  - 黄: 60-79点
  - 赤: 60点未満
- マーカータップで物件情報を表示
- 物件カードから詳細画面へ遷移

## 技術スタック

- **Flutter SDK**: 3.0+
- **状態管理**: Provider
- **地図表示**: Google Maps Flutter
- **ローカルストレージ**: SharedPreferences
- **UIライブラリ**: Google Fonts, Flutter Animate

## セットアップ

### 前提条件
- Flutter SDK 3.0以上
- Dart SDK 3.0以上
- Android Studio / Xcode（iOS開発の場合）

### インストール手順

1. **リポジトリのクローン**
```bash
cd suumo_finder_app
```

2. **依存関係のインストール**
```bash
flutter pub get
```

3. **Google Maps APIキーの設定**

#### Android の場合
`android/app/src/main/AndroidManifest.xml` に以下を追加:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>
</manifest>
```

#### iOS の場合
`ios/Runner/AppDelegate.swift` に以下を追加:
```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

4. **アプリの実行**
```bash
flutter run
```

## 📂 プロジェクト構造

```
suumo_finder_app/
├── lib/
│   ├── main.dart                    # アプリのエントリーポイント
│   ├── models/
│   │   └── property.dart            # データモデル
│   ├── providers/
│   │   └── property_provider.dart   # 状態管理
│   ├── services/
│   │   └── property_service.dart    # データサービス
│   ├── screens/
│   │   ├── home_screen.dart         # ホーム画面
│   │   ├── property_detail_screen.dart  # 詳細画面
│   │   ├── filter_screen.dart       # フィルター画面
│   │   └── map_screen.dart          # 地図画面
│   └── widgets/
│       └── property_card.dart       # 物件カードウィジェット
├── assets/
│   └── data/
│       └── properties.json          # 物件データ
└── pubspec.yaml                     # 依存関係定義
```

## カスタマイズ

### 物件データの更新

`assets/data/properties.json` を編集して物件データを更新できます。

各物件には以下の情報が必要です:
- id: 物件ID
- 物件名、住所、最寄駅、駅徒歩時間
- 専有面積、間取り、賃料、管理費
- 緯度、経度
- 各駅へのアクセス時間とスコア
- 総合スコア、ランク

### スコアリングの重み調整

`lib/services/property_service.dart` の `weights` を変更:

```dart
final weights = {
  '川崎駅までの時間': 0.3,  // 30%
  '渋谷駅までの時間': 0.2,  // 20%
  '新橋駅までの時間': 0.1,  // 10%
  '新宿駅までの時間': 0.1,  // 10%
  '駅徒歩時間': 0.1,        // 10%
  '部屋の広さ': 0.2,        // 20%
};
```

## ビルドと公開

### Androidビルド
```bash
flutter build apk --release
```

### iOSビルド
```bash
flutter build ios --release
```

### Webビルド
```bash
flutter build web
```

## 今後の機能追加予定

- [ ] 物件比較機能（複数物件の並列比較）
- [ ] 通知機能（新着物件アラート）
- [ ] 検索履歴の保存
- [ ] カスタムスコアリング（ユーザーごとの重み設定）
- [ ] 物件のコメント・メモ機能
- [ ] ダークモード対応
- [ ] 多言語対応

## ライセンス

MIT License

## 開発者

NakahodoRintaro @ 2025 

## 謝辞

- SUUMO様の物件情報を参考にしています
- Google Maps Platform
- Flutter Community
