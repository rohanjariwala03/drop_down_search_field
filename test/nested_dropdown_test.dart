import 'package:flutter_test/flutter_test.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';

void main() {
  group('NestedItem Tests', () {
    test('should create NestedItem with correct properties', () {
      final item = NestedItem<String>(
        value: 'test',
        label: 'Test Label',
        children: [
          NestedItem<String>(value: 'child1', label: 'Child 1'),
          NestedItem<String>(value: 'child2', label: 'Child 2'),
        ],
      );

      expect(item.value, equals('test'));
      expect(item.label, equals('Test Label'));
      expect(item.hasChildren, isTrue);
      expect(item.isLeaf, isFalse);
      expect(item.children!.length, equals(2));
      expect(item.isExpanded, isFalse);
      expect(item.isSelectable, isTrue);
      expect(item.isDisabled, isFalse);
    });

    test('should toggle expansion state', () {
      final item = NestedItem<String>(
        value: 'test',
        children: [
          NestedItem<String>(value: 'child1'),
        ],
      );

      expect(item.isExpanded, isFalse);
      item.toggleExpansion();
      expect(item.isExpanded, isTrue);
      item.toggleExpansion();
      expect(item.isExpanded, isFalse);
    });

    test('should create NestedItem with isAllowedCheck false', () {
      final item = NestedItem<String>(
        value: 'category',
        label: 'Category Header',
        children: [
          NestedItem<String>(value: 'child1', label: 'Child 1'),
          NestedItem<String>(value: 'child2', label: 'Child 2'),
        ],
      );

      expect(item.isSelectable, isTrue); // Still selectable, just no checkbox
      expect(item.hasChildren, isTrue);
    });

    test('should expand recursively', () {
      final item = NestedItem<String>(
        value: 'root',
        children: [
          NestedItem<String>(
            value: 'level1',
            children: [
              NestedItem<String>(value: 'level2'),
            ],
          ),
        ],
      );

      item.expand(recursive: true);
      expect(item.isExpanded, isTrue);
      expect(item.children![0].isExpanded, isTrue);
    });

    test('should collapse recursively', () {
      final item = NestedItem<String>(
        value: 'root',
        isExpanded: true,
        children: [
          NestedItem<String>(
            value: 'level1',
            isExpanded: true,
            children: [
              NestedItem<String>(value: 'level2'),
            ],
          ),
        ],
      );

      item.collapse(recursive: true);
      expect(item.isExpanded, isFalse);
      expect(item.children![0].isExpanded, isFalse);
    });

    test('should find item by value', () {
      final root = NestedItem<String>(
        value: 'root',
        children: [
          NestedItem<String>(
            value: 'level1',
            children: [
              NestedItem<String>(value: 'target'),
            ],
          ),
          NestedItem<String>(value: 'level1_b'),
        ],
      );

      final found = root.findByValue('target');
      expect(found, isNotNull);
      expect(found!.value, equals('target'));

      final notFound = root.findByValue('nonexistent');
      expect(notFound, isNull);
    });

    test('should get all descendants', () {
      final root = NestedItem<String>(
        value: 'root',
        children: [
          NestedItem<String>(
            value: 'level1',
            children: [
              NestedItem<String>(value: 'level2a'),
              NestedItem<String>(value: 'level2b'),
            ],
          ),
          NestedItem<String>(value: 'level1_b'),
        ],
      );

      final descendants = root.allDescendants;
      expect(
          descendants.length, equals(4)); // level1, level2a, level2b, level1_b
      expect(descendants.map((d) => d.value), contains('level1'));
      expect(descendants.map((d) => d.value), contains('level2a'));
      expect(descendants.map((d) => d.value), contains('level2b'));
      expect(descendants.map((d) => d.value), contains('level1_b'));
    });

    test('should get only selectable descendants', () {
      final root = NestedItem<String>(
        value: 'root',
        children: [
          NestedItem<String>(
            value: 'level1',
            isSelectable: false,
            children: [
              NestedItem<String>(value: 'level2a', isSelectable: true),
              NestedItem<String>(value: 'level2b', isDisabled: true),
            ],
          ),
          NestedItem<String>(value: 'level1_b', isSelectable: true),
        ],
      );

      final selectableDescendants = root.selectableDescendants;
      expect(selectableDescendants.length, equals(2)); // level2a, level1_b
      expect(selectableDescendants.map((d) => d.value), contains('level2a'));
      expect(selectableDescendants.map((d) => d.value), contains('level1_b'));
    });

    test('should create copy with modified properties', () {
      final original = NestedItem<String>(
        value: 'original',
        label: 'Original Label',
        isExpanded: false,
      );

      final copy = original.copyWith(
        label: 'Modified Label',
        isExpanded: true,
        isAllowedCheck: false,
      );

      expect(copy.value, equals('original')); // unchanged
      expect(copy.label, equals('Modified Label')); // changed
      expect(copy.isExpanded, isTrue); // changed
      expect(original.isExpanded, isFalse); // original unchanged
    });
  });

  group('NestedDropdownConfiguration Tests', () {
    test('should create configuration with default values', () {
      const config = NestedDropdownConfiguration();

      expect(config.showExpandIcons, isTrue);
      expect(config.childIndentation,
          equals(16.0)); // Updated to match new default
      expect(config.allowParentSelection, isFalse);
      expect(config.autoExpandOnSearch, isTrue);
      expect(config.collapseOnOpen, isFalse);
      expect(config.initiallyExpanded, isFalse);
      expect(config.showOnlyMatchingBranches, isTrue);
      expect(config.expansionAnimationDuration,
          equals(const Duration(milliseconds: 200)));
    });

    test('should create configuration with custom values', () {
      const config = NestedDropdownConfiguration(
        showExpandIcons: false,
        childIndentation: 30.0,
        allowParentSelection: true,
        autoExpandOnSearch: false,
      );

      expect(config.showExpandIcons, isFalse);
      expect(config.childIndentation, equals(30.0));
      expect(config.allowParentSelection, isTrue);
      expect(config.autoExpandOnSearch, isFalse);
    });

    test('should create configuration with initiallyExpanded', () {
      const config = NestedDropdownConfiguration(
        initiallyExpanded: true,
        collapseOnOpen: false,
      );

      expect(config.initiallyExpanded, isTrue);
      expect(config.collapseOnOpen, isFalse);
    });
  });
}
