#!/bin/bash

# SUUMO家探しアプリ - セットアップスクリプト
# このスクリプトは初回セットアップを自動化します

echo "SUUMO家探しアプリ - セットアップを開始します"
echo "================================================"

# Flutterのバージョンチェック
echo ""
echo "Flutter環境をチェック中..."
if ! command -v flutter &> /dev/null
then
    echo "Flutterがインストールされていません"
    echo "https://docs.flutter.dev/get-started/install からインストールしてください"
    exit 1
fi

echo "Flutter が見つかりました"
flutter --version

# Flutter Doctorの実行
echo ""
echo "Flutter Doctor を実行中..."
flutter doctor

# 依存関係のインストール
echo ""
echo "依存関係をインストール中..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "依存関係のインストールが完了しました"
else
    echo "依存関係のインストールに失敗しました"
    exit 1
fi

# Google Maps APIキーのチェック
echo ""
echo "Google Maps API キーの設定を確認中..."

# Android設定チェック
ANDROID_MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$ANDROID_MANIFEST" ]; then
    if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" "$ANDROID_MANIFEST"; then
        echo " Android: Google Maps APIキーが設定されていません"
        echo "   $ANDROID_MANIFEST を編集してAPIキーを設定してください"
    else
        echo "Android: APIキーが設定されています"
    fi
else
    echo " Android: AndroidManifest.xmlが見つかりません"
fi

# iOS設定チェック
IOS_APPDELEGATE="ios/Runner/AppDelegate.swift"
if [ -f "$IOS_APPDELEGATE" ]; then
    if grep -q "YOUR_GOOGLE_MAPS_API_KEY_HERE" "$IOS_APPDELEGATE"; then
        echo "  iOS: Google Maps APIキーが設定されていません"
        echo "   $IOS_APPDELEGATE を編集してAPIキーを設定してください"
    else
        echo " iOS: APIキーが設定されています"
    fi
else
    echo "  iOS: AppDelegate.swiftが見つかりません"
fi

# 利用可能なデバイスの確認
echo ""
echo "利用可能なデバイスを確認中..."
flutter devices

# セットアップ完了
echo ""
echo "================================================"
echo " セットアップが完了しました！"
echo ""
echo "次のステップ:"
echo "1. Google Maps APIキーを設定（まだの場合）"
echo "   - Android: $ANDROID_MANIFEST"
echo "   - iOS: $IOS_APPDELEGATE"
echo ""
echo "2. アプリを実行:"
echo "   flutter run"
echo ""
echo "3. 詳細なガイドは SETUP_GUIDE.md を参照してください"
echo "================================================"
