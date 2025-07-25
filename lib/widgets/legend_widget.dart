import 'package:flutter/material.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HDB Price Legend', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          // Gradient bar
          Container(
            width: 220,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black26),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFFCDD2), // light red
                  Color(0xFFEF9A9A),
                  Color(0xFFE57373),
                  Color(0xFFEF5350),
                  Color(0xFFF44336),
                  Color(0xFFD32F2F),
                  Color(0xFFB71C1C), // darkest red
                ],
                stops: [0.0, 0.17, 0.34, 0.51, 0.68, 0.85, 1.0],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Scale labels
          SizedBox(
            width: 220,
            child: Row(
              children: const [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('< \$400K', style: TextStyle(fontSize: 10)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('\$500K', style: TextStyle(fontSize: 10)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('\$600K', style: TextStyle(fontSize: 10)),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('\$700K+', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 18,
                height: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              const Text('No Data', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
