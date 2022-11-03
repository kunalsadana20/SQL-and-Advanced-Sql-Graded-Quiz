use supply_db;

/**
Get the number of orders by the Type of Transaction excluding the orders shipped from Sangli and Srinagar. 
Also, exclude the SUSPECTED_FRAUD cases based on the Order Status, and sort the result in the descending order based on the number of orders.
**/
SELECT Type,
	count(Order_Id) as num_of_orders
FROM orders
WHERE Order_City<>'Sangli'
	AND Order_City<>'Srinagar'
	AND Order_Status<>'Suspected_Fraud'
GROUP BY Type
ORDER BY num_of_orders DESC;

/**
Get the list of the Top 3 customers based on the completed orders along with the following details:
Customer Id
Customer First Name
Customer City
Customer State
Number of completed orders
Total Sales
**/
SELECT 
	o.Customer_Id,
    c.First_Name,
    c.City,
    c.State,
    COUNT(DISTINCT o.Order_Id) as Number_of_completed_orders,
    SUM(i.Sales) as Total_Sales
FROM orders o
	INNER JOIN customer_info c
		ON o.Customer_Id=c.Id
	INNER JOIN ordered_items i
		ON i.Order_Id=o.Order_Id
WHERE o.Order_Status='COMPLETE'
GROUP BY o.Customer_Id
ORDER BY Number_of_completed_orders DESC
	LIMIT 3;
    
-- given soln
WITH order_summary AS
(
select 
ord.order_id,
ord.customer_id, 
SUM(sales) AS ord_sales
from orders as ord
JOIN
ordered_items as itm
ON ord.order_id=itm.order_id
WHERE ord.order_status='COMPLETE'
GROUP BY ord.order_id
)
SELECT Id AS Customer_id,
First_Name AS Customer_First_Name, 
City AS Customer_City, 
State AS Customer_State,
COUNT(DISTINCT order_id) as Completed_Orders,
SUM(ord_sales) as Total_Sales
FROM 
order_summary as ord
INNER JOIN
customer_info as cust
ON ord.customer_id=cust.id
GROUP BY 
Customer_id,
Customer_First_Name,
Customer_City
ORDER BY Completed_Orders DESC, Total_Sales DESC
LIMIT 3;

/**
Get the order count by the Shipping Mode and the Department Name. 
Consider departments with at least 40 closed/completed orders.
**/
WITH ship_dept_ord AS
(
	SELECT o.Shipping_Mode,
			d.Name as Department_Name,
			o.Order_Id,
            o.Order_Status
	FROM orders o
		INNER JOIN ordered_items i
			ON o.order_id=i.Order_Id
		INNER JOIN product_info p
			ON i.Item_Id=p.Product_Id
		INNER JOIN department d
			ON p.Department_Id=d.Id
),
dept_ord AS
(
	SELECT Department_Name,
			COUNT(Order_Id) AS order_count
	FROM ship_dept_ord
    WHERE Order_Status IN ('CLOSED','COMPLETE')
	GROUP BY Department_Name
	HAVING order_count>=40
)
SELECT Shipping_mode,
		Department_Name,
		COUNT(Order_Id) as order_count
FROM ship_dept_ord
WHERE Department_Name IN 
	(SELECT Department_Name
    FROM dept_ord)
GROUP BY Shipping_Mode,
		Department_Name;


-- given soln		
With ord_dept_summary as
( 
SELECT ord.order_id, ord.shipping_mode, d.name AS department_name, order_status
FROM
orders as ord
JOIN
ordered_items as ord_itm
ON ord.order_id=ord_itm.order_id
JOIN
product_info as p
ON ord_itm.item_id=p.product_id
JOIN
department as d
ON p.department_id=d.id
),
dept_summary AS
(
SELECT 
department_name, 
COUNT(order_id) as order_count
FROM
ord_dept_summary
WHERE order_status IN ('COMPLETE' , 'CLOSED')
GROUP BY department_name
),
dept_list AS
(
SELECT distinct department_name 
FROM 
dept_summary
WHERE order_count>=40
)
SELECT 
Shipping_mode, 
Department_Name, 
COUNT(Order_Id) as order_count
FROM ord_dept_summary
WHERE Department_Name IN 
(SELECT * FROM dept_list)
GROUP BY 
Shipping_Mode,
Department_Name; 


/**
“Create a new field as shipment compliance based on Real_Shipping_Days and Scheduled_Shipping_Days. It should have the following values:
Cancelled shipment: If the Order Status is SUSPECTED_FRAUD or CANCELED
Within schedule: If shipped within the scheduled number of days 
On time: If shipped exactly as per schedule
Up to 2 days of delay: If shipped beyond schedule but delayed by 2 days
Beyond 2 days of delay: If shipped beyond schedule with a delay of more than 2 days

-- After completing the query and executing it, which shipping mode 
-- was observed to have the highest number of delayed orders and what was the number of delayed orders?	
**/
WITH ship_compl AS
(
	SELECT Order_Id,
			Order_Status,
            Shipping_Mode,
			Real_shipping_days,
			Scheduled_shipping_days,
	CASE
		WHEN Order_status IN ('SUSPECTED_FRAUD','CANCELED') THEN 'Cancelled shipment'
		WHEN Real_shipping_days-Scheduled_shipping_days<0 THEN 'Within schedule'
		WHEN Real_shipping_days-Scheduled_shipping_days=0 THEN 'On time'
		WHEN Real_shipping_days-Scheduled_shipping_days<=2 THEN 'Up to 2 days of delay'
		WHEN Real_shipping_days-Scheduled_shipping_days>2 THEN 'Beyond 2 days of delay'
		ELSE 'Others'
	END AS shipment_compliance
	from orders
)
SELECT Shipping_Mode,
		COUNT(Order_Id) as Delayed_Orders
FROM ship_compl
WHERE shipment_compliance IN ('Up to 2 days of delay','Beyond 2 days of delay')
GROUP BY Shipping_Mode;

-- given soln
SELECT
order_id,
Real_Shipping_Days, Scheduled_Shipping_Days, 
Shipping_Mode, 
order_status,
CASE WHEN order_status = 'SUSPECTED_FRAUD' OR order_status = 'CANCELED' THEN 'Cancelled shipment'
WHEN Real_Shipping_Days<Scheduled_Shipping_Days THEN 'Within schedule'
     WHEN Real_Shipping_Days=Scheduled_Shipping_Days THEN 'On Time'
     WHEN Real_Shipping_Days<=Scheduled_Shipping_Days+2 THEN 'Upto 2 days of delay'
     WHEN Real_Shipping_Days>Scheduled_Shipping_Days+2 THEN 'Beyond 2 days of delay'
ELSE 'Others' END AS shipment_compliance
FROM
orders;


/**
“An order is canceled when the status of the order is either CANCELED or SUSPECTED_FRAUD. 
Obtain the list of states by the order cancellation% and sort them in the descending order of the cancellation%.
Definition: Cancellation% = Cancelled order / Total orders”
**/
WITH ord_cancel AS
(
	SELECT order_id,
			order_status,
			order_state as State,
	CASE
		WHEN order_status IN ('CANCELED','SUSPECTED_FRAUD') THEN 1
		ELSE 0
	END AS Cancelled
	FROM orders
)
SELECT State,
		SUM(Cancelled) as Total_cancel,
        COUNT(Order_Id) as Total_orders,
		SUM(Cancelled)/COUNT(Order_Id)*100 AS Cancellation_perc
FROM ord_cancel
GROUP BY State
ORDER BY Cancellation_perc DESC;

-- given soln
WITH cancelled_orders_summary AS
(
SELECT
Order_State, 
COUNT(order_id) as cancelled_orders
FROM Orders
WHERE order_status='CANCELED' OR order_status='SUSPECTED_FRAUD'
GROUP BY Order_State
),
total_orders_summary AS
(
SELECT
Order_State, 
COUNT(order_id) as total_orders
FROM Orders
GROUP BY Order_State
)
SELECT t.order_state,
cancelled_orders, total_orders,
cancelled_orders/total_orders*100 as cancellation_perc
FROM 
cancelled_orders_summary as c
RIGHT JOIN
total_orders_summary as t
ON c.Order_State=t.Order_state
ORDER BY cancellation_perc DESC;
