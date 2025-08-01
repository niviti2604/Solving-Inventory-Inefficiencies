CREATE DATABASE urban_retail_inventory;
USE urban_retail_inventory;

CREATE TABLE RawData (
    Date DATE,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Category VARCHAR(50),
    Region VARCHAR(50),
    Units_Sold INT,
    Inventory_Level INT,
    Demand_Forecast INT,
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    Competitor_Pricing INT,
    Weather_Conditions VARCHAR(50),
    Holiday_Promotion BOOLEAN,
    Supplier_Rating DECIMAL(10,2),
    Seasonality VARCHAR(20)
);
SELECT *
FROM RawData;

SELECT @@secure_file_priv;

LOAD DATA INFILE 'F:/NEW DOWNLOADS/Projec_sql/inventory_forecasting.csv' INTO TABLE RawData
FIELDS TERMINATED BY ','
IGNORE 1 LINES;
SELECT *
FROM RawData;

CREATE TABLE Store (
    Store_ID VARCHAR(10) PRIMARY KEY,
    Region VARCHAR(50)
);

CREATE TABLE Product (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    Seasonality VARCHAR(20),
    Supplier_Rating DECIMAL(10,2),
    Barcode VARCHAR(20)
);
CREATE TABLE Sales (
    Sale_Date DATE,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Units_Sold INT,
    PRIMARY KEY (Sale_Date, Store_ID, Product_ID),
   );
CREATE TABLE Inventory (
    Inventory_Date DATE,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Inventory_Level INT,
    PRIMARY KEY (Inventory_Date, Store_ID, Product_ID),
   
);
CREATE TABLE Forecast (
    Forecast_Date DATE,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Demand_Forecast INT,
    PRIMARY KEY (Forecast_Date, Store_ID, Product_ID),
    
);
CREATE TABLE External_Factors (
    Factor_Date DATE,
    Store_ID VARCHAR(10),
    Weather_Conditions VARCHAR(50),
    Holiday_Promotion BOOLEAN,
    Competitor_Pricing INT,
    PRIMARY KEY (Factor_Date, Store_ID),
   
);
INSERT IGNORE INTO Store (Store_ID, Region)
SELECT DISTINCT Store_ID, Region FROM RawData;

INSERT IGNORE INTO Product (
    Product_ID, Category, Price, Discount, Seasonality, Supplier_Rating, Barcode
)
SELECT DISTINCT
    Product_ID,
    Category,
    Price,
    Discount,
    Seasonality,
    Supplier_Rating,
    LPAD(Product_ID, 12, '0') 
FROM RawData;

INSERT INTO Sales (Sale_Date, Store_ID, Product_ID, Units_Sold)
SELECT Date, Store_ID, Product_ID, Units_Sold FROM RawData;

INSERT INTO Inventory (Inventory_Date, Store_ID, Product_ID, Inventory_Level)
SELECT Date, Store_ID, Product_ID, Inventory_Level FROM RawData;

INSERT INTO Forecast (Forecast_Date, Store_ID, Product_ID, Demand_Forecast)
SELECT Date, Store_ID, Product_ID, Demand_Forecast FROM RawData;

INSERT IGNORE INTO External_Factors (
    Factor_Date, Store_ID, Weather_Conditions, Holiday_Promotion, Competitor_Pricing
)
SELECT DISTINCT
    Date,
    Store_ID,
    Weather_Conditions,
    Holiday_Promotion,
    Competitor_Pricing
FROM RawData;

SELECT COUNT(*) FROM Store;
SELECT COUNT(*) FROM Product;
SELECT COUNT(*) FROM Sales;
