import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef ResponsivePageBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    required this.compactBuilder,
    required this.expandedBuilder,
    this.breakpoint = 900,
    this.maxContentWidth = 1180,
    this.compactPadding = const EdgeInsets.all(16),
    this.expandedPadding = const EdgeInsets.all(24),
    super.key,
  });

  final ResponsivePageBuilder compactBuilder;
  final ResponsivePageBuilder expandedBuilder;
  final double breakpoint;
  final double maxContentWidth;
  final EdgeInsets compactPadding;
  final EdgeInsets expandedPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= breakpoint;
        final padding = isExpanded ? expandedPadding : compactPadding;
        final contentHeight = constraints.hasBoundedHeight
            ? math.max(0, constraints.maxHeight - padding.vertical).toDouble()
            : null;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Padding(
              padding: padding,
              child: SizedBox(
                width: double.infinity,
                height: contentHeight,
                child: isExpanded
                    ? expandedBuilder(context, constraints)
                    : compactBuilder(context, constraints),
              ),
            ),
          ),
        );
      },
    );
  }
}
