import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:drop_down_search_field/src/nested_item_widgets/nested_item_model.dart';

typedef SuggestionsCallback<T> = FutureOr<Iterable<T>> Function(String pattern);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T itemData);
typedef SuggestionSelectionCallback<T> = void Function(T suggestion);
typedef ErrorBuilder = Widget Function(BuildContext context, Object? error);
typedef PaginatedSuggestionsCallback<T> = FutureOr<Iterable<T>> Function(
    String pattern);

typedef AnimationTransitionBuilder = Widget Function(
    BuildContext context, Widget child, AnimationController? controller);
typedef LayoutArchitecture = Widget Function(
    Iterable<Widget> items, ScrollController controller);

typedef SuggestionMultiSelectionCallback<T> = void Function(
    T suggestion, bool selected);

typedef ChipBuilder<T> = Widget Function(BuildContext context, T itemData);

typedef ItemDisabledCallback<T> = bool Function(T itemData);

// Nested dropdown type definitions
typedef NestedSuggestionsCallback<T> = FutureOr<Iterable<NestedItem<T>>>
    Function(String pattern);
typedef NestedItemBuilder<T> = Widget Function(
    BuildContext context, NestedItem<T> itemData, int depth);
typedef NestedSuggestionSelectionCallback<T> = void Function(
    NestedItem<T> suggestion);
typedef NestedSuggestionMultiSelectionCallback<T> = void Function(
    NestedItem<T> suggestion, bool selected);
typedef NestedItemDisabledCallback<T> = bool Function(NestedItem<T> itemData);
typedef NestedItemSearchCallback<T> = bool Function(
    NestedItem<T> item, String pattern);
typedef NestedChipBuilder<T> = Widget Function(
    BuildContext context, NestedItem<T> itemData);
