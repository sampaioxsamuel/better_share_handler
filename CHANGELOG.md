# 1.1.0

Direct share suggestions now follow the platform guidelines and can be managed from Dart.

- Add `recordReceivedMessage()` to rank conversations by incoming messages too
- Add `removeConversations()` and `removeAllConversations()` to remove share suggestions (left groups, deleted chats, logout)
- Add `isGroup` to `recordSentMessage()` and `recordReceivedMessage()`
- Android: publish suggestions with `pushDynamicShortcut`, so the oldest one is evicted instead of failing at the shortcut limit, and usage is reported for ranking
- Android: report `SEND_MESSAGE`/`RECEIVE_MESSAGE` capabilities (with `Audience` for groups), add a long label and fit avatars to the adaptive icon safe zone
- iOS: donate avatars as image data, set the interaction direction and group identifier
- iOS: sanitize shared file names in the share extension before writing them to the App Group container

# 1.0.0

First release of `better_share_handler`, a maintained fork of `share_handler` 0.0.26 by Shout (https://github.com/AboutShout/share_handler) published as a single package.

- Android and iOS implementations merged into one package (no federated sub-packages)
- iOS share extension module renamed to `better_share_handler_models`
- Swift Package Manager and CocoaPods support
- UIScene lifecycle support
- Validate iOS callback URLs and use one-time callback keys
- Keep initial shares out of the live stream and buffer live events until listening
- Stage Android attachments atomically and bound queued events
- Privacy manifests for App Group UserDefaults access
