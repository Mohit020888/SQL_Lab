-- Active: 1689443183275@@127.0.0.1@5432@postgres@public

/*Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/
SELECT "Product_Id", "Product_Name"
FROM product_info
WHERE "Category_Id" IN (
    SELECT "Id"
    FROM category
    WHERE "Name" LIKE '%Golf%'
)
ORDER BY "Product_Id";

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.
*/

SELECT p."Product_Name", SUM(oi."Sales") AS Total_Sales
FROM product_info p
JOIN ordered_items oi ON p."Product_Id" = oi."Item_Id"
JOIN category c ON p."Category_Id" = c."Id"
WHERE c."Name" LIKE '%Golf%'
GROUP BY p."Product_Name"
ORDER BY Total_Sales DESC
LIMIT 10;

-- **********************************************************************************************************************************



/*
Question: Segment wise orders
Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders
*/

SELECT c."Segment" AS Customer_segment, COUNT(*) AS Orders
FROM customer_info c
JOIN orders o ON c."Id" = o."Customer_Id"
GROUP BY c."Segment"
ORDER BY Orders DESC;

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

SELECT c."Segment" AS Customer_segment, 
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders WHERE "Real_Shipping_Days" = 6)), 1) AS Percentage_order_split
FROM customer_info c
JOIN orders o ON c."Id" = o."Customer_Id"
WHERE o."Real_Shipping_Days" = 6
GROUP BY c."Segment"
ORDER BY Percentage_order_split DESC;




