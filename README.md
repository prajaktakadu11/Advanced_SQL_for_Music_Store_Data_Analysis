# Music_storedata_analysis

### Project Overview
The Music Store Data Analysis Project aims to analyze sales data from a hypothetical music store to uncover trends, patterns, and insights that can inform business decisions. The project involves using SQL for data extraction, transformation, and analysis.

### Objectives
Identify Best-Selling Products: Determine which tracks, albums, and genres generate the most sales.<br>
Customer Insights: Understand customer behavior, including top-spending customers and geographic distribution.<br>
Sales Performance: Analyze sales performance over time and identify peak periods.<br>
Product Relationships: Discover which products are often purchased together.

### Tools and Technologies
Database: MySQL
Query Language: SQL
Visualization: dbdiagram.io (for schema visualization)

### Key SQL Queries and Insights
#### 1. Best-Selling Artist
Identifies the artist with the highest sales.

WITH best_selling_artist AS (
    SELECT artist.artist_id, artist.name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album2 ON album2.album_id = track.album_id
    JOIN artist ON artist.artist_id = album2.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.name AS artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 a ON a.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY amount_spent DESC;

#### Insight: Identifies top customers for the best-selling artist, which helps target marketing efforts.

#### 2. Popular Genres by Country
Determines the most popular music genre in each country

WITH popular_genre AS (
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name AS genre_name, genre.genre_id, 
    ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
    ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo = 1;

#### Insight: Highlights genre preferences by country, aiding regional marketing strategies.

#### 3. Top-Spending Customers by Country
Identifies the top-spending customer in each country.

WITH Customer_with_country AS (
    SELECT customer.customer_id AS cust_id, customer.first_name AS first_name, customer.last_name AS last_name,
           invoice.billing_country AS billing_country, SUM(invoice.total) AS total_spending,
           ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
)
SELECT * FROM Customer_with_country WHERE RowNo = 1;

#### Insight: Identifies key customers in each region, useful for personalized engagement.

### Visualization
Schema diagrams can be visualized using tools like dbdiagram.io. These visualizations help in understanding the database structure and the relationships between different entities.

### Conclusion
This project demonstrates the power of SQL in extracting meaningful insights from data. By analyzing sales patterns, customer behavior, and product relationships, businesses can make informed decisions to drive growth and improve customer satisfaction.
