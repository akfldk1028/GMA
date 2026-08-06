import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gma_app/features/scrapnote/models/highlight_color.dart';

void main() {
  group('HighlightColors constants', () {
    test('yellow is 0xFFFFEB3B', () {
      expect(HighlightColors.yellow, 0xFFFFEB3B);
    });

    test('green is 0xFF4CAF50', () {
      expect(HighlightColors.green, 0xFF4CAF50);
    });

    test('blue is 0xFF2196F3', () {
      expect(HighlightColors.blue, 0xFF2196F3);
    });

    test('pink is 0xFFE91E63', () {
      expect(HighlightColors.pink, 0xFFE91E63);
    });

    test('orange is 0xFFFF9800', () {
      expect(HighlightColors.orange, 0xFFFF9800);
    });

    test('defaultColor equals yellow', () {
      expect(HighlightColors.defaultColor, HighlightColors.yellow);
    });

    test('highlightOpacity is 0.4', () {
      expect(HighlightColors.highlightOpacity, 0.4);
    });
  });

  group('HighlightColors availableColors', () {
    test('contains exactly 5 colors', () {
      expect(HighlightColors.availableColors, hasLength(5));
    });

    test('contains all defined colors', () {
      expect(
        HighlightColors.availableColors,
        containsAll([
          HighlightColors.yellow,
          HighlightColors.green,
          HighlightColors.blue,
          HighlightColors.pink,
          HighlightColors.orange,
        ]),
      );
    });

    test('yellow is the first color in the list', () {
      expect(HighlightColors.availableColors.first, HighlightColors.yellow);
    });

    test('all values are non-zero ARGB integers', () {
      for (final color in HighlightColors.availableColors) {
        expect(color, greaterThan(0));
        // Alpha channel should be FF (fully opaque)
        expect((color >> 24) & 0xFF, 0xFF);
      }
    });

    test('all colors are distinct', () {
      final set = HighlightColors.availableColors.toSet();
      expect(set.length, HighlightColors.availableColors.length);
    });
  });

  group('LastUsedHighlightColor provider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is defaultColor (yellow)', () {
      final color = container.read(lastUsedHighlightColorProvider);
      expect(color, HighlightColors.defaultColor);
    });

    test('setColor updates the state', () {
      final notifier = container.read(lastUsedHighlightColorProvider.notifier);
      notifier.setColor(HighlightColors.blue);

      final color = container.read(lastUsedHighlightColorProvider);
      expect(color, HighlightColors.blue);
    });

    test('setColor can be called multiple times', () {
      final notifier = container.read(lastUsedHighlightColorProvider.notifier);

      notifier.setColor(HighlightColors.green);
      expect(
        container.read(lastUsedHighlightColorProvider),
        HighlightColors.green,
      );

      notifier.setColor(HighlightColors.pink);
      expect(
        container.read(lastUsedHighlightColorProvider),
        HighlightColors.pink,
      );
    });

    test('setColor accepts any integer color value', () {
      final notifier = container.read(lastUsedHighlightColorProvider.notifier);
      const customColor = 0xFF123456;
      notifier.setColor(customColor);

      expect(container.read(lastUsedHighlightColorProvider), customColor);
    });

    test('each container instance starts fresh with default', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();

      container1
          .read(lastUsedHighlightColorProvider.notifier)
          .setColor(HighlightColors.orange);

      // container2 should be independent
      expect(
        container2.read(lastUsedHighlightColorProvider),
        HighlightColors.defaultColor,
      );

      container1.dispose();
      container2.dispose();
    });
  });
}
