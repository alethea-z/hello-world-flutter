# Testing and delivery notes

## Automated checks
- `flutter analyze`
- `flutter test --coverage`
- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`

## BDD trace
- Feature spec: `test/bdd/hello_world.feature`
- Widget verification: `test/widget_test.dart`

## Evidence to collect for release readiness
For every story/use case, capture and archive:
1. Test command and exit code
2. Screenshot of the running app on emulator/device
3. Screenshot or log excerpt of the executed test
4. GitHub Actions run URL
5. Built artifact URL (APK/IPA or release asset)

## Planned release artifacts
- Android APK from GitHub Actions
- iOS unsigned build output from GitHub Actions

## Notes
This repository is intended to keep repeatable build and test steps in GitHub Actions. Local runs are only for verifying and iterating on the workflow before relying on CI.
