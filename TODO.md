# Google Play 配信 TODO

目的: 品質を上げて calculator_app (表示名「電卓」) を Google Play に配信する。

## 完了

- [x] 動作確認: `flutter analyze` / `flutter test`(42件) 全てパス、タップ操作によるウィジェットテストとゴールデンスクリーンショットで挙動・レイアウトも確認済み
- [x] applicationId: `com.amatori3.calculator_app`（`com.example` からの変更は元々不要だった）
- [x] アプリ表示名を「電卓」に設定（`AndroidManifest.xml` の label、`MaterialApp.title`）
- [x] アプリアイコンをFlutterデフォルトから独自デザインに変更（deepPurple系、全mipmapサイズ + Play Console用512px hi-resアイコンを `docs/store-assets/` に用意）
- [x] リリースビルドで R8 minify / shrinkResources を有効化
- [x] リリース署名鍵 (`android/upload-keystore.jks`) を作成し `android/key.properties` を設定。`flutter build appbundle --release` / `apk --release` とも実署名（CN=amamam...）で正常ビルドを確認、debug鍵へのフォールバックなし
  - 手順は `android/KEYSTORE_SETUP.md` に記載
  - **要確認**: `upload-keystore.jks` とそのパスワードをリポジトリ外（パスワードマネージャー等）にバックアップ済みか未確認のまま
- [x] プライバシーポリシー草案を `docs/privacy-policy.md` に作成（通信・権限・データ収集なしのシンプルな内容）
- [x] プライバシーポリシーの公開URLを用意（2026-09-20）
  - リポジトリ `Amatori3/calculator_app` を public に変更し、GitHub Pages を `main` の `/docs` から配信
  - Play Console 提出用URL: https://amatori3.github.io/calculator_app/privacy-policy
  - 公開前に履歴を確認済み（鍵・パスワードの混入なし）。LICENSE は未設定（必要なら追加）

- [x] エミュレータ(AVD `test_avd`, Android 14)でリリースAPKの実動作を確認（2026-09-20）
  - 表示、ボタン入力、計算（123+456=579、840÷4=210）、ライト/ダーク両テーマを確認
  - 起動オプション `-no-window -gpu swiftshader_indirect -memory 3072 -cores 6` が必要（既定のRAM 1.5GBだとSystemUIがANRになる）
- [x] ストア用スクリーンショット4枚を `docs/store-assets/screenshots/` に用意（1080x2160、24bit PNG・アルファなし）
  - Playの縦横比制限（長辺が短辺の2倍以内）のため `adb shell wm size 1080x2160` で撮影
- [x] ストア掲載文の下書きを `docs/store-listing.md` に作成

## 未着手

- [ ] **Play Console デベロッパーアカウント** — $25、本人確認あり。ユーザー本人の作業（代行不可）
- [ ] 機能グラフィック(1024x500) — 未作成。ストア掲載に必須
- [ ] 掲載文・スクリーンショットの最終確認 — `docs/store-listing.md`（カテゴリ等は仮置き）と `docs/store-assets/screenshots/` をユーザーが確認する
- [ ] （任意）Android実機での確認 — エミュレータでは確認済み
