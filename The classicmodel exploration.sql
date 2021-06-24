/*
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types, procedures

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
GO 
CREATE VIEW inventory as
SELECT productline, sum(quantityInStock) as stocks 
FROM products
GROUP BY productLine;

SELECT productline, 100*stocks/(SELECT SUM(stocks) FROM inventory) as percentageInStock
FROM inventory
ORDER BY percentageInStock DESC;


--convert miles per gallon to liters per 100 kilometers
/*
Convert gallon/miles to litter/100km
1 gallon = 4.546092 litter
1 miles = 1.609344 km
*/

GO
CREATE PROCEDURE convertunit @gallonPerMiles decimal(10,2)
AS
BEGIN
	DECLARE @litterper100km decimal(10,2)
	SET @litterper100km = @gallonPerMiles * (4.546092/100*1.609344);
	SELECT @litterper100km;
END

--a procedure to increase the price of a specified product category by a given percentage (create another view to check result)
GO
CREATE VIEW  products2 AS
SELECT * FROM products;

GO
CREATE PROCEDURE increasePrice (@percentage decimal(5,2), @line varchar(50))
AS
BEGIN
	UPDATE products2
	SET  MSRP = MSRP * @percentage
	FROM   products2 
	WHERE  productLine = @line;
END


-- payment by month in 2004
/* Create temp_table to extract payment month */
CREATE TABLE paymentsbymonth(
  customerNumber int NOT NULL,
  checkNumber varchar(50) NOT NULL,
  paymentmonth int NOT NULL,
  paymentyear int NOT NULL,
  amount decimal(10,2) NOT NULL,
  PRIMARY KEY (customerNumber,checkNumber)
 );

 INSERT INTO paymentsbymonth
 SELECT customerNumber, checkNumber,
		DATEPART(month, paymentdate),
		DATEPART(YEAR, paymentdate),
		amount
		FROM payments;

SELECT paymentyear, paymentmonth, sum(amount) 
FROM paymentsbymonth
WHERE paymentyear = '2004'
GROUP BY paymentyear, paymentmonth
ORDER BY paymentyear, paymentmonth ASC;

CREATE TABLE paymentsbymonth(
  customerNumber int NOT NULL,
  checkNumber varchar(50) NOT NULL,
  paymentmonth int NOT NULL,
  paymentyear int NOT NULL,
  amount decimal(10,2) NOT NULL,
  PRIMARY KEY (customerNumber,checkNumber)
 );

 INSERT INTO paymentsbymonth
 SELECT customerNumber, checkNumber,
		DATEPART(month, paymentdate),
		DATEPART(YEAR, paymentdate),
		amount
		FROM payments;
GO 
CREATE VIEW monthlypaid AS
SELECT paymentyear, paymentmonth, sum(amount) as monthpaid
FROM paymentsbymonth
GROUP BY paymentyear, paymentmonth;

--orders by month
CREATE TABLE orderbymonth(
orderNumber int NOT NULL,
orderyear int NOT NULL,
ordermonth int NOT NULL,
ordervalue int NOT NULL)

INSERT INTO orderbymonth(orderNumber, orderyear, ordermonth, ordervalue)
SELECT o.orderNumber, 
		DATEPART(year, orderdate),
		DATEPART(month, orderdate),
		quantityOrdered* priceEach
FROM orders o JOIN orderdetails od ON o.orderNumber = od.orderNumber;

GO
CREATE VIEW monthlyorder AS
SELECT orderyear, ordermonth, sum(ordervalue) as monthorder
FROM orderbymonth
GROUP BY orderyear, ordermonth;

-- the ratio the value of payments made to orders received for each month of 2004
SELECT orderyear as year, ordermonth as month, 100*monthpaid/monthorder as ratiopaidorders
FROM monthlypaid 
JOIN monthlyorder ON ordermonth = paymentmonth
WHERE paymentyear = '2004'


--the difference in the amount received for each month of 2004 compared to 2003
CREATE VIEW monthlypaid2003 AS
SELECT paymentyear, paymentmonth, monthpaid
FROM monthlypaid
WHERE paymentyear = '2003';

CREATE VIEW monthlypaid2004 AS
SELECT paymentyear, paymentmonth, monthpaid
FROM monthlypaid
WHERE paymentyear = '2004'

SELECT m3.paymentmonth, (m4.monthpaid-m3.monthpaid) as difference
FROM monthlypaid2003 m3 JOIN monthlypaid2004 m4 ON m3.paymentmonth = m4.paymentmonth


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


--

