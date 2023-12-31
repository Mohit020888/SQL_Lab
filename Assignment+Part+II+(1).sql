
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

SELECT TO_CHAR(o."Order_Date", 'YYYY-MM') AS Month,
       SUM(oi."Quantity") AS Quantities_sold,
       SUM(oi."Sales") AS Sales
FROM orders o
JOIN ordered_items oi ON o."Order_Id" = oi."Order_Id"
JOIN product_info pi ON oi."Item_Id" = pi."Product_Id"
WHERE pi."Product_Name" LIKE '%Nike%'
GROUP BY Month
ORDER BY Month;





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
SELECT pi."Product_Id", pi."Product_Name", c."Name" as Category_Name, d."Name" as Department_Name, pi."Product_Price"
FROM product_info pi
JOIN category c ON pi."Category_Id" = c."Id"
JOIN department d ON c."Id" = d."Id"
ORDER BY pi."Product_Price" DESC
LIMIT 5;


-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/

SELECT pi."Product_Name", SUM(oi."Sales") AS Sales, COUNT(DISTINCT o."Order_Id") AS Order_Count
FROM orders o
JOIN ordered_items oi ON o."Order_Id" = oi."Order_Id"
JOIN product_info pi ON oi."Item_Id" = pi."Product_Id"
WHERE o."Type" = 'CASH'
GROUP BY pi."Product_Name"
ORDER BY Order_Count DESC, Sales DESC
LIMIT 10;


-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/

SELECT *
FROM orders o
JOIN customer_info c ON o."Customer_Id" = c."Id"
WHERE c."State" = 'TX'
  AND c."Street" LIKE '%Plaza%'
  AND c."Street" NOT LIKE '%Mountain%'
ORDER BY o."Order_Id";


-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/

SELECT COUNT(DISTINCT o."Order_Id") AS Order_Count
FROM orders o
JOIN customer_info c ON o."Customer_Id" = c."Id"
JOIN ordered_items oi ON o."Order_Id" = oi."Order_Id"
JOIN product_info pi ON oi."Item_Id" = pi."Product_Id"
JOIN department d ON pi."Department_Id" = d."Id"
WHERE c."Segment" = 'Home Office'
  AND d."Name" IN ('Apparel', 'Outdoors');

 



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

SELECT "Order_State", "Order_City", COUNT(*) AS "Order_Count",
       DENSE_RANK() OVER (PARTITION BY "Order_State" ORDER BY COUNT(*) DESC, "Order_City") AS "City_Rank"
FROM orders o
JOIN customer_info c ON o."Customer_Id" = c."Id"
JOIN ordered_items oi ON o."Order_Id" = oi."Order_Id"
JOIN product_info pi ON oi."Item_Id" = pi."Product_Id"
JOIN department d ON pi."Department_Id" = d."Id"
WHERE c."Segment" = 'Home Office'
  AND d."Name" IN ('Apparel', 'Outdoors')
GROUP BY "Order_State", "Order_City"
ORDER BY "Order_State" ASC, "City_Rank" ASC, "Order_City" ASC;


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

WITH underestimated_orders AS (
  SELECT o."Shipping_Mode",
         EXTRACT(YEAR FROM o."Order_Date") AS "Order_Year",
         COUNT(*) AS "Shipping_Underestimated_Order_Count",
         ROW_NUMBER() OVER (PARTITION BY EXTRACT(YEAR FROM o."Order_Date") ORDER BY COUNT(*) DESC) AS "Shipping_Mode_Rank"
  FROM orders o
  JOIN customer_info c ON o."Customer_Id" = c."Id"
  WHERE o."Scheduled_Shipping_Days" < o."Real_Shipping_Days"
    AND o."Order_Status" IN ('COMPLETE', 'CLOSED')
    AND c."Segment" = 'Consumer'
  GROUP BY o."Shipping_Mode", "Order_Year"
)
SELECT "Shipping_Mode", "Shipping_Underestimated_Order_Count", "Shipping_Mode_Rank"
FROM underestimated_orders
ORDER BY "Order_Year" ASC, "Shipping_Mode_Rank" ASC;


-- **********************************************************************************************************************************





