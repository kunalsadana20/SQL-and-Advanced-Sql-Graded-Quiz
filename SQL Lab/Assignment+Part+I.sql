use supply_db ;

/*
Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/
SELECT p.product_name,
       p.product_id
FROM   product_info p
       INNER JOIN category c
               ON p.category_id = c.id
WHERE  lower(c.name) REGEXP 'golf'
ORDER  BY p.product_id; 

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/
SELECT p.product_name,
       Sum(o.sales) AS Sales
FROM   product_info p
       INNER JOIN category c
               ON p.category_id = c.id
       INNER JOIN ordered_items o
               ON p.product_id = o.item_id
WHERE  lower(c.name) REGEXP 'golf'
GROUP  BY p.product_name
ORDER  BY sales DESC
LIMIT  10; 

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/
SELECT c.segment AS Customer_segment,
       Count(o.order_id) AS Orders
FROM   orders o
       INNER JOIN customer_info c
               ON o.customer_id = c.id
GROUP  BY c.segment
ORDER  BY orders DESC; 

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/
WITH order_summary
AS
  (
             SELECT     segment         AS customer_segment,
                        count(order_id) AS orders
             FROM       orders o
             INNER JOIN customer_info c
             ON         o.customer_id = c.id
             WHERE      real_shipping_days = 6
             GROUP BY   segment )
  SELECT     t1.customer_segment,
             round(t1.orders / sum(t2.orders) * 100, 1) AS percentage_order_split
  FROM       order_summary t1
  INNER JOIN order_summary t2
  GROUP BY   customer_segment;

-- **********************************************************************************************************************************
