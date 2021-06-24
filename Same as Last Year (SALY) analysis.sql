/*
Same as Last Year (SALY) analysis: concept to calculate sales revenue of a product code this year compare with the previous year, incase compare 2004 with 2003
skills: CTE, Join, temp_table
*/

SELECT od.productCode,sum(quantityOrdered*priceEach) as sales_2003 INTO #sales2003
FROM orderdetails  od 
JOIN orders o ON o.orderNumber =od.orderNumber 
WHERE  orderDate BETWEEN '2002-12-31' AND '2004-01-01'
GROUP BY od.productCode;

SELECT od.productCode,sum(quantityOrdered*priceEach) as sales_2004 INTO #sales2004
FROM orderdetails  od 
JOIN orders o ON o.orderNumber =od.orderNumber 
WHERE  orderDate BETWEEN '2003-12-31' AND '2005-01-01'
GROUP BY od.productCode;

Select * from #sales2003;
Select * from #sales2004;

SELECT s3.productCode, sales_2003, sales_2004, round((100*sales_2003/sales_2004),2) as percentagechange
FROM #sales2003 s3 LEFT JOIN #sales2004 s4 ON s3.productCode = s4.productCode;

DROP TABLE #sales2003;
DROP TABLE #sales2004;
