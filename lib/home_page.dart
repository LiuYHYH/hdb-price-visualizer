import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hdb_price_visualizer/widgets/legend_widget.dart';
import 'package:hdb_price_visualizer/widgets/map_widget.dart';
import 'package:hdb_price_visualizer/widgets/flat_type_dropdown.dart';
import 'package:hdb_price_visualizer/utils/color_scale.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _geoJsonData;
  final MapController _mapController = MapController();
  String selectedFlatType = '2 ROOM';
  final List<String> flatTypes = [
    '2 ROOM', '3 ROOM', '4 ROOM', '5 ROOM', 'EXECUTIVE'
  ];

  List<double> _bands = [];
  final List<Color> _bandColors = [
    Color(0xFFFFCDD2),
    Color(0xFFEF9A9A),
    Color(0xFFE57373),
    Color(0xFFD32F2F),
    Color(0xFFB71C1C),
  ];


  late final GeoJsonParser _geoJsonParser;

  List<Map<String, dynamic>> _polygonProperties = [];

  @override
  void initState() {
    super.initState();
    _geoJsonParser = GeoJsonParser(
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
        Color fillColor = avgPrice > 0.0
            ? getAutoScaledColor(avgPrice, _bands, _bandColors).withOpacity(0.5)
            : Colors.grey.shade400.withOpacity(0.3);

        return Polygon(
          points: points,
          holePointsList: holes ?? [],
          color: fillColor,
          borderColor: Colors.black,
          borderStrokeWidth: 1.0,
        );
      },
    );
    _loadGeoJson();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      String fileName = 'assets/hdb_price_map_${selectedFlatType.replaceAll(' ', '_').toLowerCase()}.geojson';
      final String data = await rootBundle.loadString(fileName);
      final geoJson = jsonDecode(data);

      setState(() {
        _geoJsonData = data;
        _geoJsonParser.polygons.clear();
        _geoJsonParser.polylines.clear();
        _geoJsonParser.parseGeoJson(geoJson);

        // Extract properties from features
        _polygonProperties = (geoJson['features'] as List)
            .map((f) => f['properties'] as Map<String, dynamic>)
            .toList();

        // Now extract avg_price from properties
        final prices = _polygonProperties
            .map((p) => p['avg_price'])
            .where((v) => v != null && v is num && v > 0)
            .map((v) => (v as num).toDouble())
            .toList();

        _bands = computeBands(prices, _bandColors.length);
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
                HdbMapWidget(
                  mapController: _mapController,
                  geoJsonParser: _geoJsonParser,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: LegendWidget(
                    bands: _bands,
                    colors: _bandColors,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: FlatTypeDropdown(
                    selectedFlatType: selectedFlatType,
                    flatTypes: flatTypes,
                    onChanged: (type) {
                      setState(() {
                        selectedFlatType = type;
                      });
                      _loadGeoJson();
                      _loadGeoJson();
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
