# 1.0.0

First release of `better_share_handler`, a maintained fork of `share_handler` 0.0.26 by Shout (https://github.com/AboutShout/share_handler) published as a single package.

- Android and iOS implementations merged into one package (no federated sub-packages)
- iOS share extension module renamed to `better_share_handler_models`
- Swift Package Manager and CocoaPods support
- UIScene lifecycle support
- Fix iOS share extension cancelling every share on device because `UserDefaults.synchronize()` returns false inside extensions
- Validate iOS callback URLs and use one-time callback keys
- Keep initial shares out of the live stream and buffer live events until listening
- Stage Android attachments atomically and bound queued events
- Privacy manifests for App Group UserDefaults access
