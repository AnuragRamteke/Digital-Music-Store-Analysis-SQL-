use music;

# Project Operations :
# 1) Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

# 2) Which countries have the most Invoices?

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc;

# 3) What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

# 4) Which city has the best customers? we would like to throw a promotional music festival in the city
#    we made the most money. write a query that returns one city that has the highest sum of invoice totals.
#     return both the city name & sum of all invoice totals

select sum(total) as invoice_total, billing_city
from invoice 
group by billing_city
order by invoice_total desc;

# 5) Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
#    Return your list ordered alphabetically by email starting with A..

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

# 6) Return all the track names that have a song length longer than the average song length. 
#    Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC; 

# 7) We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
#    with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
#    the maximum number of purchases is shared return all Genres.

#    Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level.

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

# 8)  Write a query that determines the customer that has spent the most on music for each country. 
#     Write a query that returns the country along with the top customer and how much they spent. 
#     For countries where the top amount spent is shared, provide all customers who spent this amount. */

#     Steps to Solve:  Similar to the above question. There are two parts in question- 
#     first find the most spent on music for each country and second filter the data for respective customers.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;