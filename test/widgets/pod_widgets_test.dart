import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:driver_app/generated/l10n/app_localizations.dart';
import 'package:driver_app/generated/l10n/app_localizations_ar.dart';
import 'package:driver_app/generated/l10n/app_localizations_en.dart';
import 'package:driver_app/generated/l10n/app_localizations_fr.dart';
import 'package:driver_app/src/features/pod/presentation/widgets/pod_widgets.dart';
import '../support/pump.dart';

/// 1x1 transparent PNG — a valid decodable image for the "captured" photo state.
Uint8List _tinyPng() => base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M8AAAMBAQDJ/IjpAAAAAElFTkSuQmCC',
    );

AppLocalizations _loc(String locale) {
  switch (locale) {
    case 'fr':
      return AppLocalizationsFr();
    case 'en':
      return AppLocalizationsEn();
    case 'ar':
      return AppLocalizationsAr();
    default:
      throw ArgumentError('Unknown locale: $locale');
  }
}

Locale _flutterLocale(String locale) => switch (locale) {
      'fr' => const Locale('fr'),
      'en' => const Locale('en'),
      'ar' => const Locale('ar'),
      _ => throw ArgumentError('Unknown locale: $locale'),
    };

class _FakeItem {
  final String name = 'Test Item';
  final String? sku = 'SKU-1';
  final int quantity = 5;
}

void main() {
  group('PodInstructionsCard — i18n', () {
    for (final loc in ['fr', 'en', 'ar']) {
      testWidgets('renders localized step 1 ($loc)', (tester) async {
        await pumpThemed(
          tester,
          PodInstructionsCard(locale: loc),
          locale: _flutterLocale(loc),
        );
        // The 3 steps render as one multi-line Text, so match a substring.
        expect(find.textContaining(_loc(loc).pod_step_1), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('PodPhotoSection', () {
    testWidgets('empty state shows tap hint + take label (fr)', (tester) async {
      await pumpThemed(
        tester,
        PodPhotoSection(
          title: 'Bon de livraison',
          subtitle: 'Photo du BL signé',
          bytes: null,
          isRequired: true,
          onCapture: () {},
          onClear: () {},
          locale: 'fr',
          icon: LucideIcons.fileText,
        ),
        locale: const Locale('fr'),
      );
      final fr = _loc('fr');
      expect(find.text(fr.pod_photo_tap_hint), findsOneWidget);
      expect(find.text(fr.pod_photo_take), findsOneWidget);
    });

    testWidgets('captured state shows retake + delete (en)', (tester) async {
      await pumpThemed(
        tester,
        PodPhotoSection(
          title: 'Delivery note',
          subtitle: 'Signed BL photo',
          bytes: _tinyPng(),
          isRequired: true,
          onCapture: () {},
          onClear: () {},
          locale: 'en',
          icon: LucideIcons.fileText,
        ),
        locale: const Locale('en'),
      );
      final en = _loc('en');
      expect(find.text(en.pod_photo_retake), findsOneWidget);
      expect(find.text(en.pod_photo_delete), findsOneWidget);
    });

    testWidgets('golden — empty', (tester) async {
      await pumpThemed(
        tester,
        PodPhotoSection(
          title: 'Bon de livraison',
          subtitle: 'Photo du BL signé',
          bytes: null,
          isRequired: true,
          onCapture: () {},
          onClear: () {},
          locale: 'fr',
          icon: LucideIcons.fileText,
        ),
        locale: const Locale('fr'),
      );
      await expectLater(
        find.byType(PodPhotoSection),
        matchesGoldenFile('goldens/pod_photo_section_empty.png'),
      );
    });
  });

  group('PodItemOutcomeRow', () {
    testWidgets('renders item name + outcome chips, no exception (fr)', (tester) async {
      await pumpThemed(
        tester,
        PodItemOutcomeRow(
          item: _FakeItem(),
          currentQty: 5,
          outcome: 'DELIVERED',
          reason: null,
          locale: 'fr',
          onOutcome: (_) {},
          onQty: (_) {},
          onReason: (_) {},
        ),
        locale: const Locale('fr'),
      );
      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text(podOutcomeLabel('DELIVERED', 'fr')), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
