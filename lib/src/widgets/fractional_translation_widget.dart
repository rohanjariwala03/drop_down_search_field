import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A safe wrapper around FractionalTranslation that prevents hit testing
/// when the widget needs layout, avoiding the debugNeedsLayout assertion error
class SafeFractionalTranslation extends SingleChildRenderObjectWidget {
  const SafeFractionalTranslation({
    super.key,
    required this.translation,
    super.child,
  });

  final Offset translation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSafeFractionalTranslation(translation: translation);
  }

  @override
  void updateRenderObject(
      BuildContext context,
      // ignore: library_private_types_in_public_api
      covariant _RenderSafeFractionalTranslation renderObject) {
    renderObject.translation = translation;
  }
}

class _RenderSafeFractionalTranslation extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _RenderSafeFractionalTranslation({
    required Offset translation,
    RenderBox? child,
  }) : _translation = translation {
    this.child = child;
  }

  Offset _translation;
  Offset get translation => _translation;
  set translation(Offset value) {
    if (_translation == value) return;
    _translation = value;
    markNeedsLayout();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // If we need layout, don't participate in hit testing
    if (debugNeedsLayout) {
      return false;
    }
    return super.hitTest(result, position: position);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // If we need layout, don't allow children to participate in hit testing
    if (debugNeedsLayout) {
      return false;
    }

    final RenderBox? child = this.child;
    if (child == null) return false;

    final Offset childPosition = position - _translation;
    return result.addWithPaintOffset(
      offset: _translation,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return child.hitTest(result, position: childPosition);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final RenderBox? child = this.child;
    if (child != null) {
      context.paintChild(child, offset + _translation);
    }
  }

  @override
  void performLayout() {
    final RenderBox? child = this.child;
    if (child != null) {
      child.layout(constraints, parentUsesSize: true);
      size = child.size;
    } else {
      size = constraints.smallest;
    }
  }
}
