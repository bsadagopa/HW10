use sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column `Actor Name`.  
SELECT upper(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. 
-- Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(30) AFTER last_name;

-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY middle_name BLOB;

-- 3c. Now delete the `middle_name` column.
ALTER TABLE actor DROP middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, count(*) AS 'same_last_name_count' FROM actor
GROUP BY last_name 
HAVING same_last_name_count >=2 ;

#SELECT * FROM ACTOR WHERE last_name = 'WILLIAMS';

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table 
-- as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
-- Otherwise, change the first name to `MUCHO GROUCHO`, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO 
-- `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor
SET first_name = 
	CASE 
		WHEN first_name = 'HARPO' 
			THEN 'GROUCHO'
		ELSE 'MUCHO GROUCHO'
	END
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
JOIN address
ON address.address_id = staff.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.
SELECT S.FIRST_NAME, S.LAST_NAME, SUM(P.AMOUNT)
FROM STAFF AS S
JOIN PAYMENT AS P
ON S.STAFF_ID = P.STAFF_ID
WHERE MONTH(P.PAYMENT_DATE) =  08 AND YEAR(P.PAYMENT_DATE) = 2005
GROUP BY S.STAFF_ID;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT F.TITLE, COUNT(FA.ACTOR_ID) AS ACTOR_COUNT
FROM FILM_ACTOR AS FA
INNER JOIN FILM AS F
ON F.FILM_ID = FA.FILM_ID
GROUP BY F.TITLE;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT F.TITLE, COUNT(I.FILM_ID) AS 'FILM COPY COUNT'
FROM INVENTORY AS I
JOIN FILM AS F
ON F.FILM_ID = I.FILM_ID
WHERE F.TITLE = 'Hunchback Impossible';

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name:
SELECT C.FIRST_NAME, C.LAST_NAME, SUM(P.AMOUNT)
FROM CUSTOMER AS C
JOIN PAYMENT AS P
USING (CUSTOMER_ID)
GROUP BY C.CUSTOMER_ID
ORDER BY C.LAST_NAME;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` 
-- have also soared in popularity. Use subqueries to display the titles of movies 
-- starting with the letters `K` and `Q` whose language is English.
SELECT F.TITLE
FROM FILM AS F
JOIN LANGUAGE AS L
USING (LANGUAGE_ID)
WHERE L.NAME = 'ENGLISH' 
AND F.TITLE LIKE 'K%' 
OR F.TITLE LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT A.FIRST_NAME, A.LAST_NAME
FROM ACTOR AS A
WHERE A.ACTOR_ID IN 
	(
	SELECT FA.ACTOR_ID FROM FILM_ACTOR AS FA
    WHERE FILM_ID IN
		(
        SELECT F.FILM_ID FROM FILM AS F
        WHERE F.TITLE='ALONE TRIP'
        )
	);


-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT C.FIRST_NAME, C.LAST_NAME, C.EMAIL
FROM CUSTOMER AS C
WHERE ADDRESS_ID IN
	(
    SELECT A.ADDRESS_ID FROM ADDRESS AS A
    WHERE CITY_ID IN
		(
        SELECT CITY_ID FROM CITY
        WHERE COUNTRY_ID IN
			(
            SELECT COUNTRY_ID FROM COUNTRY
            WHERE COUNTRY = 'CANADA'
            )
        )
    );


-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as family films.
SELECT F.TITLE, C.NAME
FROM FILM AS F
JOIN FILM_CATEGORY AS FC USING (FILM_ID)
JOIN CATEGORY AS C USING (CATEGORY_ID)
WHERE C.NAME = 'FAMILY';

-- 7e. Display the most frequently rented movies in descending order.
SELECT F.TITLE, COUNT(*) AS RENTAL_COUNT FROM FILM AS F
JOIN INVENTORY AS I USING (FILM_ID)
JOIN RENTAL AS R USING (INVENTORY_ID)
GROUP BY F.TITLE
ORDER BY RENTAL_COUNT DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT S.STORE_ID, SUM(P.AMOUNT) FROM PAYMENT P
JOIN RENTAL R USING (RENTAL_ID)
JOIN INVENTORY I USING (INVENTORY_ID)
JOIN STORE S USING (STORE_ID)
GROUP BY S.STORE_ID;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.STORE_ID, C.CITY, CO.COUNTRY
FROM STORE S 
JOIN ADDRESS A USING (ADDRESS_ID)
JOIN CITY C USING (CITY_ID)
JOIN COUNTRY CO USING (COUNTRY_ID)
GROUP BY S.STORE_ID;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, 
-- inventory, payment, and rental.)
SELECT CA.NAME AS GENRE, SUM(P.AMOUNT) AS 'GROSS REVENUE' FROM CATEGORY CA
JOIN FILM_CATEGORY FC USING (CATEGORY_ID)
JOIN INVENTORY I USING (FILM_ID)
JOIN RENTAL R USING (INVENTORY_ID)
JOIN PAYMENT P USING (RENTAL_ID)
GROUP BY CA.NAME
ORDER BY SUM(P.AMOUNT)  DESC LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above
-- to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW TOP_FIVE_GENRES AS
SELECT CA.NAME AS GENRE, SUM(P.AMOUNT) AS 'GROSS REVENUE' FROM CATEGORY CA
JOIN FILM_CATEGORY FC USING (CATEGORY_ID)
JOIN INVENTORY I USING (FILM_ID)
JOIN RENTAL R USING (INVENTORY_ID)
JOIN PAYMENT P USING (RENTAL_ID)
GROUP BY CA.NAME
ORDER BY SUM(P.AMOUNT)  DESC LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM TOP_FIVE_GENRES;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW TOP_FIVE_GENRES;



