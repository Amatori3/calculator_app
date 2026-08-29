# Release signing setup

Google Play rejects APKs/AABs signed with the default debug certificate, so a
real upload keystore is required before the first release build. This is a
one-time, per-developer step — do it locally, not via an agent, since the
passwords must live only in your password manager.

## 1. Generate the keystore

Run this yourself in a terminal (it prompts for passwords interactively, so
they never land in shell history or logs):

```bash
cd android
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Pick a strong store password and key password (they can be the same value)
and save them in your password manager immediately — **if this file or its
passwords are lost, you can never publish an update to the same Play Store
listing under the same signing identity again.**

## 2. Create `android/key.properties`

Copy `android/key.properties.example` to `android/key.properties` and fill in
the real values:

```
storePassword=<your store password>
keyPassword=<your key password>
keyAlias=upload
storeFile=upload-keystore.jks
```

Both `key.properties` and `*.jks` are already covered by
`android/.gitignore` — never commit them.

## 3. Build the release artifact

```bash
flutter build appbundle --release
```

`android/app/build.gradle.kts` picks up `key.properties` automatically when
it exists; without it, release builds silently fall back to the debug key
(fine for local `flutter run --release`, not fine for upload).

## Back up the keystore

Store `upload-keystore.jks` somewhere durable outside this repo (password
manager attachment, encrypted drive, etc.) — it is not recoverable if lost.
