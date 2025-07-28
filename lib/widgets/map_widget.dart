import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';

class HdbMapWidget extends StatelessWidget {
  final MapController mapController;
  final GeoJsonParser geoJsonParser;

  const HdbMapWidget({
    super.key,
    required this.mapController,
    required this.geoJsonParser,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
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
          polygons: geoJsonParser.polygons,
        ),
        PolylineLayer(
          polylines: geoJsonParser.polylines,
        ),
      ],
    );
  }
}