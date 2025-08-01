CREATE INDEX idx_sales_date ON Sales (Sale_Date);
CREATE INDEX idx_sales_product ON Sales (Product_ID);

CREATE INDEX idx_inventory_product ON Inventory (Product_ID);
CREATE INDEX idx_inventory_date ON Inventory (Inventory_Date);

CREATE INDEX idx_forecast_date_product ON Forecast (Forecast_Date, Product_ID);

CREATE INDEX idx_external_store_date ON External_Factors (Store_ID, Factor_Date);

CREATE INDEX idx_product_category ON Product (Category);

SHOW INDEX FROM Sales;

CREATE INDEX idx_sales_date ON Sales (Sale_Date);
SHOW INDEX FROM Sales;





