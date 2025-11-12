import 'dart:async';
import 'package:drop_down_search_field/src/keyboard_suggestion_selection_notifier.dart';
import 'package:drop_down_search_field/src/should_refresh_suggestion_focus_index_notifier.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_controller.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_decoration.dart';
import 'package:drop_down_search_field/src/nested_item_widgets/nested_suggestion_list.dart';
import 'package:drop_down_search_field/src/nested_item_widgets/nested_item_model.dart';
import 'package:drop_down_search_field/src/type_def.dart';
import 'package:drop_down_search_field/src/multi_selection_widgets/multi_select_drop_down_box_configuration.dart';
import 'package:drop_down_search_field/src/multi_selection_widgets/multi_select_dropdown_display_widget.dart';
import 'package:drop_down_search_field/src/widgets/fractional_translation_widget.dart';
import 'package:drop_down_search_field/src/widgets/search_field_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// A specialized dropdown widget for hierarchical/nested suggestions
///
/// This widget extends the functionality of DropDownSearchField to support
/// nested/hierarchical data structures with expand/collapse functionality.
///
/// Example usage:
/// ```dart
/// NestedDropDownSearchField<String>(
///   nestedSuggestionsCallback: (pattern) async {
///     return [
///       NestedItem(
///         value: 'Category 1',
///         children: [
///           NestedItem(value: 'Item 1.1'),
///           NestedItem(value: 'Item 1.2'),
///         ],
///       ),
///       // ... more items
///     ];
///   },
///   nestedItemBuilder: (context, item, depth) {
///     return ListTile(
///       title: Text(item.label ?? item.value.toString()),
///       leading: depth > 0 ? Icon(Icons.subdirectory_arrow_right) : null,
///     );
///   },
///   onNestedSuggestionSelected: (item) {
///     // Handle selection
///   },
/// )
/// ```
class NestedDropDownSearchField<T> extends StatefulWidget {
  /// Called with the search pattern to get the nested suggestions.
  final NestedSuggestionsCallback<T> nestedSuggestionsCallback;

  /// Called when a nested suggestion is tapped.
  final NestedSuggestionSelectionCallback<T>? onNestedSuggestionSelected;

  /// Called when multiple nested suggestions are selected.
  final NestedSuggestionMultiSelectionCallback<T>?
      onNestedSuggestionMultiSelected;

  /// Called for each nested suggestion to build the corresponding widget.
  final NestedItemBuilder<T> nestedItemBuilder;

  /// Called for each nested suggestion to determine if it should be disabled.
  final NestedItemDisabledCallback<T>? nestedItemDisabledCallback;

  /// Custom search callback for nested items
  final NestedItemSearchCallback<T>? nestedItemSearchCallback;

  /// Custom equality function for nested items
  final bool Function(NestedItem<T> item1, NestedItem<T> item2)?
      nestedEqualityFunction;

  /// Configuration for nested dropdown behavior
  final NestedDropdownConfiguration nestedDropdownConfiguration;

  final IndexedWidgetBuilder? itemSeparatorBuilder;
  final ScrollController? scrollController;
  final SuggestionsBoxDecoration suggestionsBoxDecoration;
  final SuggestionsBoxController? suggestionsBoxController;
  final Duration debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final bool intercepting;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration animationDuration;
  final AxisDirection direction;
  final double animationStart;
  final TextFieldConfiguration textFieldConfiguration;
  final double suggestionsBoxVerticalOffset;
  final bool getImmediateSuggestions;
  final bool hideOnLoading;
  final bool hideOnEmpty;
  final bool hideOnError;
  final bool hideSuggestionsOnKeyboardHide;
  final bool keepSuggestionsOnLoading;
  final bool keepSuggestionsOnSuggestionSelected;
  final bool autoFlipDirection;
  final bool autoFlipListDirection;
  final double autoFlipMinHeight;
  final bool hideKeyboard;
  final int minCharsForSuggestions;
  final bool hideKeyboardOnDrag;
  final void Function(bool)? onSuggestionsBoxToggle;
  final bool displayAllSuggestionWhenTap;
  final bool isMultiSelectDropdown;
  final List<NestedItem<T>>? initiallySelectedItems;
  final DropdownBoxConfiguration? multiSelectDropdownBoxConfiguration;
  final FormFieldValidator<List<NestedItem<T>>>? validator;
  final NestedChipBuilder<T>? chipBuilder;

  /// Creates a [NestedDropDownSearchField]
  const NestedDropDownSearchField({
    required this.nestedSuggestionsCallback,
    required this.nestedItemBuilder,
    this.onNestedSuggestionSelected,
    this.onNestedSuggestionMultiSelected,
    this.nestedItemDisabledCallback,
    this.nestedItemSearchCallback,
    this.nestedEqualityFunction,
    this.nestedDropdownConfiguration = const NestedDropdownConfiguration(),
    this.itemSeparatorBuilder,
    this.intercepting = false,
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
    super.key,
  })  : assert(animationStart >= 0.0 && animationStart <= 1.0),
        assert(
            direction == AxisDirection.down || direction == AxisDirection.up),
        assert(minCharsForSuggestions >= 0),
        assert(!hideKeyboardOnDrag ||
            hideKeyboardOnDrag && !hideSuggestionsOnKeyboardHide),
        assert(
          !(onNestedSuggestionSelected != null &&
              onNestedSuggestionMultiSelected != null),
          'Only one of onNestedSuggestionSelected or onNestedSuggestionMultiSelected must be provided.',
        ),
        assert(
          !isMultiSelectDropdown ||
              (onNestedSuggestionMultiSelected != null &&
                  initiallySelectedItems != null),
          'onNestedSuggestionMultiSelected and initiallySelectedItems must be provided when isMultiSelectDropdown is true.',
        ),
        assert(
            isMultiSelectDropdown ||
                multiSelectDropdownBoxConfiguration == null,
            'Cannot provide multiSelectDropdownBoxConfiguration when isMultiSelectDropdown is false.');

  @override
  State<NestedDropDownSearchField<T>> createState() =>
      _NestedDropDownSearchFieldState<T>();
}

class _NestedDropDownSearchFieldState<T>
    extends State<NestedDropDownSearchField<T>> with WidgetsBindingObserver {
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
      // The NestedDropDownSearchField is inside a scrollable widget
      _scrollPosition = scrollableState.position;

      _scrollPosition!.removeListener(_scrollResizeListener);
      _scrollPosition!.isScrollingNotifier.addListener(_scrollResizeListener);
    }
  }

  void _scrollResizeListener() {
    bool isScrolling = _scrollPosition!.isScrollingNotifier.value;
    _resizeOnScrollTimer?.cancel();
    if (isScrolling) {
      // Scroll started - use a more defensive approach during scrolling
      _resizeOnScrollTimer =
          Timer.periodic(_resizeOnScrollRefreshRate, (timer) {
        if (mounted && _suggestionsBox != null && _suggestionsBox!.isOpened) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                _suggestionsBox != null &&
                _suggestionsBox!.isOpened) {
              _suggestionsBox!.resize();
            }
          });
        }
      });
    } else {
      // Scroll finished - safe to resize immediately
      if (mounted && _suggestionsBox != null && _suggestionsBox!.isOpened) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _suggestionsBox != null && _suggestionsBox!.isOpened) {
            _suggestionsBox!.resize();
          }
        });
      }
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

      final suggestionsList = NestedSuggestionsList<T>(
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
        nestedSuggestionsCallback: widget.nestedSuggestionsCallback,
        animationDuration: widget.animationDuration,
        animationStart: widget.animationStart,
        getImmediateSuggestions: widget.getImmediateSuggestions,
        onSuggestionSelected: widget.onNestedSuggestionSelected == null
            ? null
            : (NestedItem<T> selection) {
                if (!widget.keepSuggestionsOnSuggestionSelected) {
                  _effectiveFocusNode!.unfocus();
                  _suggestionsBox!.close();
                }
                widget.onNestedSuggestionSelected!(selection);
              },
        onSuggestionMultiSelected: widget.onNestedSuggestionMultiSelected ==
                null
            ? null
            : (suggestion, selected) {
                widget.onNestedSuggestionMultiSelected!(suggestion, selected);
              },
        itemBuilder: widget.nestedItemBuilder,
        itemDisabledCallback: widget.nestedItemDisabledCallback,
        itemSeparatorBuilder: widget.itemSeparatorBuilder,
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
        equalityFunction: widget.nestedEqualityFunction,
        itemSearchCallback: widget.nestedItemSearchCallback,
        nestedConfig: widget.nestedDropdownConfiguration,
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
        child: RepaintBoundary(
          child: SafeFractionalTranslation(
            translation: _suggestionsBox!.direction == AxisDirection.down
                ? const Offset(0, 0)
                : const Offset(0.0, -1.0),
            child: TextFieldTapRegion(
              onTapOutside: (e) {
                if (widget.suggestionsBoxDecoration
                    .closeSuggestionBoxWhenTapOutside) {
                  if (_suggestionsBox?.isOpened ?? false) {
                    _focusNode?.unfocus();
                    _suggestionsBox?.close();
                  }
                }
              },
              child: suggestionsList,
            ),
          ),
        ),
      );

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
            ? MultiSelectDropdownDisplayWidget<NestedItem<T>>(
                initiallySelectedItems: widget.initiallySelectedItems ?? [],
                textFieldConfiguration: widget.textFieldConfiguration,
                focusNode: _effectiveFocusNode,
                dropdownBoxConfiguration:
                    widget.multiSelectDropdownBoxConfiguration ??
                        const DropdownBoxConfiguration(),
                chipBuilder: widget.chipBuilder == null
                    ? null
                    : (context, itemData) =>
                        widget.chipBuilder!(context, itemData),
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
