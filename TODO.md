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

## 未着手

- [ ] **プライバシーポリシーの公開URL** — `docs/privacy-policy.md` を GitHub Pages 等でホストし、Play Console 提出用のURLを用意する
- [ ] **Play Console デベロッパーアカウント** — $25、本人確認あり。ユーザー本人の作業（代行不可）
- [ ] ストア掲載素材 — スクリーンショット、簡単な説明文、機能グラフィック(1024x500)
- [ ] （任意）実機/エミュレータでの最終動作確認 — この開発環境はWSLg上でLinuxデスクトップ版がGPU初期化に失敗し、Web版ビルドも時間がかかり未検証。Android実機かAVDでの確認が望ましい
