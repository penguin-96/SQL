 /*Q1: users who have not placed orders ever */
SELECT name, user_id  from "swiggy-schema_users" ssu 
WHERE user_id NOT IN 
(SELECT user_id from "swiggy-schema_orders" sso)



/*Q2: Average Price of a Dish: Sort by cheapest to expensive*/
select ssm.f_id ,f_name Dish_Name, AVG(price) Average_Price 
from "swiggy-schema_menu" ssm 
join "swiggy-schema_food" ssf on ssm.f_id =ssf.f_id
GROUP BY ssm.f_id
ORDER by average_price ASC



/*Q3: Top restaurants in terms if number of orders*/
SELECT ssr.r_name 'Restaurant Name', COUNT(order_id) 'No. of Orders'
from "swiggy-schema_restaurants" ssr 
join "swiggy-schema_orders" sso  on ssr.r_id =sso.r_id 
GROUP BY ssr.r_name 
ORDER BY 'No. of Orders' DESC 
LIMIT 1



/*top by month May*/
SELECT ssr.r_name as Name, COUNT(order_id) 'No. of Orders' , SUBSTRING(sso.date,4,3) as Month
from "swiggy-schema_restaurants" ssr 
join "swiggy-schema_orders" sso on ssr.r_id = sso.r_id 
WHERE SUBSTRING(sso.date,4,3) LIKE 'Jun'
GROUP BY ssr.r_name 
order BY COUNT(order_id) DESC 
Limit 1



/*Q4: restaurants with sales > 500 for a month*/
SELECT ssr.r_name 'Restaurant_Name', SUM(sso.amount) 'Total Sales'
from "swiggy-schema_restaurants" ssr 
join "swiggy-schema_orders" sso on ssr.r_id = sso.r_id
WHERE SUBSTRING(sso.date,4,3) LIKE 'Jun'
GROUP BY ssr.r_id 
HAVING SUM(sso.amount) > 500



/*Q5: all orders with order details for a particular customer in a particular date range*/
SELECT sso.order_id , ssu.name 'User_Name' ,ssf.f_name 'Dish_Name',ssr.r_name 'Restaurant_Name', sso.amount 'amount', sso.date 'date'  
FROM "swiggy-schema_orders" sso
Join "swiggy-schema_order_details" ssod on ssod.order_id = sso.order_id 
Join "swiggy-schema_food" ssf on ssod.f_id = ssf.f_id 
JOIN "swiggy-schema_restaurants" ssr on sso.r_id = ssr.r_id 
JOIN "swiggy-schema_users" ssu on sso.user_id = ssu.user_id 
WHERE sso.user_id = '4.0' AND (sso.date LIKE '%May%' OR sso.date LIKE '%Jun%')



/*Q6: restaurants with max repeated customers  */
SELECT r_name 'Rest_Name', COUNT(*) 'No._of_Regular_Customers' 
FROM 	(SELECT ssu.name, ssr.r_name, COUNT(*) 'Visits' 
		FROM "swiggy-schema_orders" sso 
		join "swiggy-schema_restaurants" ssr on sso.r_id = ssr.r_id 
		JOIN "swiggy-schema_users" ssu on sso.user_id = ssu.user_id 
		GROUP BY ssu.name, ssr.r_name
		HAVING COUNT(*) > 1)
GROUP BY r_name 
ORDER BY COUNT(*) DESC 
LIMIT 1



/*Q7: Month over month revenue growth of swiggy*/
WITH s AS 
		(SELECT SUBSTRING(sso.date, 4,3) 'Month', SUM(amount) 'Sales', lag(SUM(amount),1) over (order by SUM(amount)) AS 'prev_sales'
		from "swiggy-schema_orders" sso 
		group by SUBSTRING(sso.date, 4.3)
		ORDER BY (CASE SUBSTRING(sso.date, 4,3)
    		WHEN 'Jan' THEN 1
    		WHEN 'Feb' THEN 2
    		WHEN 'Mar' THEN 3
		    WHEN 'Apr' THEN 4
			WHEN 'May' THEN 5
		    WHEN 'Jun' THEN 6
		    WHEN 'Jul' THEN 7
		    WHEN 'Aug' THEN 8
		    WHEN 'Sep' THEN 9
		    WHEN 'Oct' THEN 10
		    WHEN 'Nov' THEN 11
		    WHEN 'Dec' THEN 12
		  END) ASC)
SELECT Month , ((Sales - prev_sales)/prev_sales)*100 'growth'
FROM s



/*Q8: Customer - favorite food*/
select User, Dish, MAX(Dish_Bought) 'Freq'
from (select ssu.name 'User', ssf.f_name 'Dish', COUNT(*) 'Dish_Bought'
		FROM "swiggy-schema_orders" sso 
		join "swiggy-schema_order_details" ssod on ssod.order_id = sso.order_id
		JOIN "swiggy-schema_food" ssf on ssf.f_id = ssod.f_id 
		JOIN "swiggy-schema_users" ssu on ssu.user_id = sso.user_id 
		GROUP BY sso.user_id, ssf.f_name) t
GROUP BY User


/* Another altenative to Q8 with flawed logic*/
select ssu.name 'User', ssf.f_name 'Dish', COUNT(*) 'Dish_Bought'
FROM "swiggy-schema_orders" sso 
join "swiggy-schema_order_details" ssod on ssod.order_id = sso.order_id
JOIN "swiggy-schema_food" ssf on ssf.f_id = ssod.f_id 
JOIN "swiggy-schema_users" ssu on ssu.user_id = sso.user_id 
GROUP BY sso.user_id, ssf.f_name
ORDER BY COUNT(*) DESC 
LIMIT 6