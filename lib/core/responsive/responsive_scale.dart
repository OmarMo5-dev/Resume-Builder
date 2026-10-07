import 'package:flutter/widgets.dart';

double responsiveScale(
    BuildContext context, {
      required double base,
      double minScale = 0.9,
      double maxScale = 1.15,
    }) {
  final width = MediaQuery.sizeOf(context).width;

  final scale = width / 390;

  final boundedScale = scale.clamp(
    minScale,
    maxScale,
  );

  return base * boundedScale;
}