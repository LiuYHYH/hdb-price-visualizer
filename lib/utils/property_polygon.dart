import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class PropertyPolygon extends Polygon {
  final Map<String, dynamic> properties;

  PropertyPolygon({
    required List<LatLng> points,
    List<List<LatLng>>? holePointsList,
    required this.properties,
    Color borderColor = const Color(0xFF000000),
    Color color = const Color(0x10000000),
    bool isFilled = true,
    double borderStrokeWidth = 1.0,
  }) : super(
          points: points,
          holePointsList: holePointsList,
          borderColor: borderColor,
          color: color,
          isFilled: isFilled,
          borderStrokeWidth: borderStrokeWidth,
        );
}