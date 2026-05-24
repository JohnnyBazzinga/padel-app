import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:padel_app/core/config/app_config.dart';

void main() {
  group('Production checks', () {
    test('backend endpoints use Railway production host', () {
      expect(AppConfig.apiBaseUrl, 'https://padel-backend-production-5eca.up.railway.app/api');
      expect(AppConfig.wsBaseUrl, 'wss://padel-backend-production-5eca.up.railway.app');
      expect(AppConfig.apiBaseUrl.startsWith('https://'), true);
      expect(AppConfig.wsBaseUrl.startsWith('wss://'), true);
    });

    test('providers do not include demo/mock switches', () async {
      final files = [
        'lib/shared/providers/auth_provider.dart',
        'lib/shared/providers/clubs_provider.dart',
        'lib/shared/providers/matches_provider.dart',
        'lib/shared/providers/bookings_provider.dart',
        'lib/shared/providers/rankings_provider.dart',
      ];

      for (final file in files) {
        final content = await File(file).readAsString();
        expect(content.contains('kDemoMode'), false);
        expect(content.contains('Mock data for demo mode'), false);
      }
    });
  });
}
