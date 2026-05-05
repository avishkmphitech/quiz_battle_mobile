import 'package:flutter/material.dart';
import 'package:quiz_battle/core/constants/app_assets.dart';

/// Brand mark from `assets/branding/app_logo.png` (matches design palette).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 200,
    this.semanticLabel = 'Quiz Battle App logo',
  });

  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Image.asset(
        AppAssets.appLogo,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
