
CREATE TEMPORARY TABLE product_revenue AS
SELECT 
  Product_ID,
  SUM(Units_Sold * Price) AS Total_Revenue
FROM inventory_records
GROUP BY Product_ID;

DROP TEMPORARY TABLE IF EXISTS product_revenue_ranked;

CREATE TEMPORARY TABLE product_revenue_ranked AS
SELECT 
  Product_ID,
  Total_Revenue,
  SUM(Total_Revenue) OVER (ORDER BY Total_Revenue DESC) AS Cumulative_Revenue
FROM product_revenue;

-- total reveniew =
SELECT SUM(Total_Revenue) INTO @total_rev FROM product_revenue;

SELECT 
  Product_ID,
  Total_Revenue,
  ROUND(Cumulative_Revenue / @total_rev * 100, 2) AS Cumulative_Revenue_Percent,
  CASE
    WHEN Cumulative_Revenue / @total_rev <= 0.80 THEN 'A'
    WHEN Cumulative_Revenue / @total_rev <= 0.95 THEN 'B'
    ELSE 'C'
  END AS ABC_Category
FROM product_revenue_ranked
ORDER BY Total_Revenue DESC;




