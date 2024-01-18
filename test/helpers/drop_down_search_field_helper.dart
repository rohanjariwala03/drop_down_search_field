import 'package:drop_down_search_field/src/suggestions/suggestions_box_decoration.dart';
import 'package:drop_down_search_field/src/widgets/drop_down_search_form_field.dart';
import 'package:drop_down_search_field/src/widgets/search_field_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class to get the material DropDownSearchField test page
class MaterialDropDownSearchFieldHelper {
  static Widget getMaterialDropDownSearchFieldPage() {
    return const MaterialApp(
      home: MaterialDropDownSearchFieldPage(),
    );
  }
}

/// The widget that will be returned for the material DropDownSearchField test page
class MaterialDropDownSearchFieldPage extends StatefulWidget {
  final String? title;

  const MaterialDropDownSearchFieldPage({super.key, this.title});

  @override
  State<MaterialDropDownSearchFieldPage> createState() =>
      _MaterialDropDownSearchFieldPageState();
}

class _MaterialDropDownSearchFieldPageState
    extends State<MaterialDropDownSearchFieldPage> {
  final List<TextEditingController> _controllers = [];

  /// Items that will be used to search
  final List<String> foodItems = [
    "Bread",
    "Burger",
    "Cheese",
    "Milk",
    "Milkshake",
    "Orange"
  ];

  /// This is to trigger a loading builder when searching for items
  Future<List<String>> _getFoodItems(String pattern) async {
    pattern = pattern.trim();
    if (pattern.isNotEmpty) {
      return Future.delayed(
          const Duration(seconds: 2),
          () => foodItems
              .where(
                  (item) => item.toLowerCase().contains(pattern.toLowerCase()))
              .toList());
    } else {
      return Future.delayed(const Duration(seconds: 2), () => []);
    }
  }

  /// Widget that will be displayed when no results were found
  Widget _getNoResultText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Text("No results found!"),
    );
  }

  /// Widget that returns the DropDownSearchFormField
  Widget _getDropDownSearchField() {
    final controller = TextEditingController();
    _controllers.add(controller);

    return DropDownSearchFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        inputFormatters: [LengthLimitingTextInputFormatter(50)],
        controller: controller,
        decoration: InputDecoration(
            labelText: "Please provide a search term",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            )),
      ),
      autoFlipDirection: true,
      loadingBuilder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 150,
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      suggestionsCallback: _getFoodItems,
      noItemsFoundBuilder: _getNoResultText,
      itemBuilder: (context, String suggestion) {
        return ListTile(
          tileColor: Colors.white,
          title: Text(suggestion),
        );
      },
      suggestionsBoxDecoration: const SuggestionsBoxDecoration(
        elevation: 2,
        hasScrollbar: true,
      ),
      getImmediateSuggestions: false,
      onSuggestionSelected: (String suggestion) => controller.text = suggestion,
      minCharsForSuggestions: 1,
    );
  }

  @override
  void dispose() {
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Material DropDownSearchField test'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (context, index) => const SizedBox(height: 100),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _getDropDownSearchField(),
            itemCount: 6,
          ),
        ),
      ),
    );
  }
}
