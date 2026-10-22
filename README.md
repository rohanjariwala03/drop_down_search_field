<meta name='keywords' content='flutter, drop_down_search_field, autocomplete, customizable, floating, type_ahead, nested_dropdown, hierarchical, multi_select, tree_view'>

[![Pub](https://img.shields.io/pub/v/drop_down_search_field)](https://pub.dev/packages/drop_down_search_field)

# Flutter DropDownSearchField
A customizable DropDownSearchField (autocomplete) widget for Flutter. It handles flat lists, multi-selection, and nested (hierarchical) data such as categories, org charts or folder trees.

- Type-ahead search with debouncing
- Nested dropdowns with expand/collapse, any depth
- Multi-select with chips
- Paginated loading for long lists
- Styling and behavior options for both the text field and the suggestions box

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/main/drop_down_search_field.gif">

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/main/paginated_dropdown_search_field.gif">

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/main/multi_select_dropdown_search_field.gif">

## Features

### Core Functionality
* Suggestions show in an overlay that floats above other widgets.
* You decide how each suggestion looks through a builder function.
* The text field accepts the usual `TextField` parameters (decoration, controller, style and so on).
* Comes as a plain widget and as a `FormField` with validation.
* You can change the suggestions box decoration, loader, animation, debounce duration and more.

### Advanced Features
* Multi-select dropdown with chips and your own selection logic.
* Nested dropdown for multi-level data with expand/collapse.
* Paginated suggestions that load more items as the user scrolls.
* Disabled items that stay visible but can't be selected.
* Search inside nested items, with matching branches expanded automatically.

### Nested Dropdown Capabilities
* Tree-like display with no limit on nesting depth.
* Expand/collapse icons on parent items.
* Select items at any level, or make parents group headers only.
* Configurable indentation per level.
* Search shows only matching branches and expands them.

## Installation
Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  drop_down_search_field: ^1.3.0+1
```

Or run `flutter pub add drop_down_search_field`.

Requires Dart 3.0.5 or newer and Flutter 3.10.0 or newer.

## Recent changes
- 1.3.0+1: `MultiSelectDropdownSearchFormField` now runs its `validator`, and the error text shows under the chip box.
- 1.3.0+1: Tapping outside an open suggestions box closes it without the tap reaching widgets behind it. Taps on suggestions are no longer dropped when the text field loses focus.
- 1.3.0: Added `NestedDropDownSearchField` for hierarchical data.
- 1.2.2+1: `DropDownSearchFormField` uses the `suffixIcon` from your decoration. It falls back to a dropdown arrow.
- 1.2.0: Added `itemDisabledCallback` to show items that can't be selected.

See [CHANGELOG.md](https://github.com/rohanjariwala03/drop_down_search_field/blob/main/CHANGELOG.md) for the full list.

## Quick Start

`displayAllSuggestionWhenTap` and `isMultiSelectDropdown` are required on `DropDownSearchField` and `NestedDropDownSearchField`.

### Basic Dropdown
```dart
import 'package:drop_down_search_field/drop_down_search_field.dart';

DropDownSearchField<String>(
  suggestionsCallback: (pattern) async {
    return ['Apple', 'Banana', 'Cherry']
        .where((item) => item.toLowerCase().contains(pattern.toLowerCase()));
  },
  itemBuilder: (context, suggestion) {
    return ListTile(title: Text(suggestion));
  },
  onSuggestionSelected: (suggestion) {
    print('Selected: $suggestion');
  },
  displayAllSuggestionWhenTap: false,
  isMultiSelectDropdown: false,
)
```

### Nested Dropdown
```dart
NestedDropDownSearchField<String>(
  nestedSuggestionsCallback: (pattern) async {
    return [
      NestedItem(
        value: 'fruits',
        label: 'Fruits',
        children: [
          NestedItem(value: 'apple', label: 'Apple'),
          NestedItem(value: 'banana', label: 'Banana'),
        ],
      ),
    ];
  },
  nestedItemBuilder: (context, item, depth) {
    return ListTile(title: Text(item.label ?? item.value));
  },
  onNestedSuggestionSelected: (item) {
    print('Selected: ${item.value}');
  },
  displayAllSuggestionWhenTap: true,
  isMultiSelectDropdown: false,
)
```

## Usage examples
You can import the package with:
```dart
import 'package:drop_down_search_field/drop_down_search_field.dart';
```

Use it as follows:

### Example 1:
```dart
DropDownSearchField(
  textFieldConfiguration: TextFieldConfiguration(
    autofocus: true,
    style: DefaultTextStyle.of(context).style.copyWith(
      fontStyle: FontStyle.italic
    ),
    decoration: InputDecoration(
      border: OutlineInputBorder()
    )
  ),
  suggestionsCallback: (pattern) async {
    return await BackendService.getSuggestions(pattern);
  },
  itemBuilder: (context, suggestion) {
    return ListTile(
      leading: Icon(Icons.shopping_cart),
      title: Text(suggestion['name']),
      subtitle: Text('\$${suggestion['price']}'),
    );
  },
  onSuggestionSelected: (suggestion) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProductPage(product: suggestion)
    ));
  },
  displayAllSuggestionWhenTap: false,
  isMultiSelectDropdown: false,
)
```
`textFieldConfiguration` configures the displayed `TextField`. Here we set
`autofocus`, `style` and `decoration`.

`suggestionsCallback` is called with the text the user typed and returns an
`Iterable` of suggestions, either synchronously or as a `Future`. Here it calls
an async `BackendService.getSuggestions`.

`itemBuilder` builds a widget for each suggestion. Here it's a `ListTile` with
the item's name and price. Don't set an `onTap` on it; DropDownSearchField
handles taps.

`onSuggestionSelected` is called when the user taps a suggestion. Here we open
a page for the tapped product.

`displayAllSuggestionWhenTap` controls what gets passed to the callback when the
box opens. With `true` it is called with an empty string, so the user sees the
whole list. With `false` it gets the current text.

### Example 2:
Here's `DropDownSearchFormField` inside a `Form`:
```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _dropDownSearchController = TextEditingController();
String? _selectedFruit;
...
Form(
  key: _formKey,
  child: Padding(
    padding: EdgeInsets.all(32.0),
    child: Column(
      children: <Widget>[
        Text(
          'What is your favorite fruit?'
        ),
        DropDownSearchFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: _dropDownSearchController,
            decoration: InputDecoration(
              labelText: 'Fruit'
            )
          ),
          suggestionsCallback: (pattern) {
            return FruitsService.getSuggestions(pattern);
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (suggestion) {
            _dropDownSearchController.text = suggestion;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a fruit';
            }
            return null;
          },
          onSaved: (value) => _selectedFruit = value,
        ),
        SizedBox(height: 10.0,),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Your Favorite Fruit is $_selectedFruit')
              ));
            }
          },
        )
      ],
    ),
  ),
)
```
We pass `_dropDownSearchController` (a `TextEditingController`) as the
`controller` in `textFieldConfiguration`. When a suggestion is selected,
`onSuggestionSelected` writes it into the text field.

`validator` works like any `FormField.validator`. Here it shows an error if the
field is empty. `onSaved` stores the value in `_selectedFruit`.

`transitionBuilder` returns `suggestionsBox` as is, which turns off the
open animation.

`DropDownSearchFormField` shows a dropdown arrow as its suffix icon. Set
`suffixIcon` in the decoration to use your own.

### Example 3: Multi-Select Form Field
`MultiSelectDropdownSearchFormField` shows the selected items as chips and
supports a `validator`. The validator receives the items picked in the
dropdown. For preselected items, set `initiallySelectedItems: _selectedNames`
and `initialValue: List<String>.of(_selectedNames)` so the displayed selection
and form value start in sync. Use separate lists because the form field and
this example's selection callback each update their own list.

```dart
final List<String> _selectedNames = [];
...
MultiSelectDropdownSearchFormField<String>(
  textFieldConfiguration: TextFieldConfiguration(
    decoration: InputDecoration(hintText: 'Type to search'),
  ),
  suggestionsCallback: (pattern) => getSuggestions(pattern),
  itemBuilder: (context, suggestion) => ListTile(title: Text(suggestion)),
  initiallySelectedItems: _selectedNames,
  onMultiSuggestionSelected: (suggestion, isSelected) {
    setState(() {
      isSelected ? _selectedNames.add(suggestion) : _selectedNames.remove(suggestion);
    });
  },
  chipBuilder: (context, item) => Chip(label: Text(item)),
  validator: (selected) =>
      (selected == null || selected.isEmpty) ? 'Pick at least one name' : null,
  displayAllSuggestionWhenTap: true,
  dropdownBoxConfiguration: DropdownBoxConfiguration(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Selected Items',
    ),
    scrollbarConfiguration: ScrollbarConfiguration(thickness: 5),
  ),
)
```
`dropdownBoxConfiguration` styles the box that holds the chips, and
`scrollbarConfiguration` styles its scrollbar. If your item type doesn't
implement `==`, pass `multiSelectEquality` so selected items are matched
correctly.

### Example 4: Nested Dropdown
Here's the nested dropdown with hierarchical data:

```dart
NestedDropDownSearchField<String>(
  textFieldConfiguration: TextFieldConfiguration(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Search categories...',
      prefixIcon: Icon(Icons.search),
    ),
  ),
  nestedSuggestionsCallback: (pattern) async {
    return [
      NestedItem(
        value: 'Technology',
        label: 'Technology',
        icon: Icons.computer,
        children: [
          NestedItem(value: 'Flutter', label: 'Flutter'),
          NestedItem(value: 'JavaScript', label: 'JavaScript'),
          NestedItem(
            value: 'Databases',
            label: 'Database Systems',
            children: [
              NestedItem(value: 'MySQL', label: 'MySQL'),
              NestedItem(value: 'PostgreSQL', label: 'PostgreSQL'),
              NestedItem(value: 'MongoDB', label: 'MongoDB'),
            ],
          ),
        ],
      ),
      NestedItem(
        value: 'Science',
        label: 'Science',
        icon: Icons.science,
        children: [
          NestedItem(
            value: 'Physics',
            label: 'Physics',
            children: [
              NestedItem(value: 'Quantum Mechanics'),
              NestedItem(value: 'Thermodynamics'),
            ],
          ),
        ],
      ),
    ];
  },
  nestedItemBuilder: (context, item, depth) {
    return ListTile(
      leading: item.icon != null
          ? Icon(item.icon as IconData)
          : (depth > 0 ? Icon(Icons.subdirectory_arrow_right) : null),
      title: Text(
        item.label ?? item.value,
        style: TextStyle(
          fontWeight: item.hasChildren ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: item.hasChildren ? Text('${item.children!.length} items') : null,
      dense: depth > 0,
    );
  },
  onNestedSuggestionSelected: (item) {
    print('Selected: ${item.label ?? item.value}');
  },
  nestedDropdownConfiguration: NestedDropdownConfiguration(
    childIndentation: 16.0,
    allowParentSelection: true,
    autoExpandOnSearch: true,
    showExpandIcons: true,
    initiallyExpanded: false,
  ),
  displayAllSuggestionWhenTap: true,
  isMultiSelectDropdown: false,
)
```

### Example 5: Multi-Select Nested Dropdown
For multi-selection with nested items:

```dart
NestedDropDownSearchField<String>(
  textFieldConfiguration: TextFieldConfiguration(
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Select multiple items...',
    ),
  ),
  nestedSuggestionsCallback: getSuggestions,
  nestedItemBuilder: nestedItemBuilder,
  onNestedSuggestionMultiSelected: (item, isSelected) {
    if (isSelected) {
      selectedItems.add(item);
      // Auto-select children when parent is selected
      if (item.hasChildren) {
        selectedItems.addAll(item.selectableDescendants);
      }
    } else {
      selectedItems.remove(item);
      // Auto-deselect children when parent is deselected
      if (item.hasChildren) {
        selectedItems.removeWhere((i) =>
          item.selectableDescendants.contains(i));
      }
    }
  },
  chipBuilder: (context, item) {
    return Chip(
      label: Text(item.label ?? item.value),
      onDeleted: () => removeSelectedItem(item),
    );
  },
  isMultiSelectDropdown: true,
  initiallySelectedItems: selectedItems,
  displayAllSuggestionWhenTap: true,
)
```

### Paginated Suggestions
Pass `paginatedSuggestionsCallback` instead of `suggestionsCallback` (provide
one or the other, not both). When the user scrolls to the end of the list, the
callback is called again with the same pattern and a loader shows at the
bottom. The callback doesn't get a page number, so track the page yourself and
return the full list so far with the next batch appended. If a call returns no
new items, the list stays as it is.

```dart
paginatedSuggestionsCallback: (pattern) async {
  return await repository.loadMore(pattern); // previous items + next page
},
```

### Disabled Items
Use `itemDisabledCallback` to keep an item in the list but block selection.
Disabled items also skip hover and keyboard navigation.

```dart
itemDisabledCallback: (suggestion) => suggestion['disabled'] as bool,
```

For nested dropdowns, use `nestedItemDisabledCallback` or set `isDisabled` on
the `NestedItem`.

### Alternative Layout Architecture:

By default, DropDownSearchField renders the `itemBuilder` widgets in a `ListView`.
Pass `layoutArchitecture` to lay them out yourself. For example, a grid with
the standard `GridView`:

```dart
DropDownSearchField(
    ...,
  layoutArchitecture: (items, scrollController) {
        return ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [
              GridView.count(
                physics: const ScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 5 / 5,
                shrinkWrap: true,
                children: items.toList(),
              ),
            ]);
      },
);
```

### Animations
Placing DropDownSearchField in widgets with animations may cause the suggestions box
to resize incorrectly. Since animation times vary, you need to correct this
manually when the animation ends. Add a `SuggestionsBoxController` (described
below) and the following code for the `AnimationController`:
```dart
late void Function(AnimationStatus) _statusListener;

@override
void initState() {
  super.initState();
  _statusListener = (AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _suggestionsBoxController.resize();
    }
  };

  _animationController.addStatusListener(_statusListener);
}

@override
void dispose() {
  _animationController.removeStatusListener(_statusListener);
  _animationController.dispose();
  super.dispose();
}
```

#### Dialogs
There is a known issue with dialogs where the suggestions box sometimes appears too small.
It's the same timing problem described above. `showDialog` animates for 150 ms, and
DropDownSearchField waits 170 ms to compensate. This works most of the time. If the box
is still too small, closing and reopening the keyboard usually fixes it.

## Nested Dropdown Feature Guide

The nested dropdown shows hierarchical data as a tree. Use it for categories, org
structures, file systems, or any data with parent-child relationships.

### Key Concepts

#### NestedItem Model
`NestedItem<T>` is the building block of the nested dropdown:
```dart
NestedItem<String>(
  value: 'parentId',              // Unique identifier
  label: 'Display Name',          // Optional display text
  icon: Icons.folder,             // Optional icon
  children: [                     // Child items
    NestedItem(value: 'child1', label: 'Child 1'),
    NestedItem(value: 'child2', label: 'Child 2'),
  ],
  isExpanded: false,              // Expansion state
  isSelectable: true,             // Can be selected
  isDisabled: false,              // Is disabled
  metadata: {'key': 'value'},     // Custom data
)
```

Two `NestedItem`s are equal when their `value` and `label` match. Pass
`nestedEqualityFunction` to `NestedDropDownSearchField` to compare them another way.

### Configuration Options

#### NestedDropdownConfiguration
Controls how the nested dropdown looks and behaves. Values shown are the defaults:

```dart
NestedDropdownConfiguration(
  // Visual settings
  childIndentation: 16.0,         // Indentation per level
  showExpandIcons: true,          // Show expand/collapse icons
  expandIcon: null,               // Custom expand icon, e.g. Icons.expand_more
  collapseIcon: null,             // Custom collapse icon, e.g. Icons.expand_less
  expansionAnimationDuration: Duration(milliseconds: 200),

  // Behavior settings
  allowParentSelection: false,    // Can select parent items
  autoExpandOnSearch: true,       // Auto-expand when searching
  collapseOnOpen: false,          // Collapse all on open
  initiallyExpanded: false,       // Expand all on open (ignored if collapseOnOpen is true)
  showOnlyMatchingBranches: true, // Show only matching items
)
```

### Advanced Features

#### Parent and Child Selection
Handle parent-child relationships in multi-select mode:
```dart
onNestedSuggestionMultiSelected: (item, isSelected) {
  if (isSelected) {
    // Select the item
    selectedItems.add(item);

    // Auto-select all children when parent is selected
    if (item.hasChildren) {
      selectedItems.addAll(item.selectableDescendants);
    }
  } else {
    // Deselect the item
    selectedItems.remove(item);

    // Auto-deselect all children when parent is deselected
    if (item.hasChildren) {
      for (final child in item.selectableDescendants) {
        selectedItems.removeWhere((i) => i.value == child.value);
      }
    }
  }
}
```

#### Custom Item Builder
Build a different widget for each level of the tree:
```dart
nestedItemBuilder: (context, item, depth) {
  return ListTile(
    leading: _buildLeadingIcon(item, depth),
    title: Text(
      item.label ?? item.value,
      style: TextStyle(
        fontWeight: item.hasChildren ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14 - (depth * 0.5), // Smaller text for deeper levels
      ),
    ),
    subtitle: item.hasChildren
      ? Text('${item.children!.length} items', style: TextStyle(fontSize: 12))
      : null,
    contentPadding: EdgeInsets.only(left: 16.0 + (depth * 12.0)),
    dense: depth > 0,
  );
}

Widget _buildLeadingIcon(NestedItem item, int depth) {
  if (item.icon != null) {
    return Icon(item.icon as IconData, size: 20);
  }

  if (depth == 0) return Icon(Icons.folder, size: 20);
  if (depth == 1) return Icon(Icons.subdirectory_arrow_right, size: 16);
  return Icon(Icons.circle, size: 8);
}
```

#### Filtering and Search
The nested dropdown filters the tree you return from `nestedSuggestionsCallback`,
so the callback can return the whole tree. By default an item matches when its
`label` (or `value.toString()`) contains the typed text, ignoring case. All levels
are searched. Parents of a match stay visible, and with `autoExpandOnSearch` they
are expanded.

To change the matching rule, pass `nestedItemSearchCallback`:
```dart
nestedItemSearchCallback: (item, pattern) =>
    item.value.toLowerCase().startsWith(pattern.toLowerCase()),
```

### Utility Methods

`NestedItem` has a few helpers:

```dart
final item = NestedItem(...);

// Check properties
bool hasChildren = item.hasChildren;
bool isLeaf = item.isLeaf;

// Expansion control
item.expand();                    // Expand this item
item.collapse();                  // Collapse this item
item.expand(recursive: true);     // Expand recursively
item.toggleExpansion();           // Toggle expansion state

// Find items
final found = item.findByValue('targetValue');
final allDescendants = item.allDescendants;
final selectableOnly = item.selectableDescendants;

// Create copies
final copy = item.copyWith(
  label: 'New Label',
  isExpanded: true,
);
```

### Best Practices

1. For large trees, load data lazily in `nestedSuggestionsCallback`.
2. Use clear icons and labels so users can tell the levels apart.
3. Test with screen readers and keyboard navigation.
4. Keep indentation and styling consistent across levels.
5. Give visual feedback when items expand or collapse.

## Customizations
DropDownSearchField widgets consist of a TextField and a suggestions box that shows
as the user types. You can customize both.

### Customizing the TextField
Use the `textFieldConfiguration` property. It takes a `TextFieldConfiguration`,
which accepts the usual `TextField` properties such as `decoration`, `style`,
`controller`, `focusNode`, `autofocus` and `enabled`.

### Customizing the suggestions box
The suggestions box has sensible defaults. To override them, pass a
`SuggestionsBoxDecoration` to the `suggestionsBoxDecoration` property.

Use `offsetX` in `SuggestionsBoxDecoration` to shift the box along the x-axis,
and `constraints` (a `BoxConstraints`) to set its width and height. Together they
let you place the box almost anywhere.

#### Customizing the loader, the error and the "no items found" message
Use `loadingBuilder`, `errorBuilder` and `noItemsFoundBuilder` to replace the
default widgets. For example, a custom error widget:
```dart
errorBuilder: (BuildContext context, Object? error) =>
  Text(
    '$error',
    style: TextStyle(
      color: Theme.of(context).colorScheme.error
    )
  )
```

By default, the suggestions box keeps the old suggestions while new ones load.
To show a circular progress indicator instead, set `keepSuggestionsOnLoading` to false.

#### Hiding the suggestions box
There are three cases where you can hide the suggestions box.

Set `hideOnLoading` to true to hide the box while suggestions load. This also
ignores `loadingBuilder`. Set `hideOnEmpty` to true to hide it when there are no
suggestions. This also ignores `noItemsFoundBuilder`. Set `hideOnError` to true
to hide it when loading fails. This also ignores `errorBuilder`.

By default, the suggestions box hides when the keyboard hides. To change this,
set `hideSuggestionsOnKeyboardHide` to false.

Tapping outside the box closes it, and the tap doesn't reach widgets behind it.
Set `closeSuggestionBoxWhenTapOutside` to false in `SuggestionsBoxDecoration`
to turn this off.

#### Customizing the decoration of the suggestions box
`suggestionsBoxDecoration` also controls the look of the box. For example, to
remove its elevation:
```dart
suggestionsBoxDecoration: SuggestionsBoxDecoration(
  elevation: 0.0
)
```

To style the box's scrollbar, set `scrollBarDecoration`. It covers thumb color,
thickness, radius, margins and visibility:
```dart
suggestionsBoxDecoration: SuggestionsBoxDecoration(
  scrollBarDecoration: ScrollBarDecoration(
    thumbColor: Colors.orange,
    thickness: 10,
  ),
)
```

#### Customizing the debounce duration
The callback doesn't fire on every keystroke. It waits until the user stops
typing for a while, then calls `suggestionsCallback`. The wait defaults to
300 milliseconds. Change it with `debounceDuration`.

#### Customizing the animation
Three parameters control the suggestions box animation: `animationDuration`,
`animationStart` and `transitionBuilder`.

`animationDuration` sets how long the animation takes. `animationStart` sets the
point (between 0.0 and 1.0) where it starts. `transitionBuilder` receives the
`suggestionsBox` and the `animationController` and returns a widget that uses the
controller to animate the box. For example:
```dart
transitionBuilder: (context, suggestionsBox, animationController) =>
  FadeTransition(
    child: suggestionsBox,
    opacity: CurvedAnimation(
      parent: animationController!,
      curve: Curves.fastOutSlowIn
    ),
  )
```
This uses [FadeTransition](https://api.flutter.dev/flutter/widgets/FadeTransition-class.html)
to fade in the `suggestionsBox`. Note that `animationController` is the parent
of the animation.

To remove the animation, return `suggestionsBox` as is. You can also use this
callback to wrap the box in other widgets, not only for animation.

#### Customizing the offset of the suggestions box
By default, the suggestions box shows 5 pixels below the `TextField`.
Change this with `suggestionsBoxVerticalOffset`.

#### Customizing the direction of the suggestions list
By default, the list grows downward. Set `direction` to `AxisDirection.up` to
show the box above the field. The list then grows upward, with the first
suggestion at the bottom. Only `AxisDirection.down` and `AxisDirection.up`
are allowed.

Set `autoFlipDirection` to `true` to flip the direction when there isn't enough
room. This helps when the field is inside a scrollable widget or on small
screens. `autoFlipMinHeight` (default 64.0) sets the space below which it flips,
and `autoFlipListDirection` (default true) controls whether the list order flips too.

#### Controlling the suggestionsBox
Create a `SuggestionsBoxController` and pass it to `suggestionsBoxController`.
It has `open()`, `close()`, `toggle()` and `resize()`.

#### Other parameters
| Parameter | Default | What it does |
| --- | --- | --- |
| `minCharsForSuggestions` | `0` | Characters needed before the callback is called. |
| `getImmediateSuggestions` | `false` | Fetch suggestions as soon as the field is built. The box still opens only on focus. |
| `keepSuggestionsOnSuggestionSelected` | `false` | Keep the box open after a selection. |
| `hideKeyboard` | `false` | Make the text field read-only so the keyboard never opens. |
| `hideKeyboardOnDrag` | `false` | Hide the keyboard when the user scrolls the list. Requires `hideSuggestionsOnKeyboardHide: false`. |
| `onSuggestionsBoxToggle` | | Called with `true`/`false` when the box opens or closes. |
| `itemSeparatorBuilder` | | Builds a separator between suggestions. |
| `scrollController` | | Controls scrolling of the suggestions list. |
| `intercepting` | `false` | Works around [Flutter issue 98507](https://github.com/flutter/flutter/issues/98507), for example a dropdown over a Google Map on Flutter Web. |

<!-- ## Blog
You can checkout detailed blog on medium.
[drop_down_search_field](https://medium.com/@rohanjariwala03/dropdown-with-future-search-option-818a7dc1196) -->

## How you can help
[Contribution Guidelines](https://github.com/rohanjariwala03/drop_down_search_field/blob/main/CONTRIBUTING.md)


## TODO
- Enhanced nested dropdown animations and transitions
- More built-in item builder templates for common use cases
- Improved accessibility features for nested structures
- Performance optimizations for very large nested datasets
- Additional keyboard navigation options for nested items
