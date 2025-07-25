import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hdb_price_visualizer/widgets/legend_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _geoJsonData;
  final MapController _mapController = MapController();

  // Helper to get color based on avg_price
  Color _getPriceColor(double avgPrice) {
    if (avgPrice <= 0.0) {
      return Colors.grey.shade400.withOpacity(0.7);
    } else if (avgPrice < 400000) {
      return const Color(0xFFFFCDD2).withOpacity(0.7);
    } else if (avgPrice < 450000) {
      return const Color(0xFFEF9A9A).withOpacity(0.7);
    } else if (avgPrice < 500000) {
      return const Color(0xFFE57373).withOpacity(0.7);
    } else if (avgPrice < 550000) {
      return const Color(0xFFEF5350).withOpacity(0.7);
    } else if (avgPrice < 600000) {
      return const Color(0xFFF44336).withOpacity(0.7);
    } else if (avgPrice < 650000) {
      return const Color(0xFFD32F2F).withOpacity(0.7);
    } else {
      return const Color(0xFFB71C1C).withOpacity(0.7);
    }
  }
  // Initialize GeoJsonParser with corrected polygonCreationCallback
 final GeoJsonParser _geoJsonParser = GeoJsonParser(
    defaultPolygonBorderColor: Colors.black,
    defaultPolygonBorderStroke: 1.0,
    polygonCreationCallback: (List<LatLng> points, List<List<LatLng>>? holes, Map<String, dynamic> properties) {
      double avgPrice = 0.0;
      if (properties.containsKey('avg_price')) {
        final priceValue = properties['avg_price'];
        if (priceValue is num) {
          avgPrice = priceValue.toDouble();
        } else if (priceValue is String) {
          avgPrice = double.tryParse(priceValue) ?? 0.0;
        }
      }
      // Use the new color scale
      Color fillColor = _MyHomePageState()._getPriceColor(avgPrice);

      return Polygon(
        points: points,
        holePointsList: holes ?? [],
        color: fillColor,
        borderColor: Colors.black,
        borderStrokeWidth: 1.0,
      );
    },
  );


  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      // Load the GeoJSON file from assets
      final String data = await rootBundle.loadString('assets/hdb_price_map_data.geojson');
      setState(() {
        _geoJsonData = data;
        // Parse the GeoJSON data
        _geoJsonParser.parseGeoJson(jsonDecode(data));
      });
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load map data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _geoJsonData == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(1.3521, 103.8198), // Center on Singapore
                    initialZoom: 11.0,
                    minZoom: 10.0,
                    maxZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.hdb_price_visualizer',
                    ),
                    PolygonLayer(
                      polygons: _geoJsonParser.polygons,
                    ),
                    PolylineLayer(
                      polylines: _geoJsonParser.polylines,
                    ),
                  ],
                ),
                const Positioned(
                  top: 10,
                  right: 10,
                  child: LegendWidget(),
                ),
              ],
            ),
    );
  }
}
