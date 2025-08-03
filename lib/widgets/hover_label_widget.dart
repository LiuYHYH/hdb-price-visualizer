import 'package:flutter/material.dart';

class HoverLabelWidget extends StatelessWidget {
  final Map<String, dynamic> properties;
  final Offset position;

  const HoverLabelWidget({
    super.key,
    required this.properties,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: position.dx + 10,
      top: position.dy + 10,
      child: Card(
        color: Colors.yellow[100],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Town: ${properties['HDB_TOWN'] ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Avg Price: \$${(properties['avg_price'] ?? 0.0).toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}