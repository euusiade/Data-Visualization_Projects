
#Top Performing Restaurants by Revenue
WITH discountpercentage AS (
    SELECT 
        UDF_ExtractNumbers(discounts_offers) AS discounts,
        order_value
    FROM 
        food_orders
),
Discount AS (
    SELECT 
        order_value, 
        (order_value * (discounts / 100)) AS discountperorder
    FROM 
        discountpercentage
),
total_revenue AS (
    SELECT 
        f.restaurant_id, 
        SUM(f.order_value + f.commission_fee + f.delivery_fee - d.discountperorder - f.refunds_chargebacks) AS totalrevenue
    FROM 
        food_orders f
    JOIN 
        Discount d 
    ON 
        f.order_value = d.order_value
    GROUP BY 
        f.restaurant_id
)
SELECT 
    restaurant_id,
    totalrevenue,
    RANK() OVER (ORDER BY totalrevenue DESC) AS ranking
FROM 
    total_revenue
ORDER BY 
    ranking
LIMIT 10;

#Order Value Distribution by Payment Method
SELECT DISTINCT
    payment_method, SUM(order_value) AS totalvalue
FROM
    food_orders
GROUP BY payment_method
ORDER BY 2;

#Delivery Time Analysis
SELECT 
    YEARWEEK(delivery_datetime, 1) AS time_period,
    CASE
        WHEN delivery_fee BETWEEN 0 AND 5 THEN '0-5'
        WHEN delivery_fee BETWEEN 6 AND 10 THEN '6-10'
        WHEN delivery_fee BETWEEN 11 AND 20 THEN '11-20'
        ELSE '21+'
    END AS fee_range,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE,
                order_datetime,
                delivery_datetime))) AS avg_delivery_time
FROM
    food_orders
GROUP BY time_period , fee_range
ORDER BY time_period , fee_range;
    

#Order Trends Over Time
SELECT 
    CONCAT(EXTRACT(YEAR FROM order_datetime), '-W', LPAD(EXTRACT(WEEK FROM order_datetime), 2, '0')) AS Order_Week,
    COUNT(*) AS Total_Orders,
    SUM(order_value) AS Total_Order_Value
FROM 
    food_orders
GROUP BY 
    Order_Week
ORDER BY 
    Order_Week;




