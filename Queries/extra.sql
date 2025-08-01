-- safety stock --remove
SELECT 
    i.Product_ID,
    COUNT(*) AS Days_Below_Threshold,
    ROUND(AVG(i.Inventory_Level)) AS Avg_Stock,
    MAX(f.Demand_Forecast) AS Peak_Demand,
    MAX(f.Demand_Forecast) - ROUND(AVG(i.Inventory_Level)) AS Recommended_Buffer
FROM Inventory i
JOIN Forecast f 
  ON i.Product_ID = f.Product_ID 
  AND i.Inventory_Date = f.Forecast_Date 
  AND i.Store_ID = f.Store_ID
WHERE i.Inventory_Level < f.Demand_Forecast
GROUP BY i.Product_ID
HAVING Days_Below_Threshold >= 5;



-- monthly store leaderboard --remove
SELECT 
    s.Store_ID,
    ROUND(AVG(ABS(s.Units_Sold - f.Demand_Forecast)), 2) AS Avg_Error,
    RANK() OVER (ORDER BY ROUND(AVG(ABS(s.Units_Sold - f.Demand_Forecast)), 2)) AS Accuracy_Rank
FROM Sales s
JOIN Forecast f 
  ON s.Sale_Date = f.Forecast_Date AND s.Product_ID = f.Product_ID AND s.Store_ID = f.Store_ID
WHERE MONTH(s.Sale_Date) = MONTH(CURDATE())
GROUP BY s.Store_ID;

-- weather based demand --remove
SELECT 
    e.Weather_Conditions,
    ROUND(AVG(s.Units_Sold), 2) AS Avg_Sales
FROM Sales s
JOIN External_Factors e 
  ON s.Sale_Date = e.Factor_Date AND s.Store_ID = e.Store_ID
GROUP BY e.Weather_Conditions;

-- barcode generation --remove
SELECT Product_ID, LPAD(Product_ID, 12, '0') AS Barcode FROM Product;
SELECT * FROM Product WHERE Barcode = '0000000P0016';

SELECT 
  Product_ID,
  SUM(Units_Sold) AS Total_Sold,
  CASE
    WHEN SUM(Units_Sold) >= 1000 THEN 'Fast-Moving'
    WHEN SUM(Units_Sold) BETWEEN 500 AND 999 THEN 'Moderate'
    ELSE 'Slow-Moving'
  END AS Product_Category
FROM Sales
GROUP BY Product_ID
ORDER BY Total_Sold DESC;


SELECT 
  i.Store_ID,
  i.Product_ID,
  ROUND(AVG(i.Inventory_Level)) AS Avg_Stock_Level,
  ROUND(AVG(f.Demand_Forecast)) AS Avg_Demand,
  ROUND(AVG(i.Inventory_Level) - AVG(f.Demand_Forecast)) AS Stock_Adjustment,
  CASE
    WHEN AVG(i.Inventory_Level) - AVG(f.Demand_Forecast) > 50 THEN 'Reduce Stock'
    WHEN AVG(i.Inventory_Level) - AVG(f.Demand_Forecast) < -20 THEN 'Increase Stock'
    ELSE 'Stock Level OK'
  END AS Recommendation
FROM Inventory i
JOIN Forecast f 
  ON i.Product_ID = f.Product_ID 
  AND i.Inventory_Date = f.Forecast_Date
  AND i.Store_ID = f.Store_ID
GROUP BY i.Store_ID, i.Product_ID
ORDER BY Recommendation DESC;

-- sesasonal deviation --remoce
SELECT 
  MONTH(Sale_Date) AS Sale_Month,
  Product_ID,
  SUM(Units_Sold) AS Monthly_Sales
FROM Sales
GROUP BY Product_ID, MONTH(Sale_Date)
ORDER BY Product_ID, Sale_Month;

-- weekly --remove
SELECT 
  DAYNAME(Sale_Date) AS Day_Of_Week,
  Product_ID,
  AVG(Units_Sold) AS Avg_Sales
FROM Sales
GROUP BY Product_ID, Day_Of_Week
ORDER BY Product_ID, FIELD(Day_Of_Week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

SELECT 
  Sale_Date,
  Product_ID,
  SUM(Units_Sold) AS Daily_Sales,
  AVG(SUM(Units_Sold)) OVER (PARTITION BY Product_ID ORDER BY Sale_Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Rolling_7_Day_Avg
FROM Sales
GROUP BY Product_ID, Sale_Date
ORDER BY Product_ID, Sale_Date;

SELECT Supplier_ID, AVG(Delivery_Delay) AS Avg_Delay, COUNT(DISTINCT Product_ID) AS Variety 
FROM Supplier_Performance 
GROUP BY Supplier_ID;


--  out of stock freq. --remove
SELECT 
  Product_ID,
  Store_ID,
  COUNT(*) AS Stockout_Days
FROM Inventory
WHERE Inventory_Level = 0
GROUP BY Product_ID, Store_ID
HAVING Stockout_Days >= 1;

-- actual vs forecasted --remove
SELECT 
  i.Product_ID,
  i.Store_ID,
  f.Forecast_Date,
  f.Demand_Forecast,
  i.Inventory_Level,
  (f.Demand_Forecast - i.Inventory_Level) AS Gap
FROM Inventory i
JOIN Forecast f
  ON i.Product_ID = f.Product_ID
  AND i.Inventory_Date = f.Forecast_Date
  AND i.Store_ID = f.Store_ID
WHERE i.Inventory_Level < f.Demand_Forecast
ORDER BY Gap DESC;

-- slow restocks -rremove
SELECT 
  Product_ID,
  Store_ID,
  MIN(Inventory_Date) AS Stockout_Start,
  MAX(Inventory_Date) AS Stockout_End,
  DATEDIFF(MAX(Inventory_Date), MIN(Inventory_Date)) AS Days_Out
FROM Inventory
WHERE Inventory_Level = 0
GROUP BY Product_ID, Store_ID
HAVING Days_Out > 3;

-- aging of inventory --remove
SELECT 
  Product_ID,
  Store_ID,
  DATEDIFF(CURDATE(), MIN(Inventory_Date)) AS Days_In_Stock
FROM Inventory
WHERE Inventory_Level > 0
GROUP BY Product_ID, Store_ID;

-- cost of over stocks --remove
SELECT Product_ID, Price
FROM Product
WHERE Price IS NOT NULL
LIMIT 10;


-- supplier performance --remove
CREATE TABLE retail_data (
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
    Holiday_Promotion TINYINT(1),
    Supplier_Rating DECIMAL(10,2),
    Seasonality VARCHAR(20)
);

--stockouts despite of demand
SELECT  
  Product_ID,  
  Store_ID,  
  COUNT(*) AS Stockout_With_Demand
FROM retail_data
WHERE Inventory_Level = 0 AND Demand_Forecast > 0
GROUP BY Product_ID, Store_ID
HAVING Stockout_With_Demand > 0
ORDER BY Stockout_With_Demand DESC
LIMIT 1000;