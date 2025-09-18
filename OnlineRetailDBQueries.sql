

CREATE DATABASE OnlineRetailDB;
GO


USE OnlineRetailDB;
Go


CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);


CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);


CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'COLUMN'; 

CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);


SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON o.OrderId = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity * oi.Price) AS TotalSales
FROM OrderItems oi
JOIN Products p 
ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;


SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders;

SELECT CustomerID, FirstName, LastName, TotalSpent, rn
FROM
(SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpent,
ROW_NUMBER() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS rn
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerId
GROUP BY c.CustomerID, c.FirstName, c.LastName)
sub WHERE rn <= 5;

SELECT CategoryID, CategoryName, TotalQuantitySold, rn
FROM (
SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity) AS TotalQuantitySold,
ROW_NUMBER() OVER (ORDER BY SUM(oi.Quantity) DESC) AS rn
FROM OrderItems oi
JOIN Products p 
ON oi.ProductID = p.ProductID
JOIN Categories c
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName) sub
WHERE rn = 1;


INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Keyboard', 1, 39.99, 0);

SELECT * FROM Products WHERE Stock = 0;

SELECT ProductID, ProductName, Stock FROM Products WHERE Stock = 0;

SELECT p.ProductID, p.ProductName, c.CategoryName, p.Stock 
FROM Products p JOIN Categories c
ON p.CategoryID = c.CategoryID
WHERE Stock = 0;

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone
FROM Customers c JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATEADD(DAY, -30, GETDATE());

SELECT YEAR(OrderDate) as OrderYear,
MONTH(OrderDate) as OrderMonth,
COUNT(OrderID) as TotalOrders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

SELECT TOP 1 o.OrderID, o.OrderDate, o.TotalAmount, c.FirstName, c.LastName
FROM Orders o JOIN Customers c
ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC;


SELECT c.CategoryID, c.CategoryName, AVG(p.Price) as AveragePrice 
FROM Categories c JOIN Products p
ON c.CategoryID = p.ProductID
GROUP BY c.CategoryID, c.CategoryName;

SELECT c.CustomerID, c.FirstName, c.LastName, c.Email, c.Phone, O.OrderID, o.TotalAmount
FROM Customers c LEFT OUTER JOIN Orders o
ON c.CustomerID = o.CustomerID
WHERE o.OrderId IS NULL;

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalQuantitySold
FROM OrderItems oi JOIN Products p
ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY p.ProductName;

SELECT c.CategoryID, c.CategoryName, SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM OrderItems oi JOIN Products p
ON oi.ProductID = p.ProductID
JOIN Categories c
ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;

SELECT c.CategoryID, c.CategoryName, p1.ProductID, p1.ProductName, p1.Price
FROM Categories c JOIN Products p1
ON c.CategoryID = p1.CategoryID
WHERE p1.Price = (SELECT Max(Price) FROM Products p2 WHERE p2.CategoryID = p1.CategoryID)
ORDER BY p1.Price DESC;

SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, o.TotalAmount
FROM Orders o JOIN Customers c
ON o.CustomerID = c.CustomerID
WHERE o.TotalAmount >= 49.99
ORDER BY o.TotalAmount DESC;

SELECT p.ProductID, p.ProductName, COUNT(oi.OrderID) as OrderCount
FROM Products p JOIN OrderItems oi
ON p.ProductID = oi.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY OrderCount DESC;

SELECT TOP 3 p.ProductID, p.ProductName, COUNT(oi.OrderID) AS OrderCount
FROM OrderItems oi JOIN  Products p
ON oi.ProductID = p.ProductID
GROUP BY  p.ProductID, p.ProductName
ORDER BY OrderCount DESC;

SELECT Country, COUNT(CustomerID) AS TotalCustomers
FROM Customers GROUP BY Country ORDER BY TotalCustomers DESC;

SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalSpending
FROM Customers c JOIN Orders o
ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;


SELECT o.OrderID, c.CustomerID, c.FirstName, c.LastName, COUNT(oi.OrderItemID) AS NumberOfItems
FROM Orders o JOIN OrderItems oi
ON o.OrderID = oi.OrderID
JOIN Customers c 
ON o.CustomerID = c.CustomerID
GROUP BY o.OrderID, c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(oi.OrderItemID) >= 1
ORDER BY NumberOfItems;


CREATE TABLE ChangeLog (
	LogID INT PRIMARY KEY IDENTITY(1,1),
	TableName NVARCHAR(50),
	Operation NVARCHAR(10),
	RecordID INT,
	ChangeDate DATETIME DEFAULT GETDATE(),
	ChangedBy NVARCHAR(100)
);
GO

-- A. Triggers for Products Table
-- Trigger for INSERT on Products table
CREATE OR ALTER TRIGGER trg_Insert_Product
ON Products
AFTER INSERT
AS
BEGIN
	
	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'INSERT', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Products table.';
END;
GO

-- Try to insert one record into the Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Wireless Mouse', 1, 4.99, 20);

INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES ('Spiderman Multiverse Comic', 3, 2.50, 150);

SELECT * FROM Products;

SELECT * FROM ChangeLog;

CREATE OR ALTER TRIGGER trg_Update_Product
ON Products
AFTER UPDATE
AS
BEGIN	
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'UPDATE', inserted.ProductID, SYSTEM_USER
	FROM inserted;

	PRINT 'UPDATE operation logged for Products table.';
END;
GO

UPDATE Products SET Price = Price - 300 WHERE ProductID = 2;

CREATE OR ALTER TRIGGER trg_delete_Product
ON Products
AFTER DELETE
AS
BEGIN
	
	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Products', 'DELETE', deleted.ProductID, SYSTEM_USER
	FROM deleted;

	PRINT 'DELETE operation logged for Products table.';
END;
GO

-- Try to delete an existing record to see the effect of Trigger
DELETE FROM Products WHERE ProductID = 11;

-- B. Triggers for Customers Table
CREATE OR ALTER TRIGGER trg_Insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'INSERT', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	-- Display a message indicating that the trigger has fired.
	PRINT 'INSERT operation logged for Customers table.';
END;
GO

CREATE OR ALTER TRIGGER trg_Update_Customers
ON Customers
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'UPDATE', inserted.CustomerID, SYSTEM_USER
	FROM inserted;

	PRINT 'UPDATE operation logged for Customers table.';
END;
GO

-- Trigger for DELETE on Customers table
CREATE OR ALTER TRIGGER trg_Delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;

	-- Insert a record into the ChangeLog Table
	INSERT INTO ChangeLog (TableName, Operation, RecordID, ChangedBy)
	SELECT 'Customers', 'DELETE', deleted.CustomerID, SYSTEM_USER
	FROM deleted;

	PRINT 'DELETE operation logged for Customers table.';
END;
GO

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Virat', 'Kohli', 'virat.kingkohli@example.com', '123-456-7890', 'South Delhi', 'Delhi', 
'Delhi', '5456665', 'INDIA');
GO
	
UPDATE Customers SET State = 'Florida' WHERE State = 'IL';
GO
	
DELETE FROM Customers WHERE CustomerID = 5;
GO

Index on CategoryID: Usually created with the primary key.
*/

USE OnlineRetailDB;
GO
-- Clustered Index on Categories Table (CategoryID)
CREATE CLUSTERED INDEX IDX_Categories_CategoryID
ON Categories(CategoryID);
GO


ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Produ__440B1D61;

-- Clustered Index on Products Table (ProductID)
CREATE CLUSTERED INDEX IDX_Products_ProductID 
ON Products(ProductID);
GO

CREATE NONCLUSTERED INDEX IDX_Products_CategoryID
ON Products(CategoryID);
GO

CREATE NONCLUSTERED INDEX IDX_Products_Price
ON Products(Price);
GO

-- Recreate Foreign Key Constraint on OrderItems (ProductID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (ProductID) REFERENCES Products(ProductID);
GO



ALTER TABLE OrderItems DROP CONSTRAINT FK__OrderItem__Order__44FF419A;

CREATE CLUSTERED INDEX IDX_Orders_OrderID
ON Orders(OrderID);
GO

-- Non-Clustered Index on CustomerID: To speed up queries filtering by CustomerID.
CREATE NONCLUSTERED INDEX IDX_Orders_CustomerID
ON Orders(CustomerID);
GO

--  Non-Clustered Index on OrderDate: To speed up queries filtering or sorting by OrderDate.
CREATE NONCLUSTERED INDEX IDX_Orders_OrderDate
ON Orders(OrderDate);
GO

-- Recreate Foreign Key Constraint on OrderItems (OrderID Column)
ALTER TABLE OrderItems ADD CONSTRAINT FK_OrderItems_OrderID
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID);
GO


-- Clustered Index on OrderItemID
CREATE CLUSTERED INDEX IDX_OrderItems_OrderItemID
ON OrderItems(OrderItemID);
GO

CREATE NONCLUSTERED INDEX IDX_OrderItems_OrderID
ON OrderItems(OrderID);
GO

CREATE NONCLUSTERED INDEX IDX_OrderItems_ProductID
ON OrderItems(ProductID);
GO



ALTER TABLE Orders DROP CONSTRAINT FK__Orders__Customer__403A8C7D;

-- Clustered Index on CustomerID
CREATE CLUSTERED INDEX IDX_Customers_CustomerID
ON Customers(CustomerID);
GO

CREATE NONCLUSTERED INDEX IDX_Customers_Email
ON Customers(Email);
GO

CREATE NONCLUSTERED INDEX IDX_Customers_Country
ON Customers(Country);
GO

-- Recreate Foreign Key Constraint on Orders (CustomerID Column)
ALTER TABLE Orders ADD CONSTRAINT FK_Orders_CustomerID
FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);
GO


CREATE VIEW vw_ProductDeails AS
SELECT p.ProductID, p.ProductName, p.Price, p.Stock, c.CategoryName
FROM Products p INNER JOIN Categories c
ON p.CategoryID = c.CategoryID;
GO

-- Display product details with category names using view
SELECT * FROM vw_ProductDeails;

CREATE VIEW vw_CustomerOrders 
AS
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(o.OrderID) AS TotalOrders,
SUM(oi.Quantity * p.Price) as TotalAmount
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY c.CustomerID, c.FirstName, c.LastName;
GO


CREATE VIEW vw_RecentOrders 
AS
SELECT o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName,
SUM(oi.Quantity * oi.Price) as OrderAmount
FROM Customers c 
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, o.OrderDate, c.CustomerID, c.FirstName, c.LastName;
GO


SELECT * FROM vw_ProductDeails;


SELECT * FROM vw_ProductDeails WHERE Price BETWEEN 10 AND 500;


SELECT CategoryName, Count(ProductID) AS ProductCount
FROM vw_ProductDeails GROUP BY CategoryName; 


SELECT * FROM vw_CustomerOrders WHERE TotalOrders > 1;


SELECT CustomerID, FirstName, LastName, TotalAmount FROM vw_CustomerOrders
ORDER BY TotalAmount DESC;


SELECT * FROM vw_RecentOrders WHERE OrderAmount > 1000;


SELECT ro.OrderID, ro.OrderDate, ro.CustomerID, ro.FirstName, ro.LastName, ro.OrderAmount
FROM vw_RecentOrders ro
INNER JOIN 
(SELECT CustomerID, Max(OrderDate) as LatestOrderDate FROM vw_RecentOrders GROUP BY CustomerID)
latest
ON ro.CustomerID = latest.CustomerID AND ro.OrderDate = latest.LatestOrderDate
ORDER BY ro.OrderDate DESC;
GO


SELECT * FROM vw_ProductDeails WHERE CategoryName = 'Books';


SELECT pd.CategoryName, SUM(oi.Quantity * p.Price) AS TotalSales
FROM OrderItems oi
INNER JOIN Products p ON oi.ProductID = p.ProductID
INNER JOIN vw_ProductDeails pd ON p.ProductID = pd.ProductID
GROUP BY pd.CategoryName
ORDER BY TotalSales DESC;


SELECT co.CustomerID, co.FirstName, co.LastName, o.OrderID, o.OrderDate,
pd.ProductName, oi.Quantity, pd.Price
FROM Orders o 
INNER JOIN OrderItems oi ON o.OrderID = oi.OrderID
INNER JOIN vw_ProductDeails pd ON oi.ProductID = pd.ProductID
INNER JOIN vw_CustomerOrders co ON o.CustomerID = co.CustomerID
ORDER BY o.OrderDate DESC;


SELECT TOP 5 CustomerID, FirstName, LastName, TotalAmount 
FROM vw_CustomerOrders ORDER BY TotalAmount DESC;


SELECT * FROM vw_ProductDeails WHERE Stock < 50;


SELECT * from vw_RecentOrders WHERE OrderDate >= DATEADD(DAY, -7, GETDATE());


SELECT p.ProductID, p.ProductName, SUM(oi.Quantity) AS TotalSold
FROM vw_RecentOrders ro
INNER JOIN OrderItems oi ON ro.OrderID = oi.OrderID
INNER JOIN Products p ON oi.ProductID = p.ProductID
WHERE ro.OrderDate >= DATEADD(MONTH, -1, GETDATE())
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSold DESC;


CREATE LOGIN SalesUser WITH PASSWORD = 'strongpassword';


USE OnlineRetailDB;
GO

CREATE USER SalesUser FOR LOGIN SalesUser;



CREATE ROLE SalesRole;
CREATE ROLE MarketingRole;


EXEC sp_addrolemember 'SalesRole', 'SalesUser';


GRANT SELECT ON Customers TO SalesRole;

GRANT INSERT ON Orders TO SalesRole;

GRANT UPDATE ON Orders TO SalesRole;

GRANT SELECT ON Products TO SalesRole;

SELECT * FROM Customers;
DELETE FROM Customers;

SELECT * FROM Orders;
DELETE FROM Orders;
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES (1, GETDATE(), 600);

SELECT * FROM Products;
DELETE FROM Products;


REVOKE INSERT ON Orders FROM SalesRole;



SELECT * FROM fn_my_permissions(NULL,'DATABASE');


CREATE ROLE ReadOnlyRole;
GRANT SELECT ON SCHEMA::dbo TO ReadOnlyRole;

CREATE ROLE DataEntryClerk;
GRANT INSERT ON Orders TO DataEntryClerk;
GRANT INSERT ON OrderItems TO DataEntryClerk;

CREATE ROLE ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO ProductManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO ProductManagerRole;

CREATE ROLE OrderProcessorRole;
GRANT SELECT, UPDATE ON Orders TO OrderProcessorRole;

CREATE ROLE CustomerSupportRole;
GRANT SELECT ON Customers TO CustomerSupportRole;
GRANT SELECT ON Orders TO CustomerSupportRole;

CREATE ROLE MarketingAnalystRole;
GRANT SELECT ON SCHEMA::dbo TO MarketingAnalystRole;

CREATE ROLE SalesAnalystRole;
GRANT SELECT ON Orders TO SalesAnalystRole;
GRANT SELECT ON OrderItems TO SalesAnalystRole;

CREATE ROLE InventoryManagerRole;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO InventoryManagerRole;

CREATE ROLE FinanceManagerRole;
GRANT SELECT, UPDATE ON Orders TO FinanceManagerRole;

CREATE ROLE BackupOperatorRole;
GRANT BACKUP DATABASE TO BackupOperatorRole;

CREATE ROLE DatabaseDeveloperRole;
GRANT CREATE TABLE, ALTER, DROP ON SCHEMA::dbo TO DatabaseDeveloperRole;

CREATE ROLE RestrictedReadRole;
GRANT SELECT (FirstName, LastName, Email) ON Customers TO RestrictedReadRole;

CREATE ROLE ReportingRole;
GRANT SELECT ON SalesReportView TO ReportingRole;
GRANT SELECT ON InventoryReportView TO ReportingRole;


CREATE ROLE TempAccessRole;
GRANT SELECT ON SCHEMA::dbo TO TempAccessRole;

REVOKE SELECT ON SCHEMA::dbo FROM TempAccessRole;

CREATE ROLE AuditorRole;
GRANT SELECT ON SCHEMA::dbo TO AuditorRole;
DENY INSERT, UPDATE, DELETE ON SCHEMA::dbo TO AuditorRole;

CREATE APPLICATION ROLE AppRole WITH PASSWORD = 'StrongPassword1';
GRANT SELECT, INSERT, UPDATE ON Orders TO AppRole;


CREATE ROLE CombinedRole;
EXEC sp_addrolemember 'SalesRole', 'CombinedRole';
EXEC sp_addrolemember 'MarketingRole', 'CombinedRole';

CREATE ROLE SensitiveDataRole;
GRANT SELECT (Email, Phone) ON Customers TO SensitiveDataRole;

CREATE ROLE DevRole;
GRANT CONTROL ON DATABASE::OnlineRetailDB TO DevRole;

CREATE ROLE SecurityAdminRole;
GRANT ALTER ANY LOGIN TO SecurityAdminRole;
GRANT ALTER ANY USER TO SecurityAdminRole;
GRANT ALTER ANY ROLE TO SecurityAdminRole;


