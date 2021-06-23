/*
Basket of goods analysis: A common retail analytics task is to analyze each basket or order to learn what products are often purchased together. 
In this time, report the names of products that appear in the same order ten or more times.
*/

USE Salesdata;

--create pair orders table
SELECT * INTO #temporder 
FROM (
	SELECT od1.orderNumber, CONCAT(od1.productCode,' ', od2.productCode) AS items
	FROM (SELECT DISTINCT productCode, orderNumber FROM orderdetails) od1
	JOIN (SELECT DISTINCT productCode, orderNumber FROM orderdetails) od2
	ON od1.orderNumber = od2.orderNumber
	WHERE od1.productCode != od2.productCode AND od1.productCode < od2.productCode
	) temporder;

--create showing frequency	
SELECT * INTO #frequency
FROM(
SELECT items, count(*) as frequency FROM #temporder
GROUP BY items
) frequency;

--filter basket items which have been often bought together more than 10 times 
SELECT * INTO #frequencyitem 
FROM 
(SELECT RTRIM(LEFT(items, 9)) as item1, LTRIM(RIGHT(items, 9)) as item2
FROM #frequency
WHERE frequency >= 10) frequencyitem 

 --showing pair basket items and its name
 SELECT item1, p1.productName, item2, p2.productName
 FROM #frequencyitem
 JOIN products p1 ON item1 = p1.productCode
 JOIN products p2 ON item2 = p2.productCode;

 DROP TABLE #temporder;
 DROP TABLE #frequency;
 DROP TABLE #frequencyitem;





