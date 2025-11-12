import 'dart:async';
import 'dart:math';
import 'package:drop_down_search_field/src/keyboard_suggestion_selection_notifier.dart';
import 'package:drop_down_search_field/src/should_refresh_suggestion_focus_index_notifier.dart';
import 'package:drop_down_search_field/src/nested_item_widgets/nested_item_model.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_decoration.dart';
import 'package:drop_down_search_field/src/suggestions/suggestions_box_controller.dart';
import 'package:drop_down_search_field/src/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// Helper class to represent flattened nested items
class _FlattenedNestedItem<T> {
  final NestedItem<T> item;
  final int depth;

  _FlattenedNestedItem(this.item, this.depth);
}

/// Renders nested suggestions in a hierarchical dropdown list
///
/// Supported list layout architectures:
/// ```dart
/// [
///    NestedItem(
///        value: 'Item1',
///        children: [
///          NestedItem(value: 'SubItem1'),
///          NestedItem(value: 'SubItem2'),
///        ]
///    ),
///    ....
/// ]
/// ```
class NestedSuggestionsList<T> extends StatefulWidget {
  final SuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final NestedSuggestionSelectionCallback<T>? onSuggestionSelected;
  final NestedSuggestionMultiSelectionCallback<T>? onSuggestionMultiSelected;
  final NestedSuggestionsCallback<T>? nestedSuggestionsCallback;
  final NestedItemBuilder<T> itemBuilder;
  final NestedItemDisabledCallback<T>? itemDisabledCallback;
  final IndexedWidgetBuilder? itemSeparatorBuilder;
  final ScrollController? scrollController;
  final SuggestionsBoxDecoration? decoration;
  final Duration? debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final bool intercepting;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration? animationDuration;
  final double? animationStart;
  final AxisDirection? direction;
  final bool? hideOnLoading;
  final bool? hideOnEmpty;
  final bool? hideOnError;
  final bool? keepSuggestionsOnLoading;
  final int? minCharsForSuggestions;
  final KeyboardSuggestionSelectionNotifier keyboardSuggestionSelectionNotifier;
  final ShouldRefreshSuggestionFocusIndexNotifier
      shouldRefreshSuggestionFocusIndexNotifier;
  final VoidCallback giveTextFieldFocus;
  final VoidCallback onSuggestionFocus;
  final KeyEventResult Function(FocusNode _, KeyEvent event) onKeyEvent;
  final bool hideKeyboardOnDrag;
  final bool displayAllSuggestionWhenTap;
  final bool isMultiSelectDropdown;
  final List<NestedItem<T>>? initiallySelectedItems;
  final SuggestionsBoxController? suggestionsBoxController;
  final Widget? textFieldWidget;
  final bool Function(NestedItem<T>, NestedItem<T>)? equalityFunction;
  final NestedItemSearchCallback<T>? itemSearchCallback;
  final NestedDropdownConfiguration nestedConfig;

  const NestedSuggestionsList({
    super.key,
    required this.suggestionsBox,
    this.controller,
    this.intercepting = false,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.onSuggestionMultiSelected,
    this.nestedSuggestionsCallback,
    required this.itemBuilder,
    this.itemDisabledCallback,
    this.itemSeparatorBuilder,
    this.scrollController,
    this.decoration,
    this.debounceDuration,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationDuration,
    this.animationStart,
    this.direction,
    this.hideOnLoading,
    this.hideOnEmpty,
    this.hideOnError,
    this.keepSuggestionsOnLoading,
    this.minCharsForSuggestions,
    required this.keyboardSuggestionSelectionNotifier,
    required this.shouldRefreshSuggestionFocusIndexNotifier,
    required this.giveTextFieldFocus,
    required this.onSuggestionFocus,
    required this.onKeyEvent,
    required this.hideKeyboardOnDrag,
    required this.displayAllSuggestionWhenTap,
    required this.isMultiSelectDropdown,
    this.initiallySelectedItems,
    required this.suggestionsBoxController,
    this.textFieldWidget,
    this.equalityFunction,
    this.itemSearchCallback,
    this.nestedConfig = const NestedDropdownConfiguration(),
  });

  @override
  State<NestedSuggestionsList<T>> createState() =>
      _NestedSuggestionsListState<T>();
}

class _NestedSuggestionsListState<T> extends State<NestedSuggestionsList<T>>
    with SingleTickerProviderStateMixin {
  Iterable<NestedItem<T>>? _suggestions;
  List<NestedItem<T>>? _filteredSuggestions;
  late bool _suggestionsValid;
  late VoidCallback _controllerListener;
  Timer? _debounceTimer;
  bool? _isLoading, _isQueued;
  Object? _error;
  AnimationController? _animationController;
  String? _lastTextValue;
  late final ScrollController _scrollController =
      widget.scrollController ?? ScrollController();
  List<FocusNode> _focusNodes = [];
  int _suggestionIndex = -1;

  // Cache for disabled state to avoid repeated calls
  final Map<NestedItem<T>, bool> _disabledCache = <NestedItem<T>, bool>{};

  _NestedSuggestionsListState() {
    _controllerListener = () {
      // If we came here because of a change in selected text, not because of
      // actual change in text
      if (widget.controller!.text == _lastTextValue) return;

      _lastTextValue = widget.controller!.text;

      _debounceTimer?.cancel();
      if (widget.controller!.text.length < widget.minCharsForSuggestions!) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _suggestions = null;
            _filteredSuggestions = null;
            _suggestionsValid = true;
            _clearDisabledCache();
          });
        }
        return;
      } else {
        _debounceTimer = Timer(widget.debounceDuration!, () async {
          if (_debounceTimer!.isActive) return;
          if (_isLoading!) {
            _isQueued = true;
            return;
          }

          await invalidateSuggestions();
          while (_isQueued!) {
            _isQueued = false;
            await invalidateSuggestions();
          }
        });
      }
    };
  }

  @override
  void didUpdateWidget(NestedSuggestionsList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(_controllerListener);
    _getSuggestions(widget.controller!.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getSuggestions(
        widget.displayAllSuggestionWhenTap ? '' : widget.controller!.text);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _suggestionsValid = widget.minCharsForSuggestions! > 0 ? true : false;
    _isLoading = false;
    _isQueued = false;
    _lastTextValue = widget.controller!.text;

    if (widget.getImmediateSuggestions) {
      _getSuggestions(widget.controller!.text);
    }

    widget.controller!.addListener(_controllerListener);

    widget.keyboardSuggestionSelectionNotifier.addListener(() {
      final suggestionsLength = _getVisibleSuggestions().length;
      final event = widget.keyboardSuggestionSelectionNotifier.value;
      if (event == null || suggestionsLength == 0) return;

      if (event == LogicalKeyboardKey.arrowDown &&
          _suggestionIndex < suggestionsLength - 1) {
        _suggestionIndex = _findNextEnabledIndex(
            _suggestionIndex + 1, suggestionsLength, true);
      } else if (event == LogicalKeyboardKey.arrowUp && _suggestionIndex > -1) {
        _suggestionIndex = _findNextEnabledIndex(
            _suggestionIndex - 1, suggestionsLength, false);
      }

      if (_suggestionIndex > -1 && _suggestionIndex < _focusNodes.length) {
        final focusNode = _focusNodes[_suggestionIndex];
        focusNode.requestFocus();
        widget.onSuggestionFocus();
      } else {
        widget.giveTextFieldFocus();
      }
    });

    widget.shouldRefreshSuggestionFocusIndexNotifier.addListener(() {
      if (_suggestionIndex != -1) {
        _suggestionIndex = -1;
      }
    });
  }

  Future<void> invalidateSuggestions() async {
    _suggestionsValid = false;
    await _getSuggestions(widget.controller!.text);
  }

  Future<void> _getSuggestions(String pattern) async {
    if (_suggestionsValid) return;
    _suggestionsValid = true;

    if (mounted) {
      setState(() {
        _animationController!.forward(from: 1.0);
        _isLoading = true;
        _error = null;
      });

      Iterable<NestedItem<T>>? suggestions;
      Object? error;

      try {
        suggestions = await widget.nestedSuggestionsCallback!(pattern);
      } catch (e) {
        error = e;
      }

      if (mounted) {
        setState(() {
          double? animationStart = widget.animationStart;
          if (error != null || suggestions?.isEmpty == true) {
            animationStart = 1.0;
          }
          _animationController!.forward(from: animationStart);

          _error = error;
          _isLoading = false;
          _suggestions = suggestions;
          _clearDisabledCache();

          // Filter and process suggestions based on search pattern
          _filteredSuggestions = _filterSuggestions(suggestions, pattern);

          // Generate focus nodes for all visible items
          final visibleItems = _getVisibleSuggestions();
          _focusNodes = List.generate(
            visibleItems.length,
            (index) => FocusNode(onKeyEvent: (focusNode, event) {
              return widget.onKeyEvent(focusNode, event);
            }),
          );
        });
      }
    }
  }

  List<NestedItem<T>>? _filterSuggestions(
      Iterable<NestedItem<T>>? suggestions, String pattern) {
    if (suggestions == null || pattern.isEmpty) {
      // Handle initial expansion/collapse state
      if (widget.nestedConfig.collapseOnOpen) {
        for (final item in suggestions ?? <NestedItem<T>>[]) {
          item.collapse(recursive: true);
        }
      } else if (widget.nestedConfig.initiallyExpanded) {
        for (final item in suggestions ?? <NestedItem<T>>[]) {
          item.expand(recursive: true);
        }
      }
      return suggestions?.toList();
    }

    final filtered = <NestedItem<T>>[];

    for (final item in suggestions) {
      final matchingItem = _filterNestedItem(item, pattern);
      if (matchingItem != null) {
        filtered.add(matchingItem);
      }
    }

    return filtered;
  }

  NestedItem<T>? _filterNestedItem(NestedItem<T> item, String pattern) {
    // Check if current item matches
    final itemMatches = _itemMatches(item, pattern);

    // Filter children recursively
    final List<NestedItem<T>> matchingChildren = [];
    if (item.hasChildren) {
      for (final child in item.children!) {
        final matchingChild = _filterNestedItem(child, pattern);
        if (matchingChild != null) {
          matchingChildren.add(matchingChild);
        }
      }
    }

    // If showing only matching branches and neither item nor children match, exclude
    if (widget.nestedConfig.showOnlyMatchingBranches &&
        !itemMatches &&
        matchingChildren.isEmpty) {
      return null;
    }

    // Create a copy with filtered children
    final filteredItem = item.copyWith(
      children: matchingChildren.isEmpty ? null : matchingChildren,
    );

    // Auto-expand if configured and there are matches
    if (widget.nestedConfig.autoExpandOnSearch &&
        pattern.isNotEmpty &&
        (itemMatches || matchingChildren.isNotEmpty)) {
      filteredItem.isExpanded = true;
    }

    return filteredItem;
  }

  bool _itemMatches(NestedItem<T> item, String pattern) {
    // Use custom search callback if provided
    if (widget.itemSearchCallback != null) {
      return widget.itemSearchCallback!(item, pattern);
    }

    // Default search logic
    final searchText = pattern.toLowerCase();
    final itemLabel = (item.label ?? item.value.toString()).toLowerCase();
    return itemLabel.contains(searchText);
  }

  List<NestedItem<T>> _getVisibleSuggestions() {
    if (_filteredSuggestions == null) return [];

    final List<NestedItem<T>> visible = [];

    void addVisibleItems(List<NestedItem<T>> items) {
      for (final item in items) {
        visible.add(item);
        if (item.hasChildren && item.isExpanded) {
          addVisibleItems(item.children!);
        }
      }
    }

    addVisibleItems(_filteredSuggestions!);
    return visible;
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _debounceTimer?.cancel();
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty = (_filteredSuggestions?.isEmpty ?? true) &&
        widget.controller!.text == "";

    if ((_suggestions == null || isEmpty) &&
        _isLoading == false &&
        _error == null) {
      return Container();
    }

    Widget child;
    if (_isLoading!) {
      if (widget.hideOnLoading!) {
        child = Container(height: 0);
      } else {
        child = createLoadingWidget();
      }
    } else if (_error != null) {
      if (widget.hideOnError!) {
        child = Container(height: 0);
      } else {
        child = createErrorWidget();
      }
    } else if (_filteredSuggestions!.isEmpty) {
      if (widget.hideOnEmpty!) {
        child = Container(height: 0);
      } else {
        child = createNoItemsFoundWidget();
      }
    } else {
      child = createSuggestionsWidget();
    }

    if (widget.isMultiSelectDropdown) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: widget.textFieldWidget,
          ),
          Flexible(child: child),
        ],
      );
    }

    final animationChild = widget.transitionBuilder != null
        ? widget.transitionBuilder!(context, child, _animationController)
        : SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: CurvedAnimation(
                parent: _animationController!, curve: Curves.fastOutSlowIn),
            child: child,
          );

    BoxConstraints constraints;
    if (widget.decoration!.constraints == null) {
      constraints = BoxConstraints(
        maxHeight: widget.suggestionsBox!.maxHeight,
      );
    } else {
      double maxHeight = min(widget.decoration!.constraints!.maxHeight,
          widget.suggestionsBox!.maxHeight);
      constraints = widget.decoration!.constraints!.copyWith(
        minHeight: min(widget.decoration!.constraints!.minHeight, maxHeight),
        maxHeight: maxHeight,
      );
    }

    var container = PointerInterceptor(
        intercepting: widget.intercepting,
        child: Material(
          elevation: widget.decoration!.elevation,
          color: widget.decoration!.color,
          shape: widget.decoration!.shape,
          borderRadius: widget.decoration!.borderRadius,
          shadowColor: widget.decoration!.shadowColor,
          clipBehavior: widget.decoration!.clipBehavior,
          child: ConstrainedBox(
            constraints: constraints,
            child: animationChild,
          ),
        ));

    return container;
  }

  Widget createLoadingWidget() {
    Widget child;

    if (widget.keepSuggestionsOnLoading! && _filteredSuggestions != null) {
      if (_filteredSuggestions!.isEmpty) {
        child = createNoItemsFoundWidget();
      } else {
        child = createSuggestionsWidget();
      }
    } else {
      child = widget.loadingBuilder != null
          ? widget.loadingBuilder!(context)
          : const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            );
    }

    return child;
  }

  Widget createErrorWidget() {
    return widget.errorBuilder != null
        ? widget.errorBuilder!(context, _error)
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: $_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
  }

  Widget createNoItemsFoundWidget() {
    return widget.noItemsFoundBuilder != null
        ? widget.noItemsFoundBuilder!(context)
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No Items Found!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).disabledColor, fontSize: 18.0),
            ),
          );
  }

  Widget createSuggestionsWidget() {
    // Flatten the nested structure into a linear list for ListView
    final flattenedItems = _getFlattenedVisibleItems();

    Widget child = ListView.separated(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      keyboardDismissBehavior: widget.hideKeyboardOnDrag
          ? ScrollViewKeyboardDismissBehavior.onDrag
          : ScrollViewKeyboardDismissBehavior.manual,
      controller: _scrollController,
      reverse: widget.suggestionsBox!.direction == AxisDirection.down
          ? false
          : widget.suggestionsBox!.autoFlipListDirection,
      itemCount: flattenedItems.length,
      itemBuilder: (BuildContext context, int index) {
        final itemData = flattenedItems[index];
        final focusNode =
            index < _focusNodes.length ? _focusNodes[index] : FocusNode();

        return TextFieldTapRegion(
          child: _buildFlatNestedItem(itemData, focusNode),
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          widget.itemSeparatorBuilder?.call(context, index) ??
          const SizedBox.shrink(),
    );

    if (widget.decoration!.hasScrollbar) {
      child = MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Theme(
          data: ThemeData(
            scrollbarTheme: getScrollbarTheme(),
          ),
          child: Scrollbar(
            controller: _scrollController,
            child: child,
          ),
        ),
      );
    }

    child = TextFieldTapRegion(child: child);

    return child;
  }

  // Get all visible items as a flat list with their depth information
  List<_FlattenedNestedItem<T>> _getFlattenedVisibleItems() {
    if (_filteredSuggestions == null) return [];

    final List<_FlattenedNestedItem<T>> flattened = [];

    void flattenItems(List<NestedItem<T>> items, int depth) {
      for (final item in items) {
        flattened.add(_FlattenedNestedItem<T>(item, depth));

        // Add children if item is expanded
        if (item.hasChildren && item.isExpanded) {
          flattenItems(item.children!, depth + 1);
        }
      }
    }

    flattenItems(_filteredSuggestions!, 0);
    return flattened;
  }

  // Build a single flattened nested item
  Widget _buildFlatNestedItem(
      _FlattenedNestedItem<T> itemData, FocusNode focusNode) {
    final item = itemData.item;
    final depth = itemData.depth;
    final indentation =
        (depth * widget.nestedConfig.childIndentation).clamp(0.0, 100.0);

    // Check if item is disabled
    final isDisabled =
        item.isDisabled || (widget.itemDisabledCallback?.call(item) ?? false);

    // Check if item is selected (for multi-select)
    final isSelected = widget.initiallySelectedItems?.any((selectedItem) =>
            widget.equalityFunction?.call(selectedItem, item) ??
            selectedItem == item) ??
        false;

    // Check if item can be selected
    final canSelect = item.isSelectable &&
        !isDisabled &&
        (widget.nestedConfig.allowParentSelection || item.isLeaf);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusNode: focusNode,
        onTap: isDisabled ? null : () => _handleItemTap(item),
        focusColor: Theme.of(context).hoverColor,
        child: ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.hasChildren && widget.nestedConfig.showExpandIcons)
                IconButton(
                  onPressed: isDisabled ? null : () => _toggleExpansion(item),
                  icon: Icon(
                    item.isExpanded
                        ? (widget.nestedConfig.collapseIcon ??
                            Icons.expand_less)
                        : (widget.nestedConfig.expandIcon ?? Icons.expand_more),
                  ),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              if (!item.hasChildren || !widget.nestedConfig.showExpandIcons)
                const SizedBox(width: 25),
              if (widget.isMultiSelectDropdown && canSelect)
                Checkbox(
                  value: isSelected,
                  onChanged: !canSelect || isDisabled
                      ? null
                      : (bool? checked) {
                          widget.onSuggestionMultiSelected
                              ?.call(item, checked ?? false);
                          setState(() {});
                        },
                ),
            ],
          ),
          contentPadding: EdgeInsets.only(
            left: 16.0 + indentation,
            right: 16.0,
          ),
          title: widget.itemBuilder(context, item, depth),
          dense: true,
        ),
      ),
    );
  }

  // Handle item tap
  void _handleItemTap(NestedItem<T> item) {
    final isDisabled =
        item.isDisabled || (widget.itemDisabledCallback?.call(item) ?? false);

    if (isDisabled) return;

    // If item has children and we're not in multi-select mode, toggle expansion
    if (item.hasChildren && !widget.isMultiSelectDropdown) {
      _toggleExpansion(item);
      return;
    }

    // Handle selection if item can be selected
    final canSelect = item.isSelectable &&
        !isDisabled &&
        (widget.nestedConfig.allowParentSelection || item.isLeaf);

    if (canSelect) {
      if (widget.isMultiSelectDropdown) {
        // In multi-select mode, also check if checkbox is allowed
        final isSelected = widget.initiallySelectedItems?.any((selectedItem) =>
                widget.equalityFunction?.call(selectedItem, item) ??
                selectedItem == item) ??
            false;
        widget.onSuggestionMultiSelected?.call(item, !isSelected);
        setState(() {});
      } else {
        widget.giveTextFieldFocus();
        widget.onSuggestionSelected?.call(item);
      }
    } else if (item.hasChildren) {
      // If can't select but has children, toggle expansion
      _toggleExpansion(item);
    }
  }

  // Toggle expansion state and refresh the UI
  void _toggleExpansion(NestedItem<T> item) {
    setState(() {
      item.toggleExpansion();

      // Regenerate focus nodes for new visible items
      final flattenedItems = _getFlattenedVisibleItems();
      _focusNodes = List.generate(
        flattenedItems.length,
        (index) => FocusNode(onKeyEvent: (focusNode, event) {
          return widget.onKeyEvent(focusNode, event);
        }),
      );
    });
  }

  ScrollbarThemeData? getScrollbarTheme() {
    return const ScrollbarThemeData().copyWith(
      thickness: WidgetStatePropertyAll(
          widget.decoration?.scrollBarDecoration?.thickness),
      thumbColor: WidgetStatePropertyAll(
          widget.decoration?.scrollBarDecoration?.thumbColor),
      radius: widget.decoration?.scrollBarDecoration?.radius,
      thumbVisibility: WidgetStatePropertyAll(
          widget.decoration?.scrollBarDecoration?.thumbVisibility),
      crossAxisMargin: widget.decoration?.scrollBarDecoration?.crossAxisMargin,
      mainAxisMargin: widget.decoration?.scrollBarDecoration?.mainAxisMargin,
      interactive: widget.decoration?.scrollBarDecoration?.interactive,
    );
  }

  int _findNextEnabledIndex(
      int startIndex, int suggestionsLength, bool forward) {
    if (widget.itemDisabledCallback == null) {
      if (forward) {
        return startIndex < suggestionsLength ? startIndex : -1;
      } else {
        return startIndex >= 0 ? startIndex : -1;
      }
    }

    int currentIndex = startIndex;
    final visibleSuggestions = _getVisibleSuggestions();

    while (forward ? (currentIndex < suggestionsLength) : (currentIndex >= 0)) {
      if (currentIndex < visibleSuggestions.length) {
        final suggestion = visibleSuggestions[currentIndex];
        final isDisabled = _isItemDisabled(suggestion);

        if (!isDisabled) {
          return currentIndex;
        }
      }

      currentIndex = forward ? currentIndex + 1 : currentIndex - 1;
    }

    return -1;
  }

  bool _isItemDisabled(NestedItem<T> item) {
    if (widget.itemDisabledCallback == null) {
      return false;
    }

    if (_disabledCache.containsKey(item)) {
      return _disabledCache[item]!;
    }

    final isDisabled = widget.itemDisabledCallback!(item);
    _disabledCache[item] = isDisabled;
    return isDisabled;
  }

  void _clearDisabledCache() {
    _disabledCache.clear();
  }
}
