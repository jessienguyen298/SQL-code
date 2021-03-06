/*
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Converting Data Types, procedures

*/


-- The difference in days between the most recent and oldest order date in the Orders file
SELECT DATEDIFF(D,Min(orderDate),MAX(orderDate)) as Days
FROM orders
;


--time between order date and ship date for each customer ordered by the largest difference
SELECT orderNumber, DATEDIFF(D, orderDate, shippedDate) as Days
FROM orders
ORDER BY Days DESC;


-- the value of orders shipped in August 2004
SELECT o.orderNumber, (od.quantityOrdered*od.priceEach) as orderValue, o.orderDate
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.orderDate like '2004-08%'
ORDER BY o.orderDate


--the total value ordered, total amount paid, and their difference for each customer for orders placed in 2004 and payments received in 2004 
SELECT sum(od.quantityOrdered*od.priceEach) as TotalOrderValue, 
	sum(p.amount) as TotalPaid,
	(sum(od.quantityOrdered*od.priceEach)-sum(p.amount)) as difference
FROM orderdetails od 
JOIN orders o ON o.orderNumber = od.orderNumber
JOIN payments p ON p.customerNumber = o.customerNumber
WHERE o.orderDate like '2004%' AND p.paymentDate like '2004%'


-- DEBT in 2003
SELECT c.customerNumber, c.customerName, sum(quantityOrdered*priceEach) as debt
FROM customers c 
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE year(orderDate)='2003' 
	AND c.customerNumber NOT IN (SELECT customerNumber FROM payments WHERE year(paymentDate) = '2003')
GROUP BY c.customerNumber, c.customerName

--the employees who report to those employees who report to Diane Murphy
SELECT e1.employeeNumber, CONCAT(e1.firstName, ' ', e1.lastName) as fullName
FROM employees e1
JOIN employees e2
ON e1.reportsTo = e2.employeeNumber
WHERE e2.employeeNumber = 
              (SELECT employeeNumber 
              FROM employees 
              WHERE CONCAT(firstName, ' ', lastName) ='Diane Murphy');
            
	    
--the percentage value of each product in inventory
SELECT productline, 100*SUM(quantityInStock)/
	(SELECT SUM(quantityInStock) 
	FROM products) as percentageInStock
FROM products
GROUP BY productLine
ORDER BY percentageInStock DESC;



-- payment by month in 2004
SELECT YEAR(paymentDate) as year, MONTH(paymentDate) as month, SUM(amount) as sum_ym
FROM payments 
WHERE YEAR(paymentDate) = '2004'
GROUP BY YEAR(paymentDate), MONTH(paymentDate)
ORDER BY MONTH(paymentDate);

--orders by month
SELECT YEAR(orderDate) as year, MONTH(orderDate) as month, SUM(quantityOrdered*priceEach) as sum_ym
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE YEAR(orderDate) = '2004'
GROUP BY YEAR(orderDate), MONTH(orderDate)
ORDER BY MONTH(orderDate);

-- the ratio the value of payments made to orders received for each month of 2004
SELECT orderyear as year, ordermonth as month, 100*monthpaid/monthorder as ratiopaidorders
FROM monthlypaid 
JOIN monthlyorder ON ordermonth = paymentmonth
WHERE paymentyear = '2004'


--the difference in the amount received for each month of 2004 compared to 2003
SELECT p1.month, (p2.monthpaid - p1.monthpaid) as difference
FROM(
	SELECT  YEAR(paymentDate) AS year, MONTH(PaymentDate) as month, SUM(amount) as monthpaid
      FROM Payments 
	  WHERE YEAR(paymentDate)= '2003'
	  GROUP BY YEAR(paymentDate), MONTH(PaymentDate)
	  )p1
JOIN (
	SELECT  YEAR(paymentDate) AS year, MONTH(PaymentDate) as month, SUM(amount) as monthpaid
      FROM Payments 
	  WHERE YEAR(paymentDate)= '2004'
	  GROUP BY YEAR(paymentDate), MONTH(PaymentDate)
	  )p2
ON p1.month =p2.month


--the amount ordered in a specific month and year for customers containing a specified character string in their name
GO 
CREATE PROCEDURE customerorderreport @month int, @year int, @name varchar(30)
AS
BEGIN
SELECT c.customerNumber, c.customerName,
			DATEPART(year, orderDate) as year, 
			DATEPART(month, orderdate) as month,
			sum(quantityOrdered*priceEach) as ordervalue
	FROM customers c 
	JOIN orders o ON c.customerNumber = o.customerNumber
	JOIN orderdetails od ON o.orderNumber = od.orderNumber
	WHERE DATEPART(year, orderDate) = @year and DATEPART(month, orderdate)= @month and c.customerName like ('%' + @name + '%')
	GROUP BY c.customerNumber, c.customerName, DATEPART(year, orderDate), DATEPART(month, orderdate)
END;


--change creditlimit by country
GO 
CREATE PROCEDURE updatecreditlimit @ratio decimal(5,2), @country varchar(30)
	AS
	BEGIN
	UPDATE customers
		SET creditLimit = creditLimit * @ratio
		FROM customers
		WHERE country = @country;
	END;
	

--Compute the revenue generated by each customer based on their orders. Also, show each customer's revenue as a percentage of total revenue
SELECT c.customerName,c.customerNumber,
		sum(quantityOrdered*priceEach) as revenue, 
		ROUND(100*sum(quantityOrdered*priceEach)/(SELECT sum(quantityOrdered*priceEach) FROM orderdetails),2) as ratioRevenue
FROM customers c 
	JOIN orders o ON c.customerNumber = o.customerNumber
	JOIN orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName,c.customerNumber
ORDER BY c.customerName;

--the profit generated by each customer based on their orders. Also, show each customer's profit as a percentage of total profit. Sort by profit descending
SELECT c.customerName,c.customerNumber,
		(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) as profit, 
		ROUND(100*(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice))/
		(SELECT 
			(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) 
		FROM orderdetails od 
		JOIN products p 
		ON p.productCode = od.productCode ),
		2) as ratioprofit
FROM customers c 
	JOIN orders o ON c.customerNumber = o.customerNumber
	JOIN orderdetails od ON o.orderNumber = od.orderNumber
	JOIN products p ON p.productCode = od.productCode
GROUP BY c.customerName,c.customerNumber
ORDER BY profit DESC;

-- the profit generated by each sales representative based on the orders from the customers they serve. Sort by profit generated descending
SELECT c.SalesRepEmployeeNumber, CONCAT(e.firstName,' ', e.lastName) as fullName,
		(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) as profit, 
		ROUND(100*(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice))/
		(SELECT 
			(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) 
		FROM orderdetails od 
		JOIN products p 
		ON p.productCode = od.productCode ),
		2) as ratioprofit
FROM customers c 
	JOIN orders o ON c.customerNumber = o.customerNumber
	JOIN orderdetails od ON o.orderNumber = od.orderNumber
	JOIN products p ON p.productCode = od.productCode
	JOIN employees e ON c.SalesRepEmployeeNumber= e.employeeNumber
GROUP BY c.SalesRepEmployeeNumber, CONCAT(e.firstName,' ', e.lastName)
ORDER BY profit DESC;


--the revenue generated by each product, sorted by product name
SELECT p.productCode,productName,
		sum(quantityOrdered*priceEach) as revenue, 
		ROUND(100*sum(quantityOrdered*priceEach)/(SELECT sum(quantityOrdered*priceEach) FROM orderdetails),2) as ratioRevenue
FROM  products p 
	JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode,productName
ORDER BY productName;

--the profit generated by each product line, sorted by profit descending
SELECT p.productLine,
		(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) as profit, 
		ROUND(100*(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice))/
		(SELECT 
			(sum(quantityOrdered*priceEach)-sum(quantityOrdered*buyPrice)) 
		FROM orderdetails od 
		JOIN products p 
		ON p.productCode = od.productCode ),
		2) as ratioprofit
FROM  products p 
	JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productLine
ORDER BY profit DESC;


--payments in any month and year are more than twice the average for that month and year
SELECT p.checkNumber, p.amount, p.paymentDate
FROM(
	SELECT *, AVG(amount) OVER (PARTITION BY YEAR(paymentDate), MONTH(PaymentDate)) as avg_ym
      FROM Payments 
	  )p
WHERE p.amount > 2 * avg_ym
ORDER BY paymentDate;

--the percentage value of its stock on hand as a percentage of the stock on hand for product line to which it belongs
SELECT productCode,
ROUND(100*quantityInStock*buyPrice/(SUM(quantityInStock*buyPrice) OVER (PARTITION BY productLine)),2) AS value_IL,
ROUND(100*quantityInStock*buyPrice/(SELECT SUM(quantityInStock*buyPrice) FROM products),2) AS value_IS
FROM products
ORDER BY value_IS, value_IL

-- orders containing more than two products, report those products that constitute more than 50% of the value of the order
SELECT od1.productCode, od1.orderNumber
FROM orderdetails od1
JOIN 
	(SELECT orderNumber, COUNT(productCode) as type_products, 
			SUM(quantityOrdered*priceEach) as ordervalue
		FROM orderdetails
		GROUP BY orderNumber
		HAVING COUNT(productCode) >2) od2
ON od1.orderNumber = od2.orderNumber
WHERE quantityOrdered*priceEach*2 > od2.ordervalue
