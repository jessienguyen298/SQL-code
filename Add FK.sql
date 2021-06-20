ALTER TABLE customers
ADD FOREIGN KEY (employeeNumber) REFERENCES employees(employeeNumber);

ALTER TABLE employees
ADD FOREIGN KEY (reportsTo, officeCode) REFERENCES employees (employeeNumber, officeCode);

ALTER TABLE orderdetails
ADD FOREIGN KEY (orderNumber, productCode) REFERENCES orders(orderNumber, productCode);

ALTER TABLE orderdetails
ADD FOREIGN KEY (productCode) REFERENCES products(productCode)

ALTER TABLE orders
ADD FOREIGN KEY (customerNumber) REFERENCES customers (customerNumber)

ALTER TABLE products
ADD FOREIGN KEY (productLine) REFERENCES productlines(productLine)