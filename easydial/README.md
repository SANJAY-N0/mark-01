# EasyDial

A large-tile phone dialler for up to six favourite contacts, designed for older
adults, people with low vision, and people with limited fine motor control.
Tapping a contact opens the phone's own dialler with the number filled in. The
user presses call themselves.

Built with Flutter, Android first.

## Project layout

```
easydial/
├── pubspec.yaml
├── lib/
│   ├── main.dart                      App entry point and theme
│   ├── models/favourite.dart          Favourite contact model
│   ├── services/
│   │   ├── favourites_repository.dart Local storage and photo files
│   │   ├── dialer_service.dart        Opens the native dialler (tel: link)
│   │   └── contact_service.dart       System contact picker
│   ├── screens/
│   │   ├── home_screen.dart           Six tiles, Edit Contacts button
│   │   ├── edit_contacts_screen.dart  Reorder, edit, remove, add
│   │   └── contact_form_screen.dart   Add or edit one contact
│   ├── widgets/
│   │   ├── contact_avatar.dart        Photo or initials
│   │   ├── contact_tiles.dart         Large contact and empty tiles
│   │   └── common_widgets.dart        BigButton and info dialog
│   └── utils/phone_utils.dart         Validation and number cleanup
└── test/phone_utils_test.dart
```

## 1. Set up the project

You need Flutter 3.22 or newer (`flutter --version`) and an Android phone with
USB debugging enabled.

Flutter generates the Android and iOS platform folders, so create a project and
then copy in the files from this folder:

```bash
flutter create --platforms=android easydial_app
cd easydial_app
```

Replace the generated `pubspec.yaml`, the `lib/` folder and the `test/` folder
with the ones from this project. Then install the dependencies:

```bash
flutter pub get
```

## 2. Add Android permissions and dialler access

Open `android/app/src/main/AndroidManifest.xml`.

Add the contacts permission just above `<application>`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

Add the dialler query inside `<manifest>`, after the closing `</application>` tag.
On Android 11 and later, this lets the app open the dialler:

```xml
<queries>
    <intent>
        <action android:name="android.intent.action.DIAL" />
        <data android:scheme="tel" />
    </intent>
</queries>
```

Set the app name shown on the phone by changing `android:label` on `<application>`
to `"EasyDial"`.

Photo selection uses the system photo picker, so no storage permission is needed.
Camera, microphone and location are not requested.

## 3. Run on a device

```bash
flutter run
```

On first launch, EasyDial adds three clearly labelled sample contacts
("Anne (Sample)", etc.) so the layout can be previewed. Use **Edit Contacts** and
then **Remove sample contacts** to delete them, and add real people.

## 4. Run the tests

```bash
flutter test
```

The automated tests cover phone validation and number cleanup. The rest of the
checklist in the specification (permission denial, screen readers, enlarged
text, and dialling the correct number) is a manual test on a real device.

## Design decisions

- **Dialler, not auto-call.** Tapping a tile opens the dialler with the number
  filled in. Nothing is dialled without the user pressing call.
- **Local-only data.** Favourites are saved with `shared_preferences`. Photos are
  copied into the app's private folder. No account, server or internet access is
  needed.
- **Contacts are never deleted.** Removing a favourite only removes it from
  EasyDial. The phone's address book is not changed.
- **Reordering uses buttons, not drag and drop.** "Move up" and "Move down" are
  easier for users with shaky hands and do not rely on gestures.
- **Permissions are asked late.** The contacts permission is requested only when
  the user chooses "Choose from Contacts". Users who decline can type details
  instead.
- **Large text.** Text follows the system font size. Tile content scales down
  slightly, rather than overflowing, when the system text size is very large.

## Known limitations and notes

- I have not been able to compile or run this project in the environment that
  produced it. Expect to fix small issues on first build, and check the
  `flutter_contacts` API against the version you install. If `requestPermission`
  is reported as missing, use `FlutterContacts.permissions.request(PermissionType.read)`
  in `contact_service.dart`.
- Removing a sample contact that has been edited is not automatic. Use the
  Remove button on that card.
- **iOS** is not configured. To build for iOS later, add
  `NSContactsUsageDescription` to `ios/Runner/Info.plist`. Note that the
  `tel:` link opens the dialler on iPhone but iOS does not support every
  Android-style dialler behaviour.
- Screen-reader labels are set on the tiles and buttons. Test with TalkBack on
  a real device before release.
