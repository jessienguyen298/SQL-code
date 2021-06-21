
-- the products purchased by Herkku Gifts
SELECT p.productCode, p.productName
FROM products p
	JOIN orderdetails od ON p.productCode = od.productCode
	JOIN orders o ON o.orderNumber = od.orderNumber
	JOIN customers c ON c.customerNumber = o.customerNumber
WHERE c.customerName= 'Herkku Gifts'
;

--Compute the commission for each sales representative (5%), Sort by employee last name and first name
SELECT e.employeeNumber,
      SUM(od.quantityOrdered*od.priceEach*0.05) as comission, 
      e.lastName, 
      e.firstName
FROM orderdetails od 
    JOIN orders o ON od.orderNumber = o.orderNumber
    JOIN customers c ON o.customerNumber = c.customerNumber
    JOIN employees e ON e.employeeNumber = c.SalesRepEmployeeNumber
GROUP BY e.employeeNumber, e.lastName, e.firstName
ORDER BY e.lastName, e.firstName ASC
;


