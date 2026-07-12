import 'package:flutter/material.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({required this.form, required this.content, super.key});

  final Widget form;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 380, child: form),
              const SizedBox(width: 24),
              Expanded(child: content),
            ],
          );
        }

        return ListView(
          children: [
            form,
            const SizedBox(height: 20),
            SizedBox(height: 520, child: content),
          ],
        );
      },
    );
  }
}
