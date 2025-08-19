import 'dart:async';
import 'package:drop_down_search_field/src/keyboard_suggestion_selection_notifier.dart';
import 'package:drop_down_search_field/src/should_refresh_suggestion_focus_index_notifier.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_controller.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_decoration.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_list.dart';
import 'package:drop_down_search_field/src/type_def.dart';
import 'package:drop_down_search_field/src/multi_selection_widgets/multi_select_drop_down_box_configuration.dart';
import 'package:drop_down_search_field/src/multi_selection_widgets/multi_select_dropdown_display_widget.dart';
import 'package:drop_down_search_field/src/widgets/search_field_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// # Flutter DropDownSearchField
/// A DropDownSearchField widget for Flutter, where you can show suggestions to
/// users as they type
///
/// ## Features
/// * Shows suggestions in an overlay that floats on top of other widgets
/// * Allows you to specify what the suggestions will look like through a
/// builder function
/// * Allows you to specify what happens when the user taps a suggestion
/// * Accepts all the parameters that traditional TextFields accept, like
/// decoration, custom TextEditingController, text styling, etc.
/// * Provides two versions, a normal version and a [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
/// version that accepts validation, submitting, etc.
/// * Provides high customizable; you can customize the suggestion box decoration,
/// the loading bar, the animation, the debounce duration, etc.
///
/// ## Installation
/// See the [installation instructions on pub](https://pub.dartlang.org/packages/drop_down_search_field#-installing-tab-).
///
/// ## Usage examples
/// You can import the package with:
/// ```dart
/// import 'package:drop_down_search_field/drop_down_search_field.dart';
/// ```
///
/// and then use it as follows:
///
/// ### Example 1:
/// ```dart
/// DropDownSearchField(
///   textFieldConfiguration: TextFieldConfiguration(
///     autofocus: true,
///     style: DefaultTextStyle.of(context).style.copyWith(
///       fontStyle: FontStyle.italic
///     ),
///     decoration: InputDecoration(
///       border: OutlineInputBorder()
///     )
///   ),
///   suggestionsCallback: (pattern) async {
///     return await BackendService.getSuggestions(pattern);
///   },
///   itemBuilder: (context, suggestion) {
///     return ListTile(
///       leading: Icon(Icons.shopping_cart),
///       title: Text(suggestion['name']),
///       subtitle: Text('\$${suggestion['price']}'),
///     );
///   },
///   onSuggestionSelected: (suggestion) {
///     Navigator.of(context).push(MaterialPageRoute(
///       builder: (context) => ProductPage(product: suggestion)
///     ));
///   },
/// )
/// ```
/// In the code above, the `textFieldConfiguration` property allows us to
/// configure the displayed `TextField` as we want. In this example, we are
/// configuring the `autofocus`, `style` and `decoration` properties.
///
/// The `suggestionsCallback` is called with the search string that the user
/// types, and is expected to return a `List` of data either synchronously or
/// asynchronously. In this example, we are calling an asynchronous function
/// called `BackendService.getSuggestions` which fetches the list of
/// suggestions.
///
/// The `itemBuilder` is called to build a widget for each suggestion.
/// In this example, we build a simple `ListTile` that shows the name and the
/// price of the item. Please note that you shouldn't provide an `onTap`
/// callback here. The DropDownSearchField widget takes care of that.
///
/// The `onSuggestionSelected` is a callback called when the user taps a
/// suggestion. In this example, when the user taps a
/// suggestion, we navigate to a page that shows us the information of the
/// tapped product.
///
/// ### Example 2:
/// Here's another example, where we use the DropDownSearchFormField inside a `Form`:
/// ```dart
/// final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
/// final TextEditingController _dropDownSearchFieldController = TextEditingController();
/// String _selectedCity;
/// ...
/// Form(
///   key: this._formKey,
///   child: Padding(
///     padding: EdgeInsets.all(32.0),
///     child: Column(
///       children: <Widget>[
///         Text(
///           'What is your favorite city?'
///         ),
///         DropDownSearchFormField(
///           textFieldConfiguration: TextFieldConfiguration(
///             controller: _dropDownSearchFieldController,
///             decoration: InputDecoration(
///               labelText: 'City'
///             )
///           ),
///           suggestionsCallback: (pattern) {
///             return CitiesService.getSuggestions(pattern);
///           },
///           itemBuilder: (context, suggestion) {
///             return ListTile(
///               title: Text(suggestion),
///             );
///           },
///           transitionBuilder: (context, suggestionsBox, controller) {
///             return suggestionsBox;
///           },
///           onSuggestionSelected: (suggestion) {
///             _dropDownSearchFieldController.text = suggestion;
///           },
///           validator: (value) {
///             if (value.isEmpty) {
///               return 'Please select a city';
///             }
///           },
///           onSaved: (value) => this._selectedCity = value,
///         ),
///         SizedBox(height: 10.0,),
///         RaisedButton(
///           child: Text('Submit'),
///           onPressed: () {
///             if (this._formKey.currentState.validate()) {
///               this._formKey.currentState.save();
///               Scaffold.of(context).showSnackBar(SnackBar(
///                 content: Text('Your Favorite City is ${this._selectedCity}')
///               ));
///             }
///           },
///         )
///       ],
///     ),
///   ),
/// )
/// ```
/// Here, we assign to the `controller` property of the `textFieldConfiguration`
/// a `TextEditingController` that we call `_dropDownSearchFieldController`.
/// We use this controller in the `onSuggestionSelected` callback to set the
/// value of the `TextField` to the selected suggestion.
///
/// The `validator` callback can be used like any `FormField.validator`
/// function. In our example, it checks whether a value has been entered,
/// and displays an error message if not. The `onSaved` callback is used to
/// save the value of the field to the `_selectedCity` member variable.
///
/// The `transitionBuilder` allows us to customize the animation of the
/// suggestion box. In this example, we are returning the suggestionsBox
/// immediately, meaning that we don't want any animation.
///
/// ## Customizations
/// DropDownSearchField widgets consist of a TextField and a suggestion box that shows
/// as the user types. Both are highly customizable
///
/// ### Customizing the TextField
/// You can customize the text field using the `textFieldConfiguration` property.
/// You provide this property with an instance of `TextFieldConfiguration`,
/// which allows you to configure all the usual properties of `TextField`, like
/// `decoration`, `style`, `controller`, `focusNode`, `autofocus`, `enabled`,
/// etc.
///
/// ### Customizing the Suggestions Box
/// DropDownSearchField provides default configurations for the suggestions box. You can,
/// however, override most of them.
///
/// #### Customizing the loader, the error and the "no items found" message
/// You can use the [loadingBuilder], [errorBuilder] and [noItemsFoundBuilder] to
/// customize their corresponding widgets. For example, to show a custom error
/// widget:
/// ```dart
/// errorBuilder: (BuildContext context, Object error) =>
///   Text(
///     '$error',
///     style: TextStyle(
///       color: Theme.of(context).errorColor
///     )
///   )
/// ```
/// #### Customizing the animation
/// You can customize the suggestion box animation through 3 parameters: the
/// `animationDuration`, the `animationStart`, and the `transitionBuilder`.
///
/// The `animationDuration` specifies how long the animation should take, while the
/// `animationStart` specified what point (between 0.0 and 1.0) the animation
/// should start from. The `transitionBuilder` accepts the `suggestionsBox` and
/// `animationController` as parameters, and should return a widget that uses
/// the `animationController` to animate the display of the `suggestionsBox`.
/// For example:
/// ```dart
/// transitionBuilder: (context, suggestionsBox, animationController) =>
///   FadeTransition(
///     child: suggestionsBox,
///     opacity: CurvedAnimation(
///       parent: animationController,
///       curve: Curves.fastOutSlowIn
///     ),
///   )
/// ```
/// This uses [FadeTransition](https://docs.flutter.io/flutter/widgets/FadeTransition-class.html)
/// to fade the `suggestionsBox` into the view. Note how the
/// `animationController` was provided as the parent of the animation.
///
/// In order to fully remove the animation, `transitionBuilder` should simply
/// return the `suggestionsBox`. This callback could also be used to wrap the
/// `suggestionsBox` with any desired widgets, not necessarily for animation.
///
/// #### Customizing the debounce duration
/// The suggestions box does not fire for each character the user types. Instead,
/// we wait until the user is idle for a duration of time, and then call the
/// `suggestionsCallback`. The duration defaults to 300 milliseconds, but can be
/// configured using the `debounceDuration` parameter.
///
/// #### Customizing the offset of the suggestions box
/// By default, the suggestions box is displayed 5 pixels below the `TextField`.
/// You can change this by changing the `suggestionsBoxVerticalOffset` property.
///
/// #### Customizing the decoration of the suggestions box
/// You can also customize the decoration of the suggestions box using the
/// `suggestionsBoxDecoration` property. For example, to remove the elevation
/// of the suggestions box, you can write:
/// ```dart
/// suggestionsBoxDecoration: SuggestionsBoxDecoration(
///   elevation: 0.0
/// )
/// ```
/// A [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
/// implementation of [DropDownSearchField], that allows the value to be saved,
/// validated, etc.
///
/// See also:
///
/// * [DropDownSearchField], A [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
/// that displays a list of suggestions as the user types
class DropDownSearchField<T> extends StatefulWidget {
  /// Called with the search pattern to get the search suggestions.
  ///
  /// If paginatedSuggestionCallback is null then this callback must not be null. It is be called by the
  /// DropDownSearchField widget and provided with the search pattern. It should return a [List](https://api.dartlang.org/stable/2.0.0/dart-core/List-class.html)
  /// of suggestions either synchronously, or asynchronously (as the result of a
  /// [Future](https://api.dartlang.org/stable/dart-async/Future-class.html)).
  /// Typically, the list of suggestions should not contain more than 4 or 5
  /// entries. These entries will then be provided to [itemBuilder] to display
  /// the suggestions.
  ///
  /// Example:
  /// ```dart
  /// suggestionsCallback: (pattern) async {
  ///   return await _getSuggestions(pattern);
  /// }
  /// ```
  final SuggestionsCallback<T>? suggestionsCallback;

  /// Called with the search pattern to get the search suggestions.
  ///
  /// If suggestionCallback is null then this callback must not be null. It is be called by the DropDownSearchField
  /// widget and provided with the search pattern. It should return a [List](https://api.dartlang.org/stable/2.0.0/dart-core/List-class.html)
  /// of suggestions either synchronously, or asynchronously (as the result of a
  /// [Future](https://api.dartlang.org/stable/dart-async/Future-class.html)).
  /// Typically, the list of suggestions should not contain more than 4 or 5
  /// entries. These entries will then be provided to [itemBuilder] to display
  /// the suggestions.
  ///
  /// Example:
  /// ```dart
  /// paginatedSuggestionsCallback: (pattern, page) async {
  ///   return await _getSuggestions(pattern, page);
  /// }
  /// ```
  final SuggestionsCallback<T>? paginatedSuggestionsCallback;

  /// Called when a suggestion is tapped.
  ///
  /// This callback must not be null. It is called by the DropDownSearchField widget and
  /// provided with the value of the tapped suggestion.
  ///
  /// For example, you might want to navigate to a specific view when the user
  /// tabs a suggestion:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   Navigator.of(context).push(MaterialPageRoute(
  ///     builder: (context) => SearchResult(
  ///       searchItem: suggestion
  ///     )
  ///   ));
  /// }
  /// ```
  ///
  /// Or to set the value of the text field:
  /// ```dart
  /// onSuggestionSelected: (suggestion) {
  ///   _controller.text = suggestion['name'];
  /// }
  /// ```
  final SuggestionSelectionCallback<T>? onSuggestionSelected;

  /// Called when multiple suggestions are selected.
  ///
  /// This callback must not be null. It is called by the DropDownSearchField widget and
  /// provided with the list of values of the selected suggestions.
  ///
  /// For example, you might want to navigate to a specific view when the user
  /// selects multiple suggestions:
  /// ```dart
  /// onSuggestionMultiSelected: (suggestions) {
  ///   Navigator.of(context).push(MaterialPageRoute(
  ///     builder: (context) => SearchResults(
  ///       searchItems: suggestions
  ///     )
  ///   ));
  /// }
  /// ```
  ///
  /// Or to set the value of the text field:
  /// ```dart
  /// onSuggestionMultiSelected: (suggestions) {
  ///   _controller.text = suggestions.map((s) => s['name']).join(', ');
  /// }
  /// ```
  final SuggestionMultiSelectionCallback<T>? onSuggestionMultiSelected;

  /// Called for each suggestion returned by [suggestionsCallback] to build the
  /// corresponding widget.
  ///
  /// This callback must not be null. It is called by the DropDownSearchField widget for
  /// each suggestion, and expected to build a widget to display this
  /// suggestion's info. For example:
  ///
  /// ```dart
  /// itemBuilder: (context, suggestion) {
  ///   return ListTile(
  ///     title: Text(suggestion['name']),
  ///     subtitle: Text('USD' + suggestion['price'].toString())
  ///   );
  /// }
  /// ```
  final ItemBuilder<T> itemBuilder;

  /// Called for each suggestion to determine if it should be disabled.
  ///
  /// This callback is optional. If provided, it is called for each suggestion
  /// and expected to return a boolean indicating whether the suggestion should
  /// be disabled. Disabled suggestions cannot be selected and don't respond to
  /// hover or keyboard navigation.
  ///
  /// Example:
  /// ```dart
  /// itemDisabledCallback: (suggestion) {
  ///   return suggestion.isDisabled; // Assuming your suggestion object has an isDisabled property
  /// }
  /// ```
  final ItemDisabledCallback<T>? itemDisabledCallback;

  final IndexedWidgetBuilder? itemSeparatorBuilder;

  /// By default, we render the suggestions in a ListView, using
  /// the `itemBuilder` to construct each element of the list.  Specify
  /// your own `layoutArchitecture` if you want to be responsible
  /// for laying out the widgets using some other system (like a grid).
  final LayoutArchitecture? layoutArchitecture;

  /// used to control the scroll behavior of item-builder list
  final ScrollController? scrollController;

  /// The decoration of the material sheet that contains the suggestions.
  ///
  /// If null, default decoration with an elevation of 4.0 is used
  ///

  final SuggestionsBoxDecoration suggestionsBoxDecoration;

  /// Used to control the `_SuggestionsBox`. Allows manual control to
  /// open, close, toggle, or resize the `_SuggestionsBox`.
  final SuggestionsBoxController? suggestionsBoxController;

  /// The duration to wait after the user stops typing before calling
  /// [suggestionsCallback]
  ///
  /// This is useful, because, if not set, a request for suggestions will be
  /// sent for every character that the user types.
  ///
  /// This duration is set by default to 300 milliseconds
  final Duration debounceDuration;

  /// Called when waiting for [suggestionsCallback] to return.
  ///
  /// It is expected to return a widget to display while waiting.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('Loading...');
  /// }
  /// ```
  ///
  /// If not specified, a [CircularProgressIndicator](https://docs.flutter.io/flutter/material/CircularProgressIndicator-class.html) is shown
  final WidgetBuilder? loadingBuilder;

  /// Called when [suggestionsCallback] returns an empty array.
  ///
  /// It is expected to return a widget to display when no suggestions are
  /// available.
  /// For example:
  /// ```dart
  /// (BuildContext context) {
  ///   return Text('No Items Found!');
  /// }
  /// ```
  ///
  /// If not specified, a simple text is shown
  final WidgetBuilder? noItemsFoundBuilder;

  /// Called when [suggestionsCallback] throws an exception.
  ///
  /// It is called with the error object, and expected to return a widget to
  /// display when an exception is thrown
  /// For example:
  /// ```dart
  /// (BuildContext context, error) {
  ///   return Text('$error');
  /// }
  /// ```
  ///
  /// If not specified, the error is shown in [ThemeData.errorColor](https://docs.flutter.io/flutter/material/ThemeData/errorColor.html)
  final ErrorBuilder? errorBuilder;

  /// Used to overcome [Flutter issue 98507](https://github.com/flutter/flutter/issues/98507)
  /// Most commonly experienced when placing the [DropDownSearchFormField] on a google map in Flutter Web.
  final bool intercepting;

  /// Called to display animations when [suggestionsCallback] returns suggestions
  ///
  /// It is provided with the suggestions box instance and the animation
  /// controller, and expected to return some animation that uses the controller
  /// to display the suggestion box.
  ///
  /// For example:
  /// ```dart
  /// transitionBuilder: (context, suggestionsBox, animationController) {
  ///   return FadeTransition(
  ///     child: suggestionsBox,
  ///     opacity: CurvedAnimation(
  ///       parent: animationController,
  ///       curve: Curves.fastOutSlowIn
  ///     ),
  ///   );
  /// }
  /// ```
  /// This argument is best used with [animationDuration] and [animationStart]
  /// to fully control the animation.
  ///
  /// To fully remove the animation, just return `suggestionsBox`
  ///
  /// If not specified, a [SizeTransition](https://docs.flutter.io/flutter/widgets/SizeTransition-class.html) is shown.
  final AnimationTransitionBuilder? transitionBuilder;

  /// The duration that [transitionBuilder] animation takes.
  ///
  /// This argument is best used with [transitionBuilder] and [animationStart]
  /// to fully control the animation.
  ///
  /// Defaults to 500 milliseconds.
  final Duration animationDuration;

  /// Determine the [SuggestionBox]'s direction.
  ///
  /// If [AxisDirection.down], the [SuggestionBox] will be below the [TextField]
  /// and the [_SuggestionsList] will grow **down**.
  ///
  /// If [AxisDirection.up], the [SuggestionBox] will be above the [TextField]
  /// and the [_SuggestionsList] will grow **up**.
  ///
  /// [AxisDirection.left] and [AxisDirection.right] are not allowed.
  final AxisDirection direction;

  /// The value at which the [transitionBuilder] animation starts.
  ///
  /// This argument is best used with [transitionBuilder] and [animationDuration]
  /// to fully control the animation.
  ///
  /// Defaults to 0.25.
  final double animationStart;

  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the DropDownSearchField widget displays
  final TextFieldConfiguration textFieldConfiguration;

  /// How far below the text field should the suggestions box be
  ///
  /// Defaults to 5.0
  final double suggestionsBoxVerticalOffset;

  /// If set to true, suggestions will be fetched immediately when the field is
  /// added to the view.
  ///
  /// But the suggestions box will only be shown when the field receives focus.
  /// To make the field receive focus immediately, you can set the `autofocus`
  /// property in the [textFieldConfiguration] to true
  ///
  /// Defaults to false
  final bool getImmediateSuggestions;

  /// If set to true, no loading box will be shown while suggestions are
  /// being fetched. [loadingBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnLoading;

  /// If set to true, nothing will be shown if there are no results.
  /// [noItemsFoundBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnEmpty;

  /// If set to true, nothing will be shown if there is an error.
  /// [errorBuilder] will also be ignored.
  ///
  /// Defaults to false.
  final bool hideOnError;

  /// If set to false, the suggestions box will stay opened after
  /// the keyboard is closed.
  ///
  /// Defaults to true.
  final bool hideSuggestionsOnKeyboardHide;

  /// If set to false, the suggestions box will show a circular
  /// progress indicator when retrieving suggestions.
  ///
  /// Defaults to true.
  final bool keepSuggestionsOnLoading;

  /// If set to true, the suggestions box will remain opened even after
  /// selecting a suggestion.
  ///
  /// Note that if this is enabled, the only way
  /// to close the suggestions box is either manually via the
  /// `SuggestionsBoxController` or when the user closes the software
  /// keyboard if `hideSuggestionsOnKeyboardHide` is set to true. Users
  /// with a physical keyboard will be unable to close the
  /// box without a manual way via `SuggestionsBoxController`.
  ///
  /// Defaults to false.
  final bool keepSuggestionsOnSuggestionSelected;

  /// If set to true, in the case where the suggestions box has less than
  /// _SuggestionsBoxController.minOverlaySpace to grow in the desired [direction], the direction axis
  /// will be temporarily flipped if there's more room available in the opposite
  /// direction.
  ///
  /// Defaults to false
  final bool autoFlipDirection;

  /// If set to false, suggestion list will not be reversed according to the
  /// [autoFlipDirection] property.
  ///
  /// Defaults to true.
  final bool autoFlipListDirection;

  /// Minimum height below [autoFlipDirection] is triggered
  ///
  /// Defaults to 64.0.
  final double autoFlipMinHeight;

  final bool hideKeyboard;

  /// The minimum number of characters which must be entered before
  /// [suggestionsCallback] is triggered.
  ///
  /// Defaults to 0.
  final int minCharsForSuggestions;

  /// If set to true and if the user scrolls through the suggestion list, hide the keyboard automatically.
  /// If set to false, the keyboard remains visible.
  /// Throws an exception, if hideKeyboardOnDrag and hideSuggestionsOnKeyboardHide are both set to true as
  /// they are mutual exclusive.
  ///
  /// Defaults to false
  final bool hideKeyboardOnDrag;

  // Adds a callback for the suggestion box opening or closing
  final void Function(bool)? onSuggestionsBoxToggle;

  // If set to true, sending text as empty.
  // If set to false, sending text as whatever you have wrote
  // Default is false
  final bool displayAllSuggestionWhenTap;

  // If set to true, the dropdown will be a multi-select dropdown
  // If set to false, the dropdown will be a single-select dropdown
  final bool isMultiSelectDropdown;

  // The selected items in the dropdown when it is a multi-select dropdown
  final List<T>? initiallySelectedItems;

  // The configuration of the dropdown box when it is a multi-select dropdown
  final DropdownBoxConfiguration? multiSelectDropdownBoxConfiguration;

  /// Validator for the [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
  final FormFieldValidator<List<T>>? validator;

  /// The builder for the chips that are displayed in the dropdown
  ///
  /// This property allows you to customize the appearance and behavior of the chips
  final ChipBuilder<T>? chipBuilder;

  /// A custom equality function to compare two items of type T.
  ///
  /// This function is used to determine if two items are considered equal.
  /// It can be useful in scenarios like multi-select dropdowns where you need
  /// to check if an item is already selected.
  ///
  /// If not provided, the default equality comparison will be used.
  final bool Function(T item1, T item2)? multiSelectEquality;

  /// Creates a [DropDownSearchField]
  const DropDownSearchField({
    this.suggestionsCallback,
    this.paginatedSuggestionsCallback,
    required this.itemBuilder,
    this.itemDisabledCallback,
    this.itemSeparatorBuilder,
    this.layoutArchitecture,
    this.intercepting = false,
    this.onSuggestionSelected,
    this.onSuggestionMultiSelected,
    this.textFieldConfiguration = const TextFieldConfiguration(),
    this.suggestionsBoxDecoration = const SuggestionsBoxDecoration(),
    this.debounceDuration = const Duration(milliseconds: 300),
    this.suggestionsBoxController,
    this.scrollController,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationStart = 0.25,
    this.animationDuration = const Duration(milliseconds: 500),
    this.getImmediateSuggestions = false,
    this.suggestionsBoxVerticalOffset = 5.0,
    this.direction = AxisDirection.down,
    this.hideOnLoading = false,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideSuggestionsOnKeyboardHide = true,
    this.keepSuggestionsOnLoading = true,
    this.keepSuggestionsOnSuggestionSelected = false,
    this.autoFlipDirection = false,
    this.autoFlipListDirection = true,
    this.autoFlipMinHeight = 64.0,
    this.hideKeyboard = false,
    this.minCharsForSuggestions = 0,
    this.onSuggestionsBoxToggle,
    this.hideKeyboardOnDrag = false,
    required this.displayAllSuggestionWhenTap,
    required this.isMultiSelectDropdown,
    this.initiallySelectedItems,
    this.multiSelectDropdownBoxConfiguration,
    this.validator,
    this.chipBuilder,
    this.multiSelectEquality,
    super.key,
  })  : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(
            direction == AxisDirection.down || direction == AxisDirection.up),
        assert(minCharsForSuggestions >= 0),
        assert(!hideKeyboardOnDrag ||
            hideKeyboardOnDrag && !hideSuggestionsOnKeyboardHide),
        assert(
          (suggestionsCallback != null ||
                  paginatedSuggestionsCallback != null) &&
              !(suggestionsCallback != null &&
                  paginatedSuggestionsCallback != null),
          'Either suggestionsCallback or paginatedSuggestionsCallback must be provided, but not both.',
        ),
        assert(
          !(onSuggestionSelected != null && onSuggestionMultiSelected != null),
          'Only one of onSuggestionSelected or onSuggestionMultiSelected must be provided.',
        ),
        assert(
          !isMultiSelectDropdown ||
              (onSuggestionMultiSelected != null &&
                  initiallySelectedItems != null),
          'onSuggestionMultiSelected and initiallySelectedItems must be provided when isMultiSelectDropdown is true.',
        ),
        assert(
            isMultiSelectDropdown ||
                multiSelectDropdownBoxConfiguration == null,
            'Cannot provide multiSelectDropdownBoxConfiguration when isMultiSelectDropdown is false.');

  @override
  // ignore: library_private_types_in_public_api
  _DropDownSearchFieldState<T> createState() => _DropDownSearchFieldState<T>();
}

class _DropDownSearchFieldState<T> extends State<DropDownSearchField<T>>
    with WidgetsBindingObserver {
  FocusNode? _focusNode;
  final KeyboardSuggestionSelectionNotifier
      _keyboardSuggestionSelectionNotifier =
      KeyboardSuggestionSelectionNotifier();
  TextEditingController? _textEditingController;
  SuggestionsBox? _suggestionsBox;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _textEditingController;
  FocusNode? get _effectiveFocusNode =>
      widget.textFieldConfiguration.focusNode ?? _focusNode;
  late VoidCallback _focusNodeListener;

  final LayerLink _layerLink = LayerLink();

  // Timer that resizes the suggestion box on each tick. Only active when the user is scrolling.
  Timer? _resizeOnScrollTimer;
  // The rate at which the suggestion box will resize when the user is scrolling
  final Duration _resizeOnScrollRefreshRate = const Duration(milliseconds: 500);
  // Will have a value if the dropdown_search_field is inside a scrollable widget
  ScrollPosition? _scrollPosition;

  // Keyboard detection
  // final Stream<bool>? _keyboardVisibility = (supportedPlatform) ? KeyboardVisibilityController().onChange : null;
  final Stream<bool>? _keyboardVisibility = null;
  late StreamSubscription<bool>? _keyboardVisibilitySubscription;

  bool _areSuggestionsFocused = false;
  late final _shouldRefreshSuggestionsFocusIndex =
      ShouldRefreshSuggestionFocusIndexNotifier(
          textFieldFocusNode: _effectiveFocusNode);

  @override
  void didChangeMetrics() {
    // Catch keyboard event and orientation change; resize suggestions list
    _suggestionsBox!.onChangeMetrics();
  }

  @override
  void dispose() {
    _suggestionsBox!.close();
    _suggestionsBox!.widgetMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    _keyboardVisibilitySubscription?.cancel();
    _effectiveFocusNode!.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _resizeOnScrollTimer?.cancel();
    _scrollPosition?.removeListener(_scrollResizeListener);
    _textEditingController?.dispose();
    _keyboardSuggestionSelectionNotifier.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event) {
    // HardwareKeyboard.instance.isLogicalKeyPressed

    if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // do nothing to avoid puzzling users until keyboard arrow nav is implemented
    } else {
      _keyboardSuggestionSelectionNotifier.onKeyboardEvent(event);
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.textFieldConfiguration.controller == null) {
      _textEditingController = TextEditingController();
    }

    final textFieldConfigurationFocusNode =
        widget.textFieldConfiguration.focusNode;
    if (textFieldConfigurationFocusNode == null) {
      _focusNode = FocusNode(onKeyEvent: _onKeyEvent);
    } else if (textFieldConfigurationFocusNode.onKeyEvent == null) {
      // * we add the _onKeyEvent callback to the textFieldConfiguration focusNode
      textFieldConfigurationFocusNode.onKeyEvent = ((node, event) {
        final keyEventResult = _onKeyEvent(node, event);
        return keyEventResult;
      });
    } else {
      final onKeyCopy = textFieldConfigurationFocusNode.onKeyEvent!;
      textFieldConfigurationFocusNode.onKeyEvent = ((node, event) {
        _onKeyEvent(node, event);
        return onKeyCopy(node, event);
      });
    }

    _suggestionsBox = SuggestionsBox(
      context,
      widget.direction,
      widget.autoFlipDirection,
      widget.autoFlipListDirection,
      widget.autoFlipMinHeight,
    );

    widget.suggestionsBoxController?.suggestionsBox = _suggestionsBox;
    widget.suggestionsBoxController?.effectiveFocusNode = _effectiveFocusNode;

    _focusNodeListener = () {
      if (_effectiveFocusNode!.hasFocus) {
        _suggestionsBox!.open();
      } else if (!_areSuggestionsFocused) {
        if (widget.hideSuggestionsOnKeyboardHide) {
          _suggestionsBox!.close();
        }
      }

      widget.onSuggestionsBoxToggle?.call(_suggestionsBox!.isOpened);
    };

    _effectiveFocusNode!.addListener(_focusNodeListener);

    // hide suggestions box on keyboard closed
    _keyboardVisibilitySubscription =
        _keyboardVisibility?.listen((bool isVisible) {
      if (widget.hideSuggestionsOnKeyboardHide && !isVisible) {
        _effectiveFocusNode!.unfocus();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      if (mounted) {
        _initOverlayEntry();
        // calculate initial suggestions list size
        _suggestionsBox!.resize();

        // in case we already missed the focus event
        if (_effectiveFocusNode!.hasFocus) {
          _suggestionsBox!.open();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollableState = Scrollable.maybeOf(context);
    if (scrollableState != null) {
      // The DropDownSearchField is inside a scrollable widget
      _scrollPosition = scrollableState.position;

      _scrollPosition!.removeListener(_scrollResizeListener);
      _scrollPosition!.isScrollingNotifier.addListener(_scrollResizeListener);
    }
  }

  void _scrollResizeListener() {
    bool isScrolling = _scrollPosition!.isScrollingNotifier.value;
    _resizeOnScrollTimer?.cancel();
    if (isScrolling) {
      // Scroll started
      _resizeOnScrollTimer =
          Timer.periodic(_resizeOnScrollRefreshRate, (timer) {
        _suggestionsBox!.resize();
      });
    } else {
      // Scroll finished
      _suggestionsBox!.resize();
    }
  }

  void _initOverlayEntry() {
    _suggestionsBox!.overlayEntry = OverlayEntry(builder: (context) {
      void giveTextFieldFocus() {
        _effectiveFocusNode?.requestFocus();
        _areSuggestionsFocused = false;
      }

      void onSuggestionFocus() {
        if (!_areSuggestionsFocused) {
          _areSuggestionsFocused = true;
        }
      }

      final suggestionsList = SuggestionsList<T>(
        suggestionsBox: _suggestionsBox,
        decoration: widget.suggestionsBoxDecoration,
        debounceDuration: widget.debounceDuration,
        intercepting: widget.intercepting,
        controller: _effectiveController,
        loadingBuilder: widget.loadingBuilder,
        scrollController: widget.scrollController,
        noItemsFoundBuilder: widget.noItemsFoundBuilder,
        errorBuilder: widget.errorBuilder,
        transitionBuilder: widget.transitionBuilder,
        suggestionsCallback: widget.suggestionsCallback,
        paginatedSuggestionsCallback: widget.paginatedSuggestionsCallback,
        animationDuration: widget.animationDuration,
        animationStart: widget.animationStart,
        getImmediateSuggestions: widget.getImmediateSuggestions,
        onSuggestionSelected: widget.onSuggestionSelected == null
            ? null
            : (T selection) {
                if (!widget.keepSuggestionsOnSuggestionSelected) {
                  _effectiveFocusNode!.unfocus();
                  _suggestionsBox!.close();
                }
                widget.onSuggestionSelected!(selection);
              },
        onSuggestionMultiSelected: widget.onSuggestionMultiSelected == null
            ? null
            : (suggestion, selected) {
                widget.onSuggestionMultiSelected!(suggestion, selected);
              },
        itemBuilder: widget.itemBuilder,
        itemDisabledCallback: widget.itemDisabledCallback,
        itemSeparatorBuilder: widget.itemSeparatorBuilder,
        layoutArchitecture: widget.layoutArchitecture,
        direction: _suggestionsBox!.direction,
        hideOnLoading: widget.hideOnLoading,
        hideOnEmpty: widget.hideOnEmpty,
        hideOnError: widget.hideOnError,
        keepSuggestionsOnLoading: widget.keepSuggestionsOnLoading,
        minCharsForSuggestions: widget.minCharsForSuggestions,
        keyboardSuggestionSelectionNotifier:
            _keyboardSuggestionSelectionNotifier,
        shouldRefreshSuggestionFocusIndexNotifier:
            _shouldRefreshSuggestionsFocusIndex,
        giveTextFieldFocus: giveTextFieldFocus,
        onSuggestionFocus: onSuggestionFocus,
        onKeyEvent: _onKeyEvent,
        hideKeyboardOnDrag: widget.hideKeyboardOnDrag,
        displayAllSuggestionWhenTap: widget.displayAllSuggestionWhenTap,
        isMultiSelectDropdown: widget.isMultiSelectDropdown,
        initiallySelectedItems: widget.initiallySelectedItems,
        suggestionsBoxController: widget.suggestionsBoxController,
        textFieldWidget: textFieldWidget(),
        equalityFunction: widget.multiSelectEquality,
      );

      double w = _suggestionsBox!.textBoxWidth;
      if (widget.suggestionsBoxDecoration.constraints != null) {
        if (widget.suggestionsBoxDecoration.constraints!.minWidth != 0.0 &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity) {
          w = (widget.suggestionsBoxDecoration.constraints!.minWidth +
                  widget.suggestionsBoxDecoration.constraints!.maxWidth) /
              2;
        } else if (widget.suggestionsBoxDecoration.constraints!.minWidth !=
                0.0 &&
            widget.suggestionsBoxDecoration.constraints!.minWidth > w) {
          w = widget.suggestionsBoxDecoration.constraints!.minWidth;
        } else if (widget.suggestionsBoxDecoration.constraints!.maxWidth !=
                double.infinity &&
            widget.suggestionsBoxDecoration.constraints!.maxWidth < w) {
          w = widget.suggestionsBoxDecoration.constraints!.maxWidth;
        }
      }

      final Widget compositedFollower = CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(
            widget.suggestionsBoxDecoration.offsetX,
            _suggestionsBox!.direction == AxisDirection.down
                ? _suggestionsBox!.textBoxHeight +
                    widget.suggestionsBoxVerticalOffset
                : -widget.suggestionsBoxVerticalOffset),
        child: FractionalTranslation(
          translation: _suggestionsBox!.direction == AxisDirection.down
              ? const Offset(0, 0)
              : const Offset(0.0, -1.0),
          child: TextFieldTapRegion(
            onTapOutside: (e) {
              if (widget
                  .suggestionsBoxDecoration.closeSuggestionBoxWhenTapOutside) {
                if (_suggestionsBox?.isOpened ?? false) {
                  _focusNode?.unfocus();
                  _suggestionsBox?.close();
                }
              }
            },
            child: suggestionsList,
          ),
        ),
      );

      // When wrapped in the Positioned widget, the suggestions box widget
      // is placed before the Scaffold semantically. In order to have the
      // suggestions box navigable from the search input or keyboard,
      // Semantics > Align > ConstrainedBox are needed. This does not change
      // the style visually. However, when VO/TB are not enabled it is
      // necessary to use the Positioned widget to allow the elements to be
      // properly tappable.
      return MediaQuery.of(context).accessibleNavigation
          ? Semantics(
              container: true,
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: w),
                  child: compositedFollower,
                ),
              ),
            )
          : Positioned(
              width: w,
              child: compositedFollower,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: PointerInterceptor(
        intercepting: widget.intercepting,
        child: widget.isMultiSelectDropdown
            ? MultiSelectDropdownDisplayWidget<T>(
                initiallySelectedItems: widget.initiallySelectedItems ?? [],
                textFieldConfiguration: widget.textFieldConfiguration,
                focusNode: _effectiveFocusNode,
                dropdownBoxConfiguration:
                    widget.multiSelectDropdownBoxConfiguration ??
                        const DropdownBoxConfiguration(),
                chipBuilder: widget.chipBuilder,
                // validator: widget.validator,
              )
            : textFieldWidget(),
      ),
    );
  }

  Widget textFieldWidget() {
    return TextField(
      focusNode: _effectiveFocusNode,
      controller: _effectiveController,
      decoration: widget.textFieldConfiguration.decoration,
      style: widget.textFieldConfiguration.style,
      textAlign: widget.textFieldConfiguration.textAlign,
      enabled: widget.textFieldConfiguration.enabled,
      keyboardType: widget.textFieldConfiguration.keyboardType,
      autofocus: widget.textFieldConfiguration.autofocus,
      inputFormatters: widget.textFieldConfiguration.inputFormatters,
      autocorrect: widget.textFieldConfiguration.autocorrect,
      maxLines: widget.textFieldConfiguration.maxLines,
      textAlignVertical: widget.textFieldConfiguration.textAlignVertical,
      minLines: widget.textFieldConfiguration.minLines,
      maxLength: widget.textFieldConfiguration.maxLength,
      maxLengthEnforcement: widget.textFieldConfiguration.maxLengthEnforcement,
      obscureText: widget.textFieldConfiguration.obscureText,
      onChanged: widget.textFieldConfiguration.onChanged,
      onSubmitted: widget.textFieldConfiguration.onSubmitted,
      onEditingComplete: widget.textFieldConfiguration.onEditingComplete,
      onTap: widget.textFieldConfiguration.onTap,
      onTapOutside: widget.textFieldConfiguration.onTapOutside,
      scrollPadding: widget.textFieldConfiguration.scrollPadding,
      textInputAction: widget.textFieldConfiguration.textInputAction,
      textCapitalization: widget.textFieldConfiguration.textCapitalization,
      keyboardAppearance: widget.textFieldConfiguration.keyboardAppearance,
      cursorWidth: widget.textFieldConfiguration.cursorWidth,
      cursorRadius: widget.textFieldConfiguration.cursorRadius,
      cursorColor: widget.textFieldConfiguration.cursorColor,
      mouseCursor: widget.textFieldConfiguration.mouseCursor,
      textDirection: widget.textFieldConfiguration.textDirection,
      enableInteractiveSelection:
          widget.textFieldConfiguration.enableInteractiveSelection,
      readOnly: widget.hideKeyboard,
      autofillHints: widget.textFieldConfiguration.autofillHints,
    );
  }
}
