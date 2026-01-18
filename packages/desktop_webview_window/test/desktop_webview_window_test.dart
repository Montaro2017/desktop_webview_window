import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:desktop_webview_window/src/webview_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channelName = 'webview_window';
  const codec = StandardMethodCodec();
  final channel = const MethodChannel(channelName, codec);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('WebviewWindow.create sends create method and returns WebviewImpl',
      () async {
    final calls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'create') {
        return 42;
      }
      return null;
    });

    final webview = await WebviewWindow.create();

    expect(webview, isA<Webview>());
    expect((webview as dynamic).viewId, 42);
    expect(calls.length, 1);
    expect(calls.first.method, 'create');
    expect(calls.first.arguments, isA<Map>());
  });

  test('setApplicationNameForUserAgent sends correct method call', () async {
    final calls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    final webview = WebviewImpl(1, channel);
    await webview.setApplicationNameForUserAgent(' MyApp/1.0.0');

    expect(calls.length, 1);
    expect(calls.first.method, 'setApplicationNameForUserAgent');
    expect(calls.first.arguments, {
      'viewId': 1,
      'applicationName': ' MyApp/1.0.0',
    });
  });

  test('setUserAgent sends correct method call on Windows', () async {
    if (!Platform.isWindows) {
      return;
    }

    final calls = <MethodCall>[];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });

    final webview = WebviewImpl(7, channel);
    await webview.setUserAgent('CustomUserAgent/2.0');

    expect(calls.length, 1);
    expect(calls.first.method, 'setUserAgent');
    expect(calls.first.arguments, {
      'viewId': 7,
      'userAgent': 'CustomUserAgent/2.0',
    });
  });
}
