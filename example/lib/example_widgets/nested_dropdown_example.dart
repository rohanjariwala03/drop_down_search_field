import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class NestedDropdownExample extends StatefulWidget {
  const NestedDropdownExample({super.key});

  @override
  State<NestedDropdownExample> createState() => _NestedDropdownExampleState();
}

class _NestedDropdownExampleState extends State<NestedDropdownExample> {
  final TextEditingController _dropdownSearchFieldController =
      TextEditingController();
  final List<NestedItem<String>> _selectedItems = [];
  SuggestionsBoxController suggestionBoxController = SuggestionsBoxController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Sample nested data structure
  late List<NestedItem<String>> nestedData;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    nestedData = [
      NestedItem(
        value: 'Technology',
        label: 'Technology',
        icon: Icons.computer,
        children: [
          NestedItem(value: 'Dart', label: 'Dart'),
          NestedItem(value: 'Flutter', label: 'Flutter'),
          NestedItem(value: 'JavaScript', label: 'JavaScript'),
          NestedItem(value: 'Python', label: 'Python'),
          NestedItem(value: 'Java', label: 'Java'),
          NestedItem(
            value: 'Databases',
            label: 'Database Systems',
            icon: Icons.storage,
            children: [
              NestedItem(value: 'MySQL', label: 'MySQL'),
              NestedItem(value: 'PostgreSQL', label: 'PostgreSQL'),
              NestedItem(value: 'MongoDB', label: 'MongoDB'),
              NestedItem(value: 'SQLite', label: 'SQLite'),
            ],
          ),
          NestedItem(
            value: 'Cloud',
            label: 'Cloud Services',
            icon: Icons.cloud,
            children: [
              NestedItem(value: 'AWS', label: 'Amazon Web Services'),
              NestedItem(value: 'Google Cloud', label: 'Google Cloud Platform'),
              NestedItem(value: 'Azure', label: 'Microsoft Azure'),
              NestedItem(value: 'Firebase', label: 'Firebase'),
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
              NestedItem(
                  value: 'Quantum Mechanics', label: 'Quantum Mechanics'),
              NestedItem(value: 'Thermodynamics', label: 'Thermodynamics'),
              NestedItem(value: 'Electromagnetism', label: 'Electromagnetism'),
            ],
          ),
          NestedItem(
            value: 'Chemistry',
            label: 'Chemistry',
            children: [
              NestedItem(
                  value: 'Organic Chemistry', label: 'Organic Chemistry'),
              NestedItem(
                  value: 'Inorganic Chemistry', label: 'Inorganic Chemistry'),
              NestedItem(
                  value: 'Physical Chemistry', label: 'Physical Chemistry'),
            ],
          ),
          NestedItem(
            value: 'Biology',
            label: 'Biology',
            children: [
              NestedItem(value: 'Genetics', label: 'Genetics'),
              NestedItem(value: 'Ecology', label: 'Ecology'),
              NestedItem(value: 'Microbiology', label: 'Microbiology'),
            ],
          ),
        ],
      ),
      NestedItem(
        value: 'Arts',
        label: 'Arts & Literature',
        icon: Icons.palette,
        children: [
          NestedItem(
            value: 'Visual Arts',
            label: 'Visual Arts',
            children: [
              NestedItem(value: 'Painting', label: 'Painting'),
              NestedItem(value: 'Sculpture', label: 'Sculpture'),
              NestedItem(value: 'Photography', label: 'Photography'),
              NestedItem(value: 'Digital Art', label: 'Digital Art'),
            ],
          ),
          NestedItem(
            value: 'Literature',
            label: 'Literature',
            children: [
              NestedItem(value: 'Fiction', label: 'Fiction'),
              NestedItem(value: 'Poetry', label: 'Poetry'),
              NestedItem(value: 'Drama', label: 'Drama'),
              NestedItem(value: 'Non-fiction', label: 'Non-fiction'),
            ],
          ),
        ],
      ),
      NestedItem(
        value: 'Sports',
        label: 'Sports',
        icon: Icons.sports_soccer,
        children: [
          NestedItem(
            value: 'Team Sports',
            label: 'Team Sports',
            children: [
              NestedItem(value: 'Football', label: 'Football'),
              NestedItem(value: 'Basketball', label: 'Basketball'),
              NestedItem(value: 'Soccer', label: 'Soccer'),
              NestedItem(value: 'Baseball', label: 'Baseball'),
            ],
          ),
          NestedItem(
            value: 'Individual Sports',
            label: 'Individual Sports',
            children: [
              NestedItem(value: 'Tennis', label: 'Tennis'),
              NestedItem(value: 'Golf', label: 'Golf'),
              NestedItem(value: 'Swimming', label: 'Swimming'),
              NestedItem(value: 'Track & Field', label: 'Track & Field'),
            ],
          ),
        ],
      ),
    ];
  }

  Future<Iterable<NestedItem<String>>> getSuggestions(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return nestedData;
    }

    // Filter the nested data based on the query
    return _filterNestedData(nestedData, query);
  }

  List<NestedItem<String>> _filterNestedData(
      List<NestedItem<String>> items, String query) {
    final List<NestedItem<String>> filtered = [];

    for (final item in items) {
      final itemMatches = _itemMatches(item, query);
      final List<NestedItem<String>> matchingChildren = [];

      if (item.hasChildren) {
        matchingChildren.addAll(_filterNestedData(item.children!, query));
      }

      if (itemMatches || matchingChildren.isNotEmpty) {
        filtered.add(item.copyWith(
          children: matchingChildren.isEmpty ? null : matchingChildren,
          isExpanded: query.isNotEmpty, // Auto-expand when searching
        ));
      }
    }

    return filtered;
  }

  bool _itemMatches(NestedItem<String> item, String query) {
    final searchText = query.toLowerCase();
    final itemLabel = (item.label ?? item.value).toLowerCase();
    return itemLabel.contains(searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nested Dropdown Example'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select your interests:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Single Selection Example
              const Text('Single Selection:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              NestedDropDownSearchField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Search categories...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  controller: _dropdownSearchFieldController,
                ),
                nestedSuggestionsCallback: getSuggestions,
                nestedItemBuilder: (context, item, depth) {
                  return ListTile(
                    leading: item.icon != null
                        ? Icon(item.icon as IconData)
                        : (depth > 0
                            ? const Icon(Icons.subdirectory_arrow_right)
                            : null),
                    title: Text(
                      item.label ?? item.value,
                      style: TextStyle(
                        fontWeight: item.hasChildren
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: item.hasChildren
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                    subtitle: item.hasChildren
                        ? Text('${item.children!.length} items')
                        : null,
                    dense: depth > 0,
                  );
                },
                onNestedSuggestionSelected: (item) {
                  _dropdownSearchFieldController.text =
                      item.label ?? item.value;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Selected: ${item.label ?? item.value}')),
                  );
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  elevation: 8,
                ),
                nestedDropdownConfiguration: const NestedDropdownConfiguration(
                  childIndentation: 16.0,
                  allowParentSelection: false,
                  autoExpandOnSearch: true,
                  showOnlyMatchingBranches: true,
                  initiallyExpanded: true, // Expand all items on open
                ),
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),

              const SizedBox(height: 32),

              // Multi Selection Example
              const Text('Multi Selection:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              NestedDropDownSearchField<String>(
                textFieldConfiguration: const TextFieldConfiguration(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select multiple items...',
                    prefixIcon: Icon(Icons.checklist),
                  ),
                ),
                nestedSuggestionsCallback: getSuggestions,
                nestedItemBuilder: (context, item, depth) {
                  return ListTile(
                    leading: item.icon != null
                        ? Icon(item.icon as IconData, size: 20)
                        : (depth > 0
                            ? const Icon(Icons.circle, size: 8)
                            : null),
                    title: Text(
                      item.label ?? item.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.hasChildren
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  );
                },
                chipBuilder: (context, item) {
                  return Chip(
                    label: Text(
                      item.label ?? item.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      _selectedItems.remove(item);
                      setState(() {});
                    },
                    backgroundColor: Colors.blue.shade100,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                },
                onNestedSuggestionMultiSelected: (item, selected) {
                  if (selected) {
                    if (!_selectedItems.any((i) => i.value == item.value)) {
                      _selectedItems.add(item);
                    }
                    // Selecting children if it's parent is selected
                    if (item.hasChildren) {
                      for (final child in item.selectableDescendants) {
                        if (!_selectedItems
                            .any((i) => i.value == child.value)) {
                          _selectedItems.add(child);
                        }
                      }
                    }
                  } else {
                    _selectedItems.removeWhere((i) => i.value == item.value);
                    if (item.hasChildren) {
                      for (final child in item.selectableDescendants) {
                        _selectedItems
                            .removeWhere((i) => i.value == child.value);
                      }
                    }
                  }
                  setState(() {});
                },
                initiallySelectedItems: _selectedItems,
                nestedEqualityFunction: (item1, item2) =>
                    item1.value == item2.value,
                nestedDropdownConfiguration: const NestedDropdownConfiguration(
                  childIndentation:
                      12.0, // Smaller indentation to prevent layout issues
                  allowParentSelection: true,
                  autoExpandOnSearch: true,
                  showExpandIcons: true,
                  expandIcon: Icons.expand_more,
                  collapseIcon: Icons.expand_less,
                  initiallyExpanded: true,
                ),
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: true,
                multiSelectDropdownBoxConfiguration: DropdownBoxConfiguration(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Selected: ${_selectedItems.length} items',
                  ),
                ),
              ),

              const SizedBox(height: 100),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Single: ${_dropdownSearchFieldController.text}\n'
                          'Multi: ${_selectedItems.map((e) => e.label ?? e.value).join(', ')}',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Submit Selections'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
