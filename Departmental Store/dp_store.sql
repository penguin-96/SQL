/*max on each date*/
SELECT *,
max(Quantity) over(PARTITION by OrderDate) Max_Quanity
from TR_OrderDetails tod 

/*Unique product with max qty*/
select DISTINCT tp.ProductID ,tp.ProductName 'Product' , MAX(tod.quantity)
from TR_OrderDetails tod 
join TR_Products tp on tod.ProductID = tp.ProductID  
GROUP BY tp.ProductName 
ORDER BY tp.ProductID ASC 

/*unique prroperties sold*/
SELECT DISTINCT tpi."Prop ID" , MAX(quantity) 
from TR_OrderDetails tod 
join TR_PropertyInfo tpi on tpi."Prop ID"  = tod.PropertyID 
GROUP BY tpi."Prop ID" 

/*product categpry with max products*/
SELECT tp.ProductCategory 'category', COUNT(*) 
from TR_Products tp 
group by tp.ProductCategory 
order by COUNT(*) DESC 
LIMIT 5

/*states with no. of stores*/*/
SELECT tpi.PropertyState 'State', COUNT(*) 
from TR_PropertyInfo tpi
group by 1

/*top 5 product with max sales*/
SELECT tp.ProductName 'Product', SUM(tod.Quantity) 'Total Quantity', tp.Price 'Price', (SUM(tod.Quantity)*tp.Price) 'Total_Sales'
from TR_OrderDetails tod 
join TR_Products tp on tod.ProductID = tp.ProductID
GROUP BY tp.ProductName
ORDER BY 4 DESC 
Limit 5

/*top 5 city with max sales*/
SELECT tpi.PropertyCity , sum(tod.Quantity* tp.Price) Sales
from TR_OrderDetails tod
join TR_Products tp on tod.ProductID = tp.ProductID 
JOIN TR_PropertyInfo tpi on tod.PropertyID = tpi."Prop ID"
GROUP by 1
ORDER BY 2 DESC 
LIMIT 5


SELECT tp.ProductName 'Product', tpi.PropertyCity 'City', SUM(Quantity) 'Qty Sold', tp.Price 'Price' , SUM(Quantity)*tp.Price 'Total Sales' 
from TR_OrderDetails tod
join TR_Products tp on tod.ProductID = tp.ProductID 
JOIN TR_PropertyInfo tpi on tod.PropertyID = tpi."Prop ID" 
--WHERE tpi.PropertyCity LIKE '%Arlington' AND tp.ProductName LIKE '%Sofa'
GROUP BY tod.PropertyID  , tod.ProductID 

/*top 5 products for each city*/