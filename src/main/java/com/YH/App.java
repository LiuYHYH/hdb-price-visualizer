package com.YH;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.opencsv.bean.CsvToBeanBuilder;
import java.io.File;
import java.io.FileReader;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class App {
    // --- CONFIGURATION ---
    // Adjust these paths based on your project structure
    private static final String HDB_CSV_PATH = "src/main/resources/resale-flat-prices.csv";
    private static final String GEOJSON_INPUT_PATH = "src/main/resources/planning-area-boundary.geojson";
    private static final String GEOJSON_OUTPUT_PATH = "assets/hdb_price_map_data.geojson"; // Output to assets folder

    public static void main(String[] args) {
        try {
            App processor = new App();
            // Step 2: Calculate prices from CSV
            Map<String, Double> averagePrices = processor.calculateAveragePrices(HDB_CSV_PATH);

            // Step 3 & 4: Merge price data into GeoJSON and write output
            processor.mergePricesIntoGeoJson(averagePrices, GEOJSON_INPUT_PATH, GEOJSON_OUTPUT_PATH);
            System.out.println("Processing complete. Output written to: " + GEOJSON_OUTPUT_PATH);

        } catch (Exception e) {
            System.err.println("An error occurred during data processing:");
            e.printStackTrace();
        }
    }

    public Map<String, Double> calculateAveragePrices(String csvFilePath) throws Exception {
        System.out.println("Reading HDB data from: " + csvFilePath);
        List<HdbTransaction> transactions;
        try (FileReader reader = new FileReader(csvFilePath, StandardCharsets.UTF_8)) {
            transactions = new CsvToBeanBuilder<HdbTransaction>(reader)
                    .withType(HdbTransaction.class)
                    .build()
                    .parse();
        }
        System.out.println("Successfully read " + transactions.size() + " transactions.");
        System.out.println("Calculating average prices per town...");

        Map<String, Double> averagePriceByTown = transactions.stream()
                .collect(Collectors.groupingBy(
                        transaction -> transaction.getTown().toUpperCase(), // Convert to uppercase for matching
                        Collectors.averagingDouble(HdbTransaction::getResalePrice)
                ));

        System.out.println("Calculation complete. Found data for " + averagePriceByTown.size() + " towns.");
        return averagePriceByTown;
    }

    public void mergePricesIntoGeoJson(Map<String, Double> averagePrices, String geoJsonInputPath, String geoJsonOutputPath) throws Exception {
        System.out.println("Reading GeoJSON from: " + geoJsonInputPath);
        ObjectMapper mapper = new ObjectMapper();
        JsonNode rootNode = mapper.readTree(new File(geoJsonInputPath));

        // Get the "features" array from GeoJSON
        JsonNode features = rootNode.path("features");
        if (!features.isArray()) {
            throw new IllegalStateException("GeoJSON does not contain a 'features' array.");
        }

        System.out.println("Processing " + features.size() + " features in GeoJSON...");
        int updatedFeatures = 0;

        // Iterate through each feature
        for (JsonNode feature : features) {
    if (feature.isObject()) {
        ObjectNode featureObj = (ObjectNode) feature;
        JsonNode properties = featureObj.path("properties");
        if (properties.isObject()) {
            ObjectNode propertiesObj = (ObjectNode) properties;
            JsonNode areaNameNode = propertiesObj.path("HDB_TOWN");
            if (areaNameNode.isTextual()) {
                String areaName = areaNameNode.asText().toUpperCase();
                Double avgPrice = averagePrices.getOrDefault(areaName, 0.0);
                propertiesObj.put("avg_price", avgPrice); // <-- update the actual properties node
                updatedFeatures++;
                if (avgPrice > 0.0) {
                    System.out.println("Matched area: " + areaName + " with avg_price: " + avgPrice);
                } else {
                    System.out.println("No price data for area: " + areaName + " (set to 0.0)");
                }
            } else {
                System.out.println("Warning: Feature missing PLN_AREA_N property.");
            }
        } else {
            System.out.println("Warning: Feature missing properties object.");
        }
    }
}

        System.out.println("Updated " + updatedFeatures + " features with price data.");
        System.out.println("Writing output to: " + geoJsonOutputPath);

        // Write the modified GeoJSON to the output file
        mapper.writerWithDefaultPrettyPrinter().writeValue(new File(geoJsonOutputPath), rootNode);
        System.out.println("GeoJSON output file created successfully.");
    }
}
