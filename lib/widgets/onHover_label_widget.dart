import 'package:flutter/material.dart';

class OnTapLabel extends StatelessWidget {
  final String town;
  final double avgPrice;
  final Map<String, dynamic>? extraInfo;

  const OnTapLabel({
    super.key,
    required this.town,
    required this.avgPrice,
    this.extraInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6.0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        maxWidth: 200,
        minWidth: 150,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            town,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Avg Price: \$${avgPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap to close',
            style: TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
