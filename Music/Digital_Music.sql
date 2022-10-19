--Q1 Top 5 countries with max invoice
SELECT i.BillingCountry "Country" , COUNT(i.InvoiceId) as "No. of Invoice" 
from Invoice i 
group by 1 
ORDER BY 2 DESC LIMIT 5

/* Q2: Top 5 city that has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns the 1 city that has the highest sum of invoice totals. 
Return both the city name and the sum of all invoice totals.*/
SELECT i.BillingCity "City" , SUM(i.Total) as "Money_Earned" 
from Invoice i 
group by 1 
ORDER BY 2 DESC LIMIT 5


/*Q3: Who is the best customer?
The customer who has spent the most money will be declared the best customer. 
Build a query that returns the person who has spent the most money. */
SELECT c.FirstName 'First_Name', c.LastName 'Last_Name', SUM(i.Total) 'Total Amt' 
from Invoice i 
join Customer c on i.CustomerId = c.CustomerId 
GROUP BY i.CustomerId 
ORDER BY 3 DESC
limit 5


/* Q4: Use your query to return the email, first name, last name, and Genre of all Rock Music listeners.
Return your list ordered alphabetically by email address starting with A.*/
SELECT DISTINCT c.Email, c.FirstName , c.LastName
from Customer c 
join Invoice i ON i.CustomerId = c.CustomerId 
JOIN InvoiceLine il on il.InvoiceId = i.InvoiceId 
where il.TrackId IN (SELECT t.TrackId 
					from Track t 
					where t.GenreId IN ( SELECT g.GenreId 
										from Genre g 
										WHERE g.Name = 'Rock')
					)
ORDER BY 1


/*Q5: Question 2: Who is writing the rock music?
Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/
SELECT a2.Name , count(t.trackID) 'No. of tracks'
from Album a 
join Track t on a.AlbumId = t.AlbumId 
JOIN Artist a2 on a2.ArtistId = a.ArtistId 
WHERE t.GenreId IN (SELECT g.GenreId 
					from Genre g 
					WHERE g.Name LIKE 'Rock'
)
GROUP BY 1
ORDER by 2 DESC 
LIMIT 10


/*Q6 First, find which artist has earned the most according to the InvoiceLines?
Now use this artist to find which customer spent the most on this artist.
For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.
Notice, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, 
and then multiply this by the price for each artist.*/
Select
	    Invoice.CustomerId,
	    Customer.FirstName,
	    Customer.LastName,
	    Artist.Name Artist_Name,
	 --   InvoiceLine.InvoiceId,
	 --   InvoiceLine.TrackId,
	 --   InvoiceLine.UnitPrice,
	 --   InvoiceLine.Quantity,
	    sum(InvoiceLine.UnitPrice*InvoiceLine.Quantity) Total_Sales
From
	    Customer
	    Inner Join
	    Invoice On Invoice.CustomerId = Customer.CustomerId 
	    Inner Join
	    InvoiceLine On InvoiceLine.InvoiceId = Invoice.InvoiceId 
	    Inner Join
	    Track On InvoiceLine.TrackId = Track.TrackId 
	    Inner Join
	    Album On Track.AlbumId = Album.AlbumId 
	    Inner Join
	    Artist On Album.ArtistId = Artist.ArtistId	    
WHERE Artist.ArtistId IN (Select
		  Artist.ArtistId ID
	    
		  From
			    InvoiceLine 
			    Inner Join Track On InvoiceLine.TrackId = Track.TrackId 
			    Inner Join Album On Track.AlbumId = Album.AlbumId 
			    Inner Join Artist On Album.ArtistId = Artist.ArtistId
	   	  group by Artist.Name 
		  order by sum(InvoiceLine.UnitPrice*InvoiceLine.Quantity) desc
		  LIMIT 1)
group by 1 
order by 5 desc 



/*Q7:We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres.*/ /*sales for each country*/
with Country_List as
(
Select
    Invoice.BillingCountry As Country,
    Track.GenreId As Genre,
    Sum(Invoice.Total) As Total_Business
From
    Invoice Inner Join
    InvoiceLine On InvoiceLine.InvoiceId = Invoice.InvoiceId Inner Join
    Track On InvoiceLine.TrackId = Track.TrackId
Group By
    Invoice.BillingCountry,
    Track.GenreId
)
SELECT Country, g.Name Genre, MAX(Total_Business) 'Total Business'
from Country_List cl
join Genre g on cl.genre = g.GenreId 
group by 1 


/* Q8: max genre for each country */
SELECT 


/* Q9: Return all the track names that have a song length longer than the average song length. 
Though you could perform this with two queries. 
Imagine you wanted your query to update based on when new data is put in the database. 
Therefore, you do not want to hard code the average into your query. You only need the Track table to complete this query.
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/
Select
    Track.Name,
    Track.Milliseconds
From
    Track
Where
    Track.Milliseconds > (select avg(Track.Milliseconds)
                          from track)
order by 2 desc
 

/* Q10: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount.
You should only need to use the Customer and Invoice tables.*/
with cust as (Select
			    Customer.FirstName,
			    Customer.LastName,
			    Customer.Country,
			    Sum(Invoice.Total) As Total_Spent
			  From
			    Customer Inner Join
			    Invoice On Invoice.CustomerId = Customer.CustomerId
			 Group By
			    Customer.CustomerId,
			    Customer.Country
			    )
SELECT FirstName, LastName, Country, MAX(Total_Spent) 
from cust 
group by 3
    