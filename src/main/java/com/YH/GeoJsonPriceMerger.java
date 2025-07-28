package com.YH;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import java.io.File;
import java.util.Map;

public class GeoJsonPriceMerger {

    public void mergePricesIntoGeoJson(
            Map<String, Double> averagePrices,
            String geoJsonInputPath,
            String geoJsonOutputPath) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        JsonNode rootNode = mapper.readTree(new File(geoJsonInputPath));
        JsonNode features = rootNode.path("features");

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
                        propertiesObj.put("avg_price", avgPrice);
                    }
                }
            }
        }
        mapper.writerWithDefaultPrettyPrinter().writeValue(new File(geoJsonOutputPath), rootNode);
    }

    public void mergePricesIntoGeoJsonByFlatType(
            Map<String, Map<String, Double>> avgPriceByTownAndType,
            String flatType,
            String geoJsonInputPath,
            String geoJsonOutputPath) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        JsonNode rootNode = mapper.readTree(new File(geoJsonInputPath));
        JsonNode features = rootNode.path("features");

        for (JsonNode feature : features) {
            if (feature.isObject()) {
                ObjectNode featureObj = (ObjectNode) feature;
                JsonNode properties = featureObj.path("properties");
                if (properties.isObject()) {
                    ObjectNode propertiesObj = (ObjectNode) properties;
                    JsonNode areaNameNode = propertiesObj.path("HDB_TOWN");
                    if (areaNameNode.isTextual()) {
                        String areaName = areaNameNode.asText().toUpperCase();
                        Double avgPrice = 0.0;
                        Map<String, Double> typeMap = avgPriceByTownAndType.get(areaName);
                        if (typeMap != null) {
                            avgPrice = typeMap.getOrDefault(flatType.toUpperCase(), 0.0);
                        }
                        propertiesObj.put("avg_price", avgPrice);
                    }
                }
            }
        }
        mapper.writerWithDefaultPrettyPrinter().writeValue(new File(geoJsonOutputPath), rootNode);
    }
}