-- Online retail store description analysis. 

SELECT*
FROM onlinestore;


-- 1. Total Sales Amount: What is the total sales amount for a given time period or by country?**/

SELECT country, SUM(quantity * unitprice) as total_sales
FROM onlinestore
WHERE country = 'United Kingdom' 
      AND EXTRACT(YEAR FROM invoicedate) = 2010
GROUP BY country;


-- 2. Best-Selling Products: Which products have the highest sales in terms of quantity or revenue?

SELECT description, SUM(quantity * unitprice) as total_sales
FROM onlinestore
WHERE quantity > 0
GROUP BY description
ORDER BY total_sales DESC
LIMIT 1;


--3. Sales by Country: How do sales vary by country, and which countries generate the most revenue?
SELECT country, SUM(quantity * unitprice) as total_sales
FROM onlinestore
WHERE quantity > 0
GROUP BY country
ORDER BY total_sales DESC;

--11. Price Analysis: What is the average price for each product or category?

SELECT description, AVG(unitprice) as AVG_price
FROM onlinestore
GROUP BY description
ORDER BY AVG_price DESC;

--15. Customer Segmentation: Can you group customers into segments based on their behavior or demographics?


SELECT country, description, SUM(quantity * unitprice) as total_sales,
    CASE
        WHEN SUM(quantity * unitprice) >= 19809 THEN 'supercustomer'
        ELSE 'reg_customer'
    END AS customer_status
FROM onlinestore
WHERE description like 'WORLD WAR%'
GROUP BY country, description
ORDER BY total_sales DESC;


--19. Invoice Date Analysis: What are the busiest times of the day or week for sales?


-- Busiest days of the week for sales

SELECT
    EXTRACT(dow FROM invoicedate) AS day_of_week,
    SUM(quantity * unitprice) AS total_sales
FROM onlinestore
GROUP BY day_of_week
ORDER BY total_sales DESC;

WITH WeeklySales AS (
    SELECT
        EXTRACT(dow FROM invoicedate) AS day_of_week,
        SUM(quantity * unitprice) AS total_sales,
        RANK() OVER (ORDER BY SUM(quantity * unitprice) DESC) AS sales_rank
    FROM onlinestore
    GROUP BY day_of_week
)
SELECT day_of_week, total_sales, sales_rank
FROM WeeklySales
;

-- Busiest months for sales
SELECT
    EXTRACT(month FROM invoicedate) AS month,
    SUM(quantity * unitprice) AS total_sales
FROM onlinestore
WHERE quantity > 0
GROUP BY month
ORDER BY total_sales DESC;

WITH MonthlySales AS (
    SELECT
        EXTRACT(month FROM invoicedate) AS month,
        SUM(quantity * unitprice) AS total_sales,
        RANK() OVER (ORDER BY SUM(quantity * unitprice) DESC) AS sales_rank
    FROM onlinestore
    GROUP BY month
)
SELECT month, total_sales, sales_rank
FROM MonthlySales;

The first query provides the busiest times of the day for sales, the second query shows the busiest days of the week, and the third query displays the busiest months. You can analyze the results to determine the peak sales periods.








20. Product Descriptions: Can you analyze product descriptions for insights into customer preferences?
