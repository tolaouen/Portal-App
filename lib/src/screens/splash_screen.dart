import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/tan_meng_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111C4F), Color(0xFF182A69), Color(0xFF22367B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.brand.withValues(alpha: 0.22),
                      AppTheme.brand.withValues(alpha: 0.02),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -90,
              left: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TanMengLogo(compact: true, onDark: true),
                    const SizedBox(height: 34),
                    const Text(
                      'Next Style',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 33,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Style for every you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 56),
                    const SizedBox(
                      height: 46,
                      width: 46,
                      child: CircularProgressIndicator(
                        color: AppTheme.brand,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Loading.....',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.52),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
