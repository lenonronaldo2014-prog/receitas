import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Margem lateral padrão das telas.
  static const double screen = 20;

  static const screenPadding = EdgeInsets.symmetric(horizontal: screen);
}

abstract final class AppRadius {
  static const double card = 16;
  static const double field = 12;
  static const double button = 14;
  static const double chip = 20;

  static final cardAll = BorderRadius.circular(card);
  static final fieldAll = BorderRadius.circular(field);
  static final buttonAll = BorderRadius.circular(button);
  static final chipAll = BorderRadius.circular(chip);
}
