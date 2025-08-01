-- Add Reorder Point column
ALTER TABLE Product ADD COLUMN Reorder_Point INT;

-- Create Alert Table
CREATE TABLE Low_Stock_Alerts (
    Alert_ID INT AUTO_INCREMENT PRIMARY KEY,
    Store_ID VARCHAR(10),
    Product_ID VARCHAR(10),
    Current_Qty INT,
    Alert_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- actual trigger functon
DELIMITER $$

CREATE TRIGGER trigger_low_inventory
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    DECLARE reorder_point_value INT;

    SELECT Reorder_Point INTO reorder_point_value
    FROM Product
    WHERE Product_ID = NEW.Product_ID;

    IF NEW.Inventory_Level < reorder_point_value THEN
        INSERT INTO Low_Stock_Alerts (Store_ID, Product_ID, Current_Qty)
        VALUES (NEW.Store_ID, NEW.Product_ID, NEW.Inventory_Level);
    END IF;
END$$

DELIMITER ;
