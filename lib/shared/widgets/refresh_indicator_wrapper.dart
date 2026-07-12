import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RefreshIndicatorWrapper extends StatelessWidget {
  const RefreshIndicatorWrapper({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.colorPrimary600,
      backgroundColor: AppColors.colorWhite,
      elevation: 3,
      strokeWidth: 2,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
