import 'package:drop_down_search_field/src/suggestions/suggestions_box_controller.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_decoration.dart';
import 'package:drop_down_search_field/src/type_def.dart';
import 'package:drop_down_search_field/src/widgets/drop_down_search_field.dart';
import 'package:drop_down_search_field/src/widgets/search_field_configuration.dart';
import 'package:flutter/material.dart';

/// A [FormField](https://docs.flutter.io/flutter/widgets/FormField-class.html)
/// implementation of [DropdownSearchField], that allows the value to be saved,
/// validated, etc.
///
/// See also:
///
/// * [DropdownSearchField], A [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
/// that displays a list of suggestions as the user types
class DropDownSearchFormField<T> extends FormField<String> {
  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the DropdownSearchField widget displays
  final TextFieldConfiguration textFieldConfiguration;

  // Adds a callback for resetting the form field
  final void Function()? onReset;

  /// Creates a [DropDownSearchFormField]
  DropDownSearchFormField({
    super.key,
    String? initialValue,
    bool getImmediateSuggestions = false,
    @Deprecated('Use autovalidateMode parameter which provides more specific '
        'behavior related to auto validation. '
        'This feature was deprecated after Flutter v1.19.0.')
    bool autovalidate = false,
    super.enabled,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    super.onSaved,
    this.onReset,
    super.validator,
    ErrorBuilder? errorBuilder,
    WidgetBuilder? noItemsFoundBuilder,
    WidgetBuilder? loadingBuilder,
    void Function(bool)? onSuggestionsBoxToggle,
    Duration debounceDuration = const Duration(milliseconds: 300),
    SuggestionsBoxDecoration suggestionsBoxDecoration =
        const SuggestionsBoxDecoration(),
    SuggestionsBoxController? suggestionsBoxController,
    required SuggestionSelectionCallback<T> onSuggestionSelected,
    required ItemBuilder<T> itemBuilder,
    IndexedWidgetBuilder? itemSeparatorBuilder,
    LayoutArchitecture? layoutArchitecture,
    SuggestionsCallback<T>? suggestionsCallback,
    PaginatedSuggestionsCallback<T>? paginatedSuggestionsCallback,
    double suggestionsBoxVerticalOffset = 5.0,
    this.textFieldConfiguration = const TextFieldConfiguration(),
    AnimationTransitionBuilder? transitionBuilder,
    Duration animationDuration = const Duration(milliseconds: 500),
    double animationStart = 0.25,
    AxisDirection direction = AxisDirection.down,
    bool hideOnLoading = false,
    bool hideOnEmpty = false,
    bool hideOnError = false,
    bool hideSuggestionsOnKeyboardHide = true,
    bool intercepting = false,
    bool keepSuggestionsOnLoading = true,
    bool keepSuggestionsOnSuggestionSelected = false,
    bool autoFlipDirection = false,
    bool autoFlipListDirection = true,
    double autoFlipMinHeight = 64.0,
    bool hideKeyboard = false,
    int minCharsForSuggestions = 0,
    bool hideKeyboardOnDrag = false,
    bool displayAllSuggestionWhenTap = false,
    final ScrollController? scrollController,
  })  : assert(
            initialValue == null || textFieldConfiguration.controller == null),
        assert(minCharsForSuggestions >= 0),
        super(
            initialValue: textFieldConfiguration.controller != null
                ? textFieldConfiguration.controller!.text
                : (initialValue ?? ''),
            builder: (FormFieldState<String> field) {
              final _DropdownSearchFormFieldState state =
                  field as _DropdownSearchFormFieldState<dynamic>;

              return DropDownSearchField(
                getImmediateSuggestions: getImmediateSuggestions,
                transitionBuilder: transitionBuilder,
                errorBuilder: errorBuilder,
                noItemsFoundBuilder: noItemsFoundBuilder,
                loadingBuilder: loadingBuilder,
                debounceDuration: debounceDuration,
                suggestionsBoxDecoration: suggestionsBoxDecoration,
                suggestionsBoxController: suggestionsBoxController,
                textFieldConfiguration: textFieldConfiguration.copyWith(
                  decoration: textFieldConfiguration.decoration
                      .copyWith(errorText: state.errorText),
                  onChanged: (text) {
                    state.didChange(text);
                    textFieldConfiguration.onChanged?.call(text);
                  },
                  controller: state._effectiveController,
                ),
                suggestionsBoxVerticalOffset: suggestionsBoxVerticalOffset,
                onSuggestionSelected: onSuggestionSelected,
                onSuggestionsBoxToggle: onSuggestionsBoxToggle,
                itemBuilder: itemBuilder,
                itemSeparatorBuilder: itemSeparatorBuilder,
                layoutArchitecture: layoutArchitecture,
                suggestionsCallback: suggestionsCallback,
                paginatedSuggestionsCallback: paginatedSuggestionsCallback,
                animationStart: animationStart,
                animationDuration: animationDuration,
                direction: direction,
                hideOnLoading: hideOnLoading,
                hideOnEmpty: hideOnEmpty,
                hideOnError: hideOnError,
                hideSuggestionsOnKeyboardHide: hideSuggestionsOnKeyboardHide,
                keepSuggestionsOnLoading: keepSuggestionsOnLoading,
                keepSuggestionsOnSuggestionSelected:
                    keepSuggestionsOnSuggestionSelected,
                intercepting: intercepting,
                autoFlipDirection: autoFlipDirection,
                autoFlipListDirection: autoFlipListDirection,
                autoFlipMinHeight: autoFlipMinHeight,
                hideKeyboard: hideKeyboard,
                minCharsForSuggestions: minCharsForSuggestions,
                hideKeyboardOnDrag: hideKeyboardOnDrag,
                displayAllSuggestionWhenTap: displayAllSuggestionWhenTap,
                scrollController: scrollController,
              );
            });
  @override
  // ignore: library_private_types_in_public_api
  _DropdownSearchFormFieldState<T> createState() =>
      _DropdownSearchFormFieldState<T>();
}

class _DropdownSearchFormFieldState<T> extends FormFieldState<String> {
  TextEditingController? _controller;

  TextEditingController? get _effectiveController =>
      widget.textFieldConfiguration.controller ?? _controller;

  @override
  DropDownSearchFormField get widget =>
      super.widget as DropDownSearchFormField<dynamic>;

  @override
  void initState() {
    super.initState();
    if (widget.textFieldConfiguration.controller == null) {
      _controller = TextEditingController(text: widget.initialValue);
    } else {
      widget.textFieldConfiguration.controller!
          .addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(DropDownSearchFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.textFieldConfiguration.controller !=
        oldWidget.textFieldConfiguration.controller) {
      oldWidget.textFieldConfiguration.controller
          ?.removeListener(_handleControllerChanged);
      widget.textFieldConfiguration.controller
          ?.addListener(_handleControllerChanged);

      if (oldWidget.textFieldConfiguration.controller != null &&
          widget.textFieldConfiguration.controller == null) {
        _controller = TextEditingController.fromValue(
            oldWidget.textFieldConfiguration.controller!.value);
      }
      if (widget.textFieldConfiguration.controller != null) {
        setValue(widget.textFieldConfiguration.controller!.text);
        if (oldWidget.textFieldConfiguration.controller == null) {
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    widget.textFieldConfiguration.controller
        ?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    setState(() {
      _effectiveController!.text = widget.initialValue!;
      if (widget.onReset != null) {
        widget.onReset!();
      }
    });
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController!.text != value) {
      didChange(_effectiveController!.text);
    }
  }
}
