/*
Topic: Subqueries (in the Select, From, and Where Statement)
*/

USE Salesdata;

--products containing the name 'Ford' 
SELECT productCode, productName 
FROM products
WHERE productName like '%Ford%'
;

--products ending in 'ship'.
SELECT productCode, productName 
FROM products
WHERE productName like '%ship'
;

-- the number of customers in Denmark, Norway, and Sweden
SELECT country, COUNT(customerNumber) as CustomerQuantity
FROM customers
WHERE country IN ('Denmark', 'Norway', 'Sweden')
GROUP BY country
ORDER BY CustomerQuantity desc 
;


-- product code in the range S700_1000 to S700_1499
SELECT productCode, productName
FROM products
WHERE productCode like 'S700_10%' 
		OR productCode like 'S700_11%'
		OR productCode like 'S700_12%'
		OR productCode like 'S700_13%'
		OR productCode like 'S700_14%'
;


--employees called Dianne or Diane
SELECT lastName, firstName
FROM employees
WHERE lastName like 'Dianne' 
		OR lastName like 'Diane'
		OR firstName like 'Dianne'
		OR firstName like 'Diane'
;

-- the top of the organization
SELECT lastName, firstName
FROM employees
WHERE reportsTo is NULL
;

--reports to William Patterson
SELECT lastName, firstName
FROM employees
WHERE reportsTo = 
		(SELECT employeeNumber
		FROM employees
		WHERE lastName= 'Patterson' AND firstName = 'William')
    
 
