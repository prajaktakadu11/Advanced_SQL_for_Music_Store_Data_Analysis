create database music_database;

use music_database;

show tables;

# Simple Queries

-- Q. Who is the senior most employee based on job title?

SELECT 
    *
FROM
    employee
ORDER BY levels DESC
LIMIT 1;

-- Q. Which countries have the most Invoices?

SELECT 
    COUNT(*) AS invoice_count, billing_country
FROM
    invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

-- Q. What are top 3 values of total invoice?

SELECT 
    invoice_id, total
FROM
    invoice
ORDER BY total DESC;

/* Q. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals */

SELECT 
    billing_city, SUM(total) AS InvoiceTotal
FROM
    invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money */


SELECT 
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    SUM(invoice.total) AS total_spending
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id , customer.first_name , customer.last_name
ORDER BY total_spending DESC
LIMIT 1;

/* Q.  Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */

/*Method 1 */

SELECT DISTINCT
    email, first_name, last_name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE
    track_id IN (SELECT 
            track_id
        FROM
            track
                JOIN
            genre ON track.genre_id = genre.genre_id
        WHERE
            genre.name LIKE 'Rock')
ORDER BY email;


/* Method 2 */

SELECT DISTINCT
    email AS Email,
    first_name AS FirstName,
    last_name AS LastName,
    genre.name AS Name
FROM
    customer
        JOIN
    invoice ON invoice.customer_id = customer.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name LIKE 'Rock'
ORDER BY email;

/* Q. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

SELECT 
    COUNT(artist.artist_id) AS number_of_songs, artist.name
FROM
    track
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album2.artist_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
GROUP BY artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

/* Q. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

/* Q. Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */

WITH best_selling_artist AS (
	SELECT artist.artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY artist.artist_id, artist.name 
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM 
    invoice AS i
JOIN 
    customer AS c ON c.customer_id = i.customer_id
JOIN 
    invoice_line AS il ON il.invoice_id = i.invoice_id
JOIN 
    track AS t ON t.track_id = il.track_id
JOIN 
    album2 AS alb ON alb.album_id = t.album_id
JOIN 
    best_selling_artist AS bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 
    amount_spent DESC;
    
    
/* Q. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/

/* Method 1: Using CTE */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name as genre_name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases desc
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Method 2: : Using Recursive */

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name as genre_name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY customer.country, genre.name, genre.genre_id
		ORDER BY customer.country
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY country
		ORDER BY country)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;



/* Q. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/


/* Method 1: using CTE */

WITH Customer_with_country AS (
	SELECT 
        Customer.customer_id as cust_id,
        Customer.first_name as first_name,
        customer.last_name as last_name,
        invoice.billing_country as billing_country,
        SUM(invoice.total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY invoice.	billing_country ORDER BY SUM(invoice.total) DESC) AS RowNo 
	FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY cust_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC, total_spending DESC)
SELECT * 
FROM Customer_with_country 
WHERE RowNo <= 1;


/* Method 2: Using Recursive */

WITH RECURSIVE 
	customer_with_country AS (
	SELECT 
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        invoice.billing_country,
        SUM(invoice.total) AS total_spending
	FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country
		ORDER BY customer.first_name,customer.last_name DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customer_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;



