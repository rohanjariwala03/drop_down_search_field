import 'package:flutter/material.dart';

class ChipConfiguration {
  /// The background color of the chip.
  /// This color fills the entire background of the chip.
  final Color? backgroundColor;

  /// The icon used for the delete action.
  /// This icon appears on the chip and allows users to remove the chip when tapped.
  final Icon? deleteIcon;

  /// The text style of the chip's label.
  /// This defines the font, size, color, and other text properties of the chip's label.
  final TextStyle? labelStyle;

  /// The padding around the chip.
  /// This defines the space between the chip's content and its outer edge.
  final EdgeInsets? padding;

  /// Callback when the delete action is triggered.
  /// This function is called when the delete icon is tapped, passing the current list of chip labels.
  final ValueChanged<List<String?>>? onDelete;

  /// The padding around the chip's label.
  /// This defines the space between the label text and the edge of the chip.
  final EdgeInsetsGeometry? labelPadding;

  /// Defines how compact the chip's layout will be.
  /// This affects the overall density of the chip, making it more or less compact.
  final VisualDensity? visualDensity;

  /// Configures the minimum size of the chip's tap target.
  /// This ensures that the chip is easy to tap, even if it is small.
  final MaterialTapTargetSize? materialTapTargetSize;

  /// The elevation of the chip.
  /// This controls the shadow depth of the chip, giving it a raised appearance.
  final double? elevation;

  /// The color of the chip's shadow.
  /// This color is used for the shadow cast by the chip's elevation.
  final Color? shadowColor;

  /// The color used to tint the surface of the chip.
  /// This tint is applied over the chip's background color.
  final Color? surfaceTintColor;

  /// The theme for the chip's icons.
  /// This defines the default properties for any icons used within the chip.
  final IconThemeData? iconTheme;

  /// Constraints for the chip's avatar.
  /// These constraints define the size and layout of the avatar widget within the chip.
  final BoxConstraints? avatarBoxConstraints;

  /// Constraints for the chip's delete icon.
  /// These constraints define the size and layout of the delete icon within the chip.
  final BoxConstraints? deleteIconBoxConstraints;

  /// The animation style for the chip.
  /// This defines how the chip animates during state changes.
  final ChipAnimationStyle? chipAnimationStyle;

  /// The widget to display as the chip's avatar.
  /// This widget appears at the start of the chip, typically as an icon or image.
  final Widget? avatar;

  /// The color of the delete icon.
  /// This color is applied to the delete icon within the chip.
  final Color? deleteIconColor;

  /// The tooltip message for the delete button.
  /// This message is shown when the user hovers over or long-presses the delete icon.
  final String? deleteButtonTooltipMessage;

  /// The border side for the chip.
  /// This defines the color, width, and style of the chip's border.
  final BorderSide? side;

  /// The shape of the chip.
  /// This defines the overall shape and outline of the chip.
  final OutlinedBorder? shape;

  /// The clip behavior for the chip.
  /// This determines how the chip's content is clipped to its shape.
  final Clip clipBehavior;

  /// The color of the chip in different states.
  /// This property allows you to define different colors for the chip based on its state (e.g., selected, disabled).
  final WidgetStateProperty<Color?>? color;

  const ChipConfiguration({
    this.backgroundColor,
    this.deleteIcon,
    this.labelStyle,
    this.padding,
    this.onDelete,
    this.labelPadding,
    this.visualDensity,
    this.materialTapTargetSize,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconTheme,
    this.avatarBoxConstraints,
    this.deleteIconBoxConstraints,
    this.chipAnimationStyle,
    this.avatar,
    this.deleteIconColor,
    this.deleteButtonTooltipMessage,
    this.side,
    this.shape,
    this.clipBehavior = Clip.none,
    this.color,
  });

  /// Creates a copy of this configuration but with the given fields replaced with the new values.
  ChipConfiguration copyWith({
    Color? backgroundColor,
    Icon? deleteIcon,
    TextStyle? labelStyle,
    EdgeInsets? padding,
    ValueChanged<List<String?>>? onDelete,
    EdgeInsetsGeometry? labelPadding,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? materialTapTargetSize,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    IconThemeData? iconTheme,
    BoxConstraints? avatarBoxConstraints,
    BoxConstraints? deleteIconBoxConstraints,
    ChipAnimationStyle? chipAnimationStyle,
    Widget? avatar,
    Color? deleteIconColor,
    String? deleteButtonTooltipMessage,
    BorderSide? side,
    OutlinedBorder? shape,
    Clip? clipBehavior,
    WidgetStateProperty<Color?>? color,
  }) {
    return ChipConfiguration(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      deleteIcon: deleteIcon ?? this.deleteIcon,
      labelStyle: labelStyle ?? this.labelStyle,
      padding: padding ?? this.padding,
      onDelete: onDelete ?? this.onDelete,
      labelPadding: labelPadding ?? this.labelPadding,
      visualDensity: visualDensity ?? this.visualDensity,
      materialTapTargetSize:
          materialTapTargetSize ?? this.materialTapTargetSize,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      iconTheme: iconTheme ?? this.iconTheme,
      avatarBoxConstraints: avatarBoxConstraints ?? this.avatarBoxConstraints,
      deleteIconBoxConstraints:
          deleteIconBoxConstraints ?? this.deleteIconBoxConstraints,
      chipAnimationStyle: chipAnimationStyle ?? this.chipAnimationStyle,
      avatar: avatar ?? this.avatar,
      deleteIconColor: deleteIconColor ?? this.deleteIconColor,
      deleteButtonTooltipMessage:
          deleteButtonTooltipMessage ?? this.deleteButtonTooltipMessage,
      side: side ?? this.side,
      shape: shape ?? this.shape,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      color: color ?? this.color,
    );
  }
}
