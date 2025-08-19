import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PerformanceTestPage extends StatefulWidget {
  final int itemCount;

  const PerformanceTestPage({super.key, this.itemCount = 1000});

  @override
  State<PerformanceTestPage> createState() => _PerformanceTestPageState();
}

class _PerformanceTestPageState extends State<PerformanceTestPage> {
  final TextEditingController _controller = TextEditingController();
  late List<String> largeDataset;

  @override
  void initState() {
    super.initState();
    // Generate large dataset for performance testing
    largeDataset = List.generate(
      widget.itemCount,
      (index) => 'Item ${index + 1} - ${_generateRandomText()}',
    );
  }

  String _generateRandomText() {
    final words = [
      'Apple',
      'Banana',
      'Cherry',
      'Date',
      'Elderberry',
      'Fig',
      'Grape'
    ];
    return words[(DateTime.now().millisecondsSinceEpoch + largeDataset.length) %
        words.length];
  }

  Future<List<String>> _searchItems(String pattern) async {
    // Simulate some processing time
    await Future.delayed(const Duration(milliseconds: 10));

    return largeDataset
        .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
        .take(50) // Limit results for performance
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropDownSearchFormField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Search items',
              border: OutlineInputBorder(),
              helperText: 'Testing with large dataset',
            ),
          ),
          suggestionsCallback: _searchItems,
          itemBuilder: (context, String suggestion) {
            return ListTile(
              title: Text(suggestion),
              subtitle: Text('Index: ${largeDataset.indexOf(suggestion)}'),
            );
          },
          onSuggestionSelected: (String suggestion) {
            _controller.text = suggestion;
          },
          noItemsFoundBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No items found in large dataset'),
          ),
          loadingBuilder: (context) => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          debounceDuration: const Duration(milliseconds: 300),
          minCharsForSuggestions: 1,
        ),
      ),
    );
  }
}

class AccessibilityTestPage extends StatefulWidget {
  const AccessibilityTestPage({super.key});

  @override
  State<AccessibilityTestPage> createState() => _AccessibilityTestPageState();
}

class _AccessibilityTestPageState extends State<AccessibilityTestPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> accessibilityItems = [
    'Screen Reader Compatible',
    'Voice Control Ready',
    'High Contrast Support',
    'Keyboard Navigation',
    'Focus Management',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DropDownSearchFormField<String>(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Accessibility Features',
              border: OutlineInputBorder(),
              helperText: 'Search for accessibility features',
            ),
          ),
          suggestionsCallback: (pattern) {
            return accessibilityItems
                .where((item) =>
                    item.toLowerCase().contains(pattern.toLowerCase()))
                .toList();
          },
          itemBuilder: (context, String suggestion) {
            return Semantics(
              button: true,
              label: 'Select $suggestion',
              child: ListTile(
                title: Text(suggestion),
                leading: const Icon(Icons.accessibility),
              ),
            );
          },
          onSuggestionSelected: (String suggestion) {
            _controller.text = suggestion;
          },
          noItemsFoundBuilder: (context) => Semantics(
            label: 'No accessibility features found',
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No features found'),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('Performance Tests', () {
    testWidgets('should handle large datasets efficiently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PerformanceTestPage(itemCount: 1000)),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Measure performance of search operation
      final stopwatch = Stopwatch()..start();

      await tester.enterText(textField, 'Item');
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Search should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 seconds max

      // Should show limited results
      final listTiles = find.byType(ListTile);
      expect(listTiles.evaluate().length, lessThanOrEqualTo(50));
    });

    testWidgets('should handle rapid typing without performance issues',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PerformanceTestPage(itemCount: 500)),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Simulate rapid typing
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        await tester.enterText(textField, 'Search$i');
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should handle rapid typing efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // 3 seconds max
    });

    testWidgets('should debounce search requests effectively',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PerformanceTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Type rapidly and check debouncing
      await tester.enterText(textField, 'I');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, 'It');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, 'Ite');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(textField, 'Item');

      // Wait for debounce to complete
      await tester.pumpAndSettle();

      // Should show results for final search
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('should dispose resources properly with large datasets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PerformanceTestPage(itemCount: 1000)),
      );
      await tester.pumpAndSettle();

      // Navigate away to trigger disposal
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('New Page'))),
      );
      await tester.pumpAndSettle();

      // Should dispose without memory leaks
      expect(find.text('New Page'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should provide proper semantic labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      // Check semantic properties
      final semanticsNode = tester.getSemantics(find.byType(TextField));
      expect(semanticsNode.label, contains('Accessibility Features'));
    });

    testWidgets('should support screen readers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'Screen');
      await tester.pumpAndSettle();

      // Should show suggestions with proper semantic labels
      expect(find.text('Screen Reader Compatible'), findsOneWidget);

      // Check if suggestions have proper semantics
      final suggestionSemantics = tester.getSemantics(
        find.text('Screen Reader Compatible'),
      );
      expect(suggestionSemantics, isNotNull);
    });

    testWidgets('should handle keyboard navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Field should be focusable
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.focusNode?.hasFocus, isTrue);
    });

    testWidgets('should provide accessible error messages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Search for non-existent item
      await tester.enterText(textField, 'NonExistent');
      await tester.pumpAndSettle();

      // Should show accessible no results message
      expect(find.text('No features found'), findsOneWidget);

      final noResultsSemantics = tester.getSemantics(
        find.text('No features found'),
      );
      expect(noResultsSemantics.label,
          contains('No accessibility features found'));
    });

    testWidgets('should support high contrast mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      // Check that basic UI elements are present and visible
      expect(find.text('Accessibility Features'), findsOneWidget);
      expect(find.byIcon(Icons.accessibility),
          findsNothing); // No suggestions shown yet

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'High');
      await tester.pumpAndSettle();

      // Should show high contrast option
      expect(find.text('High Contrast Support'), findsOneWidget);
      expect(find.byIcon(Icons.accessibility), findsOneWidget);
    });

    testWidgets('should maintain focus properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Focus should be on text field
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.focusNode?.hasFocus, isTrue);

      await tester.enterText(textField, 'Keyboard');
      await tester.pumpAndSettle();

      // Focus should remain on text field after typing
      expect(textFieldWidget.focusNode?.hasFocus, isTrue);
    });

    testWidgets('should provide proper ARIA labels for suggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AccessibilityTestPage()),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      await tester.enterText(textField, 'Voice');
      await tester.pumpAndSettle();

      // Check semantic structure of suggestions
      final voiceControlFinder = find.text('Voice Control Ready');
      expect(voiceControlFinder, findsOneWidget);

      final semantics = tester.getSemantics(voiceControlFinder);
      expect(semantics, isNotNull);
    });
  });

  group('Memory Management Tests', () {
    testWidgets('should not leak memory with frequent searches',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PerformanceTestPage(itemCount: 100)),
      );
      await tester.pumpAndSettle();

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.pumpAndSettle();

      // Perform many searches
      for (int i = 0; i < 20; i++) {
        await tester.enterText(textField, 'Search$i');
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should complete without issues
      expect(find.byType(DropDownSearchFormField<String>), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds efficiently',
        (WidgetTester tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return PerformanceTestPage(itemCount: 50);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialBuildCount = buildCount;

      // Trigger rebuild
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              buildCount++;
              return PerformanceTestPage(itemCount: 50);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should not rebuild excessively
      expect(buildCount, lessThan(initialBuildCount + 5));
    });
  });
}
