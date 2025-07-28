import 'package:flutter/material.dart';

class LegendWidget extends StatelessWidget {
  final List<double> bands;
  final List<Color> colors;

  const LegendWidget({super.key, required this.bands, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: List.generate(bands.length - 1, (i) {
            return Row(
              children: [
                Container(
                  width: 24,
                  height: 16,
                  color: colors[i],
                ),
                const SizedBox(width: 8),
                Text(
                  i == 0
                    ? 'Below ${bands[i + 1].toStringAsFixed(0)}'
                    : i == bands.length - 2
                      ? 'Above ${bands[i].toStringAsFixed(0)}'
                      : '${bands[i].toStringAsFixed(0)} - ${bands[i + 1].toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
