# Project: Advanced SQL for Music Store Data Analysis

# Project Overview:
The Music Store Data Analysis Project aims to analyze sales data from a hypothetical music store to uncover trends, patterns, and insights that can inform business decisions. The project involves using SQL for data extraction, transformation, and analysis.

# Objectives:
- Identify Best-Selling Products: Determine which tracks, albums, and genres generate the most sales.<br>
- Customer Insights: Understand customer behavior, including top-spending customers and geographic distribution.<br>
- Sales Performance: Analyze sales performance over time and identify peak periods.<br>
- Product Relationships: Discover which products are often purchased together.

# Tools and Technologies:
- Database: MySQL <br>
- Query Language: SQL <br>
- Visualization: dbdiagram.io (for schema visualization)

# Key SQL Queries and Insights:
1. Best-Selling Artist:
Identifies the artist with the highest sales. <br>
```
WITH best_selling_artist AS ( <br>
    SELECT artist.artist_id, artist.name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales <br>
    FROM invoice_line <br>
    JOIN track ON track.track_id = invoice_line.track_id <br>
    JOIN album2 ON album2.album_id = track.album_id  <br>
    JOIN artist ON artist.artist_id = album2.artist_id <br>
    GROUP BY artist.artist_id, artist.name <br>
    ORDER BY total_sales DESC <br>
    LIMIT 1 <br>
) <br>
SELECT c.customer_id, c.first_name, c.last_name, bsa.name AS artist_name, SUM(il.unit_price * il.quantity) AS amount_spent <br>
FROM invoice i <br>
JOIN customer c ON c.customer_id = i.customer_id <br>
JOIN invoice_line il ON il.invoice_id = i.invoice_id <br>
JOIN track t ON t.track_id = il.track_id <br>
JOIN album2 a ON a.album_id = t.album_id <br>
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id <br>
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name <br>
ORDER BY amount_spent DESC;
```
#### Insight: Identifies top customers for the best-selling artist, which helps target marketing efforts.

2. Popular Genres by Country:
Determines the most popular music genre in each country <br>
```
WITH popular_genre AS ( <br>
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name AS genre_name, genre.genre_id, <br>
    ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo <br>
    FROM invoice_line <br>
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id <br>
    JOIN customer ON customer.customer_id = invoice.customer_id <br>
    JOIN track ON track.track_id = invoice_line.track_id <br>
    JOIN genre ON genre.genre_id = track.genre_id <br>
    GROUP BY customer.country, genre.name, genre.genre_id <br>
    ORDER BY customer.country ASC, purchases DESC <br>
) <br>
SELECT * FROM popular_genre WHERE RowNo = 1;
```
#### Insight: Highlights genre preferences by country, aiding regional marketing strategies.

3. Top-Spending Customers by Country:
Identifies the top-spending customer in each country. <br>
```
WITH Customer_with_country AS ( <br>
    SELECT customer.customer_id AS cust_id, customer.first_name AS first_name, customer.last_name AS last_name, <br>
           invoice.billing_country AS billing_country, SUM(invoice.total) AS total_spending, <br>
           ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo <br>
    FROM invoice <br>
    JOIN customer ON customer.customer_id = invoice.customer_id <br>
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country <br>
) <br>
SELECT * FROM Customer_with_country WHERE RowNo = 1;
```
#### Insight: Identifies key customers in each region, useful for personalized engagement.

#Visualization
Schema diagrams can be visualized using tools like dbdiagram.io. These visualizations help in understanding the database structure and the relationships between different entities.
![Schema diagram](https://github.com/prajaktakadu11/Advanced_SQL_for_Music_Store_Data_Analysis/blob/main/Music_database_schema.png?raw=true)

#Conclusion
This project demonstrates the power of SQL in extracting meaningful insights from data. By analyzing sales patterns, customer behavior, and product relationships, businesses can make informed decisions to drive growth and improve customer satisfaction.
