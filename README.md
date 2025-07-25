# HDB Price Visualizer

A Flutter-based interactive map application for visualizing HDB resale flat prices across Singapore’s towns and planning areas.

## Overview

This project helps users explore the spatial distribution of HDB resale prices using a color-coded map. It combines data processing (Java), geospatial mapping (GeoJSON), and a modern Flutter UI for an intuitive, informative experience.

**Key Features:**
- Interactive map of Singapore with color-coded polygons for each HDB town/planning area.
- Dynamic legend and color scale for easy interpretation of price ranges.
- Data pipeline: CSV → Java processing → GeoJSON → Flutter visualization.
- Robust handling of data mismatches and mapping between HDB towns and URA planning areas.

## Technologies Used

- **Flutter**: UI and map rendering (`flutter_map`, `latlong2`)
- **Java**: Data processing, CSV parsing, GeoJSON merging
- **Python**: GeoJSON property mapping and preprocessing
- **OpenStreetMap**: Base map tiles
- **GeoJSON**: Spatial data format

## How to Run

1. **Prepare Data**  
   - Place `resale-flat-prices.csv` and `planning-area-boundary.geojson` in `src/main/resources/`.
   - Run the Java processor to generate `assets/hdb_price_map_data.geojson`.

2. **Run the Flutter App**  
   - `flutter pub get`
   - `flutter run`

**Thank you for visiting my project.**