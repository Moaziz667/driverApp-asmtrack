// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/src/app.dart';
import 'package:driver_app/src/app_providers.dart';
import 'package:driver_app/src/services/token_storage.dart';
import 'package:driver_app/src/models/auth_tokens.dart';

class FakeTokenStorage extends TokenStorage {
  @override
  Future<String?> readApiBaseUrl() async => 'http://10.86.194.125';

  @override
  Future<AuthTokens?> readTokens() async => null;

  @override
  Future<List<int>> getOrCreateDbKey() async => List<int>.generate(32, (i) => i);
}

void main() {
  testWidgets('Driver shell renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        ],
        child: const DriverApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
