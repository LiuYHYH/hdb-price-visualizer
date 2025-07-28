import 'package:flutter/material.dart';

class FlatTypeDropdown extends StatelessWidget {
  final String selectedFlatType;
  final List<String> flatTypes;
  final ValueChanged<String> onChanged;

  const FlatTypeDropdown({
    super.key,
    required this.selectedFlatType,
    required this.flatTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedFlatType,
        items: flatTypes
            .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        onChanged: (type) {
          if (type != null) {
            onChanged(type);
          }
        },
        underline: Container(),
        style: const TextStyle(fontSize: 14, color: Colors.black),
        dropdownColor: Colors.white,
      ),
    );
  }
}