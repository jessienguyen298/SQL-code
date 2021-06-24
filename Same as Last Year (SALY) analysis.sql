/*
Same as Last Year (SALY) analysis: concept to calculate sales revenue of a product code this year compare with the previous year, incase compare 2004 with 2003
skills: CTE, Join, Case when
*/
	 
SELECT od.productCode,
       SUM(CASE WHEN year(orderDate) = 2004 THEN quantityOrdered*priceEach END) AS sales_2003,
       SUM(CASE WHEN year(orderDate) = 2003 THEN quantityOrdered*priceEach END) AS sales_2004
FROM orderdetails od 
JOIN orders o ON o.orderNumber = od.orderNumber
GROUP BY od.productCode;




