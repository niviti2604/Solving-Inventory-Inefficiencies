SELECT 
  i.Product_ID,
  i.Store_ID,
  i.Inventory_Date,
  i.Inventory_Level,
  f.Demand_Forecast,
  (f.Demand_Forecast - i.Inventory_Level) AS Gap,
  CASE
    WHEN (f.Demand_Forecast - i.Inventory_Level) > 50 THEN 'Severe Undersupply'
    WHEN (f.Demand_Forecast - i.Inventory_Level) BETWEEN 1 AND 50 THEN 'Moderate Undersupply'
    ELSE 'OK'
  END AS Supply_Status
FROM Inventory i
JOIN Forecast f 
  ON i.Product_ID = f.Product_ID
  AND i.Store_ID = f.Store_ID
  AND i.Inventory_Date = f.Forecast_Date
WHERE f.Demand_Forecast > i.Inventory_Level
ORDER BY Gap DESC;

-- restocking time
SELECT 
  i.Product_ID,
  i.Store_ID,
  MIN(i.Inventory_Date) AS Stockout_Start,
  MAX(i.Inventory_Date) AS Stockout_End,
  DATEDIFF(MAX(i.Inventory_Date), MIN(i.Inventory_Date)) AS Days_Out
FROM Inventory i
WHERE i.Inventory_Level = 0
GROUP BY i.Product_ID, i.Store_ID
HAVING Days_Out >= 2
ORDER BY Days_Out DESC;


-- report
CREATE OR REPLACE VIEW supply_issue_report AS
SELECT 
  i.Product_ID,
  i.Store_ID,
  i.Inventory_Date,
  i.Inventory_Level,
  f.Demand_Forecast,
  (f.Demand_Forecast - i.Inventory_Level) AS Demand_Supply_Gap,
  CASE 
    WHEN (f.Demand_Forecast - i.Inventory_Level) >= 50 THEN 'High'
    WHEN (f.Demand_Forecast - i.Inventory_Level) BETWEEN 20 AND 49 THEN 'Medium'
    ELSE 'Low'
  END AS Shortage_Priority
FROM Inventory i
JOIN Forecast f 
  ON i.Product_ID = f.Product_ID
  AND i.Store_ID = f.Store_ID
  AND i.Inventory_Date = f.Forecast_Date
WHERE f.Demand_Forecast > i.Inventory_Level;

SELECT * FROM supply_issue_report ORDER BY Shortage_Priority DESC;


SELECT CURRENT_USER();

