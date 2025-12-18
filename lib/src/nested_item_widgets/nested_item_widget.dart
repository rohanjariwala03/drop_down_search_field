import 'package:flutter/material.dart';
import 'package:drop_down_search_field/src/nested_item_widgets/nested_item_model.dart';
import 'package:drop_down_search_field/src/type_def.dart';

/// Widget for rendering individual nested items in the dropdown
class NestedItemWidget<T> extends StatefulWidget {
  final NestedItem<T> item;
  final int depth;
  final NestedItemBuilder<T> itemBuilder;
  final NestedSuggestionSelectionCallback<T>? onSuggestionSelected;
  final NestedSuggestionMultiSelectionCallback<T>? onSuggestionMultiSelected;
  final NestedItemDisabledCallback<T>? itemDisabledCallback;
  final NestedDropdownConfiguration config;
  final bool isMultiSelect;
  final List<NestedItem<T>>? selectedItems;
  final bool Function(NestedItem<T>, NestedItem<T>)? equalityFunction;
  final VoidCallback giveTextFieldFocus;
  final FocusNode focusNode;

  const NestedItemWidget({
    super.key,
    required this.item,
    required this.depth,
    required this.itemBuilder,
    this.onSuggestionSelected,
    this.onSuggestionMultiSelected,
    this.itemDisabledCallback,
    required this.config,
    required this.isMultiSelect,
    this.selectedItems,
    this.equalityFunction,
    required this.giveTextFieldFocus,
    required this.focusNode,
  });

  @override
  State<NestedItemWidget<T>> createState() => _NestedItemWidgetState<T>();
}

class _NestedItemWidgetState<T> extends State<NestedItemWidget<T>> {
  bool get _isDisabled {
    return widget.item.isDisabled ||
        (widget.itemDisabledCallback?.call(widget.item) ?? false);
  }

  bool get _isSelected {
    if (widget.selectedItems == null) return false;

    return widget.selectedItems!.any((item) =>
        widget.equalityFunction?.call(item, widget.item) ??
        item == widget.item);
  }

  bool get _canSelect {
    return widget.item.isSelectable &&
        !_isDisabled &&
        (widget.config.allowParentSelection || widget.item.isLeaf);
  }

  void _handleTap() {
    if (_isDisabled) return;

    // If item has children and we're not in multi-select mode, toggle expansion
    if (widget.item.hasChildren && !widget.isMultiSelect) {
      setState(() {
        widget.item.toggleExpansion();
      });
      return;
    }

    // Handle selection if item can be selected
    if (_canSelect) {
      if (widget.isMultiSelect) {
        widget.onSuggestionMultiSelected?.call(widget.item, !_isSelected);
        setState(() {});
      } else {
        widget.giveTextFieldFocus();
        widget.onSuggestionSelected?.call(widget.item);
      }
    } else if (widget.item.hasChildren) {
      // If can't select but has children, toggle expansion
      setState(() {
        widget.item.toggleExpansion();
      });
    }
  }

  void _handleExpansionToggle() {
    setState(() {
      widget.item.toggleExpansion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildItemRow(),
        if (widget.item.hasChildren && widget.item.isExpanded)
          ...widget.item.children!.map(
            (child) => NestedItemWidget<T>(
              item: child,
              depth: widget.depth + 1,
              itemBuilder: widget.itemBuilder,
              onSuggestionSelected: widget.onSuggestionSelected,
              onSuggestionMultiSelected: widget.onSuggestionMultiSelected,
              itemDisabledCallback: widget.itemDisabledCallback,
              config: widget.config,
              isMultiSelect: widget.isMultiSelect,
              selectedItems: widget.selectedItems,
              equalityFunction: widget.equalityFunction,
              giveTextFieldFocus: widget.giveTextFieldFocus,
              focusNode: FocusNode(),
            ),
          ),
      ],
    );
  }

  Widget _buildItemRow() {
    final indentation = (widget.depth * widget.config.childIndentation)
        .clamp(0.0, 100.0); // Limit max indentation

    return AnimatedContainer(
      duration: widget.config.expansionAnimationDuration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          focusNode: widget.focusNode,
          onTap: _isDisabled ? null : _handleTap,
          focusColor: Theme.of(context).hoverColor,
          child: Padding(
            padding: EdgeInsets.only(left: indentation),
            child: Row(
              children: [
                if (widget.item.hasChildren && widget.config.showExpandIcons)
                  _buildExpandIcon(),
                Expanded(
                  child: widget.isMultiSelect && _canSelect
                      ? _buildCheckboxTile()
                      : _buildRegularTile(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandIcon() {
    final isExpanded = widget.item.isExpanded;
    final icon = isExpanded
        ? (widget.config.collapseIcon ?? Icons.expand_less)
        : (widget.config.expandIcon ?? Icons.expand_more);

    return IconButton(
      onPressed: _isDisabled ? null : _handleExpansionToggle,
      icon: Icon(icon),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
    );
  }

  Widget _buildCheckboxTile() {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets
          .zero, // Remove default padding since we handle it in parent
      title: widget.itemBuilder(context, widget.item, widget.depth),
      value: _isSelected,
      enabled: _canSelect,
      dense: true, // Make it more compact
      onChanged: _canSelect
          ? (bool? checked) {
              widget.onSuggestionMultiSelected
                  ?.call(widget.item, checked ?? false);
              setState(() {});
            }
          : null,
    );
  }

  Widget _buildRegularTile() {
    return Opacity(
      opacity: _isDisabled ? 0.5 : 1.0,
      child: widget.itemBuilder(context, widget.item, widget.depth),
    );
  }
}
