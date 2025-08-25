import 'dart:async';
import 'dart:math';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:drop_down_search_field/src/keyboard_suggestion_selection_notifier.dart';
import 'package:drop_down_search_field/src/should_refresh_suggestion_focus_index_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Renders all the suggestions using a ListView as default.  If
/// `layoutArchitecture` is specified, uses that instead.

class SuggestionsList<T> extends StatefulWidget {
  final SuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final SuggestionSelectionCallback<T>? onSuggestionSelected;
  final SuggestionMultiSelectionCallback<T>? onSuggestionMultiSelected;
  final SuggestionsCallback<T>? suggestionsCallback;
  final ItemBuilder<T>? itemBuilder;
  final ItemDisabledCallback<T>? itemDisabledCallback;
  final IndexedWidgetBuilder? itemSeparatorBuilder;
  final LayoutArchitecture? layoutArchitecture;
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
  final PaginatedSuggestionsCallback<T>? paginatedSuggestionsCallback;
  final bool isMultiSelectDropdown;
  final List<T>? initiallySelectedItems;
  final SuggestionsBoxController? suggestionsBoxController;
  final Widget? textFieldWidget;
  // Custom equality function
  final bool Function(T item1, T item2)? equalityFunction;

  const SuggestionsList({
    super.key,
    required this.suggestionsBox,
    this.controller,
    this.intercepting = false,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.onSuggestionMultiSelected,
    this.suggestionsCallback,
    this.itemBuilder,
    this.itemDisabledCallback,
    this.itemSeparatorBuilder,
    this.layoutArchitecture,
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
    this.paginatedSuggestionsCallback,
    required this.isMultiSelectDropdown,
    this.initiallySelectedItems,
    required this.suggestionsBoxController,
    this.textFieldWidget,
    this.equalityFunction, // Initialize the equality function
  });

  @override
  // ignore: library_private_types_in_public_api
  _SuggestionsListState<T> createState() => _SuggestionsListState<T>();
}

class _SuggestionsListState<T> extends State<SuggestionsList<T>>
    with SingleTickerProviderStateMixin {
  Iterable<T>? _suggestions;
  late bool _suggestionsValid;
  late VoidCallback _controllerListener;
  Timer? _debounceTimer;
  bool? _isLoading, _isQueued;
  bool _paginationLoading = false;
  Object? _error;
  AnimationController? _animationController;
  String? _lastTextValue;
  late final ScrollController _scrollController =
      widget.scrollController ?? ScrollController();
  List<FocusNode> _focusNodes = [];
  int _suggestionIndex = -1;
  int pageNumber = 0;
  final multiSelectSearchFieldFocus = FocusNode();
  // Cache for disabled state to avoid repeated calls
  final Map<T, bool> _disabledCache = <T, bool>{};

  _SuggestionsListState() {
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
            _suggestionsValid = true;
            _clearDisabledCache(); // Clear cache when suggestions are cleared
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
  void didUpdateWidget(SuggestionsList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(_controllerListener);
    _getSuggestions(widget.controller!.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sending empty text when it's true so, that they can see whole list
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
      final suggestionsLength = _suggestions?.length;
      final event = widget.keyboardSuggestionSelectionNotifier.value;
      if (event == null || suggestionsLength == null) return;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.paginatedSuggestionsCallback != null) {
        _scrollController.addListener(() async {
          if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
            if (_isLoading ?? false) return;
            _isLoading = true;
            setState(() {
              _paginationLoading = true;
            });
            final olderLength = _suggestions?.length;
            pageNumber += 1;
            await invalidateSuggestions();
            if (olderLength == _suggestions?.length) {
              pageNumber -= 1;
            }
            if (mounted) {
              setState(() {
                _paginationLoading = false;
              });
            }
          }
        });
      }
    });
  }

  Future<void> invalidateSuggestions() async {
    _suggestionsValid = false;
    await _getSuggestions(widget.controller!.text);
  }

  Future<void> _getSuggestions(String suggestion) async {
    if (_suggestionsValid) return;
    _suggestionsValid = true;

    if (mounted) {
      setState(() {
        _animationController!.forward(from: 1.0);

        _isLoading = true;
        _error = null;
      });

      Iterable<T>? suggestions;
      Object? error;

      try {
        if (widget.paginatedSuggestionsCallback != null) {
          suggestions = await widget.paginatedSuggestionsCallback!(suggestion);
        } else {
          suggestions = await widget.suggestionsCallback!(suggestion);
        }
      } catch (e) {
        error = e;
      }

      if (mounted) {
        // if it wasn't removed in the meantime
        setState(() {
          double? animationStart = widget.animationStart;
          // allow suggestionsCallback to return null and not throw error here
          if (error != null || suggestions?.isEmpty == true) {
            animationStart = 1.0;
          }
          _animationController!.forward(from: animationStart);

          this._error = error;
          this._isLoading = false;
          this._suggestions = suggestions;
          _error = error;
          _isLoading = false;
          _suggestions = suggestions;
          _clearDisabledCache(); // Clear cache when suggestions change
          _focusNodes = List.generate(
            _suggestions?.length ?? 0,
            (index) => FocusNode(onKeyEvent: (focusNode, event) {
              return widget.onKeyEvent(focusNode, event);
            }),
          );
        });
      }
    }
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
    bool isEmpty =
        (_suggestions?.isEmpty ?? true) && widget.controller!.text == "";
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
    } else if (_suggestions!.isEmpty) {
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

    if (widget.keepSuggestionsOnLoading! && _suggestions != null) {
      if (_suggestions!.isEmpty) {
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
    if (widget.layoutArchitecture == null) {
      return defaultSuggestionsWidget();
    } else {
      return customSuggestionsWidget();
    }
  }

  Widget defaultSuggestionsWidget() {
    Widget child = Stack(
      children: [
        ListView.separated(
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
          itemCount: _suggestions!.length,
          itemBuilder: (BuildContext context, int index) {
            final suggestion = _suggestions!.elementAt(index);
            final focusNode = _focusNodes[index];
            final isDisabled = _isItemDisabled(suggestion);

            return TextFieldTapRegion(
              child: widget.isMultiSelectDropdown
                  ? StatefulBuilder(
                      builder: (context, setState) {
                        final isSelected = widget.initiallySelectedItems?.any(
                              (item) =>
                                  widget.equalityFunction
                                      ?.call(item, suggestion) ??
                                  item == suggestion,
                            ) ??
                            false; // Use custom equality function
                        return CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: widget.itemBuilder!(context, suggestion),
                          value: isSelected,
                          onChanged: isDisabled
                              ? null
                              : (bool? checked) {
                                  widget.onSuggestionMultiSelected!(
                                      suggestion, checked ?? false);
                                  setState(() {});
                                },
                        );
                      },
                    )
                  : InkWell(
                      focusColor: Theme.of(context).hoverColor,
                      focusNode: focusNode,
                      onTap: isDisabled
                          ? null
                          : () {
                              // * we give the focus back to the text field
                              widget.giveTextFieldFocus();

                              widget.onSuggestionSelected!(suggestion);
                            },
                      child: widget.itemBuilder!(context, suggestion),
                    ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              widget.itemSeparatorBuilder?.call(context, index) ??
              const SizedBox.shrink(),
        ),
        if (_paginationLoading)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(),
          ),
      ],
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

  Widget customSuggestionsWidget() {
    Widget child = widget.layoutArchitecture!(
      List.generate(_suggestions!.length, (index) {
        final suggestion = _suggestions!.elementAt(index);
        final focusNode = _focusNodes[index];
        final isDisabled = _isItemDisabled(suggestion);

        return TextFieldTapRegion(
          child: widget.isMultiSelectDropdown
              ? StatefulBuilder(
                  builder: (context, setState) {
                    final isSelected = widget.controller?.text
                            .contains(suggestion.toString()) ??
                        false;
                    return CheckboxListTile(
                      title: widget.itemBuilder!(context, suggestion),
                      value: isSelected,
                      onChanged: isDisabled
                          ? null
                          : (bool? checked) {
                              // widget.controller?.text = widget.initiallySelectedItems
                              //         ?.map((e) => e.toString())
                              //         .join(', ') ??
                              //     '';
                              widget.onSuggestionMultiSelected!(
                                  suggestion, checked ?? false);
                              setState(() {});
                            },
                    );
                  },
                )
              : InkWell(
                  focusColor: Theme.of(context).hoverColor,
                  focusNode: focusNode,
                  onTap: isDisabled
                      ? null
                      : () {
                          // * we give the focus back to the text field
                          widget.giveTextFieldFocus();

                          widget.onSuggestionSelected!(suggestion);
                        },
                  child: widget.itemBuilder!(context, suggestion),
                ),
        );
      }),
      _scrollController,
    );

    if (widget.decoration!.hasScrollbar) {
      child = Theme(
        data: ThemeData(
          scrollbarTheme: getScrollbarTheme(),
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Scrollbar(
            controller: _scrollController,
            child: child,
          ),
        ),
      );
    }

    child = Stack(
      children: [
        child,
        if (_paginationLoading)
          const Align(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(),
          ),
      ],
    );

    child = TextFieldTapRegion(child: child);

    return child;
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

  /// Finds the next enabled item index for keyboard navigation
  /// Returns -1 if no enabled item is found
  int _findNextEnabledIndex(
      int startIndex, int suggestionsLength, bool forward) {
    if (widget.itemDisabledCallback == null) {
      // If no disabled callback is provided, return the startIndex if within bounds
      if (forward) {
        return startIndex < suggestionsLength ? startIndex : -1;
      } else {
        return startIndex >= 0 ? startIndex : -1;
      }
    }

    int currentIndex = startIndex;
    while (forward ? (currentIndex < suggestionsLength) : (currentIndex >= 0)) {
      final suggestion = _suggestions!.elementAt(currentIndex);
      final isDisabled = _isItemDisabled(suggestion);

      if (!isDisabled) {
        return currentIndex;
      }

      currentIndex = forward ? currentIndex + 1 : currentIndex - 1;
    }

    return -1; // No enabled item found
  }

  /// Checks if an item is disabled using cache to avoid repeated calls
  bool _isItemDisabled(T item) {
    if (widget.itemDisabledCallback == null) {
      return false;
    }

    // Check cache first
    if (_disabledCache.containsKey(item)) {
      return _disabledCache[item]!;
    }

    // Call the callback and cache the result
    final isDisabled = widget.itemDisabledCallback!(item);
    _disabledCache[item] = isDisabled;
    return isDisabled;
  }

  /// Clears the disabled cache when suggestions change
  void _clearDisabledCache() {
    _disabledCache.clear();
  }
}
