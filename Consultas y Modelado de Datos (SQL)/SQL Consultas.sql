
/*Obtener el pedido más reciente de cada cliente*/

USE AdventureWorks2017;
WITH PedidosOrdenados AS (
SELECT * ,ROW_NUMBER() OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate DESC) AS RN
FROM Sales.SalesOrderHeader AS SOH
)
SELECT CustomerID AS Id_Cliente, SalesOrderID AS ID_Pedido, CAST(OrderDate AS DATE) AS Fecha, RN AS Conteo
FROM PedidosOrdenados
WHERE RN = 1

/*Numero de clientes UNICOS cuyos correos electrónicos NO contienen “test” o “demo” y han realizado pedidos desde enero 2013*/

SELECT COUNT(DISTINCT C.CustomerID) AS Cantidad_clientes
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader] AS SOH
INNER JOIN [AdventureWorks2017].[Sales].[Customer] AS C ON SOH.CustomerID = C.CustomerID
INNER JOIN [AdventureWorks2017].[Person].[Person] AS P ON C.PersonID = P.BusinessEntityID
INNER JOIN [AdventureWorks2017].[Person].[EmailAddress] AS EA ON P.BusinessEntityID = EA.BusinessEntityID
WHERE (EA.EmailAddress NOT LIKE '%test%' OR EA.EmailAddress NOT LIKE '%demo%')
AND SOH.OrderDate >= '2013-01-01'

/*¿Cómo se distribuyen las ventas por año, mes, categoría de producto y región para el 2014?*/

SELECT YEAR(SOH.OrderDate) AS Año ,MONTH(SOH.OrderDate) AS Mes, PC.name AS categoria, ST.name AS Region, SUM(SOD.linetotal) AS Total_ventas
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader] AS SOH
INNER JOIN [AdventureWorks2017].[Sales].[SalesOrderDetail] AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
INNER JOIN [AdventureWorks2017].[Production].[Product] AS P ON SOD.ProductID = P.ProductID
INNER JOIN [AdventureWorks2017].[Production].[ProductSubcategory] AS PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
INNER JOIN [AdventureWorks2017].[Production].[ProductCategory] AS PC ON PSC.ProductCategoryID = PC.ProductCategoryID
INNER JOIN [AdventureWorks2017].[Sales].[SalesTerritory] AS ST ON SOH.TerritoryID = ST.TerritoryID
WHERE YEAR(SOH.OrderDate) = '2014'
GROUP BY YEAR(SOH.OrderDate), MONTH(SOH.OrderDate), PC.Name, ST.Name
ORDER BY Año, Mes

/*Pedidos realizados en enero de 2014 de productos cuyo precio unitario sea mayor a 1000”*/

SELECT SOH.SalesOrderID AS Id_Pedido, CAST(SOH.OrderDate AS date) AS Fecha, SOD.ProductID AS Id_Producto, SOD.UnitPrice AS Precio_unitario
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD ON SOH.SalesOrderID = SOD.SalesOrderID
WHERE YEAR(SOH.OrderDate) = 2014
AND MONTH(SOH.OrderDate) = 1
AND SOD.UnitPrice > 1000
ORDER BY SOH.OrderDate

/*Empleados que han procesado más de un pedido para el mismo cliente en el mismo mes*/

SELECT SP.BusinessEntityID AS Id_Empleado, YEAR(SOH.OrderDate) AS Año, MONTH(SOH.OrderDate) AS Mes, COUNT(*) AS Numero_pedidos
FROM [AdventureWorks2017].[Sales].[SalesOrderHeader] AS SOH
INNER JOIN [AdventureWorks2017].[Sales].[SalesPerson] AS SP ON SOH.SalesPersonID = SP.BusinessEntityID
INNER JOIN [AdventureWorks2017].[Person].[Person] AS P ON SP.BusinessEntityID = P.BusinessEntityID
GROUP BY SP.BusinessEntityID, YEAR(SOH.OrderDate), MONTH(SOH.OrderDate)
HAVING COUNT(*) > 1
ORDER BY  YEAR(SOH.OrderDate), MONTH(SOH.OrderDate)