import 'dart:math' show Point;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:hdb_price_visualizer/utils/property_polygon.dart';
import 'package:latlong2/latlong.dart';

class HdbMapWidget extends StatefulWidget {
  final MapController mapController;
  final GeoJsonParser geoJsonParser;
  final List<Map<String, dynamic>> polygonProperties;
  final void Function(Map<String, dynamic> properties, Offset hoverPosition)? onPolygonHover;

  const HdbMapWidget({
    super.key,
    required this.mapController,
    required this.geoJsonParser,
    required this.polygonProperties,
    this.onPolygonHover,
  });

  @override
  State<HdbMapWidget> createState() => _HdbMapWidgetState();
}


class _HdbMapWidgetState extends State<HdbMapWidget> {
  int? _hoveredPolygonIndex;
  Timer? _hoverTimer;
  Offset? _lastHoverPosition;
  String? _lastHoverTown;

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.isEmpty) return false;
    bool isInside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) + polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }
    return isInside;
  }

  void _handleHover(Offset localPosition) {
    try {
      final camera = widget.mapController.camera;
      final screenPoint = Point<double>(localPosition.dx, localPosition.dy);
      final pointLatLng = camera.pointToLatLng(screenPoint);

      if (pointLatLng == null) return;

      List<int> hitPolygonIndices = [];
      for (int i = 0; i < widget.geoJsonParser.polygons.length; i++) {
        if (_isPointInPolygon(pointLatLng, widget.geoJsonParser.polygons[i].points)) {
          hitPolygonIndices.add(i);
        }
      }

      int? hoveredIndex;
      if (hitPolygonIndices.isNotEmpty) {
        hoveredIndex = hitPolygonIndices.reduce((a, b) {
          double areaA = _polygonArea(widget.geoJsonParser.polygons[a].points);
          double areaB = _polygonArea(widget.geoJsonParser.polygons[b].points);
          return areaA < areaB ? a : b;
        });
        final poly = widget.geoJsonParser.polygons[hoveredIndex];
        if (poly is PropertyPolygon) {
          final props = poly.properties;
          debugPrint('Hover hit polygons: $hitPolygonIndices, chosen: $hoveredIndex, town: ${props['HDB_TOWN']}');
          _hoverTimer?.cancel();
          _lastHoverPosition = localPosition;
          _hoverTimer = Timer(const Duration(seconds: 1), () {
            if (mounted && _hoveredPolygonIndex == hoveredIndex && _lastHoverPosition == localPosition) {
              widget.onPolygonHover?.call(props, localPosition);
            }
          });
          setState(() {
            _hoveredPolygonIndex = hoveredIndex;
          });
        }
      } else {
        widget.onPolygonHover?.call({}, Offset.zero);
        setState(() {
          _hoveredPolygonIndex = null;
        });
      }
    } catch (e) {
      debugPrint('Error in _handleHover: $e');
    }
  }

  double _polygonArea(List<LatLng> points) {
    double area = 0.0;
    for (int i = 0, j = points.length - 1; i < points.length; j = i++) {
      area += (points[j].longitude + points[i].longitude) *
              (points[j].latitude - points[i].latitude);
    }
    return area.abs();
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _handleHover(event.localPosition),
      onExit: (_) {
        _hoverTimer?.cancel();
        setState(() {
          _hoveredPolygonIndex = null;
        });
        widget.onPolygonHover?.call({}, Offset.zero);
      },
      child: FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
          initialCenter: const LatLng(1.3521, 103.8198),
          initialZoom: 11.0,
          minZoom: 10.0,
          maxZoom: 15.0,
          interactionOptions: const InteractionOptions(),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.hdb_price_visualizer',
            maxZoom: 19,
          ),
          PolygonLayer(
            polygons: widget.geoJsonParser.polygons,
          ),
        ],
      ),
    );
  }
}
