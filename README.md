# Hyppe

## Getting Started

## Android

To generate key (only needed to release to Play Store):

    cd android
    keytool -genkey -alias key -keyalg RSA -keystore keystore.jks -dname "CN=Hyppe, OU=Hyppe, O=Hyppe Indonesia, L=DKI Jakarta, S=Jakarta, C=ID" -storepass CHANGE_ME -keypass CHANGE_ME

After `keystore.jks` is created, create `key.properties` with the following contents:

    keyAlias=key
    keyPassword=CHANGE_ME
    storeFile=../keystore.jks
    storePassword=CHANGE_ME

Since `key.properties` contains secret, do NOT commit the file.

To generate list fingerprint:

    keytool -list -v -keystore "path > to > keystore.jks" -alias key -storepass CHANGE_ME -keypass CHANGE_ME

## Run

Via launch.json:

```
{
    "version": "0.2.0",
    "configurations": [
      {
        "name": "development",
        "program": "lib/main_dev.dart",
        "request": "launch",
        "type": "dart"
      },
      {
        "name": "profiling",
        "program": "lib/main_dev.dart",
        "request": "launch",
        "type": "dart",
        "flutterMode": "profile"
      },
      {
        "name": "production",
        "program": "lib/main_prod.dart",
        "request": "launch",
        "type": "dart",
        "flutterMode": "release"
      }
    ]
  }
```

## Releasing

### Android

Test flavor (APK):

    flutter build apk -t lib/main_dev.dart

Prod flavor (APK):

    flutter build apk -t lib/main_prod.dart --obfuscate --split-debug-info=<path-to-store-debug-info> --release --no-shrink

Prod flavor (App Bundle):

    flutter build appbundle -t lib/main_prod.dart --release

### iOS

Test flavor:

    flutter build ios -t lib/main_dev.dart

    flutter build ipa -t lib/main_dev.dart

Prod flavor:

    flutter build ios -t lib/main_prod.dart --release

    flutter build ipa -t lib/main_prod.dart --release

## Contribution Rules

1.  create branch always from develop
2.  naming sub folder branch
    ```
    a. feature for creating new feature
    b. bugfix for fixing issue
    c. refactor for refactoring code
    d. hotfix for fixing quikly for deploy the library
    ```
    ```
    example:
        - feature/branchNaming
        - bugfix/branchNaming
        - hotfix/branchNaming
        - refactor/branchNaming
    ```
3.  give the prefix for commit message header and always give sub message for the changes commit
    ```
    a. feat for new feature
    b. fix for fixing any issue
    c. refactor for refactoring code
    d. deploy for deploy new version
    ```
    ```
    example:
        - feat: backend integration
          - Integration API Backend
          - Create logic for sign up
          - Create ui home
        - fix: backend integration
          - fixing null pointer
        - refactor: backend integration
          - cleaning code
        - deploy: backend integration
          - increase version
    ```
4.  for version please follow for semantic version
5.  for merge to production or staging please request merge request to maintain our quality code
