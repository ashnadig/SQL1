Use sakila ;

# 1a. You need a list of all the actors who have Display the first and last names of all actors from the table actor.
SELECT  first_name, last_name from actor ;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT CONCAT(upper(first_name), ' ', upper(last_name)) as actor_name from actor; 

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
Select actor_id, first_name, last_name from actor 
where first_name = 'JOE';

#2b. Find all actors whose last name contain the letters GEN:
Select actor_id, first_name, last_name from actor 
where last_name like '%GEN%';

#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
Select * from actor 
where last_name like '%LI%' 
order by last_name, first_name;

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country in ( 'Afghanistan', 'Bangladesh', 'China');

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor 
ADD COLUMN `middle_name` VARCHAR(45) NOT NULL AFTER `first_name`;

#3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
CHANGE COLUMN `middle_name` `middle_name` BLOB NOT NULL ;
#3c. Now delete the middle_name column.
ALTER TABLE actor 
DROP COLUMN `middle_name`;

#4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(last_name) from actor group by last_name
having count(last_name) >1 ;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
#Write a query to fix the record.
update actor 
set first_name = 'HARPO' 
where last_name = 'Williams' and first_name = 'Groucho';
COMMIT;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, 
# HOWEVER! (Hint: update the record using a unique identifier.)
UPDATE actor 
SET first_name =
CASE
  WHEN first_name = 'HARPO'THEN 'GROUCHO'
  ELSE 'MUCHO GROUCHO'
END
WHERE actor_id = 172;
COMMIT;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE if not exists address (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
Select s.first_name, s.last_name, a.address, a.district, a.city_id, a.postal_code 
from staff s, address a
where a.address_id = s.address_id;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as Total_Amount
from staff s, payment p
where s.staff_id = p.staff_id 
and p.payment_date between '2005-08-01' and '2005-08-31'
Group By s.first_name,s.last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) as 'Number of Actors'
from film f, actor a, film_actor fa
where f.film_id = fa.film_id
and fa.actor_id = a.actor_id
group by f.title;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select  f.title, count(i.film_id) as 'Number of Copies'
from film f, inventory i
where i.film_id = f.film_id
and f.title = 'Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
select c.first_name, c.last_name,  sum(p.amount) as 'Total Amount Paid'
from customer c, payment p
where c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by c.last_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. # As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title from film
where title like 'Q%' or title like 'K%'
and (select language_id from language where name = 'English');

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select a.first_name, a.last_name from film_actor f, actor a
where  a.actor_id = f.actor_id and
f.film_id in (Select  film_id from film
where title = 'Alone Trip') ;

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select 	cu.last_name, cu.first_name, cu.email
from 	country c, address a, city cy, customer cu
where 	cu.address_id = a.address_id and
		a.city_id = cy.city_id and
        cy.country_id = c.country_id and 
		c.country = 'Canada';
        
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select f.title, f.rating, fc.category_id
from	film f, film_category fc
where 	f.film_id = fc.film_id and 
		f.rating in ('PG', 'PG-13','G');
        
#7e. Display the most frequently rented movies in descending order.
select  f.title, count(*) as rental_count
from 	film f, inventory i, rental r
where 	f.film_id = i.film_id
and		i.inventory_id = r.inventory_id
group by f.title
order by 2 desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
select i.store_id, sum(p.amount) as 'Total Sales'
from	inventory i, payment p, rental r
where	r.rental_id = p.rental_id
and		r.inventory_id = i.inventory_id
group by i.store_id;	

#7g. Write a query to display for each store its store ID, city, and country.
select 	s.store_id, c.city, co.country 
from	store s, city c, address a, country co
where 	s.address_id = a.address_id
and		a.city_id = c.city_id
and 	c.country_id = co.country_id;

#7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: 
#category, film_category, inventory, payment, and rental.)

select  fc.category_id, sum(p.amount) as 'Gross Revenue'
from	film_category fc, inventory i, payment p, rental r
where 	fc.film_id = i.film_id 
and 	i.inventory_id = r.inventory_id
and 	r.rental_id = p.rental_id
group by fc.category_id 
order by 2 desc limit 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
USE `sakila`;
CREATE  OR REPLACE VIEW `Gross_Revenue` AS
select  fc.category_id, sum(p.amount) as 'Gross Revenue'
from	film_category fc, inventory i, payment p, rental r
where 	fc.film_id = i.film_id 
and 	i.inventory_id = r.inventory_id
and 	r.rental_id = p.rental_id
group by fc.category_id 
order by 2 desc limit 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM sakila.Gross_Revenue;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW sakila.Gross_Revenue;




