import 'package:better_share_handler/better_share_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShareHandler', () {
    test('can be instantiated', () {
      expect(ShareHandler.instance, isNotNull);
    });
  });

  group('conversations', () {
    final calls = <MethodCall>[];
    final handler = MethodChannelShareHandler();

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelShareHandler.conversationsChannel, (call) async {
        calls.add(call);
        return null;
      });
    });

    test('recordSentMessage sends an outgoing message', () async {
      await handler.recordSentMessage(
        conversationIdentifier: 'chat-1',
        conversationName: 'Maria',
        conversationImageFilePath: '/tmp/avatar.png',
        serviceName: 'svc',
      );
      expect(calls.single.method, 'recordMessage');
      expect(calls.single.arguments, {
        'conversationIdentifier': 'chat-1',
        'conversationName': 'Maria',
        'imageFilePath': '/tmp/avatar.png',
        'serviceName': 'svc',
        'isGroup': false,
        'incoming': false,
      });
    });

    test('recordReceivedMessage sends an incoming group message', () async {
      await handler.recordReceivedMessage(
        conversationIdentifier: 'group-1',
        conversationName: 'Team',
        isGroup: true,
      );
      expect(calls.single.arguments, containsPair('incoming', true));
      expect(calls.single.arguments, containsPair('isGroup', true));
    });

    test('removeConversations sends the ids', () async {
      await handler.removeConversations(['a', 'b']);
      expect(calls.single.method, 'removeConversations');
      expect(calls.single.arguments, {
        'conversationIdentifiers': ['a', 'b'],
      });
    });

    test('removeAllConversations', () async {
      await handler.removeAllConversations();
      expect(calls.single.method, 'removeAllConversations');
    });
  });
}
