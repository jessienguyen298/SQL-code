USE Salesdata;
ALTER TABLE customers
ADD FOREIGN KEY (salesRepEmployeeNumber) REFERENCES employees(employeeNumber);

ALTER TABLE employees
ADD FOREIGN KEY (reportsTo) REFERENCES employees (employeeNumber);

ALTER TABLE employees
ADD FOREIGN KEY (officeCode)REFERENCES offices(officeCode);

ALTER TABLE orderdetails
ADD FOREIGN KEY (orderNumber) REFERENCES orders(orderNumber);

ALTER TABLE orderdetails
ADD FOREIGN KEY (productCode) REFERENCES products(productCode);


ALTER TABLE orders
ADD FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber);

ALTER TABLE products
ADD FOREIGN KEY (productLine) REFERENCES productlines(productLine);

ALTER TABLE payments
ADD FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber);
