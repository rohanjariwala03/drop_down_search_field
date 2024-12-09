import 'package:drop_down_search_field/src/suggestions/suggestion_box_scroll_bar_decoration.dart';
import 'package:flutter/material.dart';

/// Supply an instance of this class to the [DropDownSearchField.suggestionsBoxDecoration]
/// property to configure the suggestions box decoration
class SuggestionsBoxDecoration {
  /// The z-coordinate at which to place the suggestions box. This controls the size
  /// of the shadow below the box.
  ///
  /// Same as [Material.elevation](https://docs.flutter.io/flutter/material/Material/elevation.html)
  final double elevation;

  /// The color to paint the suggestions box.
  ///
  /// Same as [Material.color](https://docs.flutter.io/flutter/material/Material/color.html)
  final Color? color;

  /// Defines the material's shape as well its shadow.
  ///
  /// Same as [Material.shape](https://docs.flutter.io/flutter/material/Material/shape.html)
  final ShapeBorder? shape;

  /// Defines if a scrollbar will be displayed or not.
  final bool hasScrollbar;

  /// If non-null, the corners of this box are rounded by this [BorderRadius](https://docs.flutter.io/flutter/painting/BorderRadius-class.html).
  ///
  /// Same as [Material.borderRadius](https://docs.flutter.io/flutter/material/Material/borderRadius.html)
  final BorderRadius? borderRadius;

  /// The color to paint the shadow below the material.
  ///
  /// Same as [Material.shadowColor](https://docs.flutter.io/flutter/material/Material/shadowColor.html)
  final Color shadowColor;

  /// The constraints to be applied to the suggestions box
  final BoxConstraints? constraints;

  /// Adds an offset to the suggestions box
  final double offsetX;

  /// The content will be clipped (or not) according to this option.
  ///
  /// Same as [Material.clipBehavior](https://api.flutter.dev/flutter/material/Material/clipBehavior.html)
  final Clip clipBehavior;

  /// If you want to close suggestion box when use tap outside suggestionBox then pass true.
  /// Default is true
  final bool closeSuggestionBoxWhenTapOutside;

  /// The decoration to use for the scrollbar in the suggestions box.
  ///
  /// This can be used to customize the appearance of the scrollbar, such as
  /// its color, thickness, and other visual properties.
  ///
  /// If null, the default scrollbar decoration will be used.
  final ScrollBarDecoration? scrollBarDecoration;

  /// Creates a SuggestionsBoxDecoration
  const SuggestionsBoxDecoration({
    this.elevation = 4.0,
    this.color,
    this.shape,
    this.hasScrollbar = true,
    this.borderRadius,
    this.shadowColor = const Color(0xFF000000),
    this.constraints,
    this.clipBehavior = Clip.none,
    this.offsetX = 0.0,
    this.closeSuggestionBoxWhenTapOutside = true,
    this.scrollBarDecoration,
  });
}
