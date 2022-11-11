use supply_db ;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		
SELECT Date_format(order_date, '%Y-%m') AS Month,
       Sum(i.quantity)                  AS Quantities_Sold,
       Sum(i.sales)                     AS Sales
FROM   product_info p
       LEFT JOIN ordered_items i
              ON p.product_id = i.item_id
       LEFT JOIN orders o
              ON o.order_id = i.order_id
WHERE  Lower(p.product_name) LIKE '%nike%'
GROUP  BY month
ORDER  BY month; 
-- **********************************************************************************************************************************

/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/
SELECT p.Product_Id,
       p.Product_Name,
       c.name AS Category_Name,
       d.name AS Department_Name,
       p.Product_Price
FROM   product_info p
       INNER JOIN category c
               ON p.category_id = c.id
       INNER JOIN department d
               ON p.department_id = d.id
ORDER  BY product_price DESC
LIMIT  5; 
-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/
SELECT p.Product_Name,
       Sum(i.sales)               AS Sales,
       Count(DISTINCT o.order_id) AS Order_count
FROM   orders o
       LEFT JOIN ordered_items i
              ON o.order_id = i.order_id
       LEFT JOIN product_info p
              ON i.item_id = p.product_id
WHERE  o.type = 'CASH'
GROUP  BY p.product_name
ORDER  BY order_count DESC,
          sales DESC
LIMIT  10; 
-- **********************************************************************************************************************************


/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/
SELECT o.Order_Id,
       o.Type,
       o.Real_Shipping_Days,
       o.Scheduled_Shipping_Days,
       o.Customer_Id,
       o.Order_City,
       o.Order_Date,
       o.Order_Region,
       o.Order_State,
       o.Order_Status,
       o.Shipping_Mode
FROM   orders o
       INNER JOIN customer_info c
               ON o.customer_id = c.id
WHERE  c.state = 'TX'
       AND Lower(street) LIKE '%plaza%'
       AND Lower(street) NOT LIKE '%mountain%'
ORDER  BY o.order_id; 
-- **********************************************************************************************************************************


/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT Count(DISTINCT o.order_id) AS Order_Count
FROM   category cat
       LEFT JOIN product_info p
              ON cat.id = p.category_id
       LEFT JOIN ordered_items i
              ON p.product_id = i.item_id
       LEFT JOIN orders o
              ON i.order_id = o.order_id
       LEFT JOIN customer_info c
              ON o.customer_id = c.id
WHERE  ( Lower(cat.name) LIKE '%apparel%'
          OR Lower(cat.name) LIKE '%outdoor%' )
       AND c.segment = 'Home Office'; 


-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.
*/
SELECT o.Order_State,
       o.Order_City,
       Count(DISTINCT o.order_id) AS Order_Count,
       Dense_rank()
         OVER(
           PARTITION BY o.order_state
           ORDER BY Count(DISTINCT o.order_id) DESC) AS City_Rank
FROM   category cat
       LEFT JOIN product_info p
              ON cat.id = p.category_id
       LEFT JOIN ordered_items i
              ON p.product_id = i.item_id
       LEFT JOIN orders o
              ON i.order_id = o.order_id
       LEFT JOIN customer_info c
              ON o.customer_id = c.id
WHERE  ( Lower(cat.NAME) LIKE '%apparel%'
          OR Lower(cat.NAME) LIKE '%outdoor%' )
       AND c.segment = 'Home Office'
GROUP  BY o.order_state,
          o.order_city; 

-- **********************************************************************************************************************************


/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/
SELECT o.Shipping_Mode,
       Count(DISTINCT o.order_id)                    AS Shipping_Underestimated_Order_Count,
       Rank()
         OVER(
           ORDER BY Count(DISTINCT o.order_id) DESC) AS Shipping_Mode_Rank
FROM   orders o
       INNER JOIN customer_info c
               ON o.customer_id = c.id
WHERE  o.order_status IN ( 'COMPLETE', 'CLOSED' )
       AND o.scheduled_shipping_days < o.real_shipping_days
       AND c.segment = 'Consumer'
GROUP  BY o.shipping_mode; 
-- **********************************************************************************************************************************





