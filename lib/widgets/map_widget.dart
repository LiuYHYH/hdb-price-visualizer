import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
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
      final screenPoint = Point<double>(
        localPosition.dx,
        localPosition.dy,
      );
      
      final pointLatLng = camera.pointToLatLng(screenPoint);
      if (pointLatLng == null) return;

      // Find which polygon contains this point
      int? hoveredIndex;
      for (int i = 0; i < widget.geoJsonParser.polygons.length; i++) {
        if (_isPointInPolygon(pointLatLng, widget.geoJsonParser.polygons[i].points)) {
          hoveredIndex = i;
          break;
        }
      }

      if (hoveredIndex != _hoveredPolygonIndex) {
        setState(() {
          _hoveredPolygonIndex = hoveredIndex;
        });

        if (hoveredIndex != null && hoveredIndex < widget.polygonProperties.length) {
          widget.onPolygonHover?.call(
            widget.polygonProperties[hoveredIndex],
            localPosition,
          );
        } else {
          widget.onPolygonHover?.call({}, Offset.zero);
        }
      }
    } catch (e) {
      debugPrint('Error in _handleHover: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _handleHover(event.localPosition),
      onExit: (_) {
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
