import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TanMengLogo extends StatelessWidget {
  const TanMengLogo({super.key, this.compact = false, this.onDark = false});

  final bool compact;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final textColor = onDark ? Colors.white : Colors.black;
    final accent = AppTheme.royalBlue;
    final markSize = compact ? 92.0 : 134.0;
    final khmerSize = compact ? 22.0 : 32.0;
    final titleSize = compact ? 34.0 : 52.0;
    final footerSize = compact ? 22.0 : 34.0;
    final logoWidth = compact ? 320.0 : 470.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : logoWidth;
        final scale = maxWidth < logoWidth ? maxWidth / logoWidth : 1.0;

        return Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: logoWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _TmMark(size: markSize),
                      SizedBox(width: compact ? 10 : 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: compact ? 2 : 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'តាន់ ម៉េង',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: khmerSize,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'TAN MENG',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'serif',
                                  letterSpacing: compact ? 1.1 : 1.5,
                                  height: 0.95,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Container(
                    width: logoWidth,
                    height: compact ? 2.5 : 3.5,
                    color: textColor,
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    'CONSTRUCTION TOOLS',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: footerSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: compact ? 0.4 : 0.8,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TmMark extends StatelessWidget {
  const _TmMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _TmMarkPainter());
  }
}

class _TmMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF2357D6), Color(0xFF163EAE), Color(0xFF0D2F8F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    final black = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1D1D1D), Color(0xFF080808)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final white = Paint()..color = Colors.white;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.03),
    );
    canvas.drawRRect(outer, blue);

    final topBarHeight = size.height * 0.23;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, topBarHeight), blue);

    final stemX = size.width * 0.41;
    final stemWidth = size.width * 0.18;
    canvas.drawRect(
      Rect.fromLTWH(stemX, topBarHeight * 0.1, stemWidth, size.height),
      blue,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, topBarHeight, size.width, size.height * 0.035),
      white,
    );

    final leftPath = Path()
      ..moveTo(size.width * 0.03, topBarHeight + size.height * 0.02)
      ..lineTo(size.width * 0.30, topBarHeight + size.height * 0.02)
      ..lineTo(size.width * 0.39, size.height * 0.53)
      ..lineTo(size.width * 0.33, size.height * 0.60)
      ..lineTo(size.width * 0.33, size.height * 0.93)
      ..lineTo(size.width * 0.12, size.height * 0.93)
      ..lineTo(size.width * 0.12, size.height * 0.70)
      ..lineTo(size.width * 0.05, size.height * 0.64)
      ..lineTo(size.width * 0.05, size.height * 0.42)
      ..lineTo(size.width * 0.00, size.height * 0.36)
      ..close();
    canvas.drawPath(leftPath, black);

    final rightPath = Path()
      ..moveTo(size.width * 0.70, topBarHeight + size.height * 0.02)
      ..lineTo(size.width * 0.97, topBarHeight + size.height * 0.02)
      ..lineTo(size.width * 1.00, size.height * 0.36)
      ..lineTo(size.width * 0.95, size.height * 0.42)
      ..lineTo(size.width * 0.95, size.height * 0.64)
      ..lineTo(size.width * 0.88, size.height * 0.70)
      ..lineTo(size.width * 0.88, size.height * 0.93)
      ..lineTo(size.width * 0.67, size.height * 0.93)
      ..lineTo(size.width * 0.67, size.height * 0.60)
      ..lineTo(size.width * 0.61, size.height * 0.53)
      ..lineTo(size.width * 0.70, topBarHeight + size.height * 0.02)
      ..close();
    canvas.drawPath(rightPath, black);

    final stroke = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.04,
          size.height * 0.04,
          size.width * 0.92,
          size.height * 0.90,
        ),
        Radius.circular(size.width * 0.02),
      ),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
