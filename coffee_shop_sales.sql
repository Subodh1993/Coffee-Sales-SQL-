SELECT * from coffee_shop_sales

UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date date;

UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id INT;

select ROUND(sum(unit_price * transaction_qty),2) as  Total_Sales
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- May Month

-- Selected Month / Current Month - May=5
-- Previous Month - April=4

SELECT 
    MONTH(transaction_date) AS month, -- Number of Month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- Total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- Month sales Difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- division by PM sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- Percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April(PM) and May(CM)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
select COUNT(transaction_id) as  Total_Orders
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- May Month

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
SELECT SUM(transaction_qty) as Total_Quantity_Sold
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5 -- for CM(May)

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    SELECT
      CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_sales,
      CONCAT(ROUND(SUM(transaction_id)/1000,1), 'K') AS Total_Qty_Sold,
      CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM coffee_shop_sales
WHERE
transaction_date = '2023-05-18'

-- Weedends - Sat and Sun
-- Weedays - Mon to Fri

SELECT
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'K') AS Total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 2 -- May Month
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END
    
    -- Sales by Store Location
    
    SELECT
        store_location,
		CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS Total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 6 -- May
    GROUP BY store_location
    ORDER BY SUM(unit_price * transaction_qty) DESC
    
    -- Avg of sales
    
    SELECT AVG (unit_price * transaction_qty) AS Avg_Sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    
    -- different query to take avg
    
SELECT
      CONCAT(ROUND(AVG(total_sales)/1000,1), 'K') AS Avg_Sales
FROM
    (
      SELECT SUM(transaction_qty * unit_price) AS total_sales
      FROM coffee_shop_sales
      WHERE MONTH (transaction_date) = 5
      GROUP BY transaction_date
    )
    AS Internal_query
    
SELECT
   DAY(transaction_date) AS day_of_month,
   SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
    -- SALES PRODUCT CATEGORY
    
    SELECT
		product_category,
        CONCAT(ROUND(SUM(unit_price *transaction_qty)/1000,1), 'K') AS total_sales
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY product_category
    ORDER BY SUM(unit_price*transaction_qty) DESC
    
    -- TOP 10 PRODUCTS by SALES
    
    SELECT
		product_type,
        SUM(unit_price * transaction_qty) AS total_sales
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
    GROUP BY product_type
    ORDER BY SUM(unit_price * transaction_qty) DESC
    LIMIT 10
    
    -- Sales by Days | Hours
    
    SELECT
        SUM(unit_price * transaction_qty) AS total_sales,
        SUM(transaction_qty) AS Total_qty_sold,
        COUNT(*) Total_Orders
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 -- May
    AND DAYOFWEEK(transaction_date) = 1 -- Monday
    AND HOUR(transaction_time) = 14 -- Hour No
    
    
    SELECT
        HOUR(transaction_time),
        SUM(unit_price * transaction_qty) AS total_sales
	FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY HOUR(transaction_time)
    ORDER BY HOUR(transaction_time)
    
    
    SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;