-- Most Productive Month
-- Description
-- Write a query to find the month number (Eg: 4 corresponds to April) in which the most number of payments were made.
SELECT Month(payment_date) AS payment_month,
       Count(payment_id)   AS No_of_payments
FROM   payment
GROUP  BY Month(payment_date)
ORDER  BY Count(payment_id) DESC
LIMIT  1; 



-- Average Film Length by Category
-- Description
-- List the rounded average film lengths for each film category. Arrange the values in the decreasing order of the average film lengths.
SELECT Round(Avg(f.length)) AS avg_Length,
       c.NAME               AS NAME
FROM   film f
       INNER JOIN film_category fc using(film_id)
       INNER JOIN category c using(category_id)
GROUP  BY c.NAME
ORDER  BY Avg(f.length) DESC; 


-- Film Category vs. City
-- Description
-- Write a query to find the number of occurrences of each film_category in each city. Arrange them in the decreasing order of their category count.
SELECT NAME,
       city,
       Count(category_id) AS category_count
FROM   category
       INNER JOIN film_category using (category_id)
       INNER JOIN inventory using (film_id)
       INNER JOIN store using (store_id)
       INNER JOIN address using (address_id)
       INNER JOIN city using (city_id)
GROUP  BY city,
          NAME
ORDER  BY Count(category_id) DESC; 


-- Ad Campaign
-- Description
-- Suppose you are running an advertising campaign in Canada for which you need the film_ids and titles of all the films released in Canada. 
-- List the films in the alphabetical order of their titles.
SELECT DISTINCT film_id,
                title
FROM   film
       INNER JOIN inventory using (film_id)
       INNER JOIN store using (store_id)
       INNER JOIN address using (address_id)
       INNER JOIN city using (city_id)
       INNER JOIN country using (country_id)
WHERE  country = 'Canada'
ORDER  BY title; 


-- Comedy Movies
-- Description
-- Write a query to list all the films existing in the 'Comedy' category and arrange them in the alphabetical order.
SELECT DISTINCT title
FROM   film
       INNER JOIN film_category using (film_id)
       INNER JOIN category using (category_id)
WHERE  NAME = 'Comedy'; 


-- Lucky Customers
-- Description
-- List the first and last names of all customers whose first names start with the letters 'A', 'J' or 'T' or last names end with the substring 'on'. 
-- Arrange them alphabetically in the order of their first names.
SELECT first_name,
       last_name
FROM   customer
WHERE  first_name REGEXP '^[AJT]'
        OR last_name LIKE '%on'
ORDER  BY first_name; 

