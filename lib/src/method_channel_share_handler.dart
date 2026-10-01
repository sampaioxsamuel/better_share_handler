import 'package:flutter/services.dart';
import 'messages.dart';
import 'share_handler_platform.dart';

/// An implementation of [ShareHandlerPlatform]
/// that uses a `MethodChannel` to communicate with the native code.
///
/// The `better_share_handler` plugin code
/// itself never talks to the native code directly.
/// It delegates all calls to an instance of a class
/// that extends the [ShareHandlerPlatform].
///
/// The architecture above allows for platforms that communicate differently
/// with the native side (like web) to have a common interface to extend.
///
/// This is the instance that runs when the native side talks
/// to your Flutter app through MethodChannels (Android and iOS platforms).
class MethodChannelShareHandler extends ShareHandlerPlatform {
  final ShareHandlerApi _api = ShareHandlerApi();
  static const EventChannel eventChannel = EventChannel(
    "better_share_handler/sharedMediaStream",
  );
  static const MethodChannel conversationsChannel = MethodChannel(
    "better_share_handler/conversations",
  );
  static Stream<SharedMedia>? _sharedMediaStream;

  @override
  Future<SharedMedia?> getInitialSharedMedia() async {
    final SharedMedia? result = await _api.getInitialSharedMedia();
    return result;
  }

  @override
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
    bool isGroup = false,
  }) {
    return _recordMessage(
      conversationIdentifier: conversationIdentifier,
      conversationName: conversationName,
      conversationImageFilePath: conversationImageFilePath,
      serviceName: serviceName,
      isGroup: isGroup,
      incoming: false,
    );
  }

  @override
  Future<void> recordReceivedMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
    bool isGroup = false,
  }) {
    return _recordMessage(
      conversationIdentifier: conversationIdentifier,
      conversationName: conversationName,
      conversationImageFilePath: conversationImageFilePath,
      serviceName: serviceName,
      isGroup: isGroup,
      incoming: true,
    );
  }

  Future<void> _recordMessage({
    required String conversationIdentifier,
    required String conversationName,
    required String? conversationImageFilePath,
    required String? serviceName,
    required bool isGroup,
    required bool incoming,
  }) {
    return conversationsChannel
        .invokeMethod<void>('recordMessage', <String, Object?>{
          'conversationIdentifier': conversationIdentifier,
          'conversationName': conversationName,
          'imageFilePath': conversationImageFilePath,
          'serviceName': serviceName,
          'isGroup': isGroup,
          'incoming': incoming,
        });
  }

  @override
  Future<void> removeConversations(List<String> conversationIdentifiers) {
    return conversationsChannel.invokeMethod<void>(
      'removeConversations',
      <String, Object?>{'conversationIdentifiers': conversationIdentifiers},
    );
  }

  @override
  Future<void> removeAllConversations() {
    return conversationsChannel.invokeMethod<void>('removeAllConversations');
  }

  @override
  Future<void> resetInitialSharedMedia() {
    return _api.resetInitialSharedMedia();
  }

  @override
  Stream<SharedMedia> get sharedMediaStream {
    _sharedMediaStream ??= eventChannel
        .receiveBroadcastStream()
        .map<SharedMedia>((dynamic event) {
          final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
          return SharedMedia.decode(map);
        });

    return _sharedMediaStream!;
  }
}
