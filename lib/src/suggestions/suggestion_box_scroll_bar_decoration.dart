import 'package:flutter/material.dart';

export 'package:drop_down_search_field/src/suggestions/suggestion_box_scroll_bar_decoration.dart';

/// This file defines the `ScrollBarDecoration` class, which is used to
/// customize the appearance of a scrollbar in a Flutter application.

/// A class that defines the decoration for a scrollbar.
class ScrollBarDecoration {
  /// The color of the scrollbar thumb.
  final Color? thumbColor;

  /// The thickness of the scrollbar.
  final double? thickness;

  /// The radius of the scrollbar corners.
  final Radius? radius;

  /// The margin around the scrollbar.
  final EdgeInsetsGeometry? margin;

  /// Whether the scrollbar thumb should be visible.
  final bool? thumbVisibility;

  /// The margin around the scrollbar in the cross axis.
  final double? crossAxisMargin;

  /// The margin around the scrollbar in the main axis.
  final double? mainAxisMargin;

  /// Whether the scrollbar should be interactive.
  final bool? interactive;

  ScrollBarDecoration({
    this.thumbColor,
    this.thickness,
    this.radius,
    this.margin,
    this.thumbVisibility,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.interactive,
  });
}
