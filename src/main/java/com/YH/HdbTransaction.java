package com.YH;

import com.opencsv.bean.CsvBindByName;

public class HdbTransaction {
    @CsvBindByName(column = "town", required = true)
    private String town;

    @CsvBindByName(column = "resale_price", required = true)
    private double resalePrice;

    // Default constructor required by OpenCSV
    public HdbTransaction() {
    }

    // Constructor
    public HdbTransaction(String town, double resalePrice) {
        this.town = town;
        this.resalePrice = resalePrice;
    }

    // Getters
    public String getTown() {
        return town;
    }

    public double getResalePrice() {
        return resalePrice;
    }

    // Setters
    public void setTown(String town) {
        this.town = town;
    }

    public void setResalePrice(double resalePrice) {
        this.resalePrice = resalePrice;
    }
}
