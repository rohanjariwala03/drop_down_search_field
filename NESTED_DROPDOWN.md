# Nested Dropdown Functionality

This package now includes powerful nested/hierarchical dropdown functionality while maintaining the existing architecture intact.

## Features

- ✅ **Hierarchical Data Support**: Display nested/tree-structured data with multiple levels
- ✅ **Expand/Collapse**: Interactive expand/collapse functionality for parent items
- ✅ **Search & Filter**: Advanced search with auto-expansion and branch filtering
- ✅ **Multi-Select**: Support for multiple selection with nested items
- ✅ **Customizable UI**: Fully customizable appearance for each nesting level
- ✅ **Keyboard Navigation**: Full keyboard support for navigation
- ✅ **Configurable Behavior**: Extensive configuration options for nested behavior

## Quick Start

### Basic Nested Dropdown

```dart
NestedDropDownSearchField<String>(
  nestedSuggestionsCallback: (pattern) async {
    return [
      NestedItem(
        value: 'Technology',
        label: 'Technology',
        children: [
          NestedItem(value: 'Flutter', label: 'Flutter'),
          NestedItem(value: 'React', label: 'React'),
        ],
      ),
    ];
  },
  nestedItemBuilder: (context, item, depth) {
    return ListTile(
      title: Text(item.label ?? item.value),
      leading: depth > 0 ? Icon(Icons.subdirectory_arrow_right) : null,
    );
  },
  onNestedSuggestionSelected: (item) {
    print('Selected: ${item.value}');
  },
  displayAllSuggestionWhenTap: true,
  isMultiSelectDropdown: false,
)
```

### Multi-Select Nested Dropdown

```dart
List<NestedItem<String>> selectedItems = [];

NestedDropDownSearchField<String>(
  nestedSuggestionsCallback: (pattern) async {
    // Return your nested data
  },
  nestedItemBuilder: (context, item, depth) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: ListTile(
        title: Text(item.label ?? item.value),
        dense: true,
      ),
    );
  },
  onNestedSuggestionMultiSelected: (item, selected) {
    if (selected) {
      selectedItems.add(item);
    } else {
      selectedItems.removeWhere((i) => i.value == item.value);
    }
  },
  initiallySelectedItems: selectedItems,
  chipBuilder: (context, item) {
    return Chip(
      label: Text(item.label ?? item.value),
      onDeleted: () {
        selectedItems.remove(item);
        // Update state
      },
    );
  },
  isMultiSelectDropdown: true,
  displayAllSuggestionWhenTap: true,
)
```

## Data Structure

### NestedItem<T>

The core data model for nested items:

```dart
class NestedItem<T> {
  final T value;                    // The actual value
  final String? label;              // Display label (optional)
  final List<NestedItem<T>>? children; // Child items
  bool isExpanded;                  // Expansion state
  final bool isSelectable;          // Whether item can be selected
  final bool isDisabled;            // Whether item is disabled
  final dynamic icon;               // Optional icon
  final Map<String, dynamic>? metadata; // Custom data

  // Constructor and methods...
}
```

### Creating Nested Data

```dart
final nestedData = [
  NestedItem(
    value: 'technology',
    label: 'Technology',
    icon: Icons.computer,
    children: [
      NestedItem(
        value: 'programming',
        label: 'Programming',
        children: [
          NestedItem(value: 'dart', label: 'Dart'),
          NestedItem(value: 'flutter', label: 'Flutter'),
          NestedItem(value: 'javascript', label: 'JavaScript'),
        ],
      ),
      NestedItem(
        value: 'databases',
        label: 'Databases',
        children: [
          NestedItem(value: 'mysql', label: 'MySQL'),
          NestedItem(value: 'postgresql', label: 'PostgreSQL'),
        ],
      ),
    ],
  ),
  NestedItem(
    value: 'science',
    label: 'Science',
    children: [
      // More nested items...
    ],
  ),
];
```

## Configuration

### NestedDropdownConfiguration

```dart
NestedDropdownConfiguration(
  showExpandIcons: true,                    // Show expand/collapse icons
  expandIcon: Icons.expand_more,            // Custom expand icon
  collapseIcon: Icons.expand_less,          // Custom collapse icon
  childIndentation: 20.0,                   // Indentation per level
  allowParentSelection: false,              // Allow selecting parent items
  autoExpandOnSearch: true,                 // Auto-expand when searching
  collapseOnOpen: false,                    // Collapse all on dropdown open
  showOnlyMatchingBranches: true,           // Filter non-matching branches
  expansionAnimationDuration: Duration(milliseconds: 200), // Animation speed
)
```

## Callbacks and Customization

### Required Callbacks

```dart
// Provide nested suggestions
nestedSuggestionsCallback: (String pattern) async {
  // Filter and return NestedItem<T> based on search pattern
  return filteredNestedItems;
},

// Build UI for each item
nestedItemBuilder: (BuildContext context, NestedItem<T> item, int depth) {
  return ListTile(
    title: Text(item.label ?? item.value.toString()),
    leading: depth > 0 ? Icon(Icons.subdirectory_arrow_right) : null,
  );
},
```

### Optional Callbacks

```dart
// Handle single selection
onNestedSuggestionSelected: (NestedItem<T> item) {
  // Handle selection
},

// Handle multi-selection
onNestedSuggestionMultiSelected: (NestedItem<T> item, bool selected) {
  // Add/remove from selected list
},

// Custom search logic
nestedItemSearchCallback: (NestedItem<T> item, String pattern) {
  // Return true if item matches pattern
  return item.label?.toLowerCase().contains(pattern.toLowerCase()) ?? false;
},

// Check if item is disabled
nestedItemDisabledCallback: (NestedItem<T> item) {
  return item.isDisabled;
},

// Custom chip builder for multi-select
chipBuilder: (BuildContext context, NestedItem<T> item) {
  return Chip(
    label: Text(item.label ?? item.value.toString()),
    onDeleted: () => removeItem(item),
  );
},

// Custom equality function
nestedEqualityFunction: (NestedItem<T> item1, NestedItem<T> item2) {
  return item1.value == item2.value;
},
```

## Advanced Usage

### Custom Search Implementation

```dart
nestedItemSearchCallback: (NestedItem<String> item, String pattern) {
  // Search in value, label, and metadata
  final searchText = pattern.toLowerCase();
  
  // Check label
  if ((item.label ?? item.value).toLowerCase().contains(searchText)) {
    return true;
  }
  
  // Check metadata
  if (item.metadata?['tags']?.any((tag) => 
      tag.toString().toLowerCase().contains(searchText)) == true) {
    return true;
  }
  
  return false;
},
```

### Dynamic Data Loading

```dart
nestedSuggestionsCallback: (String pattern) async {
  // Fetch from API
  final response = await api.getNestedData(pattern);
  
  return response.data.map((item) => NestedItem(
    value: item.id,
    label: item.name,
    children: item.children?.map((child) => NestedItem(
      value: child.id,
      label: child.name,
    )).toList(),
  ));
},
```

### Conditional Selection

```dart
nestedDropdownConfiguration: NestedDropdownConfiguration(
  allowParentSelection: false, // Only allow leaf selection
),

nestedItemBuilder: (context, item, depth) {
  final canSelect = item.isLeaf; // Only leaves are selectable
  
  return ListTile(
    title: Text(
      item.label ?? item.value,
      style: TextStyle(
        color: canSelect ? Colors.black : Colors.grey,
        fontWeight: item.hasChildren ? FontWeight.bold : FontWeight.normal,
      ),
    ),
    trailing: item.hasChildren ? Icon(Icons.folder) : Icon(Icons.file),
  );
},
```

## API Reference

### NestedDropDownSearchField Properties

| Property | Type | Description |
|----------|------|-------------|
| `nestedSuggestionsCallback` | `NestedSuggestionsCallback<T>` | **Required.** Callback to get nested suggestions |
| `nestedItemBuilder` | `NestedItemBuilder<T>` | **Required.** Builder for nested items |
| `onNestedSuggestionSelected` | `NestedSuggestionSelectionCallback<T>?` | Single selection callback |
| `onNestedSuggestionMultiSelected` | `NestedSuggestionMultiSelectionCallback<T>?` | Multi selection callback |
| `nestedDropdownConfiguration` | `NestedDropdownConfiguration` | Configuration for nested behavior |
| `nestedItemDisabledCallback` | `NestedItemDisabledCallback<T>?` | Check if item is disabled |
| `nestedItemSearchCallback` | `NestedItemSearchCallback<T>?` | Custom search logic |
| `nestedEqualityFunction` | `Function?` | Custom equality check |
| `initiallySelectedItems` | `List<NestedItem<T>>?` | Initially selected items |
| `chipBuilder` | `NestedChipBuilder<T>?` | Chip builder for multi-select |
| `isMultiSelectDropdown` | `bool` | Enable multi-selection |
| `displayAllSuggestionWhenTap` | `bool` | Show all items on tap |

### NestedItem Methods

| Method | Description |
|--------|-------------|
| `toggleExpansion()` | Toggle expand/collapse state |
| `expand({bool recursive})` | Expand item (and children if recursive) |
| `collapse({bool recursive})` | Collapse item (and children if recursive) |
| `findByValue(T value)` | Find nested item by value |
| `get allDescendants` | Get all descendant items |
| `get selectableDescendants` | Get all selectable descendants |

## Examples

Check out the complete examples in the `example/lib/example_widgets/nested_dropdown_example.dart` file to see all features in action.

The nested dropdown functionality maintains full backward compatibility with the existing package while adding powerful hierarchical data support.