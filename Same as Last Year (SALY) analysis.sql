/*
Same as Last Year (SALY) analysis: concept to calculate sales revenue of a product code this year compare with the previous year, incase compare 2004 with 2003
skills: CTE, Join, Case when
*/
	 
SELECT od.productCode,
       SUM(CASE WHEN year(orderDate) = 2003 THEN quantityOrdered*priceEach END) AS sales_2003,
       SUM(CASE WHEN year(orderDate) = 2004 THEN quantityOrdered*priceEach END) AS sales_2004,
	   ROUND(
	   (100*SUM(CASE WHEN year(orderDate) = 2003 THEN quantityOrdered*priceEach END)
	   / SUM(CASE WHEN year(orderDate) = 2004 THEN quantityOrdered*priceEach END))
	   ,2) as percentagechange
FROM orderdetails od 
JOIN orders o ON o.orderNumber = od.orderNumber
GROUP BY od.productCode;

-- payment of customers 2003 vs 2004
SELECT c.customerName,c.customerNumber,
       SUM(CASE WHEN year(paymentDate) = 2003 THEN amount END) AS payment_2003,
       SUM(CASE WHEN year(paymentDate) = 2004 THEN amount END) AS payment_2004
FROM customers c
JOIN payments p ON c.customerNumber = p.customerNumber
GROUP BY c.customerName,c.customerNumber;


