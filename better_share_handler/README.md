# better_share_handler

[![pub package](https://img.shields.io/pub/v/better_share_handler.svg)](https://pub.dev/packages/better_share_handler)

Receive text, URLs, images, videos and files shared to your Flutter app from other apps, on iOS and Android, and show your app's conversations as direct share suggestions.

**better_share_handler is an evolution of [share_handler](https://pub.dev/packages/share_handler)**, the plugin originally created by [Shout](https://github.com/AboutShout/share_handler). It keeps the same API and native setup, and builds on it with bug fixes, modern platform support and a simpler package layout. If you already use `share_handler`, migrating takes a few minutes: see [Migrating from share_handler](#migrating-from-share_handler).

## What's improved over share_handler

- **Shares work on real iOS devices.** Fixes the share extension cancelling every share on device (the app flashed and never opened), caused by `UserDefaults.synchronize()` returning `false` inside extensions.
- **Reliable delivery.** The share that launched the app arrives once through `getInitialSharedMedia()`; shares received while the app runs arrive through `sharedMediaStream`, buffered until you start listening. No duplicates between the two.
- **Safer iOS hand-off.** Callback URLs are validated, each share uses a one-time key, and the extension only finishes after the host app actually opened.
- **Safer Android staging.** Attachments are staged atomically and queued events are bounded.
- **Modern platforms.** UIScene lifecycle, Swift Package Manager and CocoaPods, privacy manifests, Android Gradle Plugin 9.
- **One package.** Android, iOS and the Dart API ship together in `better_share_handler`: no federated sub-packages to keep in sync.

## Platform support

| Android | iOS |
| :-----: | :-: |
| ✅ | ✅ 14.0+ |

Requires Flutter 3.44+ and Dart 3.12+.

## Installation

```sh
flutter pub add better_share_handler
```

Then follow the native setup for each platform below.

## iOS setup

On iOS, other apps share through a **Share Extension**. The extension saves the shared content to an App Group shared with your app, then opens your app through a custom URL scheme so your Dart code can read it.

### 1. Runner `Info.plist`

Add the following to `ios/Runner/Info.plist`. It registers the URL scheme the Share Extension uses to open your app and, for photos, asks for photo library access.

```xml
<!-- Add for better_share_handler start -->
<!-- The 'NSUserActivityTypes' key is only needed if you plan to use the recordSentMessage API allowing for conversations to show up as direct share suggestions -->
<key>NSUserActivityTypes</key>
<array>
    <string>INSendMessageIntent</string>
</array>

<!-- Uncomment below lines if you want to use a custom group id rather than the default. Set it in Build Settings -> User-Defined -->
<!-- <key>AppGroupId</key>
<string>$(CUSTOM_GROUP_ID)</string> -->

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>ShareMedia-$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>

<key>NSPhotoLibraryUsageDescription</key>
<string>Photos can be shared to and used in this app</string>

<!-- Optional: Add/Customize for AirDrop support -->
<key>LSSupportsOpeningDocumentsInPlace</key>
<string>No</string>
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>ShareHandler</string>
        <key>LSHandlerRank</key>
        <string>Alternate</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>public.file-url</string>
            <string>public.image</string>
            <string>public.text</string>
            <string>public.movie</string>
            <string>public.url</string>
            <string>public.data</string>
        </array>
    </dict>
</array>

<!-- Add for better_share_handler end -->
```

### 2. Create the Share Extension

In Xcode, choose **File > New > Target**, pick **Share Extension** and name it `ShareExtension`.

### 3. Share Extension `Info.plist`

Replace the contents of `ios/ShareExtension/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Uncomment below lines if you want to use a custom group id rather than the default. Set it in Build Settings -> User-Defined -->
    <!-- <key>AppGroupId</key>
    <string>$(CUSTOM_GROUP_ID)</string> -->

    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionAttributes</key>
        <dict>
            <!-- Add supported message intent if you support sharing to a specific conversation - start -->
            <key>IntentsSupported</key>
            <array>
                <string>INSendMessageIntent</string>
            </array>
            <!-- Add supported message intent if you support sharing to a specific conversation (registered via the recordSentMessage api call) - end -->
            <key>NSExtensionActivationRule</key>
            <!-- Comment or delete the TRUEPREDICATE NSExtensionActivationRule that only works in development mode -->
            <!-- <string>TRUEPREDICATE</string> -->
            <!-- Add a new NSExtensionActivationRule. The rule below will allow sharing one or more file of any type, url, or text content, You can modify these rules to your liking for which types of share content, as well as how many your app can handle -->
            <string>SUBQUERY (
                extensionItems,
                $extensionItem,
                SUBQUERY (
                    $extensionItem.attachments,
                    $attachment,
                    (
                        ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.file-url"
                        || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.image"
                        || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.text"
                        || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.movie"
                        || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url"
                    )
                ).@count > 0
            ).@count > 0
	    </string>
	    <key>PHSupportedMediaTypes</key>
	    <array>
	        <string>Video</string>
	        <string>Image</string>
	    </array>
        </dict>
        <key>NSExtensionMainStoryboard</key>
        <string>MainInterface</string>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.share-services</string>
    </dict>
</dict>
</plist> 
```

### 4. App Group

Both targets must share the same App Group:

1. Select **Runner > Signing & Capabilities**, click **+ Capability** and add **App Groups**.
2. Add a group. By default the plugin expects your bundle identifier prefixed with `group.` (for example `group.com.example.app`).
3. Repeat in the **ShareExtension** target, selecting the same group.

**Custom group id (optional).** To use a different group, for example `group.myapp`:

1. In **Build Settings** of both targets, add a User-Defined setting `CUSTOM_GROUP_ID` with the group id.
2. Uncomment the `AppGroupId` key in both `Info.plist` files (steps 1 and 3).

### 5. Link the extension module

The extension uses the `better_share_handler_models` module.

**CocoaPods:** add the `ShareExtension` target inside `target 'Runner' do` in `ios/Podfile`, then run `pod install` in `ios/`:

```ruby
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))

  # better_share_handler addition start
  target 'ShareExtension' do
    inherit! :search_paths
    pod "better_share_handler_models", :path => ".symlinks/plugins/better_share_handler/ios/Models"
  end
  # better_share_handler addition end
end
```

**Swift Package Manager:** run `flutter build ios` once. Then, in Xcode, select the **ShareExtension** target > **General > Frameworks and Libraries**, click **+**, choose **Add Other... > Add Package Dependency... > Add Local...**, pick `ios/Flutter/ephemeral/Packages/.packages/better_share_handler` and add the `better-share-handler-models` product.

### 6. Share view controller

Replace the contents of `ios/ShareExtension/ShareViewController.swift`. The extension has no UI of its own: it saves the shared content and opens your app.

```swift
import better_share_handler_models
    
class ShareViewController: ShareHandlerIosViewController {}
```

## Android setup

### 1. Intent filters

In `android/app/src/main/AndroidManifest.xml`, add the intent filters for the content types you want to receive:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
.....
 >
 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>

  <application
        ...
        >

    <activity
            android:name=".MainActivity"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

             <!--TODO: Add this filter if you want to handle shared text-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="text/*" />
            </intent-filter>

            <!--TODO: Add this filter if you want to handle shared images-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="image/*" />
            </intent-filter>

            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="image/*" />
            </intent-filter>

            <!--TODO: Add this filter if you want to handle shared videos-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="video/*" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="video/*" />
            </intent-filter>

            <!--TODO: Add this filter if you want to handle any type of file-->
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND_MULTIPLE" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="*/*" />
            </intent-filter>

            <!-- TODO: (Optional) Add these meta-data tags if you want to support sharing to a specific target/conversation/shortcut (via the recordSentMessage api) -->
            <meta-data
                android:name="android.service.chooser.chooser_target_service"
                android:value="androidx.sharetarget.ChooserTargetServiceCompat" />
            <meta-data
                android:name="android.app.shortcuts"
                android:resource="@xml/share_targets" />
      </activity>

  </application>
</manifest>
```

To avoid opening a new activity for every incoming share, set `android:launchMode="singleTask"` on `MainActivity`.

### 2. Direct share suggestions (optional)

To show conversations registered with `recordSentMessage` in the share sheet, create `android/app/src/main/res/xml/share_targets.xml`, replacing `{your.package.identifier}` with your application id:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shortcuts xmlns:android="http://schemas.android.com/apk/res/android">
    <share-target android:targetClass="{your.package.identifier}.MainActivity">
        <data android:mimeType="*/*" />
        <category android:name="{your.package.identifier}.dynamic_share_target" />
    </share-target>
</shortcuts>
```

## Usage

```dart
import 'package:better_share_handler/better_share_handler.dart';

final handler = ShareHandler.instance;

// Share that launched the app (delivered once).
final SharedMedia? initial = await handler.getInitialSharedMedia();
if (initial != null) {
  handleShare(initial);
  await handler.resetInitialSharedMedia();
}

// Shares received while the app is running.
handler.sharedMediaStream.listen(handleShare);

void handleShare(SharedMedia media) {
  print('Text: ${media.content}');
  for (final attachment in media.attachments ?? <SharedAttachment?>[]) {
    print('${attachment?.type}: ${attachment?.path}');
  }
}
```

Attachment paths point to staging files. Use them right away, or copy them to your own storage if you need them later.

### Direct share suggestions

Direct share suggestions are the conversations shown at the top of the system share sheet. When the user picks one, your app opens with the shared content and the conversation already selected, so they don't have to search for it.

They work with your app's own conversations: no device contacts are needed. Typical use: a chat app with 1:1 chats and groups.

Record a conversation whenever the user sends or receives a message in it:

```dart
await ShareHandler.instance.recordSentMessage(
  conversationIdentifier: 'group-42', // your stable id, never reused
  conversationName: 'Project team',
  conversationImageFilePath: '/path/to/avatar.png', // optional, local file
  isGroup: true,
);

await ShareHandler.instance.recordReceivedMessage(
  conversationIdentifier: 'chat-7',
  conversationName: 'Maria',
);
```

When the user shares to a suggestion, `SharedMedia.conversationIdentifier` carries the id, so you can open that conversation directly.

Remove conversations that no longer exist, and clear everything on logout:

```dart
await ShareHandler.instance.removeConversations(['group-42']);
await ShareHandler.instance.removeAllConversations();
```

Notes:

- The system decides whether and where a suggestion appears, ranking by real usage. Record only real messages, not every conversation at once.
- iOS needs `INSendMessageIntent` in `NSUserActivityTypes` (Runner) and in `IntentsSupported` (ShareExtension), as shown in the iOS setup. Android needs `share_targets.xml` and the shortcut `meta-data`.
- Android shows a limited number of suggestions; the least recent ones are evicted automatically. Conversations inactive for 30 days are considered stale.
- On iOS, conversations recorded before 1.1.0 can only be removed with `removeAllConversations()`.

A complete app is available in [`example/`](example).

## Migrating from share_handler

1. In `pubspec.yaml`, replace `share_handler` with `better_share_handler: ^1.1.0`. Remove any direct dependency on `share_handler_ios`, `share_handler_android` or `share_handler_platform_interface`.
2. Replace `package:share_handler/share_handler.dart` imports with `package:better_share_handler/better_share_handler.dart`.
3. In `ios/ShareExtension/ShareViewController.swift`, replace `import share_handler_ios_models` with `import better_share_handler_models`.
4. **CocoaPods:** in the `ShareExtension` target of your `Podfile`, replace the `share_handler_ios_models` pod with the one in [iOS step 5](#5-link-the-extension-module), then run `pod install`.
   **Swift Package Manager:** remove the `share-handler-ios-models` product from the ShareExtension target and add `better-share-handler-models`.
5. Android needs no changes.

Class names (`ShareHandler`, `ShareHandlerPlatform`, `ShareHandlerIosViewController`, `SharedMedia`...) are unchanged. Behavior differences to review:

- The share that launched the app is no longer also emitted on `sharedMediaStream`; read it with `getInitialSharedMedia()`.
- `recordSentMessage()` now throws a `PlatformException` when the iOS intent donation fails.
- `ShareHandlerApi` (generated code) is no longer exported; use `ShareHandler.instance`.

## Credits

better_share_handler builds on [share_handler](https://github.com/AboutShout/share_handler) by [Shout](https://github.com/AboutShout) and its contributors, which in turn built on [receive_sharing_intent](https://github.com/KasemJaffer/receive_sharing_intent). Thank you to everyone who worked on them.

Released under the [MIT License](LICENSE).
