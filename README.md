# flutter_contact_index

A Flutter plugin for reading device contacts and returning indexed contact data
for side index UIs (such as A-Z quick navigation lists).

## Demo

<table>
  <tr>
    <td align="center"><b>iOS</b></td>
    <td align="center"><b>Android</b></td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/huangjim/flutter_contact_index/main/doc/images/demo-ios.png" alt="iOS Demo" width="370" />
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/huangjim/flutter_contact_index/main/doc/images/demo-android.png" alt="Android Demo" width="280" />
    </td>
  </tr>
</table>

## Features

- Read contacts from native address books (Android/iOS).
- Return grouped index tags via `sorKey` for fast side index navigation.
- Return contact `displayName`, `phoneList`, and optional `avatar` bytes.
- Keep platform-specific index behavior where possible.

## Install

```yaml
dependencies:
  flutter_contact_index: ^0.1.2
```

Then run:

```bash
flutter pub get
```

## Quick usage

```dart
import 'package:flutter_contact_index/flutter_contact_index.dart';

final service = FlutterContactIndex();
final contacts = await service.getAllContacts();
```

## API

- `FlutterContactIndex().getAllContacts() -> Future<List<ContactsModel>>`
- `ContactsModel`
  - `sorKey`: index tag (for example `A`, `B`, `#`)
  - `displayName`: contact display name
  - `phoneList`: phone list with label + number
  - `avatar`: optional thumbnail bytes

## Platform setup

### Android

1. Add contacts permission in your app `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

2. Request runtime permission before calling `getAllContacts()`.

### iOS

- Contacts are read from `CNContactStore`.
- Add `NSContactsUsageDescription` to your app `Info.plist`.
- Add `CFBundleLocalizations` for languages you support. If not configured,
  index grouping for some languages may degrade to `#`.
- iOS side index behavior is simulated based on locale/script detection, and may
  not be fully identical to the system Contacts app in every locale.

Example `Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>We need contacts access to show your contacts list.</string>

<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>zh-Hans</string>
  <string>zh-Hant</string>
  <string>ja</string>
</array>
```

## Example app

Run the bundled demo:

```bash
cd example
flutter run
```

## Repository

- Source: <https://github.com/huangjim/flutter_contact_index>
- Issues: <https://github.com/huangjim/flutter_contact_index/issues>
