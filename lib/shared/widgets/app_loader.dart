import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class Loader {
  Loader._();

  static bool _isVisible = false;

  static void show(BuildContext context, {String? message}) {
    if (_isVisible) return;
    _isVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      useRootNavigator: true,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Material(
            color: Colors.transparent,
            child: SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.lightSeed),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    if (!_isVisible) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _isVisible = false;
  }
}
