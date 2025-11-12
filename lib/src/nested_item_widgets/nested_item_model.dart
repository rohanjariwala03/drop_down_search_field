/// Model class for nested dropdown items
///
/// This class represents a hierarchical item that can contain child items.
/// It's designed to support nested dropdown functionality while maintaining
/// compatibility with the existing architecture.
class NestedItem<T> {
  /// The main data/value of this item
  final T value;

  /// The display label for this item (optional)
  final String? label;

  /// Child items nested under this parent
  final List<NestedItem<T>>? children;

  /// Whether this item is expanded to show children
  bool isExpanded;

  /// Whether this item is selectable
  final bool isSelectable;

  /// Whether this item is disabled
  final bool isDisabled;

  /// Optional icon data for the item
  final dynamic icon;

  /// Custom metadata for the item
  final Map<String, dynamic>? metadata;

  NestedItem({
    required this.value,
    this.label,
    this.children,
    this.isExpanded = false,
    this.isSelectable = true,
    this.isDisabled = false,
    this.icon,
    this.metadata,
  });

  /// Whether this item has children
  bool get hasChildren => children != null && children!.isNotEmpty;

  /// Whether this item is a leaf node (no children)
  bool get isLeaf => !hasChildren;

  /// Get all descendant items (children, grandchildren, etc.)
  List<NestedItem<T>> get allDescendants {
    final List<NestedItem<T>> descendants = [];

    if (hasChildren) {
      for (final child in children!) {
        descendants.add(child);
        descendants.addAll(child.allDescendants);
      }
    }

    return descendants;
  }

  /// Get all selectable descendant items
  List<NestedItem<T>> get selectableDescendants {
    return allDescendants
        .where((item) => item.isSelectable && !item.isDisabled)
        .toList();
  }

  /// Find a nested item by its value
  NestedItem<T>? findByValue(T searchValue,
      {bool Function(T, T)? equalityFunction}) {
    // Use custom equality function if provided, otherwise use default equality
    final isEqual =
        equalityFunction?.call(value, searchValue) ?? (value == searchValue);

    if (isEqual) return this;

    if (hasChildren) {
      for (final child in children!) {
        final found =
            child.findByValue(searchValue, equalityFunction: equalityFunction);
        if (found != null) return found;
      }
    }

    return null;
  }

  /// Toggle expansion state
  void toggleExpansion() {
    if (hasChildren) {
      isExpanded = !isExpanded;
    }
  }

  /// Expand this item and optionally all descendants
  void expand({bool recursive = false}) {
    if (hasChildren) {
      isExpanded = true;

      if (recursive) {
        for (final child in children!) {
          child.expand(recursive: true);
        }
      }
    }
  }

  /// Collapse this item and optionally all descendants
  void collapse({bool recursive = false}) {
    if (hasChildren) {
      isExpanded = false;

      if (recursive) {
        for (final child in children!) {
          child.collapse(recursive: true);
        }
      }
    }
  }

  /// Create a copy of this item with modified properties
  NestedItem<T> copyWith({
    T? value,
    String? label,
    List<NestedItem<T>>? children,
    bool? isExpanded,
    bool? isSelectable,
    bool? isDisabled,
    bool? isAllowedCheck,
    dynamic icon,
    Map<String, dynamic>? metadata,
  }) {
    return NestedItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelectable: isSelectable ?? this.isSelectable,
      isDisabled: isDisabled ?? this.isDisabled,
      icon: icon ?? this.icon,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'NestedItem(value: $value, label: $label, hasChildren: $hasChildren, isExpanded: $isExpanded)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NestedItem<T> &&
        other.value == value &&
        other.label == label;
  }

  @override
  int get hashCode => value.hashCode ^ label.hashCode;
}

/// Configuration for nested dropdown behavior
class NestedDropdownConfiguration {
  /// Whether to show expand/collapse icons for parent items
  final bool showExpandIcons;

  /// Custom expand icon
  final dynamic expandIcon;

  /// Custom collapse icon
  final dynamic collapseIcon;

  /// Indentation for child items (in logical pixels)
  final double childIndentation;

  /// Whether to allow selection of parent items
  final bool allowParentSelection;

  /// Whether to automatically expand items when searching
  final bool autoExpandOnSearch;

  /// Whether to collapse all items when the dropdown opens
  final bool collapseOnOpen;

  /// Whether to expand all items initially when the dropdown opens
  ///
  /// If true, all nested items will be expanded when the dropdown is first shown.
  /// This overrides the default collapsed state and provides immediate visibility
  /// of the entire hierarchy.
  ///
  /// Note: This flag is ignored if [collapseOnOpen] is true.
  final bool initiallyExpanded;

  /// Whether to show only matching items and their parents during search
  final bool showOnlyMatchingBranches;

  /// Animation duration for expand/collapse
  final Duration expansionAnimationDuration;

  const NestedDropdownConfiguration({
    this.showExpandIcons = true,
    this.expandIcon,
    this.collapseIcon,
    this.childIndentation = 16.0, // Reduced from 20.0 to prevent layout issues
    this.allowParentSelection = false,
    this.autoExpandOnSearch = true,
    this.collapseOnOpen = false,
    this.initiallyExpanded = false,
    this.showOnlyMatchingBranches = true,
    this.expansionAnimationDuration = const Duration(milliseconds: 200),
  });
}
