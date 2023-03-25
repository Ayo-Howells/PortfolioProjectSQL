/*

EXPLORING THE ADVENTUREWORKS2019 DATASET

*/

-----------------------------------------------------------------------------------------------------
--  To show how many people are in the DATABASE with no middle name  
SELECT COUNT(*) As NoMiddleName
FROM Person.Person
WHERE MiddleName IS NULL;

-- How many email addresses do not end in adventure-works.com

SELECT COUNT(EmailAddress)
FROM Person.EmailAddress
WHERE EmailAddress NOT LIKE '%adventure-works.com';


------------------------------------------------------------------------------------------------------


-- A customer has concerns with market penetration and would like a report on what states have the  most  sales  between  2010-2011.  Provide  the  data  that  the  customer  would  find  most relevant and add any additional information if required. 


SELECT StateProvinceCode, SUM(SOH.SubTotal) AS NetSales, SUM(SOH.TotalDue) AS GrossSale
FROM Sales.SalesOrderHeader AS SOH
LEFT JOIN Person.StateProvince AS StP
ON SOH.TerritoryID = StP.TerritoryID
WHERE SOH.OrderDate BETWEEN '01-01-2010'
	AND '12-31-2011'
GROUP BY StateProvinceCode
ORDER BY 2,3;

------------------------------------------------------------------------------------------------------



-- A ticket is escalated and asks what customers got the email promotion. Please provide the information. 

SELECT Firstname,MiddleName,LastName
FROM Person.Person
WHERE EmailPromotion > 0;


--------------------------------------------------------------------------------------------------

-- To retrieve a list of the different types of contacts and how many of them exist in the database, when we are only interested in ContactTypes that have 100 contacts or more.

SELECT PCT.NAME, COUNT(PBC.BusinessEntityID) AS NumberOfBusinessEntity
FROM Person.ContactType PCT
LEFT JOIN Person.BusinessEntityContact PBC
ON PCT.ContactTypeID = PBC.ContactTypeID
GROUP BY PCT.Name, PBC.ContactTypeID
HAVING COUNT(PBC.BusinessEntityID) > 100

------------------------------------------------------------------------

-- To Retrieve a list of all contacts who are 'Purchasing Manager' and their names
 
SELECT PP.FirstName, PP.LastName, HRE.JobTitle
FROM Person.Person PP
 RIGHT JOIN HumanResources.Employee HRE
ON HRE.BusinessEntityID = PP.BusinessEntityID
WHERE HRE.JobTitle ='Purchasing Manager';
 
------------------------------------------------------------------------


-- Show OrdeQty, the Name and the ListPrice of the order made by CustomerID 635


SELECT SOH.CustomerID, PP.Name, SOD.OrderQty, PP.ListPrice
FROM Sales.SalesOrderHeader SOH
RIGHT JOIN Sales.SalesOrderDetail SOD
ON SOD.SalesOrderID = SOH.SalesOrderID
LEFT JOIN Production.Product PP
ON SOD.ProductID = PP.ProductID
WHERE SOH.CustomerID = 635;


-------------------------------------------------------------------------------


-- A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.


SELECT SalesOrderID, UnitPrice
FROM Sales.SalesOrderDetail
WHERE OrderQty = 1
ORDER BY 2;


----------------------------------------------------------------------------------

-- List the product name and the companyname for all vendors for the ProductModel ‘Racing Socks’?
SELECT  PP.Name AS ProductName, PV.Name AS Vendor
FROM Purchasing.Vendor PV
LEFT JOIN Purchasing.ProductVendor PPV
ON PV.BusinessEntityID = PPV.BusinessEntityID
JOIN Production.Product PP
ON PP.ProductID = PPV.ProductID
JOIN Production.ProductModel PPM
ON PPM.ProductModelID = PP.ProductModelID
WHERE PPM.Name = 'Racing Socks'




-------------------------------------------------------------------------------

-- Where did the racing socks go? List the CustomerID, Quantity Ordered and the Address for all Customers who ordered ProductModel 'Racing Socks'.

WITH RSocks AS (
SELECT SSOD.SalesOrderID,PP.Name
FROM Sales.SalesOrderDetail SSOD
JOIN Production.Product PP
ON SSOD.ProductID = PP.ProductID
JOIN Production.ProductModel PPM
ON PPM.ProductModelID = PP.ProductModelID
WHERE PPM.Name = 'Racing Socks'
)
SELECT SSOH.CustomerID, PSPS.FirstName, PSPS.LastName, Rsocks.Name,COUNT(RSocks.Name) AS QtyOrdered, PA.AddressLine1, PA.City, PA.PostalCode
FROM RSocks 
LEFT JOIN Sales.SalesOrderHeader SSOH
ON RSocks.SalesOrderID= SSOH.SalesOrderID
LEFT JOIN Person. BusinessEntityAddress PBEA
ON SSOH.ShipToAddressID = PBEA.AddressID
LEFT JOIN Person.Person PSPS
ON PBEA.BusinessEntityID = PSPS.BusinessEntityID
LEFT JOIN Person.Address PA
ON PA.AddressID = PBEA.AddressID
GROUP BY SSOH.CustomerID, PSPS.FirstName, PSPS.LastName, Rsocks.Name,PA.AddressLine1, PA.City, PA.PostalCode
ORDER BY 1,5,7

-------------------------------------------------------------------------------

-- How many products in ProductSubCategory 'Cranksets' have been sold to an address in 'London

SELECT PA.City,COUNT(PP.ProductID),PPS.Name
FROM Person.Address PA
JOIN Sales.SalesOrderHeader SSOH
ON PA.AddressID = SSOH.ShipToAddressID
INNER JOIN Sales.SalesOrderDetail SSOD
ON SSOD.SalesOrderID = SSOH.SalesOrderID
inner JOIN Production.Product PP
ON PP.ProductID = SSOD.ProductID
inner JOIN Production.ProductSubcategory PPS
ON PP.ProductSubcategoryID =PPS.ProductSubcategoryID
WHERE PA.City = 'London'
AND PPS.Name = 'Cranksets'
GROUP BY PA.City, PPS.Name

---------------------------------------------------------------


--	For delivery purpose, specify the Customer name, business entity id, and address with the products name, orderId and productid of  each crankset type ordered

 
SELECT PSPS.FirstName, PSPS.LastName, PBEA.BusinessEntityID, PA.AddressLine1, PA.City,SSOD.SalesOrderID, PP.ProductID, PP.Name
FROM Person.Person  PSPS
RIGHT JOIN Person.BusinessEntityAddress PBEA
ON PSPS.BusinessEntityID = PBEA.BusinessEntityID
RIGHT JOIN Person.Address PA
ON PA.AddressID = PBEA.AddressID
JOIN Sales.SalesOrderHeader SSOH
ON PA.AddressID = SSOH.ShipToAddressID
INNER JOIN Sales.SalesOrderDetail SSOD
ON SSOD.SalesOrderID = SSOH.SalesOrderID
inner JOIN Production.Product PP
ON PP.ProductID = SSOD.ProductID
inner JOIN Production.ProductSubcategory PPS
ON PP.ProductSubcategoryID =PPS.ProductSubcategoryID
WHERE PA.City = 'London'
AND PPS.Name = 'Cranksets'


-------------------------------------------------------------------------------

-- To show the best selling item by value

SELECT TOP 1 PP.Name, PP.ProductID, SUM(SSOD.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail SSOD
JOIN Production.Product PP
ON PP.ProductID = SSOD.ProductID
GROUP BY PP.ProductID, PP.Name
ORDER BY 3 DESC;


