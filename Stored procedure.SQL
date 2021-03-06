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
	
