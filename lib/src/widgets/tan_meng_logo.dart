import 'package:flutter/material.dart';

class TanMengLogo extends StatelessWidget {
  const TanMengLogo({super.key, this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 240.0 : 360.0;

    return Opacity(
      opacity: onDark ? 0.96 : 1,
      child: Image.asset(
        'assets/icons/next_style_logo.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
