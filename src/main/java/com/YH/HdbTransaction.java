package com.YH;

import com.opencsv.bean.CsvBindByName;

public class HdbTransaction {
    @CsvBindByName(column = "town", required = true)
    private String town;

    @CsvBindByName(column = "flat_type", required = true)
    private String flatType;

    @CsvBindByName(column = "resale_price", required = true)
    private double resalePrice;

    // Constructor
    public HdbTransaction() {} // Needed for OpenCSV

    public HdbTransaction(String town, String flatType, double resalePrice) {
        this.town = town;
        this.flatType = flatType;
        this.resalePrice = resalePrice;
    }

    // Getters
    public String getTown() {
        return town;
    }

    public String getFlatType() {
        return flatType;
    }

    public double getResalePrice() {
        return resalePrice;
    }

    // Setters
    public void setTown(String town) {
        this.town = town;
    }

    public void setFlatType(String flatType) {
        this.flatType = flatType;
    }

    public void setResalePrice(double resalePrice) {
        this.resalePrice = resalePrice;
    }
}
