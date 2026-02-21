import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Templates E2E Test', () {
    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: '.env.test');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
          'Missing required environment variables. '
          'Copy .env.test.example to .env.test and fill in values.',
        );
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    });

    testWidgets('Verify all 25 templates load correctly', (tester) async {
      // Query templates directly from Supabase
      final response = await Supabase.instance.client
          .from('templates')
          .select()
          .order('order', ascending: true);

      // Verify count
      expect(response.length, 25, reason: 'Should have 25 templates');

      // Verify categories
      final categories = response.map((t) => t['category'] as String).toSet();
      expect(categories.length, 5, reason: 'Should have 5 categories');

      expect(categories, contains('Portrait & Face Effects'));
      expect(categories, contains('Removal & Editing'));
      expect(categories, contains('Art Style Transfer'));
      expect(categories, contains('Photo Enhancement'));
      expect(categories, contains('Creative & Fun'));

      // Verify all is_premium are false
      final premiumTemplates = response
          .where((t) => t['is_premium'] == true)
          .toList();
      expect(
        premiumTemplates.length,
        0,
        reason: 'All templates should be free',
      );

      // Verify order sequence (1-25)
      for (var i = 0; i < response.length; i++) {
        expect(
          response[i]['order'],
          i + 1,
          reason: 'Template at index $i should have order ${i + 1}',
        );
      }

      // Verify template names in correct order
      final expectedNames = [
        'Hug My Younger Self',
        'AI Bangs Filter',
        'AI Beard Filter',
        'AI Beard Remover',
        'Skin Color Changer',
        'Face Cutout',
        'Passport Photo Maker',
        'Remove Filter from Photo',
        'AI Object Remover',
        'Remove Text from Image',
        'AI Color Correction',
        'Sketch to Photo',
        'Chibi Art Generator',
        'Pixel Art Generator',
        'Lego Filter',
        'Ghibli AI Generator',
        'AI Graffiti Generator',
        'AI Snow Filter',
        'Black & White Filter',
        'Fisheye Filter',
        'AI Polaroid Maker',
        'AI Mockup Generator',
        'AI Costume Generator',
        'AI Pet Portrait',
        'AI Emoji Maker',
      ];

      for (var i = 0; i < expectedNames.length; i++) {
        expect(
          response[i]['name'],
          expectedNames[i],
          reason: 'Template ${i + 1} should be ${expectedNames[i]}',
        );
      }

      debugPrint('✅ All 25 templates verified successfully!');
      debugPrint('✅ 5 categories verified: ${categories.join(", ")}');
      debugPrint('✅ All templates are free (is_premium=false)');
      debugPrint('✅ Order sequence 1-25 correct');
    });

    testWidgets('Verify category distribution', (tester) async {
      final response = await Supabase.instance.client
          .from('templates')
          .select()
          .order('order', ascending: true);

      // Count templates per category
      final categoryCounts = <String, int>{};
      for (final template in response) {
        final category = template['category'] as String;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      expect(categoryCounts['Portrait & Face Effects'], 7);
      expect(categoryCounts['Removal & Editing'], 4);
      expect(categoryCounts['Art Style Transfer'], 6);
      expect(categoryCounts['Photo Enhancement'], 4);
      expect(categoryCounts['Creative & Fun'], 4);

      debugPrint('✅ Category distribution verified:');
      categoryCounts.forEach((cat, count) {
        debugPrint('   - $cat: $count templates');
      });
    });
  });
}
