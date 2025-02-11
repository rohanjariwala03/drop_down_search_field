import 'package:flutter/material.dart';

class ScrollbarConfiguration {
  /// Whether the scrollbar should always be shown.
  ///
  /// Defaults to false.
  final bool isAlwaysShown;

  /// The thickness of the scrollbar.
  ///
  /// Defaults to 6.0.
  final double thickness;

  /// The radius of the scrollbar.
  final Radius? radius;

  /// Whether the scrollbar should never be displayed.
  ///
  /// Defaults to false.
  final bool neverDisplayScrollbar;

  /// The color of the thumb of the scrollbar.
  final Color? thumbColor;

  /// The color of the track of the scrollbar.
  final Color? trackColor;

  /// The color of the border of the track of the scrollbar.
  final Color? trackBorderColor;

  const ScrollbarConfiguration({
    this.isAlwaysShown = false,
    this.thickness = 6.0,
    this.radius,
    this.neverDisplayScrollbar = false,
    this.thumbColor,
    this.trackColor,
    this.trackBorderColor,
  });
}
