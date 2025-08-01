import 'package:flutter/gestures.dart' show PointerExitEvent, PointerHoverEvent;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'dart:async';

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
  Timer? _hoverTimer;
  Offset? _lastHoverPosition;

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (PointerHoverEvent event) {
        _handleHover(event.localPosition);
      },
      onExit: (PointerExitEvent event) {
        _cancelHover();
      },
      child: FlutterMap(
        mapController: widget.mapController,
        options: MapOptions(
          initialCenter: const LatLng(1.3521, 103.8198),
          initialZoom: 11.0,
          minZoom: 10.0,
          maxZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.hdb_price_visualizer',
          ),
          PolygonLayer(
            polygons: widget.geoJsonParser.polygons,
          ),
          PolylineLayer(
            polylines: widget.geoJsonParser.polylines,
          ),
        ],
      ),
    );
  }

  void _handleHover(Offset position) {
    _lastHoverPosition = position;
    
    // Cancel existing timer
    _hoverTimer?.cancel();
    
    // Start new timer for 1 second
    _hoverTimer = Timer(const Duration(seconds: 1), () {
      _checkPolygonHover(position);
    });
  }

  void _cancelHover() {
    _hoverTimer?.cancel();
    if (widget.onPolygonHover != null) {
      widget.onPolygonHover!({}, const Offset(-1000, -1000));
    }
  }

  void _checkPolygonHover(Offset position) {
    if (widget.onPolygonHover != null) {
      // Convert screen coordinates to LatLng
      final latLng = widget.mapController.camera.pointToLatLng(
        math.Point(position.dx, position.dy)
      );
      
      // Check if hover is over any polygon
      for (int i = 0; i < widget.geoJsonParser.polygons.length; i++) {
        final polygon = widget.geoJsonParser.polygons[i];
        if (_isPointInPolygon(latLng, polygon.points)) {
          // Calculate label position with boundary checking
          final screenSize = MediaQuery.of(context).size;
          double adjustedX = position.dx;
          double adjustedY = position.dy;
          
          if (adjustedX > screenSize.width - 200) {
            adjustedX = screenSize.width - 200;
          }
          if (adjustedY < 100) {
            adjustedY = adjustedY + 100;
          }
          
          // Get properties using index
          Map<String, dynamic> properties = {};
          if (i < widget.polygonProperties.length) {
            properties = widget.polygonProperties[i];
          }
          
          widget.onPolygonHover!(properties, Offset(adjustedX, adjustedY));
          return;
        }
      }
      
      // No polygon found, hide label
      widget.onPolygonHover!({}, const Offset(-1000, -1000));
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0, i = 1; i < polygon.length; j = i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) + polygon[i].longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }
}
