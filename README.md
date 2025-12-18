<meta name='keywords' content='flutter, drop_down_search_field, autocomplete, customizable, floating, type_ahead, nested_dropdown, hierarchical, multi_select, tree_view'>

[![Pub](https://img.shields.io/pub/v/drop_down_search_field)](https://pub.dev/packages/drop_down_search_field)

# Flutter DropDownSearchField
A powerful and highly customizable DropDownSearchField (autocomplete) widget for Flutter that supports flat lists, multi-selection, and **hierarchical nested data structures**. Perfect for categories, organizational structures, file systems, or any data with parent-child relationships.

**Key Features:**
- 🔍 **Smart Autocomplete** - Type-ahead search with debouncing and filtering
- 🌳 **Nested/Hierarchical Dropdowns** - Support for unlimited nesting levels with expand/collapse
- 🏷️ **Multi-Selection** - Select multiple items with chip display and custom logic  
- 📱 **Highly Customizable** - Extensive styling and behavior customization options
- ⚡ **Performance Optimized** - Pagination support and efficient rendering for large datasets

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/master/drop_down_search_field.gif">

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/master/paginated_dropdown_search_field.gif">

<img src="https://raw.githubusercontent.com/rohanjariwala03/drop_down_search_field/master/multi_select_dropdown_search_field.gif">

## Features

### Core Functionality
* **Floating Overlay**: Displays suggestions in a floating overlay above other widgets
* **Customizable Appearance**: Full customization of suggestion appearance using builder functions
* **TextField Integration**: Supports all standard TextField parameters including decoration, controllers, and styling
* **Form Support**: Available as both standalone widget and FormField with validation
* **Highly Configurable**: Extensive customization options for suggestion box decoration, loading states, animations, debounce duration, and more

### Advanced Features
* **Multi-Select Dropdown**: Select multiple items with chip display and custom selection logic
* **Nested/Hierarchical Dropdown**: Support for multi-level nested data structures with expand/collapse functionality
* **Paginated Suggestions**: Load suggestions in batches for improved performance with large datasets
* **Disabled Items**: Mark specific items as non-selectable while keeping them visible
* **Smart Search**: Intelligent filtering with support for nested item searching and auto-expansion

### Nested Dropdown Capabilities
* **Hierarchical Data Structure**: Display data in tree-like structures with unlimited nesting levels
* **Expand/Collapse Controls**: Interactive expand/collapse icons for parent items
* **Multi-Level Selection**: Select items at any level of the hierarchy
* **Auto-Expansion**: Automatic expansion when searching through nested items
* **Customizable Indentation**: Configurable child item indentation for visual hierarchy
* **Parent/Child Selection Logic**: Control whether parent items are selectable or just organizational
* **Smart Filtering**: Search functionality that shows matching branches and auto-expands relevant sections

## Installation
See the [installation instructions on pub](https://pub.dartlang.org/packages/drop_down_search_field#-installing-tab-).

Note: As for DropDownSearchField 1.X this package is based on Dart 3.0 (null-safety). You may also want to explore the new built in Flutter 2 widgets that have similar behavior.

## Quick Start

### Basic Dropdown
```dart
import 'package:drop_down_search_field/drop_down_search_field.dart';

DropDownSearchField(
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
)
```
In the code above, the `textFieldConfiguration` property allows us to
configure the displayed `TextField` as we want. In this example, we are
configuring the `autofocus`, `style` and `decoration` properties.

The `suggestionsCallback` is called with the search string that the user
types, and is expected to return a `List` of data either synchronously or
asynchronously. In this example, we are calling an asynchronous function
called `BackendService.getSuggestions` which fetches the list of
suggestions.

The `itemBuilder` is called to build a widget for each suggestion.
In this example, we build a simple `ListTile` that shows the name and the
price of the item. Please note that you shouldn't provide an `onTap`
callback here. The DropDownSearchField widget takes care of that.

The `onSuggestionSelected` is a callback called when the user taps a
suggestion. In this example, when the user taps a
suggestion, we navigate to a page that shows us the information of the
tapped product.

### Example 2:
Here's another example, where we use the DropDownSearchFormField inside a `Form`:
```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _dropDownSearchController = TextEditingController();
String _selectedFruit;
...
Form(
  key: this._formKey,
  child: Padding(
    padding: EdgeInsets.all(32.0),
    child: Column(
      children: <Widget>[
        Text(
          'What is your favorite fruit?'
        ),
        DropDownSearchFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: this._dropDownSearchController,
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
            this._dropDownSearchController.text = suggestion;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Please select a fruit';
            }
          },
          onSaved: (value) => this._selectedFruit = value,
        ),
        SizedBox(height: 10.0,),
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () {
            if (this._formKey.currentState.validate()) {
              this._formKey.currentState.save();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Your Favorite Fruit is ${this._selectedFruit}')
              ));
            }
          },
        )
      ],
    ),
  ),
)
```

### Example 3: Nested Dropdown
Here's an example of using the nested dropdown functionality for hierarchical data:

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
)
```

### Example 4: Multi-Select Nested Dropdown
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
)
```
In the `textFieldConfiguration`, we assign the `_dropDownSearchController` to 
the `controller` property. This controller is a `TextEditingController`. 
When a suggestion is selected, we utilize the `onSuggestionSelected` callback 
to update the value of the `TextField` with the selected suggestion.

The `validator` callback serves a similar purpose as any `FormField.validator` function. 
In our specific example, it verifies whether a value has been entered and displays 
an error message if it hasn't. The `onSaved` callback is employed to store the field's 
value in the `_selectedFruit` member variable.

With the `transitionBuilder`, we have the flexibility to customize the animation 
of the suggestion box. In the given illustration, we immediately return the 
suggestionsBox without any animation.

### Alternative Layout Architecture:

By default, DropDownSearchField uses a `ListView` to render the items created by `itemBuilder`. 
If you specify a `layoutArchitecture` component, it will use this component instead. For example, 
here's how we render the items in a grid using the standard `GridView`:

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
to resize incorrectly. Since animation times are variable, this has to be 
corrected manually at the end of the animation. You will need to add a 
SuggestionsBoxController described below and the following code for the 
AnimationController.
```dart
void Function(AnimationStatus) _statusListener;

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
There is a known issue with opening dialogs where the suggestions box will sometimes appear too small. 
This is a timing issue caused by the animations described above. Currently, `showDialog` has a duration 
of 150 ms for the animations. DropDownSearchField has a delay of 170 ms to compensate for this. Until 
the end of the animation can be properly detected and fixed using the solution above, this temporary fix 
will work most of the time. If the suggestions box is too small, closing and reopening the keyboard will 
usually fix the issue.

## Nested Dropdown Feature Guide

The nested dropdown functionality allows you to display hierarchical data in an intuitive tree-like structure. This is perfect for categories, organizational structures, file systems, or any data with parent-child relationships.

### Key Concepts

#### NestedItem Model
The `NestedItem<T>` class is the core of the nested dropdown system:
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

### Configuration Options

#### NestedDropdownConfiguration
Configure the behavior and appearance of your nested dropdown:

```dart
NestedDropdownConfiguration(
  // Visual settings
  childIndentation: 16.0,         // Indentation per level
  showExpandIcons: true,          // Show expand/collapse icons
  expandIcon: Icons.expand_more,  // Custom expand icon
  collapseIcon: Icons.expand_less,// Custom collapse icon
  
  // Behavior settings
  allowParentSelection: true,     // Can select parent items
  autoExpandOnSearch: true,       // Auto-expand when searching
  collapseOnOpen: false,          // Collapse all on open
  initiallyExpanded: false,       // Expand all initially
  showOnlyMatchingBranches: true, // Show only matching items
)
```

### Advanced Features

#### Smart Selection Logic
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
Create custom widgets for each hierarchy level:
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
The nested dropdown supports intelligent filtering:
- **Branch Matching**: Shows entire branches when any item matches
- **Auto-Expansion**: Automatically expands matching branches
- **Recursive Search**: Searches through all hierarchy levels

### Utility Methods

The `NestedItem` class provides helpful utility methods:

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

1. **Performance**: For large datasets, implement lazy loading in `nestedSuggestionsCallback`
2. **UX**: Use meaningful icons and labels to help users understand hierarchy
3. **Accessibility**: Test with screen readers and keyboard navigation
4. **Consistency**: Maintain consistent indentation and styling across levels
5. **Feedback**: Provide visual feedback for expand/collapse actions

## Customizations
DropDownSearchField widgets consist of a TextField and a suggestion box that shows
as the user types. Both are highly customizable

### Customizing the TextField
You can customize the text field using the `textFieldConfiguration` property.
You provide this property with an instance of `TextFieldConfiguration`,
which allows you to configure all the usual properties of `TextField`, like
`decoration`, `style`, `controller`, `focusNode`, `autofocus`, `enabled`,
etc.

### Customizing the suggestions box
DropDownSearchField provides default configurations for the suggestions box. You can,
however, override most of them. This is done by passing a `SuggestionsBoxDecoration` 
to the `suggestionsBoxDecoration` property.

Use the `offsetX` property in `SuggestionsBoxDecoration` to shift the suggestions box along the x-axis. 
You may also pass BoxConstraints to `constraints` in `SuggestionsBoxDecoration` to adjust the width 
and height of the suggestions box. Using the two together will allow the suggestions box to be placed 
almost anywhere.

#### Customizing the loader, the error and the "no items found" message
You can use the `loadingBuilder`, `errorBuilder` and `noItemsFoundBuilder` to
customize their corresponding widgets. For example, to show a custom error
widget:
```dart
errorBuilder: (BuildContext context, Object error) =>
  Text(
    '$error',
    style: TextStyle(
      color: Theme.of(context).errorColor
    )
  )
```

By default, the suggestions box will maintain the old suggestions while new 
suggestions are being retrieved. To show a circular progress indicator 
during retrieval instead, set `keepSuggestionsOnLoading` to false.

#### Hiding the suggestions box
There are three scenarios when you can hide the suggestions box.

Set `hideOnLoading` to true to hide the box while suggestions are being 
retrieved. This will also ignore the `loadingBuilder`. Set `hideOnEmpty` 
to true to hide the box when there are no suggestions. This will also ignore 
the `noItemsFoundBuilder`. Set `hideOnError` to true to hide the box when there 
is an error retrieving suggestions. This will also ignore the `errorBuilder`.

By default, the suggestions box will automatically hide when the keyboard is hidden. 
To change this behavior, set `hideSuggestionsOnKeyboardHide` to false.

#### Customizing the decoration of the suggestions box
You can also customize the decoration of the suggestions box using the
`suggestionsBoxDecoration` property. For example, to remove the elevation
of the suggestions box, you can write:
```dart
suggestionsBoxDecoration: SuggestionsBoxDecoration(
  elevation: 0.0
)
```

#### Customizing the debounce duration
The suggestions box does not fire for each character the user types. Instead,
we wait until the user is idle for a duration of time, and then call the
`suggestionsCallback`. The duration defaults to 300 milliseconds, but can be
configured using the `debounceDuration` parameter.

#### Customizing the animation
You can customize the suggestion box animation through 3 parameters: the
`animationDuration`, the `animationStart`, and the `transitionBuilder`.

The `animationDuration` specifies how long the animation should take, while the
`animationStart` specified what point (between 0.0 and 1.0) the animation
should start from. The `transitionBuilder` accepts the `suggestionsBox` and
`animationController` as parameters, and should return a widget that uses
the `animationController` to animate the display of the `suggestionsBox`.
For example:
```dart
transitionBuilder: (context, suggestionsBox, animationController) =>
  FadeTransition(
    child: suggestionsBox,
    opacity: CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn
    ),
  )
```
This uses [FadeTransition](https://docs.flutter.io/flutter/widgets/FadeTransition-class.html)
to fade the `suggestionsBox` into the view. Note how the
`animationController` was provided as the parent of the animation.

In order to fully remove the animation, `transitionBuilder` should simply
return the `suggestionsBox`. This callback could also be used to wrap the
`suggestionsBox` with any desired widgets, not necessarily for animation.

#### Customizing the offset of the suggestions box
By default, the suggestions box is displayed 5 pixels below the `TextField`.
You can change this by changing the `suggestionsBoxVerticalOffset` property.

#### Customizing the direction of the suggestions list
By default, the suggestions list expands downwards. However, you can customize the growth direction 
by using the `direction` property. It allows you to choose between `AxisDirection.down` or `AxisDirection.up`. 
If you set it to `AxisDirection.up`, the list will grow in an upward direction. This means that the first 
suggestion will be positioned at the bottom of the list, while the last suggestion will appear at the top.

By setting the `autoFlipDirection` property to `true`, the suggestions list will automatically flip 
its direction whenever it detects insufficient space in the current direction. This feature is 
particularly beneficial when the DropDownSearchField is placed within a scrollable widget or when 
the developer wants to ensure that the list is always visible regardless of the user's screen size.

#### Controlling the suggestionsBox
You can manually control the suggestions box by creating a `SuggestionsBoxController` instance and 
assigning it to the `suggestionsBoxController` property. This enables you to have control over opening, 
closing, toggling, or resizing the suggestions box as per your requirements.

You can also customize suggestion box scroll bar by using property called `scrollBarDecoration` inside `suggestionsBoxDecoration`. This allows you to control color, thickness, margin and more.

<!-- ## Blog
You can checkout detailed blog on medium.
[drop_down_search_field](https://medium.com/@rohanjariwala03/dropdown-with-future-search-option-818a7dc1196) -->

## How you can help
[Contribution Guidelines](https://github.com/rohanjariwala03/drop_down_search_field/blob/master/CONTRIBUTING.md)


## TODO
- Enhanced nested dropdown animations and transitions
- More built-in item builder templates for common use cases
- Improved accessibility features for nested structures
- Performance optimizations for very large nested datasets
- Additional keyboard navigation options for nested items
