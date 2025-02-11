import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class MultiSelectDropdownDisplayWidget<T> extends StatefulWidget {
  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the DropDownSearchField widget displays
  final TextFieldConfiguration textFieldConfiguration;

  /// The selected items in the dropdown when it is a multi-select dropdown
  ///
  /// This property is used to display the selected items in the dropdown
  final List<T> initiallySelectedItems;

  /// The focus node for the text field
  ///
  /// This is used to control the focus of the text field
  final FocusNode? focusNode;

  /// The configuration for the dropdown box
  ///
  /// This property allows you to customize the appearance and behavior of the dropdown box
  final DropdownBoxConfiguration dropdownBoxConfiguration;

  /// validator for the dropdown
  ///
  /// This property allows you to validate the dropdown
  // final FormFieldValidator<List<T>>? validator;

  const MultiSelectDropdownDisplayWidget(
      {required this.initiallySelectedItems,
      required this.textFieldConfiguration,
      required this.focusNode,
      this.dropdownBoxConfiguration = const DropdownBoxConfiguration(),
      // this.validator,
      super.key});

  @override
  State<MultiSelectDropdownDisplayWidget<T>> createState() =>
      _MultiSelectDropdownDisplayWidgetState<T>();
}

class _MultiSelectDropdownDisplayWidgetState<T>
    extends State<MultiSelectDropdownDisplayWidget<T>> {
  final ScrollController _scrollController = ScrollController();
  // String? errorText;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((duration) {
  //     if (widget.validator != null) {
  //     errorText = widget.validator!(widget.initiallySelectedItems);
  //   }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.dropdownBoxConfiguration.enabled,
      child: InkWell(
        onTap: () {
          if (!widget.focusNode!.hasFocus) {
            FocusScope.of(context).requestFocus(widget.focusNode);
          }
          widget.dropdownBoxConfiguration.onTap?.call();
        },
        child: Focus(
          focusNode: widget.focusNode,
          child: SizedBox(
            width: double.infinity,
            child: (widget.dropdownBoxConfiguration.scrollbarConfiguration
                        ?.neverDisplayScrollbar ??
                    false)
                ? _buildWidget()
                : RawScrollbar(
                    controller: _scrollController,
                    thickness: widget.dropdownBoxConfiguration
                            .scrollbarConfiguration?.thickness ??
                        8,
                    thumbVisibility: widget.dropdownBoxConfiguration
                        .scrollbarConfiguration?.isAlwaysShown,
                    radius: widget.dropdownBoxConfiguration
                        .scrollbarConfiguration?.radius,
                    thumbColor: widget.dropdownBoxConfiguration
                        .scrollbarConfiguration?.thumbColor,
                    trackColor: widget.dropdownBoxConfiguration
                        .scrollbarConfiguration?.trackColor,
                    trackBorderColor: widget.dropdownBoxConfiguration
                        .scrollbarConfiguration?.trackBorderColor,
                    child: _buildWidget(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidget() {
    final dropdownBoxConfiguration = widget.dropdownBoxConfiguration.copyWith(
      decoration: widget.dropdownBoxConfiguration.decoration.copyWith(
        suffixIcon: widget.dropdownBoxConfiguration.decoration.suffixIcon ??
            const Icon(Icons.arrow_drop_down),
        // errorText: errorText,
        // errorBorder: errorText != null
        //     ? widget.dropdownBoxConfiguration.decoration.errorBorder ??
        //         const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))
        //     : null,
        // focusedErrorBorder: errorText != null
        //     ? widget.dropdownBoxConfiguration.decoration.focusedErrorBorder ??
        //         const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red))
        //     : null,
      ),
    );
    return InputDecorator(
      decoration: dropdownBoxConfiguration.decoration,
      child: Align(
        alignment: widget.dropdownBoxConfiguration.chipsAlign,
        child: widget.initiallySelectedItems.isEmpty
            ? (Text(
                dropdownBoxConfiguration.decoration.hintText ?? '',
                style: dropdownBoxConfiguration.decoration.hintStyle,
              ))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.initiallySelectedItems.map((item) {
                      return Chip(
                        label: Text(
                          item.toString(),
                          style: widget.dropdownBoxConfiguration
                              .chipConfiguration.labelStyle,
                        ),
                        labelStyle: widget.dropdownBoxConfiguration
                            .chipConfiguration.labelStyle,
                        padding: widget.dropdownBoxConfiguration
                                .chipConfiguration.padding ??
                            EdgeInsets.zero,
                        onDeleted: () {
                          setState(() {
                            widget.initiallySelectedItems.remove(item);
                          });
                          widget.dropdownBoxConfiguration.onChanged?.call(
                            widget.initiallySelectedItems
                                .map((e) => e.toString())
                                .toList(),
                          );
                          widget.dropdownBoxConfiguration.chipConfiguration
                              .onDelete
                              ?.call(
                            widget.initiallySelectedItems
                                .map((e) => e.toString())
                                .toList(),
                          );
                        },
                        deleteIcon: widget.dropdownBoxConfiguration
                            .chipConfiguration.deleteIcon,
                        backgroundColor: widget.dropdownBoxConfiguration
                            .chipConfiguration.backgroundColor,
                        elevation: widget.dropdownBoxConfiguration
                            .chipConfiguration.elevation,
                        shadowColor: widget.dropdownBoxConfiguration
                            .chipConfiguration.shadowColor,
                        surfaceTintColor: widget.dropdownBoxConfiguration
                            .chipConfiguration.surfaceTintColor,
                        visualDensity: widget.dropdownBoxConfiguration
                            .chipConfiguration.visualDensity,
                        materialTapTargetSize: widget.dropdownBoxConfiguration
                            .chipConfiguration.materialTapTargetSize,
                        labelPadding: widget.dropdownBoxConfiguration
                            .chipConfiguration.labelPadding,
                        avatar: widget
                            .dropdownBoxConfiguration.chipConfiguration.avatar,
                        clipBehavior: widget.dropdownBoxConfiguration
                            .chipConfiguration.clipBehavior,
                        side: widget
                            .dropdownBoxConfiguration.chipConfiguration.side,
                        shape: widget
                            .dropdownBoxConfiguration.chipConfiguration.shape,
                        iconTheme: widget.dropdownBoxConfiguration
                            .chipConfiguration.iconTheme,
                        avatarBoxConstraints: widget.dropdownBoxConfiguration
                            .chipConfiguration.avatarBoxConstraints,
                        deleteIconBoxConstraints: widget
                            .dropdownBoxConfiguration
                            .chipConfiguration
                            .deleteIconBoxConstraints,
                        deleteIconColor: widget.dropdownBoxConfiguration
                            .chipConfiguration.deleteIconColor,
                        deleteButtonTooltipMessage: widget
                            .dropdownBoxConfiguration
                            .chipConfiguration
                            .deleteButtonTooltipMessage,
                        chipAnimationStyle: widget.dropdownBoxConfiguration
                            .chipConfiguration.chipAnimationStyle,
                        color: widget
                            .dropdownBoxConfiguration.chipConfiguration.color,
                      );
                    }).toList(),
                  ),
                ),
              ),
      ),
    );
  }
}
