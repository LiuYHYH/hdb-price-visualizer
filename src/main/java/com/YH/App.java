package com.YH;

import java.util.List;
import java.util.Map;

public class App {
    // --- CONFIGURATION ---
    // Adjust these paths based on your project structure
    private static final String HDB_CSV_PATH = "src/main/resources/resale-flat-prices.csv";
    private static final String GEOJSON_INPUT_PATH = "src/main/resources/planning-area-boundary.geojson";
    public static void main(String[] args) {
        try {
            HdbPriceCalculator calculator = new HdbPriceCalculator();
            GeoJsonPriceMerger merger = new GeoJsonPriceMerger();

            List<HdbTransaction> transactions = calculator.readTransactions(HDB_CSV_PATH);

            // Calculate average price by town and flat type
            Map<String, Map<String, Double>> avgPriceByTownAndType = calculator.calculateAveragePricesByTownAndFlatType(transactions);

            // List of flat types you want to support
            String[] flatTypes = {"2 ROOM", "3 ROOM", "4 ROOM", "5 ROOM", "EXECUTIVE"};

            for (String flatType : flatTypes) {
                String outputPath = "assets/hdb_price_map_" + flatType.replace(" ", "_").toLowerCase() + ".geojson";
                merger.mergePricesIntoGeoJsonByFlatType(
                    avgPriceByTownAndType,
                    flatType,
                    GEOJSON_INPUT_PATH,
                    outputPath
                );
                System.out.println("Generated: " + outputPath);
            }

            System.out.println("Processing complete. All flat type GeoJSON files written to assets folder.");

        } catch (Exception e) {
            System.err.println("An error occurred during data processing:");
            e.printStackTrace();
        }
    }
}
