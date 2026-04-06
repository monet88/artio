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

    testWidgets('Verify templates load correctly', (tester) async {
      // Query templates directly from Supabase
      final response = await Supabase.instance.client
          .from('templates')
          .select()
          .order('sort_order', ascending: true);

      // Verify minimum count (admin may add more)
      expect(response.length, greaterThanOrEqualTo(25),
          reason: 'Should have at least 25 seed templates');

      // Verify core categories exist
      final categories = response.map((t) => t['category'] as String).toSet();
      expect(categories.length, greaterThanOrEqualTo(5),
          reason: 'Should have at least 5 categories');

      expect(categories, contains('Portrait & Face Effects'));
      expect(categories, contains('Removal & Editing'));
      expect(categories, contains('Art Style Transfer'));
      expect(categories, contains('Photo Enhancement'));
      expect(categories, contains('Creative & Fun'));

      // Verify sort_order is ascending and positive
      for (var i = 0; i < response.length; i++) {
        final sortOrder = response[i]['sort_order'] as int;
        expect(sortOrder, greaterThan(0),
            reason: 'Template at index $i should have positive sort_order');
        if (i > 0) {
          final prevOrder = response[i - 1]['sort_order'] as int;
          expect(sortOrder, greaterThanOrEqualTo(prevOrder),
              reason: 'sort_order should be ascending');
        }
      }

      // Verify original 25 seed templates exist (by name)
      final names = response.map((t) => t['name'] as String).toList();
      const seedNames = [
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
      for (final seed in seedNames) {
        expect(names, contains(seed),
            reason: 'Seed template "$seed" should exist');
      }

      debugPrint('✅ ${response.length} templates verified (≥25 seed)');
      debugPrint('✅ ${categories.length} categories verified');
      debugPrint('✅ sort_order ascending and positive');
    });

    testWidgets('Verify category distribution', (tester) async {
      final response = await Supabase.instance.client
          .from('templates')
          .select()
          .order('sort_order', ascending: true);

      // Count templates per category
      final categoryCounts = <String, int>{};
      for (final template in response) {
        final category = template['category'] as String;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Verify core categories have at least their seed counts
      expect(categoryCounts['Portrait & Face Effects'],
          greaterThanOrEqualTo(7));
      expect(
          categoryCounts['Removal & Editing'], greaterThanOrEqualTo(4));
      expect(
          categoryCounts['Art Style Transfer'], greaterThanOrEqualTo(6));
      expect(
          categoryCounts['Photo Enhancement'], greaterThanOrEqualTo(4));
      expect(categoryCounts['Creative & Fun'], greaterThanOrEqualTo(4));

      debugPrint('✅ Category distribution verified (≥ seed counts):');
      categoryCounts.forEach((cat, count) {
        debugPrint('   - $cat: $count templates');
      });
    });
  });
}
