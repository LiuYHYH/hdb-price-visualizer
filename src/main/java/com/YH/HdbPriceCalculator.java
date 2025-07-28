package com.YH;

import com.opencsv.bean.CsvToBeanBuilder;
import java.io.FileReader;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class HdbPriceCalculator {

    public List<HdbTransaction> readTransactions(String csvFilePath) throws Exception {
        try (FileReader reader = new FileReader(csvFilePath, StandardCharsets.UTF_8)) {
            return new CsvToBeanBuilder<HdbTransaction>(reader)
                    .withType(HdbTransaction.class)
                    .build()
                    .parse();
        }
    }

    public Map<String, Double> calculateAveragePrices(List<HdbTransaction> transactions) {
        return transactions.stream()
                .collect(Collectors.groupingBy(
                        t -> t.getTown().toUpperCase(),
                        Collectors.averagingDouble(HdbTransaction::getResalePrice)
                ));
    }

    public Map<String, Map<String, Double>> calculateAveragePricesByTownAndFlatType(List<HdbTransaction> transactions) {
        return transactions.stream()
                .collect(Collectors.groupingBy(
                        t -> t.getTown().toUpperCase(),
                        Collectors.groupingBy(
                                t -> t.getFlatType().toUpperCase(),
                                Collectors.averagingDouble(HdbTransaction::getResalePrice)
                        )
                ));
    }
}