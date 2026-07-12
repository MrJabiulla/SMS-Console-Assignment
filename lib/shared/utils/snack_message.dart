import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/text_styles.dart';

void makeSnack(
  BuildContext context,
  String message, {
  int duration = 3,
  bool isError = false,
  bool isSuccess = false,
}) {
  final backgroundColor = isError
      ? AppColors.colorError
      : isSuccess
      ? AppColors.colorSuccess
      : AppColors.colorBlack;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: styleRegular14(color: AppColors.colorWhite),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1.0),
          curve: Curves.easeInOut,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
}
