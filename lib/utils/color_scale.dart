import 'package:flutter/material.dart';

List<double> computeBands(List<double> prices, int bands) {
  if (prices.isEmpty) return List.filled(bands + 1, 0.0);
  double min = prices.reduce((a, b) => a < b ? a : b);
  double max = prices.reduce((a, b) => a > b ? a : b);
  if (min == max) return List.generate(bands + 1, (i) => min); // all same
  double step = (max - min) / bands;
  return List.generate(bands + 1, (i) => min + i * step);
}

Color getAutoScaledColor(double avgPrice, List<double> bands, List<Color> colors) {
  for (int i = 0; i < bands.length - 1; i++) {
    if (avgPrice <= bands[i + 1]) return colors[i];
  }
  return colors.last;
}

List<double> computeFriendlyBands(double min, double max, int bands) {
  // Choose a step size (e.g., 50,000 or 100,000) based on the range
  double range = max - min;
  double step;
  if (range > 400000) {
    step = 100000;
  } else if (range > 200000) {
    step = 50000;
  } else {
    step = 25000;
  }
  double start = (min / step).floor() * step;
  List<double> result = [];
  for (int i = 0; i <= bands; i++) {
    result.add(start + i * step);
  }
  // Ensure last band covers max
  if (result.last < max) result[result.length - 1] = max;
  return result;
}