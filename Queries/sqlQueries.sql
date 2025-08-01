-- top selling product
SELECT Product_ID, SUM(Units_Sold) AS Total_Sold
FROM Sales
GROUP BY Product_ID
ORDER BY Total_Sold DESC
LIMIT 10;

-- low stock alerts 
SELECT * FROM Inventory
WHERE Inventory_Level < 20;

-- Forecast Accuracy Query
SELECT 
    s.Sale_Date,
    s.Product_ID,
    s.Store_ID,
    s.Units_Sold,
    f.Demand_Forecast,
    (s.Units_Sold - f.Demand_Forecast) AS Forecast_Error
FROM Sales s
JOIN Forecast f 
  ON s.Sale_Date = f.Forecast_Date 
  AND s.Product_ID = f.Product_ID 
  AND s.Store_ID = f.Store_ID;




-- inventory turnover
SELECT 
    p.Product_ID,
    ROUND(SUM(s.Units_Sold) / NULLIF(AVG(i.Inventory_Level), 0), 2) AS Turnover_Rate
FROM Sales s
JOIN Inventory i ON s.Product_ID = i.Product_ID AND s.Sale_Date = i.Inventory_Date
JOIN Product p ON p.Product_ID = s.Product_ID
GROUP BY p.Product_ID
ORDER BY Turnover_Rate DESC;

-- revenue leakage due to stockout

SELECT 
    i.Store_ID,
    i.Product_ID,
    i.Inventory_Date,
    f.Demand_Forecast,
    p.Price,
    f.Demand_Forecast * p.Price AS Estimated_Lost_Revenue
FROM Inventory i
JOIN Forecast f ON i.Product_ID = f.Product_ID AND i.Inventory_Date = f.Forecast_Date
JOIN Product p ON i.Product_ID = p.Product_ID
WHERE i.Inventory_Level = 0 AND f.Demand_Forecast > 0;

-- reorder
SELECT 
  s.Product_ID,
  s.Store_ID,
  ROUND(AVG(s.Daily_Sales) * 5 + 20) AS Reorder_Point
FROM (
  SELECT 
    Product_ID,
    Store_ID,
    Sale_Date,
    SUM(Units_Sold) OVER (
      PARTITION BY Product_ID, Store_ID 
      ORDER BY Sale_Date 
      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) / 7 AS Daily_Sales
  FROM Sales
) AS s
GROUP BY s.Product_ID, s.Store_ID;





