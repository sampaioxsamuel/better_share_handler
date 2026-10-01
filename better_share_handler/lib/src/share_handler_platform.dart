import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'messages.dart';
import 'method_channel_share_handler.dart';

abstract class ShareHandlerPlatform extends PlatformInterface {
  /// Constructs a [ShareHandlerPlatform].
  ShareHandlerPlatform() : super(token: _token);

  static final Object _token = Object();

  static ShareHandlerPlatform _instance = MethodChannelShareHandler();

  /// The default instance of [ShareHandlerPlatform] to use.
  ///
  /// Defaults to [MethodChannelShareHandler].
  static ShareHandlerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [ShareHandlerPlatform] when they register themselves.
  static set instance(ShareHandlerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the initially stored shared media for single time use on app boot.
  /// Use [sharedMediaStream] to receive shares while the app is active.
  ///
  /// Attachment paths can be used directly during the current processing or
  /// upload flow. They point to staging files rather than durable app storage;
  /// see [SharedAttachment.path]. On iOS, remove staged files when they are no
  /// longer needed.
  Future<SharedMedia?> getInitialSharedMedia() async {
    throw UnimplementedError('getInitialSharedMedia has not been implemented.');
  }

  /// Records that the user sent a message to a conversation in your app, so
  /// the system share sheet can suggest it as a direct share target.
  ///
  /// [conversationIdentifier] is your own stable id for the conversation (a
  /// chat, group, channel...); it is returned as
  /// [SharedMedia.conversationIdentifier] when the user shares to the
  /// suggestion. Never reuse an id for a different conversation.
  /// [conversationImageFilePath] is a local image file used as the avatar.
  /// Set [isGroup] for group conversations (used by Android for ranking).
  ///
  /// Call it only when a message is actually sent; the system ranks
  /// suggestions by real usage.
  Future<void> recordSentMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
    bool isGroup = false,
  }) {
    throw UnimplementedError('recordSentMessage has not been implemented.');
  }

  /// Records that the user received a message in a conversation, which also
  /// improves its ranking as a share suggestion. See [recordSentMessage].
  Future<void> recordReceivedMessage({
    required String conversationIdentifier,
    required String conversationName,
    String? conversationImageFilePath,
    String? serviceName,
    bool isGroup = false,
  }) {
    throw UnimplementedError('recordReceivedMessage has not been implemented.');
  }

  /// Removes conversations from the share suggestions, for example after the
  /// user leaves a group or deletes a chat.
  ///
  /// On iOS, only conversations recorded with better_share_handler 1.1.0 or
  /// later can be removed by id; use [removeAllConversations] for older ones.
  Future<void> removeConversations(List<String> conversationIdentifiers) {
    throw UnimplementedError('removeConversations has not been implemented.');
  }

  /// Removes every conversation this app registered as a share suggestion,
  /// for example on logout.
  Future<void> removeAllConversations() {
    throw UnimplementedError('removeAllConversations has not been implemented.');
  }

  /// Resets the initial shared media to null to prevent duplicate handling.
  Future<void> resetInitialSharedMedia() {
    throw UnimplementedError('resetInitialSharedMedia has not been implemented.');
  }

  /// Stream that can be listened to for shared media when the app is already running.
  Stream<SharedMedia> get sharedMediaStream => throw UnimplementedError('mediaStream has not been implemented.');
}
