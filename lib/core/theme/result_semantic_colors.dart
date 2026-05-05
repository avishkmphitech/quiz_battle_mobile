import 'package:flutter/material.dart';

/// Result-only semantics (green = correct, red = wrong). Not used for general UI chrome.
abstract final class ResultSemanticColors {
  static const Color correct = Color(0xFF22C55E);
  static const Color wrong = Color(0xFFEF4444);
  static const Color correctMuted = Color(0xFF166534);
  static const Color wrongMuted = Color(0xFFB91C1C);
}
