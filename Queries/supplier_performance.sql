CREATE TABLE inventory_records (
    Date DATE,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Category VARCHAR(50),
    Region VARCHAR(50),
    Inventory_Level INT,
    Units_Sold INT,
    Units_Ordered INT,
    Demand_Forecast INT,
    Price DECIMAL(10,2),
    Discount DECIMAL(10,2),
    Weather_Condition VARCHAR(50),
    Holiday_Promotion TINYINT(1),
    Competitor_Pricing INT,
    Seasonality VARCHAR(20)
);
LOAD DATA INFILE 'F:/NEW DOWNLOADS/Projec_sql/inventory_forecasting.csv'
INTO TABLE inventory_records
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- lead time 
WITH Inventory_Change AS (
  SELECT 
    Store_ID,
    Product_ID,
    Date AS Order_Date,
    Inventory_Level,
    Units_Ordered,
    LEAD(Date, 1) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date) AS Next_Date,
    LEAD(Inventory_Level, 1) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date) AS Next_Inventory
  FROM inventory_records
)
SELECT 
  Store_ID,
  Product_ID,
  Order_Date,
  Next_Date AS Received_Date,
  Inventory_Level,
  Units_Ordered,
  Next_Inventory,
  DATEDIFF(Next_Date, Order_Date) AS Inferred_Lead_Time
FROM Inventory_Change
WHERE Units_Ordered > 0 AND Next_Inventory > Inventory_Level
ORDER BY Store_ID, Product_ID, Order_Date;

WITH Inventory_Change AS (
  SELECT 
    Store_ID,
    Product_ID,
    Date AS Order_Date,
    LEAD(Date) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date) AS Next_Date,
    DATEDIFF(LEAD(Date) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date), Date) AS Inferred_Lead_Time
  FROM inventory_records
)
SELECT * FROM Inventory_Change
ORDER BY Store_ID, Product_ID, Order_Date;



WITH Inventory_Change AS (
  SELECT 
    Store_ID,
    Product_ID,
    Date AS Order_Date,
    Inventory_Level,
    Units_Ordered,
    LEAD(Inventory_Level, 1) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date) AS Next_Inventory,
    LEAD(Date, 1) OVER (PARTITION BY Store_ID, Product_ID ORDER BY Date) AS Next_Date
  FROM inventory_records
)
SELECT 
  Store_ID,
  Product_ID,
  Order_Date,
  Next_Date AS Received_Date,
  Inventory_Level,
  Units_Ordered,
  Next_Inventory,
  (Next_Inventory - Inventory_Level) AS Received_Units,
  DATEDIFF(Next_Date, Order_Date) AS Inferred_Lead_Time,
  CASE 
    WHEN (Next_Inventory - Inventory_Level) >= Units_Ordered THEN 'Fully Filled'
    WHEN (Next_Inventory - Inventory_Level) BETWEEN 1 AND Units_Ordered - 1 THEN 'Partially Filled'
    ELSE 'Unfilled or Shrinkage'
  END AS Fulfillment_Status
FROM Inventory_Change
WHERE Units_Ordered > 0 AND Next_Inventory IS NOT NULL;









