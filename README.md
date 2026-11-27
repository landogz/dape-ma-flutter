# DAPE-MA Mobile

Flutter app for **DAPE-MA** (Dangerous Drugs Board).

## Current release

| Field | Value |
| --- | --- |
| Version | **1.0.2** |
| Build | **4** (`pubspec.yaml`: `1.0.2+4`) |
| GitHub Release | [v1.0.2-b4](https://github.com/landogz/dape-ma-flutter/releases/tag/v1.0.2-b4) |
| APK (GitHub) | [dape-ma.apk](https://github.com/landogz/dape-ma-flutter/releases/download/v1.0.2-b4/dape-ma.apk) |
| APK (production) | https://dapemade.ddb.gov.ph/download/dape-ma.apk |

In-app Android updates use production `/api/v1/app-update` + the production APK URL. GitHub Releases are the versioned archive (same pattern as Inside Scores).

## Ship checklist (agents)

On every mobile change that ships:

1. Bump `version` in `pubspec.yaml` (patch + build).
2. Sync `dape-ma-laravel/public/download/dape-ma-version.json` (and `config/dape.php` defaults).
3. **Update this README** (version, build, release links, changelog).
4. `flutter build apk --release` → copy to Laravel `public/download/dape-ma.apk`.
5. `bash scripts/publish-github-release.sh`
6. Commit / push Flutter + Laravel; pull production.

## Changelog

### 1.0.2 (build 4)

- Set Location loads PSA PSGC via one `/locations/tree` call (instant Region → Province → City).
- Password checklist shows unmet rules in red.
- GitHub Releases publish script (`scripts/publish-github-release.sh`).

### 1.0.1 (build 3)

- Earlier production APK line (pre–tree cascade / release pipeline).

## Local run

```bash
flutter pub get
flutter run
```

Release APK:

```bash
flutter build apk --release
bash scripts/publish-github-release.sh
```
