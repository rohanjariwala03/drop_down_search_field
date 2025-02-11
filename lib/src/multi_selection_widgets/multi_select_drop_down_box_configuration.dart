import 'package:drop_down_search_field/src/multi_selection_widgets/scrollbar_configuration.dart';
import 'package:flutter/material.dart';

export 'package:drop_down_search_field/src/multi_selection_widgets/scrollbar_configuration.dart';

/// Supply an instance of this class to the [DropDownSearchField.DropdownBoxConfiguration]
/// property to configure the displayed box
class DropdownBoxConfiguration {
  /// The decoration to show around the box.
  ///
  /// This property allows you to customize the appearance of the box.
  final InputDecoration decoration;

  /// How the text being edited should be aligned horizontally.
  ///
  /// This property allows you to customize the alignment of the box.
  final Alignment chipsAlign;

  /// If false the textfield is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// This property allows you to enable or disable the box.
  final bool enabled;

  /// Called when the text being edited changes.
  ///
  /// This property allows you to listen to changes in the box.
  final ValueChanged<List<String?>>? onChanged;

  /// Called for each distinct tap except for every second tap of a double tap.
  ///
  /// This property allows you to listen to taps on the box.
  final GestureTapCallback? onTap;

  /// Called for each tap that occurs outside of theTextFieldTapRegion group when the box is focused.
  ///
  /// This property allows you to listen to taps outside the box.
  final TapRegionCallback? onTapOutside;

  /// Configures padding to edges surrounding a Scrollable when the Textfield scrolls into view.
  ///
  /// This property allows you to customize the padding around the box.
  final EdgeInsets scrollPadding;

  /// The configuration for the scrollbar displayed in the dropdown box.
  ///
  /// This property allows you to customize the appearance and behavior of the scrollbar.
  final ScrollbarConfiguration? scrollbarConfiguration;

  /// Creates a DropdownBoxConfiguration
  const DropdownBoxConfiguration({
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.enabled = true,
    this.chipsAlign = Alignment.centerLeft,
    this.onTap,
    this.onTapOutside,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.scrollbarConfiguration,
  });

  /// Creates a copy of this configuration but with the given fields replaced with the new values.
  DropdownBoxConfiguration copyWith({
    InputDecoration? decoration,
    ValueChanged<List<String?>>? onChanged,
    bool? enabled,
    Alignment? chipsAlign,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    EdgeInsets? scrollPadding,
    ScrollbarConfiguration? scrollbarConfiguration,
  }) {
    return DropdownBoxConfiguration(
      decoration: decoration ?? this.decoration,
      onChanged: onChanged ?? this.onChanged,
      enabled: enabled ?? this.enabled,
      chipsAlign: chipsAlign ?? this.chipsAlign,
      onTap: onTap ?? this.onTap,
      onTapOutside: onTapOutside ?? this.onTapOutside,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      scrollbarConfiguration:
          scrollbarConfiguration ?? this.scrollbarConfiguration,
    );
  }
}
